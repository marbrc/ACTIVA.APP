# ACTIVA

**Activación de Clubes y Talleres Institucionales para la Vida Académica**
Universidad Tecnológica del Norte de Guanajuato (UTNG) · Grupo GTID243


LAS CAPTURAS ESTAN EN ACTIVA_README/ACTIVA_README

DOMINIO

<img width="1626" height="940" alt="DOMINIO_ACTIVA" src="https://github.com/user-attachments/assets/e62d1d5c-692f-4dbf-b889-724f6100988f" />

UML
<img width="2546" height="1023" alt="UML_ACTIVA" src="https://github.com/user-attachments/assets/22aacabf-11ab-4aad-8c58-e53a897624bd" />


 Descripción breve

ACTIVA es una app móvil para inscribirse y dar seguimiento a las actividades paraescolares (clubes y talleres) de la universidad. Permite explorar actividades con su cupo, horario y lugar, inscribirse y descargar el comprobante en PDF, acumular y validar horas (meta de 60 horas por cuatrimestre), recibir avisos y platicar en chats grupales por actividad. El instructor pasa lista y publica avisos, y la coordinación administra actividades, instructores, alumnos, periodo escolar y reportes.

Los 3 tipos de usuario y sus dashboards

| Usuario | Qué ve en su dashboard | Cuenta de prueba |
|---|---|---|
| **Alumno** | Progreso de horas (38/60), acceso a chats grupales, actividades por categoría, actividad sugerida y avisos recientes. Menú: Inicio, Explorar, Mis actividades, Avisos, Perfil. | `mar_alumna` |
| **Instructor** | Última sesión con acceso rápido a *Pasar lista* y *Ver alumnos*, estadísticas (alumnos, asistencia, grupos), chats y sus grupos. Menú: Inicio, Grupos, Asistencia, Avisos, Perfil. | `mar_instructor` |
| **Administrador (Coordinación de Paraescolares)** | Panel con totales (estudiantes, actividades, inscripciones, cupos), accesos a Nueva actividad, Instructores y Reportes, y actividades activas con su ocupación. Menú: Panel, Actividades, Alumnos, Reportes, Perfil. | `mar_admin` |

Contraseña de las cuentas de prueba: `Activa2026!`

Funciones por rol
- **Alumno:** explorar y filtrar actividades, inscribirse y darse de baja, comprobante con QR y folio (descarga en PDF), Mi progreso, Mis comprobantes, favoritos, encuestas de sus clubes, chats grupales, editar perfil y configuración.
- **Instructor:** pasar lista (cada asistencia suma 2 h), historial de asistencia, avisos (informativo, cambio de horario, cancelación, recordatorio), solicitudes al administrador, chats grupales.
- **Administrador:** alta y edición de actividades, alta de instructores con contraseña temporal, listado de alumnos, reportes (PDF, Word y Excel), solicitudes de instructores, periodo escolar, validación de horas y avisos generales.

Manejo de estado elegido (y por qué)

- **Manejo de estado:** [COMPLETAR: Provider / Riverpod / Bloc / otro]
- **Por qué:** [COMPLETAR: por ejemplo, sencillez para compartir el rol, los datos y las listas entre pantallas]




Demostración al docente

- Dispositivo/emulador usado: [COMPLETAR: Android/iOS · modelo/versión]
- Fecha y modalidad de la demostración: [COMPLETAR: fecha · presencial / videollamada]

#Screenshots

Splashscreen
![Splash]<img width="739" height="1600" alt="image" src="https://github.com/user-attachments/assets/73dd46cf-f9ee-4f7b-b246-af37a874dcec" />
<img width="739" height="1600" alt="image" src="https://github.com/user-attachments/assets/b76ff989-1520-4578-a12e-278d5bdc9a03" />

Autenticación
![Login] 
<img width="739" height="1600" alt="image" src="https://github.com/user-attachments/assets/38e08fea-af6f-41bf-ad48-83c622c94e63" />
![Registro] 
<img width="739" height="1600" alt="image" src="https://github.com/user-attachments/assets/895365d6-249d-4333-9904-254852e58424" />

![Validación de contraseña]
<img width="739" height="1600" alt="image" src="https://github.com/user-attachments/assets/7c3720c0-049a-4730-96d2-3f79a0c08478" />

Dashboards
![Dashboard Administrador]
<img width="389" height="786" alt="image" src="https://github.com/user-attachments/assets/24aecfac-e4d3-4b99-a8f6-e31b30838ca0" />

![Dashboard Alumno]
<img width="739" height="1600" alt="image" src="https://github.com/user-attachments/assets/f4523bd6-7c78-46b4-b2fc-80c114fa486e" />

![Dashboard Instructor]
<img width="739" height="1600" alt="image" src="https://github.com/user-attachments/assets/42517381-ac10-4741-8ba2-4e7f8f3c5253" />

#Listas
![Lista principal de actividades]
<img width="739" height="1600" alt="image" src="https://github.com/user-attachments/assets/d6806480-e3de-4716-84c7-9f4476cd5ee5" />
<img width="739" height="1600" alt="image" src="https://github.com/user-attachments/assets/1e761a38-c18a-436f-8417-7cbdb7e5f33b" />

Formularios
![Nueva actividad (Administrador)]
<img width="739" height="1600" alt="image" src="https://github.com/user-attachments/assets/607a82d8-132a-461a-b9e7-2a5e54382325" />
<img width="739" height="1600" alt="image" src="https://github.com/user-attachments/assets/eaa43b32-32d4-418a-8aac-43d1dd14cd8a" />

![Agregar instructor (Administrador)
<img width="739" height="1600" alt="image" src="https://github.com/user-attachments/assets/98e78e82-f19d-4869-8580-1af517a0e6ba" />
<img width="739" height="1600" alt="image" src="https://github.com/user-attachments/assets/730c148a-d256-4a13-b21d-1953373abd7c" />
<img width="739" height="1600" alt="image" src="https://github.com/user-attachments/assets/aaaa1c70-b5dc-41b8-9b5e-7c7e6d0462ee" />
<img width="739" height="1600" alt="image" src="https://github.com/user-attachments/assets/456dea93-cdde-4137-b532-f2b09984a0a3" />

![Nuevo aviso (Instructor)]
<img width="739" height="1600" alt="image" src="https://github.com/user-attachments/assets/0ae216af-336c-4202-8db1-16119f5ac3eb" />

![Pasar lista (Instructor)]
<img width="739" height="1600" alt="image" src="https://github.com/user-attachments/assets/f2033dd9-18dc-4471-837e-39d6845a461e" />

![Confirmar asistencia (Instructor)]
<img width="739" height="1600" alt="image" src="https://github.com/user-attachments/assets/068de8d3-8482-4049-840f-6b4b2de6b7d6" />


Funciones del alumno
![Detalle de actividad]
<img width="739" height="1600" alt="image" src="https://github.com/user-attachments/assets/11f3b233-906a-4649-a8e5-20a50464f8e2" />

![Comprobante de inscripción]
<img width="739" height="1600" alt="image" src="https://github.com/user-attachments/assets/23950def-a029-4fc2-8535-634257bf5f0f" />
<img width="739" height="1600" alt="image" src="https://github.com/user-attachments/assets/9210622a-8f96-43ff-9ad6-a2a8fd2ab071" />

![Mi progreso]
<img width="739" height="1600" alt="image" src="https://github.com/user-attachments/assets/9ed976ba-152d-49e2-887e-38ad16527e62" />

Reportes (Administrador)
![Reportes]
<img width="739" height="1600" alt="image" src="https://github.com/user-attachments/assets/7cad5d6e-906b-41fd-a703-f9f592b49294" />

Evidencia 
link en drive (classroom)
