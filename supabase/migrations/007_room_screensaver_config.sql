-- ============================================================================
-- MIGRACIÓN 007: CONFIGURACIÓN DINÁMICA DE SALVAPANTALLAS Y TÓTEM CITT
-- ============================================================================

-- Agregar columna screensaver_config JSONB a campus_rooms si no existe
ALTER TABLE public.campus_rooms 
ADD COLUMN IF NOT EXISTS screensaver_config JSONB DEFAULT '{}'::jsonb;

COMMENT ON COLUMN public.campus_rooms.screensaver_config IS 
'Configuración personalizada para el salvapantallas y vista dividida del tótem: subtítulo, descripción, ubicación de piso, resumen de equipamiento, banner, fotos de galería y palabras clave.';
