-- ============================================================================
-- MIGRACIÓN 001: ESQUEMA BASE DE PERFILES Y ROLES INSTITUCIONALES CITT
-- ============================================================================

-- 1. ENUM DE ROLES CITT
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'citt_role_type') THEN
    CREATE TYPE public.citt_role_type AS ENUM (
      'personal_duoc',
      'lider_citt',
      'consejero_carrera',
      'usuario_citt',
      'partner',
      'dev'
    );
  END IF;
END$$;

-- 2. TABLA DE PERFILES CITT CONNECT
CREATE TABLE IF NOT EXISTS public.profiles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  username TEXT NOT NULL UNIQUE,
  full_name TEXT NOT NULL,
  email TEXT NOT NULL UNIQUE,
  career_title TEXT NOT NULL,
  current_occupation TEXT NOT NULL,
  specialties TEXT[] DEFAULT '{}',
  bio TEXT NOT NULL DEFAULT '',
  role public.citt_role_type NOT NULL DEFAULT 'usuario_citt',
  campus_slug TEXT NOT NULL,
  school_slug TEXT NOT NULL,
  avatar_url TEXT,
  banner_url TEXT,
  academic_track TEXT,
  achievements TEXT[] DEFAULT '{}',
  partner_organization TEXT,
  represented_career_info TEXT,
  is_open_to_collaborate BOOLEAN NOT NULL DEFAULT true,
  is_verified BOOLEAN NOT NULL DEFAULT true,
  linkedin_url TEXT,
  github_url TEXT,
  portfolio_url TEXT,
  instagram_url TEXT,
  other_social_label TEXT,
  other_social_url TEXT,
  phone_optional TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 3. ÍNDICES
CREATE INDEX IF NOT EXISTS idx_profiles_username ON public.profiles(username);
CREATE INDEX IF NOT EXISTS idx_profiles_email ON public.profiles(email);
CREATE INDEX IF NOT EXISTS idx_profiles_role ON public.profiles(role);
CREATE INDEX IF NOT EXISTS idx_profiles_school ON public.profiles(school_slug);
CREATE INDEX IF NOT EXISTS idx_profiles_campus ON public.profiles(campus_slug);

-- 4. RLS POLICIES
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Lectura pública de perfiles" ON public.profiles FOR SELECT USING (true);
CREATE POLICY "Inserción de perfiles" ON public.profiles FOR INSERT WITH CHECK (true);
CREATE POLICY "Actualización de perfiles" ON public.profiles FOR UPDATE USING (true);
