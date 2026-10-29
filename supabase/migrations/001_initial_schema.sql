-- ============================================================================
-- CITT CONNECT - MIGRACIÓN INICIAL DE BASE DE DATOS (SUPABASE / POSTGRESQL)
-- Repositorio: CITT_Connect_Backend
-- Incluye: 6 Roles Oficiales, Sedes, Escuelas Duoc UC, Perfiles, QR/NFC,
-- Proyectos Inter-Sedes ("Pedir Ayuda") y Muro Nacional (Noticias/Partners/Consejeros)
-- ============================================================================

CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- 1. TIPOS ENUMERADOS (ENUMS)

-- 6 Roles Oficiales de CITT Connect:
--   usuario_citt:      Miembro activo de cualquier carrera dentro de un CITT
--   lider_citt:        Autoridad estudiantil/técnica dentro de su sede CITT
--   consejero_carrera: Puente oficial entre el CITT y alumnos Duoc sin cuenta CITT Connect
--   personal_duoc:     Rango institucional máximo (Coordinadores CITT, Docentes, Directivos)
--   dev:               Desarrolladores y administradores técnicos de CITT Connect
--   partner:           Empresas o aliados externos que publican oportunidades/desafíos
CREATE TYPE public.citt_role_type AS ENUM (
  'usuario_citt',
  'lider_citt',
  'consejero_carrera',
  'personal_duoc',
  'dev',
  'partner'
);

CREATE TYPE public.nfc_tag_status AS ENUM (
  'active',
  'unassigned',
  'lost',
  'disabled'
);

CREATE TYPE public.view_source_type AS ENUM (
  'gallery',
  'qr_scan',
  'nfc_tap',
  'direct_link',
  'search'
);

CREATE TYPE public.project_status_type AS ENUM (
  'idea',
  'en_desarrollo',
  'prototipo',
  'finalizado'
);

CREATE TYPE public.post_category_type AS ENUM (
  'noticia_citt',
  'evento_nacional',
  'oportunidad_partner',
  'puente_consejero',
  'pedir_ayuda'
);

-- ============================================================================
-- 2. TABLAS CATÁLOGO INSTITUCIONALES (SEDES, ESCUELAS DUOC UC, TRACKS)
-- ============================================================================

CREATE TABLE public.campuses (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  slug TEXT NOT NULL UNIQUE,
  region TEXT NOT NULL,
  is_active BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE public.schools (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  slug TEXT NOT NULL UNIQUE,
  css_class TEXT NOT NULL,
  primary_hex VARCHAR(7) NOT NULL,
  secondary_hex VARCHAR(7) NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE public.tracks (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  slug TEXT NOT NULL UNIQUE,
  description TEXT,
  icon_name TEXT NOT NULL DEFAULT 'cpu',
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ============================================================================
-- 3. NÚCLEO DE IDENTIDAD (PERFILES DE LA COMUNIDAD CITT CONNECT)
-- ============================================================================

CREATE TABLE public.profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  username TEXT NOT NULL UNIQUE,
  full_name TEXT NOT NULL,
  institutional_email TEXT NOT NULL UNIQUE,
  public_email TEXT NOT NULL,
  avatar_url TEXT,
  career_title TEXT NOT NULL,                -- Título o Carrera (ej. "Ingeniería en Informática")
  current_occupation TEXT NOT NULL,          -- Ocupación actual (ej. "Investigador Robótica CITT / Full-Stack")
  specialties TEXT[] NOT NULL DEFAULT '{}',  -- Especialidades rápidas (ej. ARRAY['Ciberseguridad', 'React', 'IoT'])
  bio TEXT,
  citt_role public.citt_role_type NOT NULL DEFAULT 'usuario_citt',
  campus_id UUID REFERENCES public.campuses(id) ON DELETE SET NULL,
  school_id UUID REFERENCES public.schools(id) ON DELETE SET NULL,
  partner_organization TEXT,                 -- Nombre de empresa/entidad cuando citt_role = 'partner'
  represented_career_info TEXT,              -- Info de contacto para alumnos Duoc cuando citt_role = 'consejero_carrera'
  linkedin_url TEXT,
  github_url TEXT,
  portfolio_url TEXT,
  instagram_url TEXT,
  other_social_links JSONB NOT NULL DEFAULT '[]'::jsonb,
  phone_optional TEXT,
  is_open_to_collaborate BOOLEAN NOT NULL DEFAULT true,
  is_verified BOOLEAN NOT NULL DEFAULT false,
  is_public BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_profiles_username ON public.profiles(username);
CREATE INDEX idx_profiles_campus ON public.profiles(campus_id);
CREATE INDEX idx_profiles_school ON public.profiles(school_id);
CREATE INDEX idx_profiles_role ON public.profiles(citt_role);
CREATE INDEX idx_profiles_specialties ON public.profiles USING GIN (specialties);

-- ============================================================================
-- 4. HARDWARE NFC (PREPARADO PARA FASE 4) Y ANALÍTICAS DE QR / VISITAS
-- ============================================================================

CREATE TABLE public.nfc_tags (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tag_uid TEXT NOT NULL UNIQUE,
  profile_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
  status public.nfc_tag_status NOT NULL DEFAULT 'unassigned',
  pin_batch TEXT DEFAULT 'v1-sandwich-3d',
  last_scanned_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE public.profile_views (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  profile_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  source public.view_source_type NOT NULL DEFAULT 'gallery',
  viewer_campus_id UUID REFERENCES public.campuses(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ============================================================================
-- 5. PROYECTOS INTER-SEDES ("PEDIR AYUDA") Y FEED NACIONAL (PARTNERS / CONSEJEROS)
-- ============================================================================

CREATE TABLE public.projects (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  slug TEXT NOT NULL UNIQUE,
  summary TEXT NOT NULL,
  description TEXT,
  status public.project_status_type NOT NULL DEFAULT 'en_desarrollo',
  lead_profile_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  origin_campus_id UUID REFERENCES public.campuses(id) ON DELETE SET NULL,
  track_id UUID REFERENCES public.tracks(id) ON DELETE SET NULL,
  looking_for_collaborators BOOLEAN NOT NULL DEFAULT true,
  needed_specialties TEXT[] NOT NULL DEFAULT '{}',
  help_request_details TEXT,
  repo_url TEXT,
  demo_url TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE public.posts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  author_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  campus_id UUID REFERENCES public.campuses(id) ON DELETE SET NULL,
  category public.post_category_type NOT NULL DEFAULT 'noticia_citt',
  title TEXT NOT NULL,
  content TEXT NOT NULL,
  external_action_url TEXT,
  external_action_label TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ============================================================================
-- 6. SEED OFICIAL: ESCUELAS KIT DIGITAL DUOC UC, SEDES Y TRACKS
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
