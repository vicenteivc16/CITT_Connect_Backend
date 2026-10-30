# Matriz de Casos de Uso por Rol — CITT Connect (60 Casos de Uso)

> **Documento de Diseño Funcional y Arquitectura de Experiencia (UX/DX)**  
> **Versión:** 1.0.0 · Octubre 2026  
> **Propósito:** Definir exhaustivamente los 10 casos de uso prioritarios para cada uno de los 6 roles oficiales de la plataforma antes de iniciar la siguiente fase de codificación en el Roadmap de Desarrollo.

---

## Índice de Roles
1. [Rol 1: `usuario_citt` (Alumno / Miembro CITT)](#1-rol-usuario_citt-alumno--miembro-citt)
2. [Rol 2: `lider_citt` (Líder CITT / Capitán de Track)](#2-rol-lider_citt-líder-citt--capitán-de-track)
3. [Rol 3: `personal_duoc` (Personal Duoc / Docente / Coordinador)](#3-rol-personal_duoc-personal-docente--coordinador-citt)
4. [Rol 4: `consejero_carrera` (Consejero de Carrera)](#4-rol-consejero_carrera-consejero-de-carrera)
5. [Rol 5: `partner` (Partner Oficial / Empresa Aliada)](#5-rol-partner-partner-oficial--empresa-aliada)
6. [Rol 6: `dev` (Core Dev Plataforma / Administrador)](#6-rol-dev-core-dev-plataforma--administrador)
7. [Matriz de Cobertura Funcional y Próximos Pasos del Roadmap](#7-matriz-de-cobertura-funcional-y-próximos-pasos-del-roadmap)

---

## 1. Rol: `usuario_citt` (Alumno / Miembro CITT)
*Integrantes activos de la comunidad CITT en cualquiera de las 18 sedes y 9 escuelas de Duoc UC. Autenticados mediante correo institucional `@duocuc.cl`.*

```
+----------------------------------------------------------------------------------------------------+
|                                    10 CASOS DE USO: USUARIO CITT                                   |
+-------------+-------------------------------------------------------------+------------------------+
| Código      | Nombre del Caso de Uso                                      | Vista Principal        |
+-------------+-------------------------------------------------------------+------------------------+
| UC-ALU-01   | Portabilidad y Muestra del Pase QR Phygital en Eventos      | Modal / Mi Pase QR     |
| UC-ALU-02   | Descarga e Intercambio de Ficha vCard (.vcf) Móvil          | /u/[username]          |
| UC-ALU-03   | Postulación a Equipos de Proyectos Inter-Sedes              | /proyectos             |
| UC-ALU-04   | Publicación de Solicitudes de Ayuda Técnica en el Muro      | /muro                  |
| UC-ALU-05   | Personalización de Perfil Social (Banner WebP & Track)      | /mi-perfil             |
| UC-ALU-06   | Filtrado Facetado en Directorio de Alumnos y Especialidades | /directorio            |
| UC-ALU-07   | Vinculación de Contacto "+ Connect" en Agenda CITT          | /u/[username]          |
| UC-ALU-08   | Postulación a Desafíos y Pasantías de Empresas Partner      | /muro & /proyectos     |
| UC-ALU-09   | Check-in Físico en Laboratorio CITT (Tótem QR / Tag NFC)    | /nfc/[tag_uid]         |
| UC-ALU-10   | Publicación de Hito o Proyecto Personal en Portafolio       | /mi-perfil & /proyectos|
+-------------+-------------------------------------------------------------+------------------------+
```

### Detalle de Casos de Uso:

#### UC-ALU-01: Portabilidad y Muestra del Pase QR Phygital en Eventos
* **Objetivo:** Exhibir de forma instantánea la credencial con código QR de alto contraste desde el móvil para ser escaneada en ferias y summits.
* **Precondición:** El alumno inició sesión en CITT Connect desde su navegador móvil.
* **Flujo UX:**
  1. El alumno pulsa el botón amarillo destacado **"Mi Pase QR"** en la barra superior.
  2. La plataforma abre el modal phygital a pantalla completa con fondo oscurecido.
  3. El alumno puede alternar entre la cara frontal (Nombre, Carrera, Sede, Rol) y el reverso 3D con el código QR optimizado para escáneres de cámara.
  4. Permite activar el modo de alto brillo para facilitar la lectura óptica bajo luz solar.
* **Impacto en Roadmap:** Componente [`PhygitalPassCard.tsx`](file:///Users/vicentevasquez/Desktop/CITT/CITT%20Connect/CITT_Connect_Frontend/src/components/PhygitalPassCard.tsx), soporte PWA Offline.

#### UC-ALU-02: Descarga e Intercambio de Ficha vCard (`.vcf`) Móvil
* **Objetivo:** Guardar a un compañero o contacto del CITT directamente en la agenda telefónica nativa (iOS Contacts / Google Contacts) sin descargar aplicaciones de terceros.
* **Precondición:** El usuario se encuentra en la URL pública `/u/[username]` de otro miembro.
* **Flujo UX:**
  1. El usuario pulsa **"Guardar Contacto (.vcf)"**.
  2. El navegador genera dinámicamente un archivo estándar vCard 3.0 con nombre, teléfono, correo `@duocuc.cl`, rol, sede y enlace directo al perfil web.
  3. El sistema operativo del teléfono ofrece *"Añadir a Contactos"*.
* **Impacto en Roadmap:** Librería [`src/lib/vcard.ts`](file:///Users/vicentevasquez/Desktop/CITT/CITT%20Connect/CITT_Connect_Frontend/src/lib/vcard.ts) validada en iOS y Android.

#### UC-ALU-03: Postulación a Equipos de Proyectos Inter-Sedes
* **Objetivo:** Sumarse a un proyecto tecnológico liderado por otra sede de Duoc UC para aportar desde su especialidad.
* **Precondición:** Perfil activo con al menos 1 especialidad registrada.
* **Flujo UX:**
  1. El alumno navega a `/proyectos` y filtra por *"Busca Colaboradores"*.
  2. Selecciona un proyecto (ej: *"Robot Móvil con ROS 2"* de Sede Concepción).
  3. Revisa los roles requeridos y pulsa **"Postular a este Equipo"**.
  4. Redacta una breve nota de motivación y selecciona su disponibilidad horaria semanal.
  5. El Líder CITT del proyecto recibe una notificación en su panel de postulantes.
* **Impacto en Roadmap:** Tabla PostgreSQL `project_members`, RLS con status `'pending' | 'accepted'`.

#### UC-ALU-04: Publicación de Solicitudes de Ayuda Técnica en el Muro
* **Objetivo:** Pedir asistencia a la comunidad nacional cuando se enfrenta a un bloqueo técnico (ej. bug en microcontrolador ESP32 o configuración de modelo PyTorch).
* **Precondición:** Autenticado en `/muro`.
* **Flujo UX:**
  1. En `/muro`, el alumno selecciona la pestaña *"Ayuda Técnica"*.
  2. Ingresa título del problema, descripción técnica, tags (ej: `#IoT`, `#Python`) y sede.
  3. La publicación se destaca con distintivo de auxilio técnico en el feed nacional.
  4. Otros miembros responden en un hilo de comentarios con soluciones y enlaces.
* **Impacto en Roadmap:** Endpoint Supabase Realtime para notificar respuestas al autor.

#### UC-ALU-05: Personalización de Perfil Social (Banner WebP & Track)
* **Objetivo:** Configurar una presencia digital profesional y académica alineada a la Escuela a la que pertenece.
* **Precondición:** Acceso a `/mi-perfil`.
* **Flujo UX:**
  1. En `/mi-perfil`, el alumno explora el **Selector de 6 Banners Oficiales CITT** o ingresa una URL personalizada.
  2. Selecciona su Track de Formación (ej: *"Arquitectura Cloud & DevOps"*).
  3. Añade enlaces a su GitHub, LinkedIn y Portafolio.
  4. Guarda los cambios; la vista previa se actualiza inmediatamente en `/u/[username]`.
* **Impacto en Roadmap:** Sincronización con campos `banner_url`, `academic_track`, `social_links` en tabla `public.profiles`.

#### UC-ALU-06: Filtrado Facetado en Directorio de Alumnos y Especialidades
* **Objetivo:** Encontrar compañeros con habilidades complementarias (ej: buscar diseñadores UX en Sede Viña del Mar o desarrolladores móviles en Plaza Vespucio).
* **Precondición:** Navegación en `/directorio`.
* **Flujo UX:**
  1. El alumno selecciona sede en el desplegable y marca los filtros de Escuela y Especialidad.
  2. La grilla responde en tiempo real sin recargar la página.
  3. Al hacer clic en un contacto, se despliega su mini-tarjeta con estado de disponibilidad.
* **Impacto en Roadmap:** Índices GIN en PostgreSQL para búsqueda veloz sobre arreglos `specialties TEXT[]`.

#### UC-ALU-07: Vinculación de Contacto "+ Connect" en Agenda CITT
* **Objetivo:** Marcar a otros estudiantes como parte de su red personal de contactos tecnológicos dentro de Duoc UC.
* **Precondición:** Visualizar el perfil `/u/[username]` de otro estudiante.
* **Flujo UX:**
  1. Pulsa el botón **"+ Connect"**.
  2. El botón conmuta a estado verde **"Conectado en mi Red"** con micro-animación.
  3. El contador de vínculos en la barra superior se incrementa.
  4. El contacto aparece en su pestaña *"Mi Red"* en `/mi-perfil`.
* **Impacto en Roadmap:** Tabla relacional `user_connections (user_a, user_b, created_at)`.

#### UC-ALU-08: Postulación a Desafíos y Pasantías de Empresas Partner
* **Objetivo:** Resolver problemas reales planteados por empresas aliadas para obtener experiencia y validación profesional.
* **Precondición:** Perfil verificado `@duocuc.cl`.
* **Flujo UX:**
  1. En `/muro`, filtra por *"Desafíos Partner"*.
  2. Selecciona una convocatoria (ej: *"Desafío IA & Big Data Santander"*).
  3. Descarga las bases técnicas y registra su postulación (individual o en equipo CITT).
  4. Sube el enlace del repositorio del proyecto propuesto.
* **Impacto en Roadmap:** Tabla `challenge_applications` con revisión de estado por el Partner.

#### UC-ALU-09: Check-in Físico en Laboratorio CITT (Tótem QR / Tag NFC)
* **Objetivo:** Registrar asistencia física al laboratorio CITT de su sede acercando su teléfono a la entrada.
* **Precondición:** PWA instalada o lector NFC nativo activo.
* **Flujo UX:**
  1. El alumno aproxima su teléfono al pin NFC o escanea el QR fijo del laboratorio en el acceso.
  2. El sistema abre la ruta `/nfc/[tag_uid]`.
  3. Valida la sesión activa y marca el ingreso: *"Check-in exitoso en Lab CITT San Joaquín - 18:30 hrs"*.
  4. Suma horas de trabajo de laboratorio al perfil del estudiante.
* **Impacto en Roadmap:** Módulo `src/app/nfc/[tag_uid]/page.tsx` conectado a tabla `lab_checkins`.

#### UC-ALU-10: Publicación de Hito o Proyecto Personal en Portafolio
* **Objetivo:** Destacar un proyecto finalizado en su perfil público para exhibirlo a reclutadores y docentes.
* **Precondición:** Enlace a demo o repositorio listo.
* **Flujo UX:**
  1. En `/mi-perfil`, pulsa **"Añadir Proyecto al Portafolio"**.
  2. Ingresa título, resumen de 2 líneas, tecnologías utilizadas, rol desempeñado y captura de pantalla.
  3. El proyecto se exhibe en la grilla destacada de su página `/u/[username]`.
* **Impacto en Roadmap:** Subida de imagen a bucket `projects` en Supabase Storage.

---

## 2. Rol: `lider_citt` (Líder CITT / Capitán de Track)
*Estudiantes con liderazgo técnico formal en su sede (Capitanes de Robótica, IA, Desarrollo, Ciberseguridad). Su credencial combina azul circuito con toques dorados.*

```
+----------------------------------------------------------------------------------------------------+
|                                     10 CASOS DE USO: LÍDER CITT                                    |
+-------------+-------------------------------------------------------------+------------------------+
| Código      | Nombre del Caso de Uso                                      | Vista Principal        |
+-------------+-------------------------------------------------------------+------------------------+
| UC-LID-01   | Creación y Configuración de un Nuevo Proyecto de Sede       | /proyectos             |
| UC-LID-02   | Convocatoria Abierta de Reclutamiento de Talentos           | /proyectos & /muro     |
| UC-LID-03   | Aprobación y Asignación de Roles en el Equipo de Proyecto   | /proyectos/[id]/manage |
| UC-LID-04   | Publicación de Talleres, Workshops y Bootcamps de Sede      | /muro                  |
| UC-LID-05   | Registro y Préstamo de Kits de Hardware / Sensores          | /inventario (Futuro)   |
| UC-LID-06   | Otorgamiento de Reconocimientos Técnicos a Integrantes      | /u/[username]          |
| UC-LID-07   | Generación de QR Promocional para Stand en Expo CITT        | /proyectos/[id]        |
| UC-LID-08   | Coordinación Inter-Sedes para Torneos y Hackathons          | /muro & Direct Chat    |
| UC-LID-09   | Publicación de Bitácoras de Avance y Prototipos en el Feed  | /muro                  |
| UC-LID-10   | Exportación de Informe de Gestión para Coordinador CITT     | /dashboard/lider       |
+-------------+-------------------------------------------------------------+------------------------+
```

### Detalle de Casos de Uso:

#### UC-LID-01: Creación y Configuración de un Nuevo Proyecto de Sede
* **Objetivo:** Iniciar un proyecto oficial en la plataforma para documentar avances y dar visibilidad al equipo de trabajo.
* **Flujo UX:**
  1. En `/proyectos`, pulsa **"Nuevo Proyecto CITT"**.
  2. Completa el formulario estructurado: Nombre, Track temático, Sede de origen, Objetivos y Stack tecnológico.
  3. Define la visibilidad (Público inter-sedes / Borrador).
  4. El proyecto queda publicado en el catálogo nacional con badge de la sede.

#### UC-LID-02: Convocatoria Abierta de Reclutamiento de Talentos
* **Objetivo:** Abrir vacantes para incorporar perfiles de otras carreras (ej. sumar un estudiante de Diseño para UI/UX o de Administración para modelo de negocio).
* **Flujo UX:**
  1. En la ficha de su proyecto, activa la casilla *"Buscando colaboradores"*.
  2. Detalla los perfiles buscados: *"1 Diseñador Gráfico / 2 Desarrolladores Python"*.
  3. Se genera automáticamente un aviso destacado en el `/muro` nacional enlazado a la postulación.

#### UC-LID-03: Aprobación y Asignación de Roles en el Equipo de Proyecto
* **Objetivo:** Gestionar las solicitudes de estudiantes que desean unirse a su iniciativa.
* **Flujo UX:**
  1. En el panel de administración del proyecto, revisa la lista de postulantes con sus perfiles `/u/`.
  2. Evalúa sus especialidades e hitos previos.
  3. Pulsa **"Aceptar en el equipo"** y le asigna un rol interno (ej: *"Frontend Lead"*).
  4. El miembro aceptado recibe confirmación y el proyecto aparece en su credencial pública.

#### UC-LID-04: Publicación de Talleres, Workshops y Bootcamps de Sede
* **Objetivo:** Convocar a la comunidad estudiantil de su sede o de todo Duoc UC a sesiones de capacitación técnica.
* **Flujo UX:**
  1. En `/muro`, selecciona categoría *"Taller / Evento CITT"*.
  2. Define título, fecha, hora, lugar físico (ej: *"Lab CITT San Joaquín - Sala 304"*) o enlace a Teams.
  3. Habilita contador de cupos y registro con un clic para estudiantes autenticados.

#### UC-LID-05: Registro y Préstamo de Kits de Hardware / Sensores
* **Objetivo:** Controlar el uso de insumos valiosos del laboratorio (Kits Nvidia Jetson, Oculus VR, instrumental de medición).
* **Flujo UX:**
  1. El líder escanea el tag NFC adherido al hardware y el Pase QR del alumno solicitante.
  2. El sistema vincula el préstamo por un plazo determinado (ej. 7 días).
  3. Envía recordatorio automático al alumno antes de la fecha de entrega.

#### UC-LID-06: Otorgamiento de Reconocimientos Técnicos a Integrantes
* **Objetivo:** Fomentar la meritocracia y el compromiso de los miembros del equipo.
* **Flujo UX:**
  1. Visita el perfil `/u/[username]` de un integrante de su equipo.
  2. Pulsa **"Emitir Reconocimiento CITT"** (ej: *"Top Contributor Sprint 1"*, *"Maestría en Firmware"*).
  3. La insignia se visualiza de forma permanente en la sección de logros académicos del estudiante.

#### UC-LID-07: Generación de QR Promocional para Stand en Expo CITT
* **Objetivo:** Disponer de un código QR listo para imprimir en tamaño póster que dirija a los asistentes a la ficha técnica del proyecto.
* **Flujo UX:**
  1. En la página del proyecto, pulsa **"Descargar QR para Stand"**.
  2. El sistema genera un PDF vectorial de alta resolución con el logo CITT Duoc UC y el QR centralizado.

#### UC-LID-08: Coordinación Inter-Sedes para Torneos y Hackathons
* **Objetivo:** Organizar desafíos conjuntos con Líderes CITT de otras regiones de Chile.
* **Flujo UX:**
  1. Accede al canal exclusivo de líderes en `/muro` (filtrado por rol `lider_citt`).
  2. Publica la iniciativa de un torneo conjunto de ciberseguridad CTF.
  3. Acuerdan bases técnicas y coordinan las sedes participantes.

#### UC-LID-09: Publicación de Bitácoras de Avance y Prototipos en el Feed
* **Objetivo:** Mostrar evidencia del trabajo práctico a la comunidad y a directivos.
* **Flujo UX:**
  1. Sube fotos o videos cortos del prototipo físico funcionando en el laboratorio.
  2. Redacta el resumen del hito alcanzado y etiqueta a los miembros que colaboraron.

#### UC-LID-10: Exportación de Informe de Gestión para Coordinador CITT
* **Objetivo:** Consolidar métricas del track para la rendición de cuentas del semestre.
* **Flujo UX:**
  1. Pulsa **"Exportar Resumen de Track"**.
  2. Obtiene un resumen en PDF con: cantidad de proyectos, miembros activos, horas de laboratorio y convenios impactados.

---

## 3. Rol: `personal_duoc` (Personal Docente / Coordinador CITT)
*Máxima autoridad institucional de sede y carrera. Cuentan con correo `@profesor.duocuc.cl` y acento Dorado Duoc (`#FFB800`).*

```
+----------------------------------------------------------------------------------------------------+
|                                   10 CASOS DE USO: PERSONAL DUOC                                   |
+-------------+-------------------------------------------------------------+------------------------+
| Código      | Nombre del Caso de Uso                                      | Vista Principal        |
+-------------+-------------------------------------------------------------+------------------------+
| UC-DOC-01   | Emisión y Envío de Invitaciones Oficiales a Empresas Partner| /admin/invitaciones    |
| UC-DOC-02   | Patrocinio y Aval Institucional de Proyectos Tecnológicos   | /proyectos/[id]        |
| UC-DOC-03   | Promoción de Miembro a Líder CITT o Consejero de Carrera    | /roles                 |
| UC-DOC-04   | Dashboard de Analítica y Participación Inter-Sedes          | /analytics (Futuro)    |
| UC-DOC-05   | Moderación y Gobernanza Institucional del Muro Nacional     | /muro                  |
| UC-DOC-06   | Conexión Directa de Estudiantes con Oportunidades Laborales | /directorio            |
| UC-DOC-07   | Lanzamiento de Desafíos Multidisciplinarios Inter-Escuelas  | /muro & /proyectos     |
| UC-DOC-08   | Firma y Emisión de Certificados Digitales de Participación  | /certificados (Futuro) |
| UC-DOC-09   | Difusión de Directrices y Comunicados Oficiales Destacados  | /muro (Pinned Post)    |
| UC-DOC-10   | Asignación de Tags Físicos NFC a Nuevos Integrantes         | /nfc                   |
+-------------+-------------------------------------------------------------+------------------------+
```

### Detalle de Casos de Uso:

#### UC-DOC-01: Emisión y Envío de Invitaciones Oficiales a Empresas Partner
* **Objetivo:** Autorizar a una empresa aliada (ej. Banco Santander o AWS) a unirse a la plataforma con un correo corporativo no-Duoc.
* **Flujo UX:**
  1. El docente ingresa a la consola de invitaciones.
  2. Ingresa el correo corporativo del representante (`representante@empresa.com`) y nombre de la empresa.
  3. La plataforma genera un token criptográfico único (`invite_code`) registrado en `public.partner_invitations`.
  4. Envía un correo institucional formal con el enlace de canje a [`/acceso`](file:///Users/vicentevasquez/Desktop/CITT/CITT%20Connect/CITT_Connect_Frontend/src/app/acceso/page.tsx).

#### UC-DOC-02: Patrocinio y Aval Institucional de Proyectos Tecnológicos
* **Objetivo:** Otorgar el sello oficial de calidad Duoc UC a un proyecto para postularlo a fondos externos (CORFO, Explora, Brain Chile).
* **Flujo UX:**
  1. Revisa la documentación técnica del proyecto en `/proyectos/[id]`.
  2. Verifica el cumplimiento de directrices éticas y técnicas.
  3. Pulsa **"Patrocinar Proyecto Institucionalmente"**.
  4. La ficha del proyecto muestra la insignia dorada *"Patrocinado por [Nombre Docente] · Sede San Joaquín"*.

#### UC-DOC-03: Promoción de Miembro a Líder CITT o Consejero de Carrera
* **Objetivo:** Delegar autoridad técnica o de representación estudiantil a un alumno con méritos demostrados.
* **Flujo UX:**
  1. En `/roles` o en `/u/[username]`, pulsa **"Gestionar Privilegios"**.
  2. Selecciona el nuevo rol (`lider_citt` o `consejero_carrera`) y asigna el track o carrera respectiva.
  3. El sistema actualiza el registro en `auth.users` y emite una notificación al estudiante.

#### UC-DOC-04: Dashboard de Analítica y Participación Inter-Sedes
* **Objetivo:** Evaluar cuantitativamente el rendimiento del centro de innovación en su sede.
* **Flujo UX:**
  1. Visualiza indicadores clave: total de estudiantes enrolados, desglose por escuela, proyectos terminados, horas hombre de innovación y convenios con empresas.
  2. Compara el crecimiento respecto a semestres anteriores.

#### UC-DOC-05: Moderación y Gobernanza Institucional del Muro Nacional
* **Objetivo:** Mantener un entorno respetuoso, profesional y seguro dentro de la comunidad.
* **Flujo UX:**
  1. Los docentes cuentan con botón de moderación en cada publicación del muro.
  2. Pueden silenciar contenido inapropiado, enviar advertencias privadas o elevar incidentes al equipo de soporte.

#### UC-DOC-06: Conexión Directa de Estudiantes con Oportunidades Laborales
* **Objetivo:** Recomendar a un alumno con perfil sobresaliente ante una empresa partner que busca practicantes.
* **Flujo UX:**
  1. El docente busca en `/directorio` por especialidad y sede.
  2. Comparte la ficha `/u/[username]` directamente con el reclutador de la empresa mediante enlace seguro.

#### UC-DOC-07: Lanzamiento de Desafíos Multidisciplinarios Inter-Escuelas
* **Objetivo:** Integrar diferentes escuelas de Duoc UC (ej. Escuela de Salud con Escuela de Informática para telemedicina).
* **Flujo UX:**
  1. Redacta el reto con bases inter-escuelas obligatorias (equipos conformados por al menos 2 escuelas distintas).
  2. Destaca el desafío con el badge dorado institucional.

#### UC-DOC-08: Firma y Emisión de Certificados Digitales de Participación
* **Objetivo:** Otorgar constancia oficial para el currículum del estudiante con validación QR.
* **Flujo UX:**
  1. Selecciona a los integrantes de un proyecto finalizado con éxito.
  2. Firma digitalmente el certificado con sello Duoc UC.
  3. El certificado queda anexado de manera inmutable al perfil del alumno.

#### UC-DOC-09: Difusión de Directrices y Comunicados Oficiales Destacados
* **Objetivo:** Enviar información crítica a todos los miembros (ej. horarios de laboratorio, convocatorias a fondos, cierres de semestre).
* **Flujo UX:**
  1. Publica un aviso en `/muro` con la opción *"Fijar en cabecera nacional"*.
  2. Se muestra en la parte superior del feed para todos los visitantes.

#### UC-DOC-10: Asignación de Tags Físicos NFC a Nuevos Integrantes
* **Objetivo:** Entregar pines y llaveros 3D físicos con chip NFC programado.
* **Flujo UX:**
  1. El docente vincula el UID de hardware del tag NFC con la cuenta del alumno en la consola `/nfc`.
  2. El alumno puede portar su pin en la ropa y compartir su perfil con un solo tap.

---

## 4. Rol: `consejero_carrera` (Consejero de Carrera)
*El puente humano e institucional entre el CITT y los estudiantes regulares de su carrera que aún no conocen o no participan en proyectos de innovación. Su color identificador es Verde/Cyan (`#43B02A` / `#00A499`).*

```
+----------------------------------------------------------------------------------------------------+
|                                10 CASOS DE USO: CONSEJERO DE CARRERA                               |
+-------------+-------------------------------------------------------------+------------------------+
| Código      | Nombre del Caso de Uso                                      | Vista Principal        |
+-------------+-------------------------------------------------------------+------------------------+
| UC-CON-01   | Atención de Consultas de Alumnos sin Cuenta en la Red       | /u/[username]          |
| UC-CON-02   | Onboarding Asistido y Activación de Alumnos Novatos         | /acceso                |
| UC-CON-03   | Publicación de Avisos Específicos para Alumnos de su Carrera| /muro (Filtro Carrera) |
| UC-CON-04   | Detección Temprana de Talentos Académicos para el CITT      | /directorio            |
| UC-CON-05   | Sondeo de Intereses para Definir Temáticas de Workshops     | /muro (Encuestas)      |
| UC-CON-06   | Organización de Visitas Guiadas al Laboratorio CITT         | /muro                  |
| UC-CON-07   | Orientación en Convalidación de Prácticas con Proyectos CITT| /u/[username]          |
| UC-CON-08   | Curaduría de Proyectos CITT Clave para el Perfil de Egreso  | /proyectos             |
| UC-CON-09   | Enlace entre Docentes de Carrera y Equipos CITT             | /proyectos/[id]        |
| UC-CON-10   | Levantamiento de Feedback y Reporte a Dirección de Carrera  | /dashboard/consejero   |
+-------------+-------------------------------------------------------------+------------------------+
```

### Detalle de Casos de Uso:

#### UC-CON-01: Atención de Consultas de Alumnos sin Cuenta en la Red
* **Objetivo:** Servir como primer punto de contacto para estudiantes de su carrera que tienen dudas sobre qué es el CITT o cómo entrar.
* **Flujo UX:**
  1. Su perfil `/u/[username]` exhibe prominentemente el módulo *"Consejero de Carrera de [Carrera]"* con botón directo *"Enviar Consulta"*.
  2. Responde consultas académicas, requisitos de ingreso y horarios de atención.

#### UC-CON-02: Onboarding Asistido y Activación de Alumnos Novatos
* **Objetivo:** Guiar a un alumno nuevo para que cree su cuenta en `/acceso` con su correo `@duocuc.cl`.
* **Flujo UX:**
  1. Facilita el enlace de auto-registro guiado.
  2. Le muestra cómo configurar su credencial, elegir sus especialidades y generar su primer Pase QR.

#### UC-CON-03: Publicación de Avisos Específicos para Alumnos de su Carrera
* **Objetivo:** Difundir eventos relevantes para su área sin saturar al resto de la comunidad.
* **Flujo UX:**
  1. Publica en `/muro` con etiqueta de carrera (ej: `#DisenoGrafico` o `#IngenieriaInformatica`).
  2. El post se segmenta prioritariamente en el feed de los alumnos de dicha escuela.

#### UC-CON-04: Detección Temprana de Talentos Académicos para el CITT
* **Objetivo:** Invitar a alumnos con altas calificaciones o proyectos de aula sobresalientes a sumarse a iniciativas CITT.
* **Flujo UX:**
  1. Identifica al estudiante en sus actividades de carrera.
  2. Le envía una recomendación formal para postular su idea al banco de proyectos del CITT.

#### UC-CON-05: Sondeo de Intereses para Definir Temáticas de Workshops
* **Objetivo:** Consultar qué tecnologías o habilidades extracurriculares demandan sus compañeros.
* **Flujo UX:**
  1. Publica una encuesta interactiva en `/muro` (ej: *"¿Qué taller prefieren este mes: Docker, Figma avanzado o Unity?"*).
  2. Traspasa los resultados al Líder CITT para agendar el workshop.

#### UC-CON-06: Organización de Visitas Guiadas al Laboratorio CITT
* **Objetivo:** Desmitificar el laboratorio y abrirlo a las secciones de primer año.
* **Flujo UX:**
  1. Coordina una franja horaria con el Líder CITT.
  2. Publica la convocatoria de visita en el portal y coordina el grupo presencial.

#### UC-CON-07: Orientación en Convalidación de Prácticas con Proyectos CITT
* **Objetivo:** Asesorar a estudiantes sobre cómo acreditar horas de trabajo CITT en sus asignaturas de portafolio o práctica laboral.
* **Flujo UX:**
  1. Informa los requisitos de entrega y la documentación necesaria que debe emitir el Coordinador CITT.

#### UC-CON-08: Curaduría de Proyectos CITT Clave para el Perfil de Egreso
* **Objetivo:** Destacar ante los estudiantes de la carrera aquellos proyectos que fortalecen directamente las competencias exigidas por la industria en su campo laboral.

#### UC-CON-09: Enlace entre Docentes de Carrera y Equipos CITT
* **Objetivo:** Contactar a un profesor experto en una materia específica de la carrera para que actúe como mentor técnico de un proyecto CITT que lo requiere.

#### UC-CON-10: Levantamiento de Feedback y Reporte a Dirección de Carrera
* **Objetivo:** Informar al Director de Carrera sobre el impacto y recepción de las actividades del CITT en el estudiantado.

---

## 5. Rol: `partner` (Partner Oficial / Empresa Aliada)
*Empresas, instituciones gubernamentales, ONGs y aliados estratégicos del ecosistema de innovación. Se registran exclusivamente con invitación y su acento es Púrpura / Naranja (`#AC4FC6` / `#E87722`).*

```
+----------------------------------------------------------------------------------------------------+
|                                       10 CASOS DE USO: PARTNER                                     |
+-------------+-------------------------------------------------------------+------------------------+
| Código      | Nombre del Caso de Uso                                      | Vista Principal        |
+-------------+-------------------------------------------------------------+------------------------+
| UC-PAR-01   | Canje de Invitación y Configuración de Perfil Corporativo   | /acceso (Tab Canjear)  |
| UC-PAR-02   | Publicación de Desafíos de Innovación Abierta con Premios   | /muro (Tab Partners)   |
| UC-PAR-03   | Apertura de Vacantes de Prácticas y Pasantías Profesionales | /muro (Oportunidades)  |
| UC-PAR-04   | Búsqueda de Talentos Específicos en el Directorio CITT      | /directorio            |
| UC-PAR-05   | Revisión de Postulaciones Estudiantiles y Descarga de vCard | /muro/[desafio]/postul |
| UC-PAR-06   | Solicitud de Reunión de Exploración / Pitch con Equipos     | /proyectos/[id]        |
| UC-PAR-07   | Aporte de Créditos Cloud, Licencias o Hardware para Labs    | /partner/aportes       |
| UC-PAR-08   | Co-Organización de Hackathons y Datathons Nacionales        | /muro                  |
| UC-PAR-09   | Evaluación y Feedback de Soluciones Tecnológicas CITT       | /proyectos/[id]/eval   |
| UC-PAR-10   | Reporte de Retorno de Vinculación y Reclutamiento           | /partner/dashboard     |
+-------------+-------------------------------------------------------------+------------------------+
```

### Detalle de Casos de Uso:

#### UC-PAR-01: Canje de Invitación y Configuración de Perfil Corporativo
* **Objetivo:** Activar su cuenta institucional con su correo corporativo y token emitido por Duoc UC.
* **Flujo UX:**
  1. En `/acceso`, pulsa la pestaña **"Canjear Invitación"**.
  2. Ingresa el código (ej. `CITT-PARTNER-2026`) y su correo de empresa (`contacto@empresa.com`).
  3. El sistema valida la invitación y precarga los datos de la organización.
  4. Completa la configuración de su perfil de empresa: logo, sitio web y descripción de su área de I+D.

#### UC-PAR-02: Publicación de Desafíos de Innovación Abierta con Premios
* **Objetivo:** Plantear una problemática real de la industria para ser resuelta por equipos estudiantiles del CITT.
* **Flujo UX:**
  1. En `/muro`, pulsa **"Publicar Desafío de Innovación"**.
  2. Define el enunciado, los criterios de evaluación, plazo de entrega y los incentivos (premios, mentoría ejecutiva o financiamiento de prototipo).
  3. El desafío se difunde en todas las 18 sedes de Duoc UC.

#### UC-PAR-03: Apertura de Vacantes de Prácticas y Pasantías Profesionales
* **Objetivo:** Captar estudiantes y egresados capacitados en tecnologías de vanguardia para sus equipos internos.
* **Flujo UX:**
  1. Publica una oferta con perfil buscado, modalidad (remoto / presencial) y beneficios.
  2. Los estudiantes del CITT postulan con un clic compartiendo su credencial `/u/[username]`.

#### UC-PAR-04: Búsqueda de Talentos Específicos en el Directorio CITT
* **Objetivo:** Headhunting selectivo de talentos con habilidades escasas (ej: especialistas en Visión por Computadora, Seguridad Defensiva o C++ para sistemas embebidos).
* **Flujo UX:**
  1. En `/directorio`, filtra por tecnologías avanzadas y sedes.
  2. Revisa las fichas completas, portafolios de proyectos y disponibilidad de colaboración.

#### UC-PAR-05: Revisión de Postulaciones Estudiantiles y Descarga de vCard
* **Objetivo:** Evaluar a los candidatos a sus desafíos y descargar sus datos directamente a su CRM o agenda de Recursos Humanos.
* **Flujo UX:**
  1. Accede al listado de postulantes de su convocatoria.
  2. Descarga los contactos en formato vCard (.vcf) de los alumnos seleccionados para coordinar entrevistas.

#### UC-PAR-06: Solicitud de Reunión de Exploración / Pitch con Equipos
* **Objetivo:** Agendar una sesión con un equipo estudiantil que construyó un proyecto con alto potencial comercial.
* **Flujo UX:**
  1. En la ficha de un proyecto en `/proyectos`, pulsa **"Solicitar Reunión con el Equipo"**.
  2. Envía un mensaje formal que notifica tanto al Líder del proyecto como al Docente patrocinador.

#### UC-PAR-07: Aporte de Créditos Cloud, Licencias o Hardware para Labs
* **Objetivo:** Proveer herramientas a los estudiantes (ej. $10,000 USD en créditos AWS, suscripciones GitHub Enterprise o kits de robótica).
* **Flujo UX:**
  1. Registra el beneficio en la plataforma con las instrucciones de canje para los miembros CITT verificados.

#### UC-PAR-08: Co-Organización de Hackathons y Datathons Nacionales
* **Objetivo:** Impulsar una competencia tecnológica masiva con el respaldo del CITT Duoc UC.
* **Flujo UX:**
  1. Coordina el evento en conjunto con los Coordinadores CITT y genera un espacio interactivo de seguimiento en el portal.

#### UC-PAR-09: Evaluación y Feedback de Soluciones Tecnológicas CITT
* **Objetivo:** Entregar retroalimentación experta de la industria a los estudiantes sobre sus prototipos.
* **Flujo UX:**
  1. Asiste como jurado a la presentación y evalúa mediante una rúbrica en la plataforma: viabilidad comercial, calidad técnica y presentación.

#### UC-PAR-10: Reporte de Retorno de Vinculación y Reclutamiento
* **Objetivo:** Justificar la inversión de la empresa en la alianza con Duoc UC.
* **Flujo UX:**
  1. Descarga el reporte con estadísticas de postulaciones, contrataciones efectivas y soluciones tecnológicas exploradas durante el año.

---

## 6. Rol: `dev` (Core Dev Plataforma / Administrador)
*Desarrolladores, arquitectos de software e infraestructura que mantienen CITT Connect. Correo `@cittconnect.cl` y acento Azul Circuito (`#307FE2`).*

```
+----------------------------------------------------------------------------------------------------+
|                                         10 CASOS DE USO: CORE DEV                                  |
+-------------+-------------------------------------------------------------+------------------------+
| Código      | Nombre del Caso de Uso                                      | Vista Principal        |
+-------------+-------------------------------------------------------------+------------------------+
| UC-DEV-01   | Mantenimiento del Gatekeeper de Dominios Institucionales    | Backend Trigger SQL    |
| UC-DEV-02   | Auditoría de Autenticación, Tokens JWT y Prevención 401     | Logs & Telemetría      |
| UC-DEV-03   | Configuración y Auditoría de Políticas Row Level Security   | Supabase RLS           |
| UC-DEV-04   | Despliegue de Migraciones SQL Sin Caída de Servicio         | Supabase CLI           |
| UC-DEV-05   | Monitoreo de Rendimiento PWA y Edge Caching en Vercel       | Vercel Dashboard       |
| UC-DEV-06   | Generación y Revocación de Tokens de Invitación Partner     | CLI / Admin API        |
| UC-DEV-07   | Emparejamiento de Tags NFC y Lógica de Redirección Dinámica | /nfc/[tag_uid]         |
| UC-DEV-08   | Ejecución Automatizada de Auditorías Impeccable (A11y & UI) | CI/CD Detector Hook    |
| UC-DEV-09   | Respaldo Periódico y Planes de Recuperación de Desastres    | Supabase Backup Engine |
| UC-DEV-10   | Integración y Webhooks con Sistemas Centrales Duoc UC       | Edge Functions / API   |
+-------------+-------------------------------------------------------------+------------------------+
```

### Detalle de Casos de Uso:

#### UC-DEV-01: Mantenimiento del Gatekeeper de Dominios Institucionales
* **Objetivo:** Asegurar que solo usuarios con correos válidos `@duocuc.cl`, `@profesor.duocuc.cl` o `@cittconnect.cl` puedan auto-registrarse, rechazando accesos no autorizados.
* **Flujo Técnico:**
  1. Mantenimiento del trigger PostgreSQL `trg_validate_citt_user_signup` en `auth.users`.
  2. Validación paralela client-side en [`src/lib/auth.ts`](file:///Users/vicentevasquez/Desktop/CITT/CITT%20Connect/CITT_Connect_Frontend/src/lib/auth.ts) para feedback visual inmediato.

#### UC-DEV-02: Auditoría de Autenticación, Tokens JWT y Prevención 401
* **Objetivo:** Evitar desconexiones inesperadas por expiración de access tokens OAuth 2.0 y asegurar el correcto manejo del refresh token.
* **Flujo Técnico:**
  1. Monitoreo del ciclo de vida del JWT en el cliente Supabase.
  2. Implementación de interceptores de red para refresco silencioso automático de sesión antes de que el token expire.

#### UC-DEV-03: Configuración y Auditoría de Políticas Row Level Security (RLS)
* **Objetivo:** Garantizar que ningún usuario pueda modificar datos o configuraciones de otro integrante a nivel de base de datos.
* **Flujo Técnico:**
  1. Verificación periódica de directivas `FOR SELECT`, `FOR INSERT`, `FOR UPDATE` y `FOR DELETE` en tablas `profiles`, `projects`, `partner_invitations` y `comments`.

#### UC-DEV-04: Despliegue de Migraciones SQL Sin Caída de Servicio
* **Objetivo:** Aplicar cambios de esquema en PostgreSQL asegurando retrocompatibilidad total.
* **Flujo Técnico:**
  1. Prueba local de scripts SQL mediante `supabase db reset` y `supabase migration up`.
  2. Ejecución controlada contra el entorno de producción sin bloquear tablas en uso.

#### UC-DEV-05: Monitoreo de Rendimiento PWA y Edge Caching en Vercel
* **Objetivo:** Garantizar tiempos de carga inferiores a 800ms en redes móviles 4G/5G para perfiles `/u/[username]`.
* **Flujo Técnico:**
  1. Configuración de cabeceras de cache (`stale-while-revalidate`), optimización de imágenes WebP y división de código (code-splitting) en Next.js.

#### UC-DEV-06: Generación y Revocación de Tokens de Invitación Partner
* **Objetivo:** Proveer herramientas seguras a los coordinadores para emitir tokens de acceso corporativo.
* **Flujo Técnico:**
  1. Endpoint administrativo seguro protegido por RLS donde solo `dev` y `personal_duoc` pueden crear registros en `partner_invitations`.
  2. Marcado automático de estado a `'expired'` o `'revoked'`.

#### UC-DEV-07: Emparejamiento de Tags NFC y Lógica de Redirección Dinámica
* **Objetivo:** Gestionar el mapeo físico-digital entre los chips NTAG213/215 físicos y los perfiles de usuario o proyectos.
* **Flujo Técnico:**
  1. Ruta parametrizada `/nfc/[tag_uid]`.
  2. Consulta ultra-rápida indexada por `tag_uid` en base de datos.
  3. Redirección HTTP 307 instantánea hacia la URL final del miembro o tótem.

#### UC-DEV-08: Ejecución Automatizada de Auditorías Impeccable (A11y & UI)
* **Objetivo:** Mantener el estándar de excelencia visual sin degradaciones de contraste ni errores de accesibilidad.
* **Flujo Técnico:**
  1. Integración del script `.agent/skills/impeccable/scripts/impeccable detect --json` en el flujo de verificación.
  2. Cero advertencias toleradas en contraste, tipografía y diseño responsivo.

#### UC-DEV-09: Respaldo Periódico y Planes de Recuperación de Desastres
* **Objetivo:** Proteger la base de datos de usuarios, proyectos y credenciales ante fallas de infraestructura.
* **Flujo Técnico:**
  1. Políticas de snapshot automáticas point-in-time recovery (PITR) en Supabase Postgres.
  2. Verificación trimestral de restauración de respaldo en entorno de pruebas aislado.

#### UC-DEV-10: Integración y Webhooks con Sistemas Centrales Duoc UC
* **Objetivo:** Conectar CITT Connect con APIs institucionales de Duoc UC para validación de matrícula y listas de graduados.
* **Flujo Técnico:**
  1. Definición de contratos API seguros con firma HMAC.
  2. Sincronización asíncrona de sedes, carreras y estados de matrícula activa.

---

## 7. Matriz de Cobertura Funcional y Próximos Pasos del Roadmap

### Matriz de Módulos vs. Roles de Usuario

| Módulo / Vista de la Plataforma | `usuario_citt` | `lider_citt` | `personal_duoc` | `consejero_carrera` | `partner` | `dev` |
| :--- | :---: | :---: | :---: | :---: | :---: | :---: |
| **Inicio & Hero Interactivo (`/`)** | Lectura / QR | Destacado | Patrocinio | Difusión | Vitrina | Gobernanza |
| **Directorio de Miembros (`/directorio`)** | Exploración | Reclutamiento | Selección | Detección | Headhunting | Auditoría |
| **Banco de Proyectos (`/proyectos`)** | Postulante | Creador/Lead | Patrocinador | Curaduría | Evaluador | Modelado SQL |
| **Muro de Noticias y Desafíos (`/muro`)** | Interacción | Convocatorias | Moderación | Segmentación | Publicador | Realtime |
| **Pase Digital Phygital (`/u/[username]`)** | Perfil Propio | Badges Track | Aval Oficial | Ficha Guía | Evaluación | Optimización |
| **Editor de Credencial (`/mi-perfil`)** | Personalización | Gestión Track | Supervisión | Guía Alumno | Perfil Empresa | Campos Schema |
| **Portal de Acceso (`/acceso`)** | Auto-registro | Auto-registro | Auto-registro | Guía Alumno | Canje Token | Gatekeeper |
| **Ecosistema NFC (`/nfc/[tag_uid]`)** | Portador Pin | Hardware Kit | Asignación | Tótem Guía | Stand Partner | Programación |

---

### Conclusiones de Diseño para Refinar el Roadmap:
1. **Fase Inmediata (Sprint Autenticación & Conexiones):**
   * El Portal de Acceso ya implementado cubre con éxito la puerta de entrada para los 6 roles.
   * La prioridad siguiente en el backend es la activación de la tabla `user_connections` para dar vida al botón interactivo `+ Connect` en los perfiles.
2. **Fase Proyectos & Convocatorias:**
   * La relación entre `lider_citt` (creación de proyectos) y `usuario_citt` (postulación a vacantes) requerirá un flujo de estados claros (`pending`, `accepted`, `rejected`) en `/proyectos`.
3. **Fase Empresas Partner:**
   * La emisión de invitaciones por parte de `personal_duoc` y su canje en `/acceso` ya cuenta con base SQL y UI inicial; el siguiente paso es la consola de gestión de postulaciones para partners.
