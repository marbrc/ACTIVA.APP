import 'package:flutter/material.dart';

class Categoria {
  final int id;
  final String clave; // slug para URLs y filtros: "deportes"
  final String nombre; // chip de filtro: "Deportes"
  final String etiqueta; // badge en tarjetas: "Deportiva"
  final int colorValue; // 0xFFE08A3C
  final String icono; // clave del ícono, ver kIconos
  final bool activa;

  const Categoria({
    required this.id,
    required this.clave,
    required this.nombre,
    required this.etiqueta,
    required this.colorValue,
    required this.icono,
    this.activa = true,
  });

  Color get color => Color(colorValue);
}

// La BD guarda solo la clave (texto); aquí se traduce a un IconData real.
const Map<String, IconData> kIconos = {
  'deportes': Icons.sports_soccer,
  'cultura': Icons.theater_comedy,
  'recreativa': Icons.extension,
  'otros': Icons.star,
  'musica': Icons.music_note,
  'arte': Icons.palette,
  'ciencia': Icons.science,
};

IconData iconoDe(String clave) => kIconos[clave] ?? Icons.star;
