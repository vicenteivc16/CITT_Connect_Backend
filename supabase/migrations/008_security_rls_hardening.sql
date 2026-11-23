-- ==============================================================================
-- 008_security_rls_hardening.sql
-- CITT Connect — Blindaje de Políticas Row Level Security (RLS)
-- Previene escalada de privilegios y mutaciones no autorizadas en tablas de negocio.
-- ==============================================================================

-- 1. PROFILES
DROP POLICY IF EXISTS "Actualización de perfiles" ON public.profiles;
DROP POLICY IF EXISTS "Inserción de perfiles" ON public.profiles;
DROP POLICY IF EXISTS "Lectura pública de perfiles" ON public.profiles;

CREATE POLICY "profiles_select_public"
  ON public.profiles FOR SELECT
  USING (true);

CREATE POLICY "profiles_insert_authenticated"
  ON public.profiles FOR INSERT
  WITH CHECK (
    auth.role() = 'authenticated' OR
    auth.uid() = id
  );

CREATE POLICY "profiles_update_owner_or_admin"
  ON public.profiles FOR UPDATE
  USING (
    auth.uid() = id OR
    EXISTS (
      SELECT 1 FROM public.profiles p
      WHERE p.id = auth.uid() AND p.role IN ('dev', 'personal_duoc')
    )
  )
  WITH CHECK (
    -- Los usuarios normales no pueden auto-asignarse rol 'dev'
    (
      role != 'dev' OR
      EXISTS (
        SELECT 1 FROM public.profiles p
        WHERE p.id = auth.uid() AND p.role = 'dev'
      )
    )
  );

-- 2. PROJECTS
DROP POLICY IF EXISTS "Lectura pública de proyectos" ON public.projects;
DROP POLICY IF EXISTS "Inserción de proyectos" ON public.projects;
DROP POLICY IF EXISTS "Actualización de proyectos" ON public.projects;
DROP POLICY IF EXISTS "Eliminación de proyectos" ON public.projects;

CREATE POLICY "projects_select_public"
  ON public.projects FOR SELECT
  USING (true);

CREATE POLICY "projects_insert_authenticated"
  ON public.projects FOR INSERT
  WITH CHECK (
    auth.role() = 'authenticated'
  );

CREATE POLICY "projects_update_lead_or_admin"
  ON public.projects FOR UPDATE
  USING (
    lead_username = (SELECT username FROM public.profiles WHERE id = auth.uid()) OR
    EXISTS (
      SELECT 1 FROM public.profiles p
      WHERE p.id = auth.uid() AND p.role IN ('dev', 'personal_duoc')
    )
  );

CREATE POLICY "projects_delete_lead_or_admin"
  ON public.projects FOR DELETE
  USING (
    lead_username = (SELECT username FROM public.profiles WHERE id = auth.uid()) OR
    EXISTS (
      SELECT 1 FROM public.profiles p
      WHERE p.id = auth.uid() AND p.role = 'dev'
    )
  );

-- 3. ACTIVITIES
DROP POLICY IF EXISTS "Lectura pública de actividades" ON public.activities;
DROP POLICY IF EXISTS "Inserción de actividades" ON public.activities;
DROP POLICY IF EXISTS "Actualización de actividades" ON public.activities;

CREATE POLICY "activities_select_public"
  ON public.activities FOR SELECT
  USING (true);

CREATE POLICY "activities_insert_authenticated"
  ON public.activities FOR INSERT
  WITH CHECK (
    auth.role() = 'authenticated'
  );

CREATE POLICY "activities_update_instructor_or_admin"
  ON public.activities FOR UPDATE
  USING (
    instructor_username = (SELECT username FROM public.profiles WHERE id = auth.uid()) OR
    EXISTS (
      SELECT 1 FROM public.profiles p
      WHERE p.id = auth.uid() AND p.role IN ('dev', 'personal_duoc')
    )
  );

-- 4. ACTIVITY ENROLLMENTS
DROP POLICY IF EXISTS "Lectura pública de inscripciones" ON public.activity_enrollments;
DROP POLICY IF EXISTS "Inserción de inscripciones" ON public.activity_enrollments;
DROP POLICY IF EXISTS "Eliminación de inscripciones" ON public.activity_enrollments;

CREATE POLICY "enrollments_select_public"
  ON public.activity_enrollments FOR SELECT
  USING (true);

CREATE POLICY "enrollments_insert_self_or_admin"
  ON public.activity_enrollments FOR INSERT
  WITH CHECK (
    username = (SELECT username FROM public.profiles WHERE id = auth.uid()) OR
    EXISTS (
      SELECT 1 FROM public.profiles p
      WHERE p.id = auth.uid() AND p.role IN ('dev', 'personal_duoc')
    )
  );

CREATE POLICY "enrollments_delete_self_or_admin"
  ON public.activity_enrollments FOR DELETE
  USING (
    username = (SELECT username FROM public.profiles WHERE id = auth.uid()) OR
    EXISTS (
      SELECT 1 FROM public.profiles p
      WHERE p.id = auth.uid() AND p.role IN ('dev', 'personal_duoc')
    )
  );

-- 5. RESERVATIONS
DROP POLICY IF EXISTS "Lectura pública de reservas" ON public.reservations;
DROP POLICY IF EXISTS "Inserción de reservas" ON public.reservations;
DROP POLICY IF EXISTS "Actualización de reservas" ON public.reservations;

CREATE POLICY "reservations_select_public"
  ON public.reservations FOR SELECT
  USING (true);

CREATE POLICY "reservations_insert_authenticated_or_totem"
  ON public.reservations FOR INSERT
  WITH CHECK (
    auth.role() = 'authenticated' OR
    totem_token IS NOT NULL
  );

CREATE POLICY "reservations_update_incharge_or_admin"
  ON public.reservations FOR UPDATE
  USING (
    in_charge_email = (SELECT email FROM public.profiles WHERE id = auth.uid()) OR
    EXISTS (
      SELECT 1 FROM public.profiles p
      WHERE p.id = auth.uid() AND p.role IN ('dev', 'personal_duoc')
    )
  );

-- 6. CAMPUS ROOMS (SALAS)
DROP POLICY IF EXISTS "Lectura pública de salas" ON public.campus_rooms;
DROP POLICY IF EXISTS "Inserción de salas" ON public.campus_rooms;
DROP POLICY IF EXISTS "Actualización de salas" ON public.campus_rooms;
DROP POLICY IF EXISTS "Eliminación de salas" ON public.campus_rooms;

CREATE POLICY "rooms_select_public"
  ON public.campus_rooms FOR SELECT
  USING (true);

CREATE POLICY "rooms_admin_all"
  ON public.campus_rooms FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM public.profiles p
      WHERE p.id = auth.uid() AND (p.role = 'dev' OR (p.role = 'personal_duoc' AND p.campus_slug = campus_rooms.campus_slug))
    )
  );

-- 7. AUDIT LOGS
DROP POLICY IF EXISTS "Lectura pública de auditoría" ON public.audit_logs;
DROP POLICY IF EXISTS "Inserción de auditoría" ON public.audit_logs;

CREATE POLICY "audit_logs_select_admin"
  ON public.audit_logs FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.profiles p
      WHERE p.id = auth.uid() AND p.role IN ('dev', 'personal_duoc')
    )
  );

CREATE POLICY "audit_logs_insert_all"
  ON public.audit_logs FOR INSERT
  WITH CHECK (true);
