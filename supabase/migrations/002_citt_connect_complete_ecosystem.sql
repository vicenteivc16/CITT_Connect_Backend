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

-- Lectura pública para visualización en toda la red
CREATE POLICY "Lectura pública de sedes" ON public.campuses FOR SELECT USING (true);
CREATE POLICY "Lectura pública de escuelas" ON public.schools FOR SELECT USING (true);
CREATE POLICY "Lectura pública de perfiles" ON public.profiles FOR SELECT USING (true);
CREATE POLICY "Lectura pública de proyectos" ON public.projects FOR SELECT USING (true);
CREATE POLICY "Lectura pública de colaboradores" ON public.project_collaborators FOR SELECT USING (true);
CREATE POLICY "Lectura pública del muro" ON public.posts FOR SELECT USING (true);

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

-- ============================================================================
-- SEED DATA INICIAL
-- ============================================================================
INSERT INTO public.partner_invitations (code, company_name, created_by, expires_at) VALUES
  ('AWS-INNOVA-2026', 'Amazon Web Services (AWS)', 'carlos-vega-docente', now() + interval '1 year'),
  ('CITT-PARTNER-2026', 'Red de Empresas Aliadas CITT', 'carlos-vega-docente', now() + interval '1 year'),
  ('SANTANDER-HUB-2026', 'Banco Santander Innovación', 'carlos-vega-docente', now() + interval '1 year')
ON CONFLICT (code) DO NOTHING;
