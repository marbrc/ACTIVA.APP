import '../../../nucleo/componentes/avatar_activa.dart';
import '../../../modelos/enums.dart';
import '../../../datos/sesion.dart';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../nucleo/tema/tema_app.dart';
import '../../../nucleo/utilidades/formateadores.dart';
import '../../../nucleo/componentes/tarjeta_app.dart';
import '../../../datos/estado_app.dart';
import '../../../nucleo/componentes/avisos.dart';

import '../../../nucleo/componentes/dialogo_confirmar.dart';

class PantallaPerfilInstructor extends StatelessWidget {
  const PantallaPerfilInstructor({super.key});

  Widget _item(
    BuildContext c,
    IconData icon,
    String label,
    VoidCallback onTap,
  ) => ListTile(
    leading: CircleAvatar(
      backgroundColor: ColoresApp.background,
      child: Icon(icon, color: ColoresApp.primary, size: 20),
    ),
    title: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
    trailing: const Icon(Icons.chevron_right, color: Colors.black38),
    onTap: onTap,
  );

  void _soon(BuildContext c) =>
      ScaffoldMessenger.of(c)
          .showSnackBar(avisoSnack(content: Text('Próximamente')));

  @override
  Widget build(BuildContext context) {
    final i = context.watch<EstadoApp>().instructor;
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 12),
          Center(
            child: AvatarActiva(
              rol: Rol.instructor,
              iniciales: iniciales(i.nombre, i.apellidoPaterno),
              radio: 46,
              borde: true,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            i.nombreCompleto,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: ColoresApp.navy,
            ),
          ),
          const SizedBox(height: 6),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            children: [
              const Chip(label: Text('Instructor')),
              Chip(label: Text(i.especialidad)),
            ],
          ),
          const SizedBox(height: 16),
          TarjetaApp(
            padding: EdgeInsets.zero,
            child: Column(
              children: ListTile.divideTiles(
                context: context,
                tiles: [
                  _item(
                    context,
                    Icons.groups,
                    'Mis grupos',
                    () => context.go('/instructor/grupos'),
                  ),
                  _item(
                    context,
                    Icons.check_circle,
                    'Historial de asistencia',
                    () => context.push('/instructor/historial'),
                  ),
                  _item(
                    context,
                    Icons.notifications,
                    'Mis avisos publicados',
                    () => context.go('/instructor/avisos'),
                  ),
                  _item(
                    context,
                    Icons.forum_rounded,
                    'Chats grupales',
                    () => context.push('/chats'),
                  ),
                  _item(
                    context,
                    Icons.mark_email_unread_rounded,
                    'Solicitudes al administrador',
                    () => context.push('/instructor/solicitudes'),
                  ),
                  _item(
                    context,
                    Icons.edit,
                    'Editar perfil',
                    () => context.push('/perfil/editar'),
                  ),
                  _item(
                    context,
                    Icons.settings,
                    'Configuración',
                    () => context.push('/perfil/configuracion'),
                  ),
                ],
              ).toList(),
            ),
          ),
          TextButton(
            onPressed: () => cerrarSesionConfirmando(context),
            child: const Text(
              'Cerrar sesión',
              style: TextStyle(color: ColoresApp.danger),
            ),
          ),
        ],
      ),
    );
  }
}
