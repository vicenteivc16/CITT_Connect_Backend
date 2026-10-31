-- ============================================================================
-- CITT CONNECT — MIGRACIÓN COMPLETA DE ECOSISTEMA (SUPABASE / POSTGRESQL)
-- Repositorio: CITT_Connect_Backend
-- Diseñado para: Despliegue en Supabase + Vercel (Producción)
-- Contiene: 6 Roles Oficiales, 18 Sedes, 9 Escuelas Duoc UC, Perfiles,
-- Proyectos con TRL & README, Colaboradores, Postulaciones, Muro y RLS
-- ============================================================================

CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- 1. TIPOS ENUMERADOS
DO $$ BEGIN
  CREATE TYPE public.citt_role_type AS ENUM (
    'usuario_citt',
    'lider_citt',
    'consejero_carrera',
    'personal_duoc',
    'dev',
    'partner'
  );
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE TYPE public.project_maturity_type AS ENUM (
    'ideacion',
    'prototipado',
    'pruebas_campo',
    'transferencia'
  );
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE TYPE public.project_application_mode_type AS ENUM (
    'direct',
    'form'
  );
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE TYPE public.project_status_type AS ENUM (
    'idea',
    'en_desarrollo',
    'prototipo',
    'finalizado'
  );
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE TYPE public.post_category_type AS ENUM (
    'noticia_citt',
    'evento_nacional',
    'oportunidad_partner',
    'puente_consejero',
    'pedir_ayuda'
  );
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- 2. TABLAS INSTITUCIONALES (SEDES & ESCUELAS)
CREATE TABLE IF NOT EXISTS public.campuses (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  slug TEXT NOT NULL UNIQUE,
  region TEXT NOT NULL,
  is_active BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.schools (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  slug TEXT NOT NULL UNIQUE,
  css_class TEXT NOT NULL,
  primary_hex VARCHAR(7) NOT NULL,
  secondary_hex VARCHAR(7) NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 3. PERFILES DE USUARIO
CREATE TABLE IF NOT EXISTS public.profiles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  auth_user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  username TEXT NOT NULL UNIQUE,
  full_name TEXT NOT NULL,
  email TEXT NOT NULL UNIQUE,
  career_title TEXT NOT NULL,
  current_occupation TEXT NOT NULL,
  specialties TEXT[] NOT NULL DEFAULT '{}',
  bio TEXT,
  role public.citt_role_type NOT NULL DEFAULT 'usuario_citt',
  campus_slug TEXT NOT NULL,
  school_slug TEXT NOT NULL,
  avatar_url TEXT,
  banner_url TEXT,
  academic_track TEXT,
  achievements TEXT[] DEFAULT '{}',
  partner_organization TEXT,
  represented_career_info TEXT,
  linkedin_url TEXT,
  github_url TEXT,
  portfolio_url TEXT,
  instagram_url TEXT,
  phone_optional TEXT,
  is_open_to_collaborate BOOLEAN NOT NULL DEFAULT true,
  is_verified BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 4. PROYECTOS & CONVOCATORIAS
CREATE TABLE IF NOT EXISTS public.projects (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  slug TEXT NOT NULL UNIQUE,
  title TEXT NOT NULL,
  summary TEXT NOT NULL,
  status public.project_status_type NOT NULL DEFAULT 'en_desarrollo',
  lead_username TEXT NOT NULL,
  lead_name TEXT NOT NULL,
  lead_role public.citt_role_type NOT NULL,
  origin_campus_slug TEXT NOT NULL,
  school_slug TEXT NOT NULL,
  looking_for_collaborators BOOLEAN NOT NULL DEFAULT true,
  needed_specialties TEXT[] NOT NULL DEFAULT '{}',
  help_request_details TEXT,
  repo_url TEXT,
  video_url TEXT,
  cover_image_url TEXT,
  gallery_images TEXT[] DEFAULT '{}',
  readme_content TEXT,
  maturity_stage public.project_maturity_type DEFAULT 'prototipado',
  is_featured BOOLEAN NOT NULL DEFAULT false,
  featured_reason TEXT,
  application_mode public.project_application_mode_type NOT NULL DEFAULT 'direct',
  application_questions JSONB DEFAULT '[]'::jsonb,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 5. COLABORADORES DEL PROYECTO
CREATE TABLE IF NOT EXISTS public.project_collaborators (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  project_id UUID NOT NULL REFERENCES public.projects(id) ON DELETE CASCADE,
  username TEXT NOT NULL,
  full_name TEXT NOT NULL,
  role public.citt_role_type NOT NULL,
  role_in_project TEXT NOT NULL,
  campus_slug TEXT NOT NULL,
  school_slug TEXT NOT NULL,
  avatar_url TEXT,
  organization TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 6. POSTULACIONES DE ESTUDIANTES A PROYECTOS
CREATE TABLE IF NOT EXISTS public.project_applications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  project_id UUID NOT NULL REFERENCES public.projects(id) ON DELETE CASCADE,
  applicant_username TEXT NOT NULL,
  applicant_name TEXT NOT NULL,
  applicant_email TEXT NOT NULL,
  applicant_role public.citt_role_type NOT NULL,
  applicant_campus_slug TEXT NOT NULL,
  applicant_school_slug TEXT NOT NULL,
  status TEXT NOT NULL DEFAULT 'pending',
  answers JSONB DEFAULT '{}'::jsonb,
  note TEXT,
  applied_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 7. MURO NACIONAL CITT / LA GACETA
CREATE TABLE IF NOT EXISTS public.posts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  author_username TEXT NOT NULL,
  author_name TEXT NOT NULL,
  author_role public.citt_role_type NOT NULL,
  author_occupation TEXT NOT NULL,
  campus_slug TEXT NOT NULL,
  category public.post_category_type NOT NULL DEFAULT 'noticia_citt',
  title TEXT NOT NULL,
  subtitle TEXT,
  content TEXT NOT NULL,
  image_url TEXT,
  action_label TEXT,
  action_url TEXT,
  read_time TEXT DEFAULT '2 min de lectura',
  is_lead_story BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 8. CÓDIGOS DE INVITACIÓN PARTNER
CREATE TABLE IF NOT EXISTS public.partner_invitations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  code TEXT NOT NULL UNIQUE,
  company_name TEXT NOT NULL,
  created_by TEXT NOT NULL,
  expires_at TIMESTAMPTZ NOT NULL,
  is_active BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 9. SOLICITUDES BILATERALES (+CONNECT)
CREATE TABLE IF NOT EXISTS public.connection_requests (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  requester_id TEXT NOT NULL,
  receiver_id TEXT NOT NULL,
  status TEXT NOT NULL DEFAULT 'pending', -- 'pending' | 'accepted'
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(requester_id, receiver_id)
);

-- 10. HARDWARE NFC TAGS & PINS 3D
CREATE TABLE IF NOT EXISTS public.nfc_tags (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tag_uid TEXT NOT NULL UNIQUE,
  status TEXT NOT NULL DEFAULT 'unassigned', -- 'unassigned' | 'active' | 'suspended'
  assigned_username TEXT,
  batch_label TEXT,
  last_scanned_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Índices de alto rendimiento
CREATE INDEX IF NOT EXISTS idx_nfc_tags_uid ON public.nfc_tags(tag_uid);
CREATE INDEX IF NOT EXISTS idx_conn_req_lookup ON public.connection_requests(requester_id, receiver_id);
CREATE INDEX IF NOT EXISTS idx_projects_slug ON public.projects(slug);
CREATE INDEX IF NOT EXISTS idx_profiles_username ON public.profiles(username);

-- ============================================================================
-- ROW LEVEL SECURITY (RLS) POLICIES
-- ============================================================================
ALTER TABLE public.campuses ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.schools ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.projects ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.project_collaborators ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.project_applications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.posts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.partner_invitations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.connection_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.nfc_tags ENABLE ROW LEVEL SECURITY;

-- Lectura pública para visualización en toda la red
CREATE POLICY "Lectura pública de sedes" ON public.campuses FOR SELECT USING (true);
CREATE POLICY "Lectura pública de escuelas" ON public.schools FOR SELECT USING (true);
CREATE POLICY "Lectura pública de perfiles" ON public.profiles FOR SELECT USING (true);
CREATE POLICY "Lectura pública de proyectos" ON public.projects FOR SELECT USING (true);
CREATE POLICY "Lectura pública de colaboradores" ON public.project_collaborators FOR SELECT USING (true);
CREATE POLICY "Lectura pública del muro" ON public.posts FOR SELECT USING (true);
CREATE POLICY "Lectura pública de tags nfc" ON public.nfc_tags FOR SELECT USING (true);

-- Escritura controlada por usuario
CREATE POLICY "Usuarios pueden actualizar su propio perfil" ON public.profiles
  FOR UPDATE USING (auth.uid() = auth_user_id);

CREATE POLICY "Usuarios pueden insertar proyectos" ON public.projects
  FOR INSERT WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Líder de proyecto o dev puede editar proyecto" ON public.projects
  FOR UPDATE USING (auth.role() = 'authenticated');

CREATE POLICY "Postulaciones visibles para el postulante y el líder" ON public.project_applications
  FOR SELECT USING (auth.role() = 'authenticated');

CREATE POLICY "Cualquier usuario autenticado puede postular a proyectos" ON public.project_applications
  FOR INSERT WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Usuarios autenticados pueden gestionar sus solicitudes de conexión" ON public.connection_requests
  FOR ALL USING (auth.role() = 'authenticated');

CREATE POLICY "Usuarios autenticados pueden vincular tags nfc" ON public.nfc_tags
  FOR UPDATE USING (auth.role() = 'authenticated');

-- ============================================================================
-- RPC: RESOLVER PIN NFC Y REGISTRAR ESCANEO
-- ============================================================================
CREATE OR REPLACE FUNCTION public.resolve_nfc_tag(p_tag_uid TEXT)
RETURNS TABLE (
  status TEXT,
  username TEXT,
  batch_label TEXT
) LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
  -- Actualizar última lectura
  UPDATE public.nfc_tags
  SET last_scanned_at = now()
  WHERE tag_uid = lower(trim(p_tag_uid));

  RETURN QUERY
  SELECT
    t.status,
    t.assigned_username,
    t.batch_label
  FROM public.nfc_tags t
  WHERE t.tag_uid = lower(trim(p_tag_uid))
  LIMIT 1;
END;
$$;

-- ============================================================================
-- SEED DATA INICIAL
-- ============================================================================
INSERT INTO public.schools (name, slug, css_class, primary_hex, secondary_hex) VALUES
  ('Informática y Telecomunicaciones', 'informatica', 'E-IyT-New', '#307FE2', '#8BB8E8'),
  ('Ingeniería y Recursos Naturales', 'ingenieria', 'E-Ing-New', '#43B02A', '#A1D884'),
  ('Diseño', 'diseno', 'E-Dis-New', '#C4D600', '#DBE442'),
  ('Administración y Negocios', 'administracion', 'E-AyN-New', '#AC4FC6', '#C98BDB'),
  ('Comunicación', 'comunicacion', 'E-Com-New', '#D50032', '#DF4661'),
  ('Construcción', 'construccion', 'E-Cons-New', '#E87722', '#ECA154'),
  ('Salud y Bienestar', 'salud', 'E-Sal-New', '#5BC2E7', '#99D6EA'),
  ('Gastronomía', 'gastronomia', 'E-Gas', '#FF585D', '#FF808B'),
  ('Turismo y Hospitalidad', 'turismo', 'E-Tur-New', '#00A499', '#2AD2C9')
ON CONFLICT (slug) DO NOTHING;

INSERT INTO public.campuses (name, slug, region) VALUES
  ('Sede San Andrés de Concepción', 'concepcion', 'Biobío'),
  ('Sede Antonio Varas', 'antonio-varas', 'Metropolitana'),
  ('Sede San Joaquín', 'san-joaquin', 'Metropolitana'),
  ('Sede Plaza Oeste', 'plaza-oeste', 'Metropolitana'),
  ('Sede Maipú', 'maipu', 'Metropolitana'),
  ('Sede Puente Alto', 'puente-alto', 'Metropolitana'),
  ('Sede Plaza Norte', 'plaza-norte', 'Metropolitana'),
  ('Sede Plaza Vespucio', 'plaza-vespucio', 'Metropolitana'),
  ('Sede Alameda', 'alameda', 'Metropolitana'),
  ('Sede Padre Alonso de Ovalle', 'alonso-de-ovalle', 'Metropolitana'),
  ('Sede San Bernardo', 'san-bernardo', 'Metropolitana'),
  ('Sede Melipilla', 'melipilla', 'Metropolitana'),
  ('Sede Viña del Mar', 'vina-del-mar', 'Valparaíso'),
  ('Sede Valparaíso', 'valparaiso', 'Valparaíso'),
  ('Sede Villarrica', 'villarrica', 'La Araucanía'),
  ('Sede Puerto Montt', 'puerto-montt', 'Los Lagos'),
  ('Sede Nacimiento', 'nacimiento', 'Biobío'),
  ('Sede Arauco', 'arauco', 'Biobío')
ON CONFLICT (slug) DO NOTHING;

INSERT INTO public.partner_invitations (code, company_name, created_by, expires_at) VALUES
  ('AWS-INNOVA-2026', 'Amazon Web Services (AWS)', 'carlos-vega-docente', now() + interval '1 year'),
  ('CITT-PARTNER-2026', 'Red de Empresas Aliadas CITT', 'carlos-vega-docente', now() + interval '1 year'),
  ('SANTANDER-HUB-2026', 'Banco Santander Innovación', 'carlos-vega-docente', now() + interval '1 year')
ON CONFLICT (code) DO NOTHING;

INSERT INTO public.nfc_tags (tag_uid, status, assigned_username, batch_label) VALUES
  ('citt-pin-001', 'active', 'vicente.vasquez', 'Lote 3D Maipú 2026-A'),
  ('pin-dev-01', 'active', 'vicente.vasquez', 'Lote 3D Maipú 2026-A'),
  ('citt-pin-002', 'active', 'valentina.araya', 'Lote 3D San Joaquín 2026-A'),
  ('pin-val-02', 'active', 'valentina.araya', 'Lote 3D San Joaquín 2026-A'),
  ('citt-pin-003', 'active', 'diego.retamal', 'Lote 3D Maipú 2026-A'),
  ('citt-pin-004', 'active', 'camila.navarro', 'Lote 3D Viña del Mar 2026-A'),
  ('citt-pin-005', 'active', 'matias.morales', 'Lote 3D Plaza Vespucio 2026-A'),
  ('citt-new-001', 'unassigned', NULL, 'Lote Virgen Impresión 3D CITT'),
  ('citt-new-002', 'unassigned', NULL, 'Lote Virgen Impresión 3D CITT'),
  ('citt-unassigned', 'unassigned', NULL, 'Lote Virgen Impresión 3D CITT')
ON CONFLICT (tag_uid) DO NOTHING;
