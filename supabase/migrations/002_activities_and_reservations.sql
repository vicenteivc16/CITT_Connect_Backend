-- ============================================================================
-- MIGRACIÓN: ACTIVIDADES CITT, GESTIÓN DE AFORO, CUPOS Y RESERVAS DE TÓTEM
-- ============================================================================

-- 1. TABLA DE ACTIVIDADES & TALLERES CITT
CREATE TABLE IF NOT EXISTS public.activities (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  slug TEXT NOT NULL UNIQUE,
  title TEXT NOT NULL,
  description TEXT NOT NULL,
  detailed_description TEXT,
  school_slug TEXT NOT NULL,
  campus_slug TEXT NOT NULL,
  room_location TEXT NOT NULL,
  modality TEXT NOT NULL DEFAULT 'presencial', -- 'presencial' | 'hibrido' | 'online'
  status TEXT NOT NULL DEFAULT 'abierto', -- 'abierto' | 'en_curso' | 'finalizado'
  instructor_name TEXT NOT NULL,
  instructor_role public.citt_role_type NOT NULL DEFAULT 'lider_citt',
  instructor_username TEXT NOT NULL,
  instructor_avatar_url TEXT,
  capacity_per_session INT NOT NULL DEFAULT 15,
  sessions_count_per_week INT NOT NULL DEFAULT 2,
  total_seats INT NOT NULL DEFAULT 30,
  days_description TEXT NOT NULL,
  session_time TEXT NOT NULL,
  frequency_per_week INT NOT NULL DEFAULT 2,
  duration_weeks INT NOT NULL DEFAULT 4,
  start_date DATE,
  end_date DATE,
  total_hours_citt INT NOT NULL DEFAULT 16,
  tags TEXT[] DEFAULT '{}',
  cover_image_url TEXT,
  study_materials JSONB DEFAULT '[]'::jsonb,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 2. TABLA DE INSCRIPCIONES A TALLERES (ENROLLMENTS)
CREATE TABLE IF NOT EXISTS public.activity_enrollments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  activity_id UUID NOT NULL REFERENCES public.activities(id) ON DELETE CASCADE,
  username TEXT NOT NULL,
  user_email TEXT NOT NULL,
  user_full_name TEXT NOT NULL,
  user_role public.citt_role_type NOT NULL DEFAULT 'usuario_citt',
  user_campus_slug TEXT NOT NULL,
  user_school_slug TEXT NOT NULL,
  status TEXT NOT NULL DEFAULT 'confirmed', -- 'confirmed' | 'waiting_list' | 'attended' | 'cancelled'
  enrolled_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(activity_id, username)
);

-- 3. TABLA DE RESERVAS DEL CALENDARIO & TÓTEMS DE SALA CITT
CREATE TABLE IF NOT EXISTS public.reservations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  room TEXT NOT NULL,
  campus TEXT NOT NULL,
  in_charge_name TEXT NOT NULL,
  in_charge_email TEXT NOT NULL,
  in_charge_role TEXT NOT NULL,
  school TEXT NOT NULL,
  reservation_date DATE NOT NULL,
  time_slot TEXT NOT NULL,
  purpose TEXT NOT NULL,
  attendees INT NOT NULL DEFAULT 1,
  requires_computers BOOLEAN NOT NULL DEFAULT false,
  status TEXT NOT NULL DEFAULT 'CONFIRMED',
  source TEXT NOT NULL DEFAULT 'TOTEM_QR',
  totem_token TEXT,
  horas_citt TEXT DEFAULT '1.0 hr',
  checked_in BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 4. ÍNDICES DE ALTO RENDIMIENTO
CREATE INDEX IF NOT EXISTS idx_activities_slug ON public.activities(slug);
CREATE INDEX IF NOT EXISTS idx_activities_school ON public.activities(school_slug);
CREATE INDEX IF NOT EXISTS idx_activities_campus ON public.activities(campus_slug);
CREATE INDEX IF NOT EXISTS idx_enrollments_lookup ON public.activity_enrollments(activity_id, username);
CREATE INDEX IF NOT EXISTS idx_reservations_date ON public.reservations(reservation_date);

-- 5. RLS POLICIES
ALTER TABLE public.activities ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.activity_enrollments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.reservations ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Lectura pública de actividades" ON public.activities FOR SELECT USING (true);
CREATE POLICY "Inserción de actividades" ON public.activities FOR INSERT WITH CHECK (true);
CREATE POLICY "Actualización de actividades" ON public.activities FOR UPDATE USING (true);

CREATE POLICY "Lectura pública de inscripciones" ON public.activity_enrollments FOR SELECT USING (true);
CREATE POLICY "Inserción de inscripciones" ON public.activity_enrollments FOR INSERT WITH CHECK (true);
CREATE POLICY "Eliminación de inscripciones" ON public.activity_enrollments FOR DELETE USING (true);

CREATE POLICY "Lectura pública de reservas" ON public.reservations FOR SELECT USING (true);
CREATE POLICY "Inserción de reservas" ON public.reservations FOR INSERT WITH CHECK (true);
CREATE POLICY "Actualización de reservas" ON public.reservations FOR UPDATE USING (true);
