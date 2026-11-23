-- ==============================================================================
-- 009_performance_indexes.sql
-- CITT Connect — Índices de Optimización PostgreSQL
-- Acelera búsquedas multicriterio, filtros por sede/escuela y consultas de auditoría.
-- ==============================================================================

-- 1. Perfiles y Credencial Digital
CREATE INDEX IF NOT EXISTS idx_profiles_username_lower ON public.profiles (lower(username));
CREATE INDEX IF NOT EXISTS idx_profiles_campus_school ON public.profiles (campus_slug, school_slug);
CREATE INDEX IF NOT EXISTS idx_profiles_role_verified ON public.profiles (role, is_verified);
CREATE INDEX IF NOT EXISTS idx_profiles_collaborate ON public.profiles (is_open_to_collaborate);

-- 2. Actividades y Talleres
CREATE INDEX IF NOT EXISTS idx_activities_campus_status ON public.activities (campus_slug, status);
CREATE INDEX IF NOT EXISTS idx_activities_instructor ON public.activities (instructor_username);
CREATE INDEX IF NOT EXISTS idx_enrollments_act_user ON public.activity_enrollments (activity_id, username);

-- 3. Proyectos y Colaboración
CREATE INDEX IF NOT EXISTS idx_projects_status_collab ON public.projects (status, looking_for_collaborators);
CREATE INDEX IF NOT EXISTS idx_projects_origin_campus ON public.projects (origin_campus_slug);
CREATE INDEX IF NOT EXISTS idx_projects_created_desc ON public.projects (created_at DESC);

-- 4. Reservas de Salas y Tótems
CREATE INDEX IF NOT EXISTS idx_reservations_room_date ON public.reservations (room, reservation_date);
CREATE INDEX IF NOT EXISTS idx_reservations_campus_status ON public.reservations (campus, status);
CREATE INDEX IF NOT EXISTS idx_reservations_totem ON public.reservations (totem_token);

-- 5. Bitácora de Auditoría
CREATE INDEX IF NOT EXISTS idx_audit_logs_campus_created ON public.audit_logs (campus_slug, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_audit_logs_actor ON public.audit_logs (actor_username);
