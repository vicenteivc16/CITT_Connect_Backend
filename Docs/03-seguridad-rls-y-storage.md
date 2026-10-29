# 03. Seguridad Row Level Security (RLS), Storage y Servicios

> **Repositorio:** `CITT_Connect_Backend`
> **Objetivo:** Proteger la integridad de los datos de cada miembro del CITT asegurando que las tarjetas públicas sean accesibles al instante por QR/NFC.

---

## 1. Políticas Row Level Security (RLS) en PostgreSQL

Todas las tablas del esquema `public` deben tener RLS habilitado (`ALTER TABLE ... ENABLE ROW LEVEL SECURITY`).

```sql
-- ============================================================================
-- HABILITAR RLS EN TODAS LAS TABLAS
-- ============================================================================
ALTER TABLE public.campuses ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.schools ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tracks ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.skills ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.profile_tracks ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.profile_skills ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.nfc_tags ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.profile_views ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.connections ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.projects ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.project_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.posts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.badges ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_badges ENABLE ROW LEVEL SECURITY;

-- ============================================================================
-- 1. LECTURA PÚBLICA DE CATÁLOGOS
-- ============================================================================
CREATE POLICY "Catálogos visibles para todos" ON public.campuses FOR SELECT USING (true);
CREATE POLICY "Escuelas visibles para todos" ON public.schools FOR SELECT USING (true);
CREATE POLICY "Tracks visibles para todos" ON public.tracks FOR SELECT USING (true);
CREATE POLICY "Skills visibles para todos" ON public.skills FOR SELECT USING (true);
CREATE POLICY "Badges visibles para todos" ON public.badges FOR SELECT USING (true);

-- ============================================================================
-- 2. POLÍTICAS DE PERFILES (PROFILES)
-- ============================================================================
-- Cualquier persona que escanee un QR o Pin NFC puede ver un perfil público
CREATE POLICY "Perfiles públicos visibles para todos"
  ON public.profiles FOR SELECT
  USING (is_public = true OR auth.uid() = id);

-- Solo el dueño puede crear y actualizar su propio perfil
CREATE POLICY "Usuario crea su propio perfil"
  ON public.profiles FOR INSERT
  WITH CHECK (auth.uid() = id);

CREATE POLICY "Usuario edita exclusivamente su propio perfil"
  ON public.profiles FOR UPDATE
  USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);

-- ============================================================================
-- 3. POLÍTICAS DE PROYECTOS Y MURO INTER-SEDES
-- ============================================================================
CREATE POLICY "Proyectos visibles para todos"
  ON public.projects FOR SELECT USING (true);

CREATE POLICY "Miembros autenticados crean proyectos"
  ON public.projects FOR INSERT
  WITH CHECK (auth.uid() = lead_profile_id);

CREATE POLICY "Líder de proyecto puede actualizarlo"
  ON public.projects FOR UPDATE
  USING (auth.uid() = lead_profile_id);

CREATE POLICY "Publicaciones del muro visibles para miembros autenticados"
  ON public.posts FOR SELECT
  USING (auth.role() = 'authenticated' OR is_national = true);

CREATE POLICY "Autor gestiona sus publicaciones"
  ON public.posts FOR ALL
  USING (auth.uid() = author_id)
  WITH CHECK (auth.uid() = author_id);
```

---

## 2. Configuración de Buckets en Supabase Storage

Se definen 3 *buckets* públicos con restricción de escritura autenticada y optimización obligatoria a formato `.webp` desde el cliente antes de subir:

| Bucket ID | Propósito | Tamaño Máximo | Formatos Permitidos | Estructura de Ruta |
| :--- | :--- | :--- | :--- | :--- |
| **`avatars`** | Fotografías de perfil de los miembros CITT | `2 MB` | `image/webp`, `image/jpeg`, `image/png` | `{user_id}/avatar.webp` |
| **`project-covers`** | Portadas y capturas de proyectos CITT | `5 MB` | `image/webp` | `{project_id}/cover.webp` |
| **`post-media`** | Afiches de eventos, hackathons y noticias | `5 MB` | `image/webp` | `{post_id}/media.webp` |

---

## 3. Función RPC para Resolución de Pines NFC (Fase 4 Ready)

Esta función permite que el endpoint `/nfc/[tag_uid]` del Frontend resuelva a qué perfil pertenece un Pin NFC impreso en 3D y registre el escaneo en un solo paso:

```sql
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

  -- Actualizar fecha de último escaneo del Pin NFC
  UPDATE public.nfc_tags
  SET last_scanned_at = now()
  WHERE tag_uid = p_tag_uid;

  -- Registrar analítica de visita por NFC
  INSERT INTO public.profile_views (profile_id, source, viewer_campus_id)
  VALUES (v_profile_id, 'nfc_tap', p_viewer_campus_id);

  RETURN QUERY
  SELECT p.username, p.full_name
  FROM public.profiles p
  WHERE p.id = v_profile_id AND p.is_public = true;
END;
$$;
```
