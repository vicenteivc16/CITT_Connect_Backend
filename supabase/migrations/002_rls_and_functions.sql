-- ============================================================================
-- CITT CONNECT - MIGRACIÓN 002: POLÍTICAS RLS Y RESOLUCIÓN NFC / QR
-- Repositorio: CITT_Connect_Backend
-- ============================================================================

ALTER TABLE public.campuses ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.schools ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tracks ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.nfc_tags ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.profile_views ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.projects ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.posts ENABLE ROW LEVEL SECURITY;

-- 1. Lectura pública de catálogos institucionales
CREATE POLICY "Catálogos de sedes visibles para todos" ON public.campuses FOR SELECT USING (true);
CREATE POLICY "Catálogos de escuelas visibles para todos" ON public.schools FOR SELECT USING (true);
CREATE POLICY "Catálogos de tracks visibles para todos" ON public.tracks FOR SELECT USING (true);

-- 2. Políticas de Perfiles (Lectura instantánea de QR/NFC y edición por dueño)
CREATE POLICY "Perfiles públicos visibles sin login para QR y Galería"
  ON public.profiles FOR SELECT
  USING (is_public = true OR auth.uid() = id);

CREATE POLICY "Usuario crea su propio perfil"
  ON public.profiles FOR INSERT
  WITH CHECK (auth.uid() = id);

CREATE POLICY "Usuario actualiza su propio perfil"
  ON public.profiles FOR UPDATE
  USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);

-- 3. Políticas de Proyectos Inter-Sedes y Muro
CREATE POLICY "Proyectos visibles para toda la comunidad"
  ON public.projects FOR SELECT USING (true);

CREATE POLICY "Usuarios autenticados publican proyectos"
  ON public.projects FOR INSERT
  WITH CHECK (auth.uid() = lead_profile_id);

CREATE POLICY "Líder actualiza su proyecto"
  ON public.projects FOR UPDATE
  USING (auth.uid() = lead_profile_id);

CREATE POLICY "Publicaciones del muro visibles para todos"
  ON public.posts FOR SELECT USING (true);

CREATE POLICY "Usuarios autenticados crean publicaciones"
  ON public.posts FOR INSERT
  WITH CHECK (auth.uid() = author_id);

-- 4. Función RPC para resolver Tags NFC (Fase 4 Ready)
CREATE OR REPLACE FUNCTION public.resolve_nfc_tag(
  p_tag_uid TEXT,
  p_viewer_campus_id UUID DEFAULT NULL
)
RETURNS TABLE (
  username TEXT,
  full_name TEXT
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_profile_id UUID;
BEGIN
  SELECT t.profile_id INTO v_profile_id
  FROM public.nfc_tags t
  WHERE t.tag_uid = p_tag_uid
    AND t.status = 'active'
  LIMIT 1;

  IF v_profile_id IS NULL THEN
    RETURN;
  END IF;

  UPDATE public.nfc_tags
  SET last_scanned_at = now()
  WHERE tag_uid = p_tag_uid;

  INSERT INTO public.profile_views (profile_id, source, viewer_campus_id)
  VALUES (v_profile_id, 'nfc_tap', p_viewer_campus_id);

  RETURN QUERY
  SELECT p.username, p.full_name
  FROM public.profiles p
  WHERE p.id = v_profile_id AND p.is_public = true;
END;
$$;
