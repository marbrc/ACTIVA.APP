// ===================================================================
// Pantalla EXPLORAR: buscador, filtros por categoría y cuadrícula
// ===================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../nucleo/tema/tema_app.dart';
import '../../../nucleo/componentes/aparicion_suave.dart';
import '../../../datos/estado_app.dart';
import '../componentes/tarjeta_actividad.dart';

// esta pantalla sí tiene estado porque cambia el texto buscado y el filtro
class PantallaExplorar extends StatefulWidget {
  const PantallaExplorar({super.key, this.initialCat});
  // categoria con la que se abre puede venir null = todas
  final String? initialCat;
  @override
  State<PantallaExplorar> createState() => _EstadoPantallaExplorar();
}

class _EstadoPantallaExplorar extends State<PantallaExplorar> {
  // Controla el texto del buscador
  final _search = TextEditingController();
  // clave de la categoria elegid null = todas
  String? _cat;

  @override
  void initState() {
    super.initState();
    // al abrir usa la categoría que mandaron (si hay)
    _cat = widget.initialCat;
  }

  @override
  void didUpdateWidget(PantallaExplorar old) {
    super.didUpdateWidget(old);
    // si cambió la categoría desde afuera la actualiza
    if (old.initialCat != widget.initialCat) {
      setState(() => _cat = widget.initialCat);
    }
  }

  @override
  void dispose() {
    // libera el controlador cuando se cierra la pantalla
    _search.dispose();
    super.dispose();
  }

  // chip de filtro con estilo azul marino cuando está seleccionado
  Widget _chip(String label, bool selected, VoidCallback onTap) => ChoiceChip(
        label: Text(label),
        selected: selected,
        // Quita la palomita de selección
        showCheckmark: false,
        // Azul marino cuando está elegido
        selectedColor: ColoresApp.navy,
        // Blanco cuando no
        backgroundColor: Colors.white,
        // Borde azul marino si está elegido, gris clarito si no
        side: BorderSide(color: selected ? ColoresApp.navy : ColoresApp.line),
        labelStyle: TextStyle(
          color: selected ? Colors.white : ColoresApp.navy,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
        onSelected: (_) => onTap(),
      );

  @override
  Widget build(BuildContext context) {
    // Lee los datos y se redibuja si cambian
    final state = context.watch<EstadoApp>();
    // Texto buscado en minúsculas y sin espacios en los lados
    final q = _search.text.trim().toLowerCase();
    // Filtra: activa + categoría elegida + nombre que contenga lo buscado
    final lista = state.talleres
        .where((t) =>
            t.activo &&
            (_cat == null || t.categoria.clave == _cat) &&
            t.nombre.toLowerCase().contains(q))
        .toList();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título de la pantalla
            Text(
              'Actividades',
              style: TextStyle(
                fontFamily: FuentesApp.century,
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: ColoresApp.navy,
              ),
            ),
            // Subtítulo
            const Text(
              'Encuentra tu pasión, forma parte y vive la experiencia.',
              style: TextStyle(color: ColoresApp.muted, fontSize: 13),
            ),
            const SizedBox(height: 14),
            // Buscador (el estilo viene del tema)
            TextField(
              controller: _search,
              // Cada letra redibuja la lista
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search_rounded),
                hintText: '¿Qué actividad buscas?',
                // Botón X solo cuando ya escribió algo
                suffixIcon: q.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () {
                          // Borra el texto y refresca
                          _search.clear();
                          setState(() {});
                        },
                      ),
              ),
            ),
            const SizedBox(height: 12),
            // Fila de chips que se mueve de lado
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  // Chip "Todas"
                  _chip('Todas', _cat == null, () => setState(() => _cat = null)),
                  // Un chip por cada categoría activa
                  for (final c in state.categorias) ...[
                    const SizedBox(width: 8),
                    _chip(c.nombre, _cat == c.clave,
                        () => setState(() => _cat = c.clave)),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 14),
            // Expanded para que la cuadrícula use el resto de la pantalla
            Expanded(
              child: lista.isEmpty
                  // Mensaje bonito cuando no hay resultados
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.search_off_rounded,
                              size: 56,
                              color: ColoresApp.primary.withValues(alpha: 0.4)),
                          const SizedBox(height: 10),
                          const Text('No encontramos actividades',
                              style: TextStyle(color: ColoresApp.muted)),
                        ],
                      ),
                    )
                  // Cuadrícula de tarjetas
                  : GridView.builder(
                      padding: const EdgeInsets.only(bottom: 16),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        // 2 tarjetas por fila
                        crossAxisCount: 2,
                        // Alto fijo de cada tarjeta
                        mainAxisExtent: 196,
                        // Espacio horizontal y vertical entre tarjetas
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: lista.length,
                      // Cada tarjeta entra con un pequeño retraso distinto
                      itemBuilder: (_, i) => AparicionSuave(
                        delay: Duration(milliseconds: (i % 6) * 60),
                        dy: 18,
                        child: TarjetaActividad(lista[i]),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}