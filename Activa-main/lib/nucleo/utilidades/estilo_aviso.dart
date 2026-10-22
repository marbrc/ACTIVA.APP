import 'package:flutter/material.dart';

import '../../modelos/enums.dart';
import '../tema/tema_app.dart';

(Color, IconData) estiloAviso(TipoAviso t) => switch (t) {
  TipoAviso.cambioHorario => (ColoresApp.warning, Icons.access_time),
  TipoAviso.informativo => (ColoresApp.primary, Icons.person),
  TipoAviso.recordatorio => (ColoresApp.teal, Icons.star),
  TipoAviso.cancelacion => (ColoresApp.danger, Icons.cancel),
};
