# ACTIVA

**Activación de Clubes y Talleres Institucionales para la Vida Académica**
Universidad Tecnológica del Norte de Guanajuato (UTNG) · Grupo GTID243

DOMINIO

<img width="1626" height="940" alt="DOMINIO_ACTIVA" src="https://github.com/user-attachments/assets/e62d1d5c-692f-4dbf-b889-724f6100988f" />

UML
<img width="2546" height="1023" alt="UML_ACTIVA" src="https://github.com/user-attachments/assets/22aacabf-11ab-4aad-8c58-e53a897624bd" />


## 1. Descripción breve

ACTIVA es una app móvil para inscribirse y dar seguimiento a las actividades paraescolares (clubes y talleres) de la universidad. Permite explorar actividades con su cupo, horario y lugar, inscribirse y descargar el comprobante en PDF, acumular y validar horas (meta de 60 horas por cuatrimestre), recibir avisos y platicar en chats grupales por actividad. El instructor pasa lista y publica avisos, y la coordinación administra actividades, instructores, alumnos, periodo escolar y reportes.

## 2. Los 3 tipos de usuario y sus dashboards

| Usuario | Qué ve en su dashboard | Cuenta de prueba |
|---|---|---|
| **Alumno** | Progreso de horas (38/60), acceso a chats grupales, actividades por categoría, actividad sugerida y avisos recientes. Menú: Inicio, Explorar, Mis actividades, Avisos, Perfil. | `mar_alumna` |
| **Instructor** | Última sesión con acceso rápido a *Pasar lista* y *Ver alumnos*, estadísticas (alumnos, asistencia, grupos), chats y sus grupos. Menú: Inicio, Grupos, Asistencia, Avisos, Perfil. | `mar_instructor` |
| **Administrador (Coordinación de Paraescolares)** | Panel con totales (estudiantes, actividades, inscripciones, cupos), accesos a Nueva actividad, Instructores y Reportes, y actividades activas con su ocupación. Menú: Panel, Actividades, Alumnos, Reportes, Perfil. | `mar_admin` |

Contraseña de las cuentas de prueba: `Activa2026!`

**Funciones por rol**
- **Alumno:** explorar y filtrar actividades, inscribirse y darse de baja, comprobante con QR y folio (descarga en PDF), Mi progreso, Mis comprobantes, favoritos, encuestas de sus clubes, chats grupales, editar perfil y configuración.
- **Instructor:** pasar lista (cada asistencia suma 2 h), historial de asistencia, avisos (informativo, cambio de horario, cancelación, recordatorio), solicitudes al administrador, chats grupales.
- **Administrador:** alta y edición de actividades, alta de instructores con contraseña temporal, listado de alumnos, reportes (PDF, Word y Excel), solicitudes de instructores, periodo escolar, validación de horas y avisos generales.

## 3. Manejo de estado elegido (y por qué)

- **Manejo de estado:** [COMPLETAR: Provider / Riverpod / Bloc / otro]
- **Por qué:** [COMPLETAR: por ejemplo, sencillez para compartir el rol, los datos y las listas entre pantallas]

## 4. Cómo ejecutar la app

```bash
git clone [COMPLETAR: URL del repositorio]
cd [COMPLETAR: carpeta del proyecto]
flutter pub get
flutter run
```

Requisitos: Flutter SDK instalado y un dispositivo físico o emulador conectado (`flutter devices` para verificar).

## 5. Demostración al docente

- Dispositivo/emulador usado: [COMPLETAR: Android/iOS · modelo/versión]
- Fecha y modalidad de la demostración: [COMPLETAR: fecha · presencial / videollamada]

## 6. Screenshots

### Splashscreen
![Splash](screenshots/01-splash.jpg)

### Autenticación
![Login](screenshots/02-login.jpg)
![Registro](screenshots/03-registro.jpg)
![Validación de contraseña](screenshots/12-validacion-contrasena.jpg)

### Dashboards
![Dashboard Administrador](screenshots/04-dashboard-admin.jpg)
![Dashboard Alumno](screenshots/05-dashboard-alumno.jpg)
![Dashboard Instructor](screenshots/06-dashboard-instructor.jpg)

### Listas
![Lista principal de actividades](screenshots/07-lista-actividades.jpg)
![Lista de alumnos](screenshots/08-lista-alumnos.jpg)
<!-- PENDIENTE: estado vacío -->
<!-- ![Estado vacío](screenshots/09-lista-vacia.jpg) -->

### Formularios
![Nueva actividad (Administrador)](screenshots/10-formulario-nueva-actividad.jpg)
![Agregar instructor (Administrador)](screenshots/11-formulario-agregar-instructor.jpg)
![Nuevo aviso (Instructor)](screenshots/13-formulario-nuevo-aviso.jpg)
![Pasar lista (Instructor)](screenshots/14-formulario-pasar-lista.jpg)
![Confirmar asistencia (Instructor)](screenshots/19-confirmar-asistencia.jpg)

### Funciones del alumno
![Detalle de actividad](screenshots/15-detalle-actividad.jpg)
![Comprobante de inscripción](screenshots/16-comprobante.jpg)
![Mi progreso](screenshots/17-progreso-alumno.jpg)

### Reportes (Administrador)
![Reportes](screenshots/18-reportes.jpg)

### Evidencia funcional
<!-- PENDIENTE: foto del equipo con la app corriendo -->
<!-- ![Foto equipo](screenshots/20-foto-equipo.jpg) -->
<!-- PENDIENTE: captura del flujo login → dashboard → lista → formulario -->
<!-- ![Navegación](screenshots/21-navegacion.jpg) -->
