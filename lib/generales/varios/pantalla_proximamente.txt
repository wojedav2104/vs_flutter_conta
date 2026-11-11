import 'package:flutter/material.dart';

import '../idiomas/idiomas.dart';
import '../temas/espacios.dart';
import '../temas/estilos_textos.dart';


/// Pantalla provisional que se muestra al elegir una opción del menú cuyo
/// módulo aún no está implementado.
class ClasePantallaProximamente extends StatelessWidget {

  const ClasePantallaProximamente({
    super.key,
    required this.sTitulo,
  });

  final String sTitulo;

  @override
  Widget build(BuildContext oContexto) {
    return Scaffold(
      appBar : AppBar(title: Text(sTitulo)),
      body   : Center(
        child: Column(
          mainAxisSize : MainAxisSize.min,
          children     : <Widget>[
            const Icon(Icons.construction, size: 64),
            const SizedBox(height: ClaseGenEspacios.dEspacio16),
            Text(sTitulo, style: ClaseGenEstilosTexto.subtituloGrande(oContexto)),
            const SizedBox(height: ClaseGenEspacios.dEspacio08),
            Text(ClaseIdiomas.getTexto('es', 'enPreparacion'),
                 style: ClaseGenEstilosTexto.normalMediano(oContexto)),
          ],
        ),
      ),
    );
  }

}