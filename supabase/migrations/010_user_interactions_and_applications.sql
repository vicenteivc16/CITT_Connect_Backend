-- ============================================================================
-- MIGRACIÓN 010: INTERACCIÓN SOCIAL, CONEXIONES BILATERALES Y POSTULACIONES
-- CITT Connect — Ecosistema Multi-Sede Duoc UC
-- ============================================================================

-- 1. TABLA: SOLICITUDES DE CONEXIÓN BILATERALES (+CONNECT)
CREATE TABLE IF NOT EXISTS public.connection_requests (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  requester_id TEXT NOT NULL,
  receiver_id TEXT NOT NULL,
  status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'accepted', 'rejected')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(requester_id, receiver_id)
);

-- Índices de alto rendimiento para solicitudes de conexión
CREATE INDEX IF NOT EXISTS idx_conn_req_requester ON public.connection_requests(requester_id);
CREATE INDEX IF NOT EXISTS idx_conn_req_receiver ON public.connection_requests(receiver_id);
CREATE INDEX IF NOT EXISTS idx_conn_req_status ON public.connection_requests(status);
CREATE INDEX IF NOT EXISTS idx_conn_req_composite ON public.connection_requests(requester_id, receiver_id, status);

-- RLS: connection_requests
ALTER TABLE public.connection_requests ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Lectura de conexiones para participantes y usuarios verificados"
  ON public.connection_requests FOR SELECT
  USING (true);

CREATE POLICY "Usuarios autenticados pueden enviar solicitudes de conexión"
  ON public.connection_requests FOR INSERT
  WITH CHECK (
    auth.uid() IS NOT NULL AND (
      auth.uid()::text = requester_id OR
      EXISTS (
        SELECT 1 FROM public.profiles 
        WHERE id = auth.uid()::text AND (id = requester_id OR username = requester_id)
      )
    )
  );

CREATE POLICY "Destinatario o emisor pueden actualizar estado de conexión"
  ON public.connection_requests FOR UPDATE
  USING (
    auth.uid() IS NOT NULL AND (
      auth.uid()::text = receiver_id OR 
      auth.uid()::text = requester_id OR
      EXISTS (
        SELECT 1 FROM public.profiles 
        WHERE id = auth.uid()::text AND (id = receiver_id OR username = receiver_id OR id = requester_id OR username = requester_id)
      )
    )
  );

CREATE POLICY "Participantes pueden cancelar o eliminar solicitud"
  ON public.connection_requests FOR DELETE
  USING (
    auth.uid() IS NOT NULL AND (
      auth.uid()::text = requester_id OR 
      auth.uid()::text = receiver_id OR
      EXISTS (
        SELECT 1 FROM public.profiles 
        WHERE id = auth.uid()::text AND (role = 'dev')
      )
    )
  );

-- 2. TABLA: POSTULACIONES DE COLABORADORES A PROYECTOS
CREATE TABLE IF NOT EXISTS public.project_applications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  project_id TEXT NOT NULL,
  applicant_username TEXT NOT NULL,
  applicant_name TEXT NOT NULL,
  applicant_email TEXT NOT NULL,
  applicant_role TEXT NOT NULL DEFAULT 'usuario_citt',
  applicant_campus_slug TEXT NOT NULL DEFAULT 'san-joaquin',
  applicant_school_slug TEXT NOT NULL DEFAULT 'informatica',
  applied_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'accepted', 'rejected')),
  answers JSONB DEFAULT '{}'::jsonb,
  note TEXT,
  UNIQUE(project_id, applicant_username)
);

-- Índices de alto rendimiento para postulaciones
CREATE INDEX IF NOT EXISTS idx_proj_app_project ON public.project_applications(project_id);
CREATE INDEX IF NOT EXISTS idx_proj_app_applicant ON public.project_applications(applicant_username);
CREATE INDEX IF NOT EXISTS idx_proj_app_status ON public.project_applications(status);

-- RLS: project_applications
ALTER TABLE public.project_applications ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Postulaciones visibles para el postulante y líderes"
  ON public.project_applications FOR SELECT
  USING (
    auth.uid() IS NOT NULL AND (
      EXISTS (
        SELECT 1 FROM public.profiles 
        WHERE id = auth.uid()::text AND (username = applicant_username OR role IN ('dev', 'lider_citt', 'personal_duoc'))
      ) OR
      EXISTS (
        SELECT 1 FROM public.projects 
        WHERE id = project_id AND lead_username = (
          SELECT username FROM public.profiles WHERE id = auth.uid()::text
        )
      )
    )
  );

CREATE POLICY "Usuarios autenticados pueden postular a proyectos"
  ON public.project_applications FOR INSERT
  WITH CHECK (
    auth.uid() IS NOT NULL AND (
      EXISTS (
        SELECT 1 FROM public.profiles 
        WHERE id = auth.uid()::text AND username = applicant_username
      )
    )
  );

CREATE POLICY "Líder del proyecto o admin pueden actualizar estado de postulación"
  ON public.project_applications FOR UPDATE
  USING (
    auth.uid() IS NOT NULL AND (
      EXISTS (
        SELECT 1 FROM public.projects 
        WHERE id = project_id AND lead_username = (
          SELECT username FROM public.profiles WHERE id = auth.uid()::text
        )
      ) OR
      EXISTS (
        SELECT 1 FROM public.profiles 
        WHERE id = auth.uid()::text AND role = 'dev'
      )
    )
  );

-- 3. FUNCIÓN RPC ATÓMICA PARA CONTROL DE CUPOS SIN RACE CONDITIONS
CREATE OR REPLACE FUNCTION public.enroll_in_activity_atomic(
  p_activity_id TEXT,
  p_username TEXT
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_total_seats INT;
  v_enrolled TEXT[];
  v_waiting TEXT[];
  v_result JSONB;
BEGIN
  -- Bloqueo pesimista de fila (FOR UPDATE) para prevenir race conditions concurrentes
  SELECT 
    total_seats, 
    COALESCE(enrolled_usernames, ARRAY[]::TEXT[]),
    COALESCE(waiting_list_usernames, ARRAY[]::TEXT[])
  INTO 
    v_total_seats, 
    v_enrolled, 
    v_waiting
  FROM public.activities
  WHERE id = p_activity_id
  FOR UPDATE;

  IF NOT FOUND THEN
    RETURN jsonb_build_object('success', false, 'error', 'ACTIVIDAD_NO_ENCONTRADA');
  END IF;

  -- Comprobar si ya está inscrito
  IF p_username = ANY(v_enrolled) THEN
    RETURN jsonb_build_object('success', false, 'status', 'ALREADY_ENROLLED', 'message', 'Ya estás inscrito en este taller');
  END IF;

  -- Comprobar disponibilidad de cupos
  IF array_length(v_enrolled, 1) IS NULL OR array_length(v_enrolled, 1) < v_total_seats THEN
    UPDATE public.activities
    SET 
      enrolled_usernames = array_append(v_enrolled, p_username),
      updated_at = now()
    WHERE id = p_activity_id;

    RETURN jsonb_build_object(
      'success', true, 
      'status', 'ENROLLED', 
      'enrolledCount', COALESCE(array_length(v_enrolled, 1), 0) + 1,
      'totalSeats', v_total_seats,
      'isWaitingList', false
    );
  ELSE
    -- Cupos llenos: Promover o añadir a lista de espera
    IF p_username = ANY(v_waiting) THEN
      RETURN jsonb_build_object('success', false, 'status', 'ALREADY_WAITING', 'message', 'Ya estás en lista de espera');
    END IF;

    UPDATE public.activities
    SET 
      waiting_list_usernames = array_append(v_waiting, p_username),
      updated_at = now()
    WHERE id = p_activity_id;

    RETURN jsonb_build_object(
      'success', true, 
      'status', 'WAITING_LIST', 
      'waitingCount', COALESCE(array_length(v_waiting, 1), 0) + 1,
      'totalSeats', v_total_seats,
      'isWaitingList', true
    );
  END IF;
END;
$$;
