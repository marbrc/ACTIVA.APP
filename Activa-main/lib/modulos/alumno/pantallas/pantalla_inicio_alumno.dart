import '../../../nucleo/componentes/avatar_activa.dart';
import '../../../modelos/enums.dart';
// ===================================================================
// Pantalla de INICIO del alumno (primera pestaña de la barra de abajo)
// ===================================================================

// Importa los widgets básicos de Flutter (Scaffold, Text, Row, etc.)
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../nucleo/tema/tema_app.dart';
import '../../../nucleo/componentes/tarjeta_app.dart';
import '../../../nucleo/componentes/aparicion_suave.dart';
import '../../../nucleo/utilidades/formateadores.dart';
import '../../../datos/estado_app.dart';
import '../../../datos/simulados/datos_simulados.dart';
import '../componentes/miniatura_taller.dart';
import '../componentes/tarjeta_taller.dart';

import '../../../nucleo/componentes/accesos_rapidos.dart';
import '../../../nucleo/utilidades/textos.dart';

// Pantalla sin estado propio, los datos vienen de EstadoApp
class PantallaInicioAlumno extends StatelessWidget {
  // Constructor constante de la pantalla
  const PantallaInicioAlumno({super.key});

  @override
  Widget build(BuildContext context) {
    // watch hace que la pantalla se redibuje si EstadoApp cambia
    final state = context.watch<EstadoApp>();
    // toma solo el primer nombre del alumno
    final nombre = state.alumno.nombre.split(' ').first;
    // saca las iniciales para el avatar
    final iniciales = inicialesDe(nombre);
    // horas paraescolares o clubs que lleva el alumno
    final horas = state.horasRealizadas;
    // horas que le faltanm clamp evita que salga negativo
    final faltan = (metaHoras - horas).clamp(0, metaHoras);
    // progreso de 0.0 a 1.0 para el círculo
    final progreso = (horas / metaHoras).clamp(0.0, 1.0).toDouble();
    // busca una actividad con cupo y donde NO esté inscrito
    final sugerido = state.talleres.firstWhere(
      (t) => t.hayCupo && !state.estaInscrito(t.id),
      // si no hay ninguna, usa la primera de la lista
      orElse: () => state.talleres.first,
    );
    // toma el aviso más reciente
    final aviso = state.avisos.first;

    // listView permite hacer scroll, padding 0 porque el encabezado va hasta los bordes
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        // ---------- ENCABEZADO AZUL ----------
        Container(
          // Fondo degradado con los colores del logo y esquinas de abajo redondas
          decoration: const BoxDecoration(
            gradient: ColoresApp.heroGradient,
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
          ),
          // SafeArea evita que el contenido quede debajo de la barra de estado
          child: SafeArea(
            // bottom: false porque abajo no hace falta separación
            bottom: false,
            child: Padding(
              // Espacio interno: izquierda, arriba, derecha, abajo
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
              child: Column(
                // Todo alineado a la izquierda
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Fila del saludo y el avatar
                  AparicionSuave(
                    child: Row(
                      children: [
                        // Expanded hace que el saludo use todo el espacio sobrante
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Saludo con el nombre
                              Text(
                                '¡Hola, $nombre!',
                                style: TextStyle(
                                  fontFamily: FuentesApp.century,
                                  color: Colors.white,
                                  fontSize: 26,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              // Frase pequeña debajo del saludo
                              Text(
                                'Descubre, participa y vive tu universidad.',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.75),
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Avatar con borde clarito
                        GestureDetector(
                        onTap: () => context.go('/alumno/perfil'),
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            AvatarActiva(rol: Rol.alumno, iniciales: iniciales, radio: 25, borde: true),
                            Positioned(
                              right: -2,
                              bottom: -2,
                              child: Container(
                                padding: const EdgeInsets.all(3),
                                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                                child: const Icon(Icons.person, size: 12, color: ColoresApp.primary),
                              ),
                            ),
                          ],
                        ),
                      ),
                      ],
                    ),
                  ),
                  // Espacio vertical entre el saludo y el progreso
                  const SizedBox(height: 22),

                  // Panel de progreso con efecto cristal
                  AparicionSuave(
                    delay: const Duration(milliseconds: 120),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        // Blanco casi transparente para que se vea el degradado
                        color: Colors.white.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.20),
                        ),
                      ),
                      child: Row(
                        children: [
                          // Círculo de progreso animado de 0 hasta el valor real
                          TweenAnimationBuilder<double>(
                            // De 0 a tu progreso
                            tween: Tween(begin: 0, end: progreso),
                            // Dura 1.2 segundos
                            duration: const Duration(milliseconds: 1200),
                            // Empieza rápido y termina suave
                            curve: Curves.easeOutCubic,
                            // v es el valor actual de la animación
                            builder: (_, v, _) => SizedBox(
                              width: 78,
                              height: 78,
                              // Stack pone el porcentaje encima del círculo
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  // SizedBox.expand hace que el círculo llene los 78x78
                                  SizedBox.expand(
                                    child: CircularProgressIndicator(
                                      value: v,
                                      strokeWidth: 7,
                                      // Parte del círculo que falta
                                      backgroundColor: Colors.white.withValues(
                                        alpha: 0.18,
                                      ),
                                      // Parte del círculo que ya llevas
                                      color: ColoresApp.sky,
                                      // Puntas redondeadas
                                      strokeCap: StrokeCap.round,
                                    ),
                                  ),
                                  // Porcentaje en el centro
                                  Text(
                                    '${(v * 100).round()}%',
                                    style: TextStyle(
                                      fontFamily: FuentesApp.century,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // Espacio entre el círculo y los textos
                          const SizedBox(width: 16),
                          // Textos del progreso
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                GestureDetector(
                                  onTap: () => context.push('/perfil/progreso'),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        context.tr('inicio.progreso'),
                                        style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 12.5),
                                      ),
                                      Icon(Icons.chevron_right_rounded, size: 16, color: Colors.white.withValues(alpha: 0.75)),
                                    ],
                                  ),
                                ),
                                // Ejemplo: "20 / 60 horas"
                                Text(
                                  '$horas / $metaHoras horas',
                                  style: TextStyle(
                                    fontFamily: FuentesApp.century,
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                // Mensaje según si ya completó las horas o no
                                Text(
                                  faltan == 0
                                      ? '¡Completaste tus horas!'
                                      : 'Te faltan $faltan horas, ¡tú puedes!',
                                  style: const TextStyle(
                                    color: ColoresApp.sky,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // ---------- CONTENIDO BLANCO DE ABAJO ----------
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AccesoChats(),
              const SizedBox(height: 26),
              // Título de categorías con botón "Ver todos"
              _EncabezadoSeccion(
                'Encuentra algo para ti',
                onSeeAll: () => context.go('/alumno/explorar'),
              ),
              const SizedBox(height: 12),
              // Fila con los 4 botones de categoría
              AparicionSuave(
                delay: const Duration(milliseconds: 200),
                child: Row(
                  // Los reparte con el mismo espacio entre ellos
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _ChipCategoria(
                      Icons.apps_rounded,
                      'Todas',
                      () => context.go('/alumno/explorar'),
                    ),
                    _ChipCategoria(
                      Icons.sports_soccer,
                      'Deportes',
                      () => context.go('/alumno/explorar'),
                    ),
                    _ChipCategoria(
                      Icons.theater_comedy,
                      'Cultura',
                      () => context.go('/alumno/explorar'),
                    ),
                    _ChipCategoria(
                      Icons.star_rounded,
                      'Otros',
                      () => context.go('/alumno/explorar'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 26),

              // Título de la actividad sugerida
              Text(
                'Actividad sugerida',
                style: TextStyle(
                  fontFamily: FuentesApp.century,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: ColoresApp.navy,
                ),
              ),
              const SizedBox(height: 12),
              // Tarjeta de la actividad sugerida
              AparicionSuave(
                delay: const Duration(milliseconds: 300),
                child: TarjetaApp(
                  // Ahora sí abre el detalle de la actividad (ya no va a Explorar)
                  onTap: () => context.push('/actividad/${sugerido.id}'),
                  child: Row(
                    children: [
                      // Cuadrito con el ícono de la categoría
                      MiniaturaTaller(sugerido, size: 64),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Nombre de la actividad
                            Text(
                              sugerido.nombre,
                              style: TextStyle(
                                fontFamily: FuentesApp.century,
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                            // Días y horario
                            Text(
                              sugerido.horarioTexto,
                              style: const TextStyle(
                                color: ColoresApp.muted,
                                fontSize: 12,
                              ),
                            ),
                            // Lugar donde se da
                            Text(
                              sugerido.lugar,
                              style: const TextStyle(
                                color: ColoresApp.muted,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 4),
                            // Lugares disponibles
                            EtiquetaCupo(sugerido),
                          ],
                        ),
                      ),
                      // Flechita de la derecha
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: ColoresApp.muted,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 26),

              // Título de avisos con "Ver todos"
              _EncabezadoSeccion(
                'Avisos recientes',
                onSeeAll: () => context.go('/alumno/avisos'),
              ),
              const SizedBox(height: 12),
              // Tarjeta del aviso más reciente
              AparicionSuave(
                delay: const Duration(milliseconds: 400),
                child: TarjetaApp(
                  onTap: () => context.go('/alumno/avisos'),
                  child: Row(
                    children: [
                      // círculo con campanita
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: ColoresApp.warning.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.notifications_rounded,
                          color: ColoresApp.warning,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Título del aviso
                            Text(
                              aviso.titulo,
                              style: TextStyle(
                                fontFamily: FuentesApp.century,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            // Mensaje, máximo 2 renglones
                            Text(
                              aviso.mensaje,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: ColoresApp.muted,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// titulo de sección con el botón "Ver todos" a la derecha
class _EncabezadoSeccion extends StatelessWidget {
  const _EncabezadoSeccion(this.title, {required this.onSeeAll});
  // text del título
  final String title;
  // que hacer al tocar "Ver todos"
  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      // el título ocupa todo el espacio que sobre
      Expanded(
        child: Text(
          title,
          style: TextStyle(
            fontFamily: FuentesApp.century,
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: ColoresApp.navy,
          ),
        ),
      ),
      // btn de texto, toma el color del tema
      TextButton(onPressed: onSeeAll, child: const Text('Ver todos ›')),
    ],
  );
}

// btn de categoría cuadro blanco con ícono y nombre abajo
class _ChipCategoria extends StatelessWidget {
  const _ChipCategoria(this.icon, this.label, this.onTap);
  // Ícono que se muestra
  final IconData icon;
  // nombre debajo del ícono
  final String label;
  // q pasa al tocarlo
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(20),
    child: Column(
      children: [
        // Cuadro blanco redondeado con sombra suave
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: ColoresApp.line),
            boxShadow: ColoresApp.softShadow,
          ),
          child: Icon(icon, color: ColoresApp.primary, size: 28),
        ),
        const SizedBox(height: 8),
        // Nombre de la categoría
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: ColoresApp.navy,
          ),
        ),
      ],
    ),
  );
}
