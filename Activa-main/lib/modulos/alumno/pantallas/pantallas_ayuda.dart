// ===================================================================
// Pantallas nuevas del alumno: Favoritos, Idioma, Aviso de privacidad
// y Ayuda y soporte
// ===================================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../datos/estado_app.dart';
import '../../../nucleo/componentes/aparicion_suave.dart';
import '../../../nucleo/componentes/boton_activa.dart';
import '../../../nucleo/componentes/estructura_subpantalla.dart';
import '../../../nucleo/componentes/tarjeta_app.dart';
import '../../../nucleo/tema/tema_app.dart';
import '../componentes/tarjeta_taller.dart';

import '../../../datos/sesion.dart';
import '../../../nucleo/componentes/avisos.dart';
import '../../../nucleo/utilidades/textos.dart';

// ───────────────────── Favoritos ─────────────────────
class PantallaFavoritos extends StatelessWidget {
  const PantallaFavoritos({super.key});

  @override
  Widget build(BuildContext context) {
    final estado = context.watch<EstadoApp>();
    final lista = estado.talleres
        .where((t) => estado.esFavorito(t.id))
        .toList();

    return EstructuraSubpantalla(
      title: 'Mis favoritos',
      fallback: '/alumno/perfil',
      child: lista.isEmpty
          ? Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 96,
                    height: 96,
                    decoration: const BoxDecoration(
                      color: ColoresApp.mist,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.favorite_border_rounded,
                      size: 44,
                      color: ColoresApp.primary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Aún no tienes favoritos',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: ColoresApp.navy,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Toca el corazón en cualquier actividad para guardarla aquí.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: ColoresApp.muted, fontSize: 13),
                  ),
                  const SizedBox(height: 24),
                  BotonActiva(
                    etiqueta: 'Explorar actividades',
                    icono: Icons.arrow_forward_rounded,
                    alPresionar: () => context.go('/alumno/explorar'),
                  ),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: lista.length,
              separatorBuilder: (_, _) => const SizedBox(height: 14),
              itemBuilder: (_, i) => AparicionSuave(
                delay: Duration(milliseconds: 60 * i),
                child: TarjetaTaller(lista[i]),
              ),
            ),
    );
  }
}

// ───────────────────── Idioma ─────────────────────
class PantallaIdioma extends StatelessWidget {
  const PantallaIdioma({super.key});

  @override
  Widget build(BuildContext context) {
    final ses = context.watch<EstadoSesion>();
    const detalles = {
      'es': 'Español (México)',
      'en': 'English',
      'fr': 'Français',
    };
    return EstructuraSubpantalla(
      title: context.tr('config.idioma'),
      fallback: '/perfil/configuracion',
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TarjetaApp(
            padding: EdgeInsets.zero,
            child: Column(
              children: ListTile.divideTiles(context: context, tiles: [
                for (final e in detalles.entries)
                  ListTile(
                    leading: Icon(Icons.language_rounded,
                        color: ses.idioma == e.key ? ColoresApp.primary : ColoresApp.muted),
                    title: Text(e.value,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: ses.idioma == e.key ? ColoresApp.navy : ColoresApp.muted,
                        )),
                    trailing: ses.idioma == e.key
                        ? const Icon(Icons.check_circle_rounded, color: ColoresApp.teal)
                        : null,
                    onTap: () {
                      ses.cambiarIdioma(e.key);
                      ScaffoldMessenger.of(context).showSnackBar(
                        avisoSnack(content: Text('${e.value} ✓'), tipo: TipoToast.exito),
                      );
                    },
                  ),
              ]).toList(),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Por ahora se traducen el menú, Inicio, Perfil y Configuración; '
            'las demás pantallas se irán agregando.',
            style: TextStyle(color: ColoresApp.muted, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

// ───────────────────── Aviso de privacidad ─────────────────────
class PantallaAvisoPrivacidad extends StatelessWidget {
  const PantallaAvisoPrivacidad({super.key});

  Widget _bloque(IconData icono, String titulo, String texto) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: TarjetaApp(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: ColoresApp.mist,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icono, color: ColoresApp.primary, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: ColoresApp.navy,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  texto,
                  style: const TextStyle(
                    fontSize: 12.5,
                    height: 1.45,
                    color: ColoresApp.muted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );

  @override
  Widget build(BuildContext context) => EstructuraSubpantalla(
    title: 'Aviso de privacidad',
    fallback: '/perfil/configuracion',
    child: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _bloque(
          Icons.badge_outlined,
          'Qué datos usamos',
          'Tu nombre, número de control, grupo, correo institucional, las actividades en las que te inscribes y tu asistencia.',
        ),
        _bloque(
          Icons.flag_outlined,
          'Para qué los usamos',
          'Para gestionar tus inscripciones, llevar el control de cupos y asistencia, contar tus horas paraescolares y enviarte avisos.',
        ),
        _bloque(
          Icons.lock_outline_rounded,
          'Cómo los protegemos',
          'Solo el personal responsable de las actividades paraescolares puede consultar tu información.',
        ),
        _bloque(
          Icons.contact_support_outlined,
          'Tus derechos',
          'Puedes pedir en la coordinación de paraescolares que corrijan o eliminen tus datos.',
        ),
        const Padding(
          padding: EdgeInsets.only(top: 6),
          child: Text(
            'Resumen informativo del prototipo ACTIVA.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black38, fontSize: 11),
          ),
        ),
      ],
    ),
  );
}

// ───────────────────── Ayuda y soporte ─────────────────────
class PantallaAyuda extends StatelessWidget {
  const PantallaAyuda({super.key});

  Widget _pregunta(String p, String r) => ExpansionTile(
    shape: const Border(),
    collapsedShape: const Border(),
    tilePadding: const EdgeInsets.symmetric(horizontal: 16),
    childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
    expandedCrossAxisAlignment: CrossAxisAlignment.start,
    title: Text(
      p,
      style: const TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 14,
        color: ColoresApp.navy,
      ),
    ),
    children: [
      Text(
        r,
        style: const TextStyle(
          fontSize: 12.5,
          height: 1.45,
          color: ColoresApp.muted,
        ),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) => EstructuraSubpantalla(
    title: 'Ayuda y soporte',
    fallback: '/perfil/configuracion',
    child: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(4, 0, 0, 10),
          child: Text(
            'Preguntas frecuentes',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: ColoresApp.navy,
              fontSize: 16,
            ),
          ),
        ),
        TarjetaApp(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              _pregunta(
                '¿Cómo me inscribo a una actividad?',
                'Entra a Explorar, elige la actividad y toca "Inscribirme". Al confirmar recibirás tu comprobante con folio y código QR.',
              ),
              const Divider(),
              _pregunta(
                '¿Cómo me doy de baja?',
                'En Mis actividades abre la actividad y elige la opción para cancelar tu inscripción.',
              ),
              const Divider(),
              _pregunta(
                '¿Qué pasa si el cupo está lleno?',
                'El botón de inscripción se deshabilita. Activa los avisos de cupos disponibles para enterarte cuando se libere un lugar.',
              ),
              const Divider(),
              _pregunta(
                '¿Cuándo se habilita la constancia final?',
                'Cuando completes las 60 horas de tu actividad paraescolar.',
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        TarjetaApp(
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: ColoresApp.mist,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.support_agent_rounded,
                  color: ColoresApp.primary,
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Text(
                  '¿Necesitas más ayuda? Acude a la coordinación de paraescolares de tu universidad.',
                  style: TextStyle(
                    fontSize: 12.5,
                    height: 1.45,
                    color: ColoresApp.muted,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
