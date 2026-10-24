import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../../datos/sesion.dart';

const idiomas = {'es': 'Español', 'en': 'English', 'fr': 'Français'};

extension TextosX on BuildContext {
  /// Traduce una clave según el idioma elegido en Configuración.
  String tr(String clave, {String n = ''}) {
    final idioma = Provider.of<EstadoSesion>(this).idioma;
    final fila = _textos[clave];
    if (fila == null) return clave;
    return fila[const ['es', 'en', 'fr'].indexOf(idioma)].replaceAll('{n}', n);
  }
}

// [español, inglés, francés]. Para traducir más pantallas agrega claves aquí.
const _textos = <String, List<String>>{
  'nav.inicio': ['Inicio', 'Home', 'Accueil'],
  'nav.explorar': ['Explorar', 'Explore', 'Explorer'],
  'nav.actividades': ['Mis actividades', 'My activities', 'Mes activités'],
  'nav.avisos': ['Avisos', 'Notices', 'Avis'],
  'nav.perfil': ['Perfil', 'Profile', 'Profil'],
  'inicio.hola': ['¡Hola, {n}!', 'Hi, {n}!', 'Salut, {n} !'],
  'inicio.lema': [
    'Descubre, participa y vive tu universidad.',
    'Discover, join and live your university.',
    'Découvre, participe et vis ton université.',
  ],
  'inicio.progreso': [
    'Tu progreso paraescolar',
    'Your extracurricular progress',
    'Ta progression parascolaire',
  ],
  'inicio.sugerida': ['Actividad sugerida', 'Suggested activity', 'Activité suggérée'],
  'inicio.avisos': ['Avisos recientes', 'Recent notices', 'Avis récents'],
  'perfil.horas': ['Horas', 'Hours', 'Heures'],
  'perfil.actividades': ['Actividades', 'Activities', 'Activités'],
  'perfil.favoritos': ['Favoritos', 'Favorites', 'Favoris'],
  'perfil.misFavoritos': ['Mis favoritos', 'My favorites', 'Mes favoris'],
  'perfil.comprobantes': ['Mis comprobantes', 'My receipts', 'Mes justificatifs'],
  'perfil.progreso': ['Mi progreso', 'My progress', 'Ma progression'],
  'perfil.chats': ['Chats grupales', 'Group chats', 'Discussions de groupe'],
  'perfil.encuestas': ['Encuestas de mis clubes', 'Club surveys', 'Sondages des clubs'],
  'perfil.academicos': ['Mis datos académicos', 'My academic info', 'Mes données académiques'],
  'perfil.editar': ['Editar perfil', 'Edit profile', 'Modifier le profil'],
  'perfil.config': ['Configuración', 'Settings', 'Paramètres'],
  'perfil.cerrar': ['Cerrar sesión', 'Sign out', 'Se déconnecter'],
  'perfil.comunidad': ['Comunidad', 'Community', 'Communauté'],
  'perfil.cuenta': ['Cuenta', 'Account', 'Compte'],
  'config.notif': ['Notificaciones', 'Notifications', 'Notifications'],
  'config.avisos': ['Avisos de actividades', 'Activity notices', "Avis d'activités"],
  'config.horario': ['Cambios de horario', 'Schedule changes', "Changements d'horaire"],
  'config.recordatorios': ['Recordatorios de clase', 'Class reminders', 'Rappels de cours'],
  'config.cupos': ['Cupos disponibles', 'Available spots', 'Places disponibles'],
  'config.sonidos': ['Sonidos de la app', 'App sounds', "Sons de l'application"],
  'config.pass': ['Cambiar contraseña', 'Change password', 'Changer le mot de passe'],
  'config.idioma': ['Idioma', 'Language', 'Langue'],
  'config.privAyuda': ['Privacidad y ayuda', 'Privacy and help', 'Confidentialité et aide'],
  'config.privacidad': ['Aviso de privacidad', 'Privacy notice', 'Avis de confidentialité'],
  'config.ayuda': ['Ayuda y soporte', 'Help and support', 'Aide et assistance'],
  'config.acerca': ['Acerca de la aplicación', 'About the app', "À propos de l'application"],
};