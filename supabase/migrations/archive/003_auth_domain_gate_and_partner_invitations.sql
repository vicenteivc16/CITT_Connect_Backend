-- ============================================================================
-- CITT CONNECT - MIGRACIÓN 003: GATEKEEPER DE DOMINIOS DUOC UC, INVITACIONES
-- PARTNER Y CAMPOS DE PERFIL SOCIAL (BANNER & TRACK ACADÉMICO)
-- Repositorio: CITT_Connect_Backend
-- ============================================================================

-- 1. Ampliar tabla public.profiles con campos de Perfil Social (Combinación 1)
ALTER TABLE public.profiles
  ADD COLUMN IF NOT EXISTS banner_url TEXT DEFAULT '/assets/citt-hero-lobby.webp',
  ADD COLUMN IF NOT EXISTS academic_track TEXT,
  ADD COLUMN IF NOT EXISTS achievements TEXT[] NOT NULL DEFAULT '{}';

-- 2. Tabla de Invitaciones para Cuentas Partner (Empresas Externas)
-- Solo usuarios con rol 'dev' (@cittconnect.cl) o 'personal_duoc' (@profesor.duocuc.cl)
-- pueden emitir invitaciones a correos corporativos externos.
CREATE TABLE IF NOT EXISTS public.partner_invitations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  invited_email TEXT NOT NULL UNIQUE,
  partner_organization TEXT NOT NULL,
  invite_code TEXT NOT NULL UNIQUE,
  invited_by UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
  campus_id UUID REFERENCES public.campuses(id) ON DELETE SET NULL,
  status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'accepted', 'revoked', 'expired')),
  expires_at TIMESTAMPTZ NOT NULL DEFAULT (now() + interval '14 days'),
  accepted_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

ALTER TABLE public.partner_invitations ENABLE ROW LEVEL SECURITY;

-- Solo Admin (@cittconnect.cl -> 'dev') y Personal Duoc (@profesor.duocuc.cl -> 'personal_duoc')
-- pueden ver y crear invitaciones para empresas Partner.
CREATE POLICY "Admin y Personal Duoc gestionan invitaciones Partner"
  ON public.partner_invitations
  FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM public.profiles p
      WHERE p.id = auth.uid()
        AND p.citt_role IN ('dev', 'personal_duoc')
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.profiles p
      WHERE p.id = auth.uid()
        AND p.citt_role IN ('dev', 'personal_duoc')
    )
  );

-- 3. Función Validadora de Dominio Institucional y Asignación Automática de Rol
-- Reglas estrictas solicitadas:
--   - @duocuc.cl          -> 'usuario_citt' (Alumno / Miembro CITT)
--   - @profesor.duocuc.cl -> 'personal_duoc' (Personal Duoc / Docente)
--   - @cittconnect.cl     -> 'dev' (Admin de Plataforma / Core Dev)
--   - Correo corporativo externo -> SOLO si tiene invitación 'pending' vigente en public.partner_invitations -> 'partner'
--   - Cualquier otro correo -> DENEGADO (RAISE EXCEPTION)
CREATE OR REPLACE FUNCTION public.validate_and_assign_citt_role()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_email TEXT;
  v_domain TEXT;
  v_assigned_role public.citt_role_type;
  v_partner_org TEXT;
  v_invite_id UUID;
  v_username TEXT;
  v_full_name TEXT;
BEGIN
  v_email := lower(trim(NEW.email));
  v_domain := split_part(v_email, '@', 2);

  IF v_domain = 'duocuc.cl' THEN
    v_assigned_role := 'usuario_citt';
  ELSIF v_domain = 'profesor.duocuc.cl' THEN
    v_assigned_role := 'personal_duoc';
  ELSIF v_domain = 'cittconnect.cl' THEN
    v_assigned_role := 'dev';
  ELSE
    -- Verificar si existe una invitación Partner activa para este correo corporativo
    SELECT id, partner_organization
      INTO v_invite_id, v_partner_org
    FROM public.partner_invitations
    WHERE lower(invited_email) = v_email
      AND status = 'pending'
      AND expires_at > now()
    LIMIT 1;

    IF v_invite_id IS NULL THEN
      RAISE EXCEPTION 'Acceso denegado: Solo se permite registro con correos @duocuc.cl, @profesor.duocuc.cl, @cittconnect.cl o mediante invitación oficial Partner.';
    END IF;

    v_assigned_role := 'partner';

    UPDATE public.partner_invitations
    SET status = 'accepted',
        accepted_at = now()
    WHERE id = v_invite_id;
  END IF;

  -- Generar perfil base en public.profiles al confirmar registro
  v_full_name := COALESCE(
    NEW.raw_user_meta_data->>'full_name',
    initcap(replace(split_part(v_email, '@', 1), '.', ' '))
  );
  v_username := regexp_replace(split_part(v_email, '@', 1), '[^a-z0-9\-_]', '-', 'g')
                || '-' || substr(NEW.id::text, 1, 4);

  INSERT INTO public.profiles (
    id,
    username,
    full_name,
    institutional_email,
    public_email,
    career_title,
    current_occupation,
    citt_role,
    partner_organization,
    is_verified,
    is_public
  ) VALUES (
    NEW.id,
    v_username,
    v_full_name,
    v_email,
    v_email,
    COALESCE(NEW.raw_user_meta_data->>'career_title', 'Comunidad CITT Duoc UC'),
    COALESCE(NEW.raw_user_meta_data->>'current_occupation', 'Miembro CITT Connect'),
    v_assigned_role,
    v_partner_org,
    true,
    true
  )
  ON CONFLICT (id) DO NOTHING;

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_validate_citt_user_signup ON auth.users;
CREATE TRIGGER trg_validate_citt_user_signup
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION public.validate_and_assign_citt_role();
