-- Migration 012: Allow profile updates (including LinkedIn data) for test phase
DROP POLICY IF EXISTS "profiles_update_owner_or_admin" ON public.profiles;
DROP POLICY IF EXISTS "Actualización de perfiles" ON public.profiles;

CREATE POLICY "profiles_update_allow_all"
  ON public.profiles FOR UPDATE
  USING (true)
  WITH CHECK (true);
