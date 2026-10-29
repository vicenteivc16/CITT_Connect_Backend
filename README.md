# CITT Connect — Backend (`CITT_Connect_Backend`) 🗄️

> **Infraestructura de Datos, Autenticación Institucional, Seguridad RLS y Servicios Multisede para CITT Connect (Duoc UC Chile).**

Este repositorio contiene toda la definición de arquitectura de datos, migraciones SQL de PostgreSQL (Supabase), políticas de seguridad a nivel de fila (Row Level Security), configuración de Buckets de almacenamiento y semillas de datos institucionales (Sedes, Escuelas Duoc UC con su colorimetría oficial y Tracks CITT).

---

## 📚 Índice de Documentación (`/Docs`)

1. 📐 **[01. Arquitectura Backend y Supabase](./Docs/01-arquitectura-backend-y-supabase.md)**
   * Visión general del Backend as a Service (Supabase) y servicios asociados.
   * Flujo de autenticación institucional (`@duocuc.cl` / `@profesor.duoc.cl`) y códigos de invitación por sede.
   * Estrategia **NFC-Ready** (resolución de tags `/nfc/[tag_uid]` y analíticas de escaneo).
2. 🗃️ **[02. Esquema de Base de Datos y Script SQL](./Docs/02-esquema-base-de-datos-sql.md)**
   * Diagrama Entidad-Relación (ERD) completo.
   * Script SQL ejecutable con todas las tablas, tipos `ENUM`, índices, triggers y *seed* inicial de Escuelas Duoc UC, Sedes y Tracks CITT.
3. 🔒 **[03. Seguridad RLS, Storage y Endpoints](./Docs/03-seguridad-rls-y-storage.md)**
   * Políticas Row Level Security (RLS) tabla por tabla.
   * Configuración de Buckets de Storage (`avatars`, `project-covers`, `post-media`) optimizados para `.webp`.
   * Contratos de datos para generación de `vCard (.vcf)` y resolución de Pines NFC.
4. 🗺️ **[04. Roadmap Backend](./Docs/04-roadmap-backend.md)**
   * Planificación de entregables de Backend desde la Fase 0 hasta la Fase 4 (Hardware NFC).
