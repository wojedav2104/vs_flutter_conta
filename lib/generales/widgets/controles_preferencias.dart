import 'package:flutter/material.dart';

import '../idiomas/idiomas.dart';
import '../preferencias/preferencias.dart';
import '../temas/espacios.dart';
import '../temas/estilos_textos.dart';
import '../temas/radios.dart';


/// Controles para elegir el tema y el idioma. Se usan en el login y en la
/// pantalla principal. Cada opción muestra su propio icono: el sol junto a
/// "Claro" y la luna junto a "Oscuro".
class ClaseControlesPreferencias extends StatelessWidget {
  
  const ClaseControlesPreferencias({
    super.key,
    required this.oPreferencias,
    required this.funcAlCambiar,
  });

  final ClasePreferencias oPreferencias;
  final VoidCallback      funcAlCambiar;

  // ── Acciones (los setters graban de inmediato en el dispositivo) ────────
  Future<void> actualizarIdioma(String? sValor) async {
    if (sValor == null) return;
    await oPreferencias.setIdioma(sValor);
    funcAlCambiar();
  }

  Future<void> actualizarTema(String? sValor) async {
    if (sValor == null) return;
    await oPreferencias.setTema(sValor);
    funcAlCambiar();
  }

  // ── Construcción de la interfaz ─────────────────────────────────────────
  @override
  Widget build(BuildContext oContexto) {
    return Row(
      mainAxisSize : MainAxisSize.min,
      children     : <Widget>[
        construirSelector(
          oContexto,
          sValor       : oPreferencias.getTema(),
          listClaves   : <String>['claro', 'oscuro'],
          listIconos   : <IconData>[Icons.light_mode, Icons.dark_mode],
          listValores  : <String>[
            ClasePreferencias.sTemaPorDefecto,
            'oscuro',
          ],
          funcAlElegir : actualizarTema,
        ),
        const SizedBox(width: ClaseGenEspacios.dEspacio08),
        construirSelector(
          oContexto,
          sValor       : oPreferencias.getIdioma(),
          listClaves   : <String>['espanol', 'frances'],
          listIconos   : <IconData>[Icons.translate, Icons.translate],
          listValores  : <String>['es', 'fr'],
          funcAlElegir : actualizarIdioma,
        ),
      ],
    );
  }

  Widget construirSelector(
    BuildContext oContexto, {
    required List<IconData>          listIconos,
    required List<String>            listClaves,
    required List<String>            listValores,
    required String                  sValor,
    required ValueChanged<String?>   funcAlElegir,
  }) {
    final ThemeData oTema = Theme.of(oContexto);
    return DropdownButton<String>(
      borderRadius : BorderRadius.circular(ClaseGenRadios.dPequeno),
      icon         : Icon(Icons.arrow_drop_down, color: oTema.colorScheme.onSurface),
      items        : <DropdownMenuItem<String>>[
        for (int i = 0; i < listValores.length; i++)
          DropdownMenuItem<String>(
            value : listValores[i],
            child : Row(
              mainAxisSize : MainAxisSize.min,
              children     : <Widget>[
                Icon(listIconos[i], color: oTema.colorScheme.onSurface),
                const SizedBox(width: ClaseGenEspacios.dEspacio08),
                Text(ClaseIdiomas.getTexto(oPreferencias.getIdioma(), listClaves[i]),
                     style: ClaseGenEstilosTexto.normalMediano(oContexto)),
              ],
            ),
          ),
      ],
      onChanged       : funcAlElegir,
      underline       : const SizedBox.shrink(),
      value           : sValor,
    );
  }

}