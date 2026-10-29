# 04. Roadmap de Desarrollo — Backend (`CITT_Connect_Backend`)

> **Planificación de Entregables de Datos, Seguridad Institucional, Gatekeeper de Dominios y CLI de Supabase**

---

## Fase 0: Inicialización e Infraestructura Base *(Completado)*
- [x] Diseño del modelo Entidad-Relación Multisede y NFC-Ready.
- [x] Creación de scripts SQL ([`001_initial_schema.sql`](../supabase/migrations/001_initial_schema.sql)) con semillas de **9 Escuelas Oficiales Duoc UC**, **18 Sedes** y **6 Roles CITT**.
- [x] Políticas RLS y función RPC para resolución de Tags NFC ([`002_rls_and_functions.sql`](../supabase/migrations/002_rls_and_functions.sql)).
- [x] Configuración de proyecto Supabase CLI ([`supabase/config.toml`](../supabase/config.toml)).

## Fase 1: Gatekeeper de Dominios Institucionales & Invitaciones Partner *(Implementado en SQL y Frontend)*
- [x] **Migración [`003_auth_domain_gate_and_partner_invitations.sql`](../supabase/migrations/003_auth_domain_gate_and_partner_invitations.sql):**
  - Regla automática de validación de correo al registrarse en `auth.users`:
    - **`@duocuc.cl`** → Asignación automática de rol `usuario_citt` (Alumno / Miembro CITT).
    - **`@profesor.duocuc.cl`** → Asignación automática de rol `personal_duoc` (Personal Duoc / Docente).
    - **`@cittconnect.cl`** → Asignación automática de rol `dev` (Admin de Plataforma / Core Dev).
    - **Cualquier otro dominio externo** → **Denegado por defecto**, salvo que posea una invitación activa en `public.partner_invitations`.
  - **Tabla `public.partner_invitations` con RLS:**
    - Solo cuentas con rol `dev` (`@cittconnect.cl`) o `personal_duoc` (`@profesor.duocuc.cl`) pueden emitir invitaciones a correos corporativos de empresas aliadas, asignándoles el rol `partner` tras aceptar.
- [ ] Vinculación a proyecto remoto con **Supabase CLI** (`supabase link --project-ref <ref>` y `supabase db push`).
- [ ] Creación de Buckets en Supabase Storage (`avatars`, `banners`, `project-covers`, `post-media`).

## Fase 2: Sincronización en Vivo y Búsqueda Multisede
- [ ] Conexión en tiempo real de `/directorio` y vínculos `+ Connect` (`public.connections`).
- [ ] Índices de búsqueda `tsvector` por nombre, carrera, sede, escuela y especialidad.
- [ ] Registro de analíticas en `public.profile_views` (visitas desde directorio, QR o Pin NFC).

## Fase 3: Red Nacional Inter-Sedes (Proyectos, Muro e Insignias)
- [ ] CRUD persistente con políticas RLS para `public.projects` ("Pedir Ayuda" inter-sedes).
- [ ] CRUD y **Supabase Realtime** para `public.posts` (Muro Nacional y convocatorias de Partners).
- [ ] Promoción de roles (`lider_citt` y `consejero_carrera`) administrada por `personal_duoc` y `dev`.

## Fase 4: Integración de Hardware Pin NFC 3D
- [ ] Activación en producción de la función RPC `resolve_nfc_tag(p_tag_uid)`.
- [ ] Asociación en un toque del UID del Pin NFC impreso en 3D con el `profile_id` del miembro.
