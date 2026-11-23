-- ============================================================================
-- MIGRACIÓN 006: ROOM SLUG Y RUTAS DINÁMICAS DE CALENDARIOS CITT
-- ============================================================================

-- 1. AGREGAR COLUMNA room_slug SI NO EXISTE
ALTER TABLE public.campus_rooms 
ADD COLUMN IF NOT EXISTS room_slug TEXT NOT NULL DEFAULT '';

-- 2. ASIGNAR SLUGS POR DEFECTO A LAS SALAS EXISTENTES
UPDATE public.campus_rooms
SET room_slug = 'sala-312'
WHERE room_name ILIKE '%312%' AND room_slug = '';

UPDATE public.campus_rooms
SET room_slug = 'lora-hardware'
WHERE room_name ILIKE '%lora%' AND room_slug = '';

UPDATE public.campus_rooms
SET room_slug = 'fablab-maker'
WHERE room_name ILIKE '%fablab%' AND room_slug = '';

UPDATE public.campus_rooms
SET room_slug = 'lab-robotica'
WHERE room_name ILIKE '%robótica%' AND room_slug = '';

UPDATE public.campus_rooms
SET room_slug = 'cyber-ops'
WHERE room_name ILIKE '%ciberseguridad%' AND room_slug = '';

UPDATE public.campus_rooms
SET room_slug = 'cowork-prototipado'
WHERE room_name ILIKE '%co-work%' AND room_slug = '';

UPDATE public.campus_rooms
SET room_slug = 'diseno-biomecanica'
WHERE room_name ILIKE '%diseño%' AND room_slug = '';

-- Fallback para cualquier sala restante sin slug
UPDATE public.campus_rooms
SET room_slug = lower(regexp_replace(room_name, '[^a-zA-Z0-9]+', '-', 'g'))
WHERE room_slug = '' OR room_slug IS NULL;

-- 3. ÍNDICE COMPUESTO PARA BÚSQUEDAS RÁPIDAS POR SEDE + SALA
CREATE UNIQUE INDEX IF NOT EXISTS idx_campus_rooms_campus_room_slug 
ON public.campus_rooms(campus_slug, room_slug);
