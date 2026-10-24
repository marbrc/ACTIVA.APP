import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../datos/estado_app.dart';
import '../../datos/simulados/datos_simulados.dart';
import '../../modelos/inscripcion.dart';
import '../../modelos/taller.dart';
import '../../modelos/usuario.dart';
import '../componentes/avisos.dart';
import '../componentes/dialogo_confirmar.dart';
import '../utilidades/formateadores.dart';
import '../../modelos/enums.dart';

/// Ventana flotante "¿Descargar? Regresar / Descargar PDF" y luego genera el archivo.
Future<void> descargarPdfConfirmando(
  BuildContext context, {
  required String nombreDoc,
  required Future<void> Function() generar,
  String titulo = '¿Descargar comprobante?',
}) async {
  final ok = await confirmarAccion(
    context,
    titulo: titulo,
    mensaje: 'Se generará "$nombreDoc" en formato PDF.',
    textoConfirmar: 'Descargar PDF',
    textoCancelar: 'Regresar',
    icono: Icons.picture_as_pdf_rounded,
  );
  if (!ok || !context.mounted) return;
  final m = ScaffoldMessenger.of(context);
  try {
    await generar();
    m.showSnackBar(
      avisoSnack(content: const Text('Comprobante descargado'), tipo: TipoToast.exito),
    );
  } catch (_) {
    m.showSnackBar(
      avisoSnack(content: const Text('No se pudo generar el PDF'), tipo: TipoToast.error),
    );
  }
}

class Documentos {
  static const _azul = PdfColor.fromInt(0xFF1B78E2);
  static const _navy = PdfColor.fromInt(0xFF0A3175);

  // la fuente base del PDF no trae algunos símbolos, los cambiamos
  static String _l(String s) =>
      s.replaceAll('–', '-').replaceAll('—', '-').replaceAll('’', "'");

  static pw.Widget _txt(String s,
          {double size = 11, bool bold = false, PdfColor color = PdfColors.black}) =>
      pw.Text(
        _l(s),
        style: pw.TextStyle(
          fontSize: size,
          fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: color,
        ),
      );

  static pw.Widget _encabezado(String titulo) => pw.Container(
        width: double.infinity,
        padding: const pw.EdgeInsets.all(18),
        decoration: pw.BoxDecoration(
          color: _azul,
          borderRadius: pw.BorderRadius.circular(12),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            _txt('ACTIVA', size: 12, color: PdfColors.white),
            _txt(titulo, size: 22, bold: true, color: PdfColors.white),
          ],
        ),
      );

  static pw.Widget _tabla(List<List<String>> filas,
          {bool encabezado = false, bool etiquetas = false}) =>
      pw.Table(
        border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
        children: [
          for (final (n, f) in filas.indexed)
            pw.TableRow(
              decoration: encabezado && n == 0
                  ? const pw.BoxDecoration(color: PdfColors.grey200)
                  : null,
              children: [
                for (final (k, c) in f.indexed)
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(6),
                    child: _txt(c,
                        size: 10,
                        bold: (encabezado && n == 0) || (etiquetas && k == 0)),
                  ),
              ],
            ),
        ],
      );

  static Future<void> _guardar(
          Uint8List bytes, String nombre, String ext, MimeType tipo) =>
      FileSaver.instance.saveFile(name: nombre, bytes: bytes, ext: ext, mimeType: tipo);

  // ───────── PDF: comprobante de inscripción ─────────
  static Future<void> comprobanteInscripcion(Inscripcion i) async {
    final t = i.taller;
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (_) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            _encabezado('Comprobante de inscripción'),
            pw.SizedBox(height: 24),
            _tabla([
              ['Nombre', i.alumno.nombreCompleto],
              ['Número de control', i.alumno.numeroControl],
              ['Actividad', t.nombre],
              ['Horario', t.horarioTexto],
              ['Lugar', t.lugar],
              ['Instructor', t.instructor.nombreCompleto],
              ['Fecha de inscripción', fechaLarga(i.fechaInscripcion)],
            ], etiquetas: true),
            pw.SizedBox(height: 24),
            pw.Row(
              children: [
                pw.BarcodeWidget(
                  barcode: pw.Barcode.qrCode(),
                  data: i.folio,
                  width: 100,
                  height: 100,
                ),
                pw.SizedBox(width: 16),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    _txt('Folio de inscripción', size: 10, color: PdfColors.grey700),
                    _txt(i.folio, size: 22, bold: true, color: _navy),
                    pw.SizedBox(height: 4),
                    _txt('Presenta este código con tu instructor.', size: 10),
                  ],
                ),
              ],
            ),
            pw.Spacer(),
            _txt('Generado por ACTIVA el ${fechaLarga(DateTime.now())}',
                size: 9, color: PdfColors.grey700),
          ],
        ),
      ),
    );
    await _guardar(await pdf.save(), 'Comprobante_${i.folio}', 'pdf', MimeType.pdf);
  }

  // ───────── PDF: constancia de horas ─────────
  static Future<void> constanciaHoras(Alumno a, int horas, {required bool finalDoc}) async {
    final titulo = finalDoc ? 'Constancia final de horas' : 'Constancia parcial de horas';
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (_) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            _encabezado(titulo),
            pw.SizedBox(height: 24),
            _tabla([
              ['Nombre', a.nombreCompleto],
              ['Número de control', a.numeroControl],
              ['Carrera', a.carrera],
              ['Grupo', a.grupo],
              ['Periodo', periodoSimulado],
              ['Horas acumuladas', '$horas de $metaHoras'],
              ['Estatus', finalDoc ? 'Actividad paraescolar completada' : 'En proceso'],
            ], etiquetas: true),
            pw.Spacer(),
            _txt('Generado por ACTIVA el ${fechaLarga(DateTime.now())}',
                size: 9, color: PdfColors.grey700),
          ],
        ),
      ),
    );
    await _guardar(
      await pdf.save(),
      '${finalDoc ? 'Constancia_final' : 'Constancia_parcial'}_${a.numeroControl}',
      'pdf',
      MimeType.pdf,
    );
  }

  // ───────── Reportes (PDF / Word / Excel) ─────────
  static List<List<String>> _filasReporte(EstadoApp s) => [
        ['Actividad', 'Instructor', 'Inscritos', 'Cupo', 'Ocupación'],
        for (final t in s.talleres)
          [
            t.nombre,
            t.instructor.nombreCompleto,
            '${t.inscritos}',
            '${t.cupoMaximo}',
            '${t.cupoMaximo == 0 ? 0 : (t.inscritos * 100 / t.cupoMaximo).round()} %',
          ],
      ];

  static List<String> _resumen(EstadoApp s) {
    final alumnos = s.todosAlumnos;
    final con60 = alumnos.where((a) => s.horasAlumno(a) >= metaHoras).length;
    return [
      'Periodo: $periodoSimulado',
      'Total de inscripciones: ${s.totalInscripciones}',
      'Alumnos con $metaHoras horas: $con60 de ${alumnos.length}',
      'Generado el ${fechaLarga(DateTime.now())}',
    ];
  }

  static Future<void> exportarReporte(String formato, EstadoApp s) async {
    final filas = _filasReporte(s);
    final resumen = _resumen(s);
    final nombre = 'Reporte_ACTIVA_${fechaIso(DateTime.now())}';
    const titulo = 'Reporte de inscripciones por actividad';

    if (formato == 'PDF') {
      final pdf = pw.Document();
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(36),
          build: (_) => [
            _encabezado(titulo),
            pw.SizedBox(height: 14),
            for (final r in resumen) _txt(r),
            pw.SizedBox(height: 14),
            _tabla(filas, encabezado: true),
          ],
        ),
      );
      await _guardar(await pdf.save(), nombre, 'pdf', MimeType.pdf);
    } else if (formato == 'Word') {
      await _guardar(_docx(titulo, resumen, filas), nombre, 'docx', MimeType.microsoftWord);
    } else {
      // "Excel": un .csv que Excel abre directo
      String celda(String c) => '"${c.replaceAll('"', '""')}"';
      final csv = filas.map((f) => f.map(celda).join(',')).join('\r\n');
      final bytes = Uint8List.fromList([0xEF, 0xBB, 0xBF, ...utf8.encode(csv)]);
      await _guardar(bytes, nombre, 'csv', MimeType.csv);
    }
  }

  // ───────── Word (.docx hecho a mano) ─────────
  static String _x(String s) =>
      s.replaceAll('&', '&amp;').replaceAll('<', '&lt;').replaceAll('>', '&gt;');

  static String _p(String t, {bool b = false, int sz = 22, String color = '000000'}) =>
      '<w:p><w:r><w:rPr>${b ? '<w:b/>' : ''}<w:color w:val="$color"/><w:sz w:val="$sz"/></w:rPr>'
      '<w:t xml:space="preserve">${_x(t)}</w:t></w:r></w:p>';

  static Uint8List _docx(String titulo, List<String> resumen, List<List<String>> filas) {
    final cols = filas.first.length;
    final ancho = 9600 ~/ cols;
    final tabla = StringBuffer('<w:tbl><w:tblPr><w:tblW w:w="0" w:type="auto"/><w:tblBorders>');
    for (final l in ['top', 'left', 'bottom', 'right', 'insideH', 'insideV']) {
      tabla.write('<w:$l w:val="single" w:sz="4" w:space="0" w:color="999999"/>');
    }
    tabla.write('</w:tblBorders></w:tblPr><w:tblGrid>');
    tabla.write('<w:gridCol w:w="$ancho"/>' * cols);
    tabla.write('</w:tblGrid>');
    for (final (n, f) in filas.indexed) {
      tabla.write('<w:tr>');
      for (final c in f) {
        tabla.write(
          '<w:tc><w:tcPr><w:tcW w:w="$ancho" w:type="dxa"/>'
          '${n == 0 ? '<w:shd w:val="clear" w:color="auto" w:fill="DCEBFB"/>' : ''}</w:tcPr>'
          '${_p(c, b: n == 0, sz: 20)}</w:tc>',
        );
      }
      tabla.write('</w:tr>');
    }
    tabla.write('</w:tbl>');

    final cuerpo = StringBuffer()
      ..write(_p(titulo, b: true, sz: 36, color: '0A3175'))
      ..writeAll(resumen.map((r) => _p(r)))
      ..write('<w:p/>')
      ..write(tabla)
      ..write('<w:p/>');

    const cab = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>';
    final doc = '$cab<w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">'
        '<w:body>$cuerpo<w:sectPr><w:pgSz w:w="12240" w:h="15840"/>'
        '<w:pgMar w:top="1134" w:right="1134" w:bottom="1134" w:left="1134" '
        'w:header="708" w:footer="708" w:gutter="0"/></w:sectPr></w:body></w:document>';

    final zip = Archive();
    void add(String ruta, String xml) {
      final d = utf8.encode(xml);
      zip.addFile(ArchiveFile(ruta, d.length, d));
    }

    add('[Content_Types].xml',
        '$cab<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">'
        '<Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>'
        '<Default Extension="xml" ContentType="application/xml"/>'
        '<Override PartName="/word/document.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml"/>'
        '</Types>');
    add('_rels/.rels',
        '$cab<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">'
        '<Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="word/document.xml"/>'
        '</Relationships>');
    add('word/document.xml', doc);
    return Uint8List.fromList(ZipEncoder().encode(zip)!);
  }

  // ───────── Calendario, ubicación y compartir ─────────
  static Future<bool> _abrir(Uri u) async {
    try {
      return await launchUrl(u, mode: LaunchMode.externalApplication);
    } catch (_) {
      return false;
    }
  }

  static DateTime _proximaSesion(Taller t) {
    final ahora = DateTime.now();
    final base = DateTime(ahora.year, ahora.month, ahora.day);
    for (var i = 0; i < 8; i++) {
      final d = base.add(Duration(days: i));
      final h = t.horarios.where((x) => x.dia.weekday == d.weekday);
      if (h.isEmpty) continue;
      if (i == 0 && ahora.hour * 60 + ahora.minute >= h.first.finMin) continue;
      return d;
    }
    return base;
  }

  static String _g(DateTime d, int min) =>
      '${d.year}${d.month.toString().padLeft(2, '0')}${d.day.toString().padLeft(2, '0')}'
      'T${(min ~/ 60).toString().padLeft(2, '0')}${(min % 60).toString().padLeft(2, '0')}00';

  /// Abre Google Calendar con la actividad ya llenada y repetida cada semana.
  static Future<bool> agregarAlCalendario(Taller t) {
    final d = _proximaSesion(t);
    final h = t.horarioDe(d);
    const dias = ['MO', 'TU', 'WE', 'TH', 'FR'];
    final byday = t.horarios.map((x) => dias[x.dia.index]).join(',');
    return _abrir(
      Uri.https('calendar.google.com', '/calendar/render', {
        'action': 'TEMPLATE',
        'text': 'ACTIVA: ${t.nombre}',
        'dates': '${_g(d, h.inicioMin)}/${_g(d, h.finMin)}',
        'details': 'Actividad paraescolar con ${t.instructor.nombreCompleto}.',
        'location': '${t.lugar}, UTNG',
        'recur': 'RRULE:FREQ=WEEKLY;BYDAY=$byday;COUNT=${t.horarios.length * 15}',
      }),
    );
  }

  static Future<bool> verUbicacion(Taller t) => _abrir(
        Uri.https('www.google.com', '/maps/search/', {
          'api': '1',
          'query': 'Universidad Tecnológica del Norte de Guanajuato ${t.lugar}',
        }),
      );

  static Future<void> compartir(BuildContext context, Taller t) async {
    final texto = '¡Únete a ${t.nombre} en ACTIVA!\n'
        '${t.horarioTexto.replaceAll(' | ', ' de ')}\n'
        'Lugar: ${t.lugar}\nInstructor: ${t.instructor.nombreCompleto}';
    var compartido = false;
    try {
      final r = await SharePlus.instance.share(ShareParams(text: texto, subject: t.nombre));
      compartido = r.status != ShareResultStatus.unavailable;
    } catch (_) {}
    if (compartido) return;
    // si el navegador/equipo no tiene "compartir", lo copiamos
    await Clipboard.setData(ClipboardData(text: texto));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        avisoSnack(content: const Text('Datos copiados para compartir'), tipo: TipoToast.info),
      );
    }
  }
}