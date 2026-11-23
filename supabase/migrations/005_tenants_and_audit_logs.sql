-- ============================================================================
-- MIGRACIÓN 005: TENANTS DE SEDE, SALAS DE LABORATORIO Y BITÁCORA DE AUDITORÍA
-- ============================================================================

-- 1. SALAS Y ESPACIOS DE INNOVACIÓN POR TENANT (SEDE)
CREATE TABLE IF NOT EXISTS public.campus_rooms (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  campus_slug TEXT NOT NULL,
  room_name TEXT NOT NULL,
  capacity INT NOT NULL DEFAULT 20,
  computers_count INT NOT NULL DEFAULT 15,
  has_maker_tools BOOLEAN NOT NULL DEFAULT false,
  has_iot_equipment BOOLEAN NOT NULL DEFAULT true,
  is_active BOOLEAN NOT NULL DEFAULT true,
  totem_token TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 2. BITÁCORA DE AUDITORÍA E HISTORIAL DE ACTIVIDAD CITT
CREATE TABLE IF NOT EXISTS public.audit_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  campus_slug TEXT NOT NULL,
  actor_username TEXT NOT NULL,
  actor_name TEXT NOT NULL,
  actor_role public.citt_role_type NOT NULL DEFAULT 'dev',
  action_type TEXT NOT NULL, -- 'reserva_sala', 'citt_pass', 'bloqueo_dia', 'nuevo_usuario', 'cambio_rol', 'proyecto_creado', 'taller_creado'
  title TEXT NOT NULL,
  details JSONB DEFAULT '{}'::jsonb,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 3. ÍNDICES
CREATE INDEX IF NOT EXISTS idx_campus_rooms_campus ON public.campus_rooms(campus_slug);
CREATE INDEX IF NOT EXISTS idx_audit_logs_campus ON public.audit_logs(campus_slug);
CREATE INDEX IF NOT EXISTS idx_audit_logs_actor ON public.audit_logs(actor_username);
CREATE INDEX IF NOT EXISTS idx_audit_logs_created ON public.audit_logs(created_at DESC);

-- 4. RLS POLICIES
ALTER TABLE public.campus_rooms ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.audit_logs ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Lectura pública de salas" ON public.campus_rooms FOR SELECT USING (true);
CREATE POLICY "Inserción de salas" ON public.campus_rooms FOR INSERT WITH CHECK (true);
CREATE POLICY "Actualización de salas" ON public.campus_rooms FOR UPDATE USING (true);
CREATE POLICY "Eliminación de salas" ON public.campus_rooms FOR DELETE USING (true);

CREATE POLICY "Lectura pública de auditoría" ON public.audit_logs FOR SELECT USING (true);
CREATE POLICY "Inserción de auditoría" ON public.audit_logs FOR INSERT WITH CHECK (true);
