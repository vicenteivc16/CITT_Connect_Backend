-- ============================================================================
-- MIGRACIÓN 004: TABLA DE PROYECTOS CITT CONNECT
-- ============================================================================

CREATE TABLE IF NOT EXISTS public.projects (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  slug TEXT NOT NULL UNIQUE,
  title TEXT NOT NULL,
  summary TEXT NOT NULL,
  status TEXT NOT NULL DEFAULT 'prototipo',
  lead_username TEXT NOT NULL,
  lead_name TEXT NOT NULL,
  lead_role public.citt_role_type NOT NULL DEFAULT 'usuario_citt',
  origin_campus_slug TEXT NOT NULL,
  school_slug TEXT NOT NULL,
  looking_for_collaborators BOOLEAN NOT NULL DEFAULT true,
  needed_specialties TEXT[] DEFAULT '{}',
  help_request_details TEXT,
  repo_url TEXT,
  cover_image_url TEXT,
  readme_content TEXT,
  maturity_stage TEXT NOT NULL DEFAULT 'idea',
  is_featured BOOLEAN NOT NULL DEFAULT false,
  featured_reason TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ÍNDICES
CREATE INDEX IF NOT EXISTS idx_projects_slug ON public.projects(slug);
CREATE INDEX IF NOT EXISTS idx_projects_school ON public.projects(school_slug);
CREATE INDEX IF NOT EXISTS idx_projects_campus ON public.projects(origin_campus_slug);
CREATE INDEX IF NOT EXISTS idx_projects_lead ON public.projects(lead_username);

-- RLS
ALTER TABLE public.projects ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Lectura pública de proyectos" ON public.projects FOR SELECT USING (true);
CREATE POLICY "Inserción de proyectos" ON public.projects FOR INSERT WITH CHECK (true);
CREATE POLICY "Actualización de proyectos" ON public.projects FOR UPDATE USING (true);
CREATE POLICY "Eliminación de proyectos" ON public.projects FOR DELETE USING (true);
