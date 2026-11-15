import 'package:flutter/material.dart';

import '../idiomas/idiomas.dart';
import '../preferencias/preferencias.dart';
import '../temas/espacios.dart';
import '../temas/estilos_textos.dart';
import '../temas/radios.dart';


/// Muestra la ventana de configuración con el formato de números y el formato de fechas.
Future<void> funcMostrarConfiguracion(
  BuildContext       oContexto,
  ClasePreferencias  oPreferencias,
  VoidCallback       funcAlCambiar,
) async {
  final String sAceptar   = ClaseIdiomas.getTexto('aceptar', oPreferencias.getIdioma());
  final String sIdioma    = oPreferencias.getIdioma();
  final String sTitulo    = ClaseIdiomas.getTexto('configuracion', sIdioma);
  await showDialog<void>(
    context            : oContexto,
    barrierDismissible : false,
    builder            : (oContextoVentana) {
      return StatefulBuilder(
        builder: (oContextoVentana, setStateVentana) {
          return AlertDialog(
            title : Text(sTitulo, style: ClaseGenEstilosTexto.subtituloMediano(oContextoVentana)),
            content: Column(
              mainAxisSize : MainAxisSize.min,
              children     : <Widget>[
                funcConstruirSelectorFormato(
                  oContextoVentana,
                  oPreferencias,
                  setStateVentana,
                  funcAlCambiar,
                  oIcono      : Icons.looks_one,
                  sClave      : 'formatoNumeros',
                  sValor      : oPreferencias.getFormatoNumeros(),
                  sValorLatino: ClasePreferencias.sFormatoNumerosPorDefecto,
                  funcGuardar : oPreferencias.setFormatoNumeros,
                ),
                const SizedBox(height: ClaseGenEspacios.dEspacio16),
                funcConstruirSelectorFormato(
                  oContextoVentana,
                  oPreferencias,
                  setStateVentana,
                  funcAlCambiar,
                  oIcono      : Icons.calendar_month,
                  sClave      : 'formatoFechas',
                  sValor      : oPreferencias.getFormatoFechas(),
                  sValorLatino: ClasePreferencias.sFormatoFechasPorDefecto,
                  funcGuardar : oPreferencias.setFormatoFechas,
                ),
              ],
            ),
            actions: <Widget>[
              FilledButton.icon(
                onPressed : () => Navigator.of(oContextoVentana).pop(),
                icon      : const Icon(Icons.check),
                label     : Text(sAceptar,
                            style: ClaseGenEstilosTexto.normalMediano(oContextoVentana)),
              ),
            ],
          );
        },
      );
    },
  );
}

Widget funcConstruirSelectorFormato(
  BuildContext              oContexto,
  ClasePreferencias         oPreferencias,
  StateSetter               setStateVentana,
  VoidCallback              funcAlCambiar, {
  required Future<void> Function(String) funcGuardar,
  required IconData                     oIcono,
  required String                       sClave,
  required String                       sValor,
  required String                       sValorLatino,
}) {
  final ThemeData oTema = Theme.of(oContexto);
  return DropdownButton<String>(
    borderRadius : BorderRadius.circular(ClaseGenRadios.dPequeno),
    icon         : Icon(Icons.arrow_drop_down, color: oTema.colorScheme.onSurface),
    items        : <DropdownMenuItem<String>>[
      DropdownMenuItem<String>(
        value : sValorLatino,
        child : Row(
          mainAxisSize : MainAxisSize.min,
          children     : <Widget>[
            Icon(oIcono, color: oTema.colorScheme.onSurface),
            const SizedBox(width: ClaseGenEspacios.dEspacio08),
            Text(ClaseIdiomas.getTexto('formatoLatino', oPreferencias.getIdioma()),
                 style: ClaseGenEstilosTexto.normalMediano(oContexto)),
          ],
        ),
      ),
      DropdownMenuItem<String>(
        value : 'frances',
        child : Row(
          mainAxisSize : MainAxisSize.min,
          children     : <Widget>[
            Icon(oIcono, color: oTema.colorScheme.onSurface),
            const SizedBox(width: ClaseGenEspacios.dEspacio08),
            Text(ClaseIdiomas.getTexto('formatoFrances', oPreferencias.getIdioma()),
                 style: ClaseGenEstilosTexto.normalMediano(oContexto)),
          ],
        ),
      ),
    ],
    onChanged : (sValorNuevo) async {
      if (sValorNuevo == null) return;
      await funcGuardar(sValorNuevo);
      setStateVentana(() {});
      funcAlCambiar();
    },
    underline : const SizedBox.shrink(),
    value     : sValor,
  );

}

