import 'package:flutter/material.dart';

import '../../../nucleo/componentes/estructura_subpantalla.dart';
import '../../../nucleo/componentes/tarjeta_app.dart';
import '../../../nucleo/tema/tema_app.dart';
import '../../../nucleo/utilidades/textos.dart';

// Agrega aquí a tu equipo
const _equipo = ['Nombre del integrante 1', 'Nombre del integrante 2'];

class PantallaAcercaDe extends StatelessWidget {
  const PantallaAcercaDe({super.key});

  Widget _bloque(IconData i, String titulo, Widget hijo) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: TarjetaApp(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(i, color: ColoresApp.primary),
            const SizedBox(width: 10),
            Text(titulo,
                style: const TextStyle(
                    fontWeight: FontWeight.w800, color: ColoresApp.navy, fontSize: 15)),
          ]),
          const SizedBox(height: 10),
          hijo,
        ],
      ),
    ),
  );

  Widget _texto(String t) =>
      Text(t, style: const TextStyle(color: ColoresApp.muted, fontSize: 13, height: 1.45));

  @override
  Widget build(BuildContext context) {
    const letras = [
      ('A', 'Activación'), ('C', 'de Clubes'), ('T', 'y Talleres'),
      ('I', 'Institucionales'), ('V', 'para la Vida'), ('A', 'Académica'),
    ];
    return EstructuraSubpantalla(
      title: context.tr('config.acerca'),
      fallback: '/perfil/configuracion',
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                gradient: ColoresApp.heroGradient,
                borderRadius: BorderRadius.circular(26),
              ),
              alignment: Alignment.center,
              child: const Text('A',
                  style: TextStyle(color: Colors.white, fontSize: 46, fontWeight: FontWeight.w800)),
            ),
          ),
          const SizedBox(height: 12),
          const Center(
            child: Text('ACTIVA',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: ColoresApp.navy)),
          ),
          const Center(
            child: Text('Versión 1.0.0', style: TextStyle(color: ColoresApp.muted, fontSize: 12)),
          ),
          const SizedBox(height: 20),
          _bloque(Icons.info_outline_rounded, '¿De qué trata?', _texto(
            'ACTIVA es una aplicación móvil que digitaliza la inscripción y el seguimiento '
            'de las actividades paraescolares y extracurriculares (talleres, clubes y deportes). '
            'Reúne a alumnos, instructores y coordinación en un solo lugar: inscripción con folio y QR, '
            'control de asistencia y horas, avisos, chats grupales, encuestas y reportes.',
          )),
          _bloque(Icons.abc_rounded, 'Qué significa ACTIVA', Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final (l, p) in letras)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(children: [
                    SizedBox(
                      width: 24,
                      child: Text(l,
                          style: const TextStyle(
                              fontWeight: FontWeight.w800, color: ColoresApp.primary, fontSize: 16)),
                    ),
                    Text(p, style: const TextStyle(fontSize: 13)),
                  ]),
                ),
            ],
          )),
          _bloque(Icons.groups_rounded, 'Qué puede hacer cada rol', _texto(
            'Alumno: explorar, inscribirse, darse de baja, ver sus horas y descargar comprobantes.\n'
            'Instructor: pasar lista, publicar avisos, chatear con su grupo y enviar solicitudes.\n'
            'Administrador: gestionar actividades e instructores, atender solicitudes y exportar reportes.',
          )),
          _bloque(Icons.code_rounded, 'Tecnología', _texto('Prototipo desarrollado con Flutter y Dart.')),
          _bloque(Icons.school_rounded, 'Equipo de desarrollo', Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [for (final n in _equipo) _texto('• $n')],
          )),
          const SizedBox(height: 4),
          const Center(
            child: Text('© 2026 ACTIVA · Proyecto integrador',
                style: TextStyle(color: Colors.black38, fontSize: 11)),
          ),
        ],
      ),
    );
  }
}