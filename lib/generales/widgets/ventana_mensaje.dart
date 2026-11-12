import 'package:flutter/material.dart';

import '../idiomas/idiomas.dart';
import '../temas/colores.dart';
import '../temas/espacios.dart';
import '../temas/estilos_textos.dart';

import '../utilitarios/formatos.dart';


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


  /// Muestra el selector de fecha y devuelve dd/mm/aaaa, o null si cancela.
  Future<String?> funcMostrarSelectorFecha(BuildContext oContexto, String sValorActual) async {
    DateTime fInicial = DateTime.now();
    final DateTime? fParseada = funcParsearFecha(sValorActual);
    if (fParseada != null) fInicial = fParseada;
    final DateTime? fFecha = await showDatePicker(
      context    : oContexto,
      initialDate: fInicial,
      firstDate  : DateTime(2020, 1, 1),
      lastDate   : DateTime(2100, 12, 31),
    );
    if (fFecha == null) return null;
    return '${fFecha.day.toString().padLeft(2, '0')}/'
           '${fFecha.month.toString().padLeft(2, '0')}/'
           '${fFecha.year}';
}

  /// Muestra el selector de hora y devuelve hh:mm, o null si cancela.
  Future<String?> funcMostrarSelectorHora(BuildContext oContexto, String sValorActual) async {
    TimeOfDay oHoraInicial = TimeOfDay.now();
    final List<String> listPartes = sValorActual.trim().split(':');
    if (listPartes.length == 2) {
      final int? iH = int.tryParse(listPartes[0]);
      final int? iM = int.tryParse(listPartes[1]);
      if (iH != null && iM != null) oHoraInicial = TimeOfDay(hour: iH, minute: iM);
    }
    final TimeOfDay? oHora = await showTimePicker(
      context      : oContexto,
      initialTime  : oHoraInicial,
    );
    if (oHora == null) return null;
    return '${oHora.hour.toString().padLeft(2, '0')}:'
           '${oHora.minute.toString().padLeft(2, '0')}';
  }

  