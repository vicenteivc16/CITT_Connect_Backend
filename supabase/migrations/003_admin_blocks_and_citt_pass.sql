-- ============================================================================
-- MIGRACIÓN 003: BLOQUEO DE DÍAS Y CITT PASS PARA CALENDARIO CITT
-- ============================================================================

-- 1. EXTENDER TABLA DE RESERVAS CON CITT PASS
ALTER TABLE public.reservations
ADD COLUMN IF NOT EXISTS applicant_username TEXT,
ADD COLUMN IF NOT EXISTS citt_pass_code TEXT,
ADD COLUMN IF NOT EXISTS citt_pass_url TEXT,
ADD COLUMN IF NOT EXISTS citt_pass_sent_at TIMESTAMPTZ;

-- 2. TABLA DE BLOQUEOS ADMINISTRATIVOS DE SALA (DÍAS / HORAS)
CREATE TABLE IF NOT EXISTS public.admin_blocks (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  campus TEXT NOT NULL,
  room TEXT NOT NULL,
  block_date DATE NOT NULL,
  start_time TEXT NOT NULL DEFAULT '08:30',
  end_time TEXT NOT NULL DEFAULT '21:00',
  reason TEXT NOT NULL,
  created_by TEXT NOT NULL DEFAULT 'Coordinación CITT',
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 3. ÍNDICES
CREATE INDEX IF NOT EXISTS idx_admin_blocks_date ON public.admin_blocks(block_date);
CREATE INDEX IF NOT EXISTS idx_admin_blocks_room ON public.admin_blocks(campus, room);

-- 4. RLS POLICIES
ALTER TABLE public.admin_blocks ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Lectura pública de bloqueos" ON public.admin_blocks FOR SELECT USING (true);
CREATE POLICY "Inserción de bloqueos" ON public.admin_blocks FOR INSERT WITH CHECK (true);
CREATE POLICY "Eliminación de bloqueos" ON public.admin_blocks FOR DELETE USING (true);
