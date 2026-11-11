import 'package:flutter/material.dart';

import '../idiomas/idiomas.dart';
import '../temas/colores.dart';
import '../temas/espacios.dart';
import '../temas/estilos_textos.dart';


/// Pide confirmación al usuario; devuelve true si confirma.
Future<bool> funcMostrarConfirmacion(
  BuildContext oContexto,
  String       sIdioma,
  String       sMensaje,
) async {
  final String sAceptar  = ClaseIdiomas.getTexto(sIdioma, 'aceptar');
  final String sCancelar = ClaseIdiomas.getTexto(sIdioma, 'cancelar');
  bool bConfirmo = false;
  await showDialog<void>(
    context            : oContexto,
    barrierDismissible : false,
    builder            : (oContextoVentana) {
      return AlertDialog(
        content : Text(sMensaje, style: ClaseGenEstilosTexto.normalMediano(oContextoVentana)),
        actions : <Widget>[
          OutlinedButton.icon(
            onPressed : () => Navigator.of(oContextoVentana).pop(),
            icon      : const Icon(Icons.cancel_outlined),
            label     : Text(sCancelar,
                        style: ClaseGenEstilosTexto.normalMediano(oContextoVentana)),
          ),
          FilledButton.icon(
            onPressed : () {
              bConfirmo = true;
              Navigator.of(oContextoVentana).pop();
            },
            icon      : const Icon(Icons.check),
            label     : Text(sAceptar,
                        style: ClaseGenEstilosTexto.normalMediano(oContextoVentana)),
          ),
        ],
      );
    },
  );
  return bConfirmo;
}


/// Muestra un mensaje con botón Aceptar y "X"; el usuario debe cerrarlo.
Future<void> funcMostrarMensaje(
  BuildContext oContexto,
  String       sIdioma,
  String       sTitulo,
  String       sMensaje,
) async {
  final String sAceptar = ClaseIdiomas.getTexto(sIdioma, 'aceptar');
  await showDialog<void>(
    context            : oContexto,
    barrierDismissible : false,
    builder            : (oContextoVentana) {
      return AlertDialog(
        title: Row(
          children: <Widget>[
            const Icon(Icons.info_outline, color: ClaseGenColores.colorAzulOscuro1),
            const SizedBox(width: ClaseGenEspacios.dEspacio08),
            Expanded(child: Text(sTitulo,
                        style: ClaseGenEstilosTexto.subtituloMediano(oContextoVentana))),
            IconButton(
              icon      : const Icon(Icons.close),
              onPressed : () => Navigator.of(oContextoVentana).pop(),
            ),
          ],
        ),
        content : Text(sMensaje, style: ClaseGenEstilosTexto.normalMediano(oContextoVentana)),
        actions : <Widget>[
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

}