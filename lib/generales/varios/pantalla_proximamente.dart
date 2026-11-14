import 'package:flutter/material.dart';

import '../idiomas/idiomas.dart';
import '../preferencias/preferencias.dart';
import '../temas/espacios.dart';
import '../temas/estilos_textos.dart';

/// Pantalla provisoria para las opciones del menú cuyo módulo aún no está
/// desarrollado: la ruta existe pero la pantalla definitiva no.
class ClasePantallaProximamente extends StatelessWidget {

  const ClasePantallaProximamente({
    super.key,
    required this.oPreferencias,
    required this.sTitulo,
  });

  final ClasePreferencias oPreferencias;
  final String            sTitulo;

  @override
  Widget build(BuildContext oContexto) {
    return Scaffold(
      appBar : AppBar(
        title: Text(sTitulo, style: ClaseGenEstilosTexto.tituloMediano(oContexto)),
      ),
      body: Center(
        child: Column(
          mainAxisSize : MainAxisSize.min,
          children     : <Widget>[
            const Icon(Icons.construction_outlined),
            const SizedBox(height: ClaseGenEspacios.dEspacio16),
            Text(
              ClaseIdiomas.getTexto(oPreferencias.getIdioma(), 'enPreparacion'),
              style : ClaseGenEstilosTexto.normalGrande(oContexto),
            ),
          ],
        ),
      ),
    );
  }

}
