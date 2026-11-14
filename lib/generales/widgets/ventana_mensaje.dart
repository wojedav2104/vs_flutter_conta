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

/// Muestra un mensaje modal con un botón Aceptar.
/// Los textos llegan traducidos desde la pantalla; sIdioma se usa para los
/// textos fijos del diálogo (tooltip de la X).
Future<void> funcMostrarMensaje(
  BuildContext oContexto,
  String        sIdioma,
  String        sTitulo,
  String        sTexto,
  String        sAceptar,
  int           iAnchoColumnas,
) async {
  await showDialog<void>(
    context            : oContexto,
    barrierDismissible : false,
    builder            : (oContextoDialogo) {
      return AlertDialog(
        title: Row(
          children: <Widget>[
            Expanded(
              child: Text(sTitulo,
                  style: ClaseGenEstilosTexto.subtituloMediano(oContextoDialogo)),
            ),
            IconButton(
              tooltip   : ClaseIdiomas.getTexto(sIdioma, 'cerrar'),
              icon      : const Icon(Icons.close),
              onPressed : () => Navigator.of(oContextoDialogo).pop(),
            ),
          ],
        ),
        content: SizedBox(
          width : iAnchoColumnas * ClaseGenLayout.dAnchoCaracter,
          child : Text(sTexto,
              style: ClaseGenEstilosTexto.normalMediano(oContextoDialogo)),
        ),
        actions: <Widget>[
          FilledButton.icon(
            onPressed : () => Navigator.of(oContextoDialogo).pop(),
            icon      : const Icon(Icons.check),
            label     : Text(sAceptar,
                style: ClaseGenEstilosTexto.normalMediano(oContextoDialogo)),
          ),
        ],
      );
    },
  );
}

/// Muestra el selector de fecha y devuelve la fecha elegida (o null si se
/// cancela). La fecha inicial se formatea como dd/mm/aaaa.
/// Si la fecha inicial está fuera del rango, se ofrece el extremo más cercano.
Future<DateTime?> funcMostrarSelectorFecha(
  BuildContext oContexto,
  String        sIdioma,
  DateTime      fFecha,
  DateTime      fPrimeraFecha,
  DateTime      fUltimaFecha,
) async {
  DateTime fInicial = fFecha;
  if (fInicial.isBefore(fPrimeraFecha)) fInicial = fPrimeraFecha;
  if (fInicial.isAfter(fUltimaFecha))   fInicial = fUltimaFecha;
  return showDatePicker(
    context      : oContexto,
    locale       : Locale(sIdioma),
    initialDate  : fInicial,
    firstDate    : fPrimeraFecha,
    lastDate     : fUltimaFecha,
  );
}

/// Muestra el selector de hora (formato 24 horas) y devuelve los minutos
/// contados desde las 00:00 (o null si se cancela).
/// Si la hora actual no es válida, se ofrece la hora del sistema.
Future<int?> funcMostrarSelectorHora(
  BuildContext oContexto,
  String        sIdioma,
  String        sHora,
) async {
  final int? iMinutos = funcParsearHora(sHora);
  final TimeOfDay fInicial = (iMinutos != null)
      ? TimeOfDay(hour: iMinutos ~/ 60, minute: iMinutos % 60)
      : TimeOfDay.now();
  final TimeOfDay? fElegida = await showTimePicker(
    context     : oContexto,
    initialTime : fInicial,
    builder     : (oContextoDialogo, oHijo) => MediaQuery(
      data: MediaQuery.of(oContextoDialogo)
              .copyWith(alwaysUse24HourFormat: true),
      child: oHijo!,
    ),
  );
  return (fElegida == null) ? null : fElegida.hour * 60 + fElegida.minute;
}


/// Muestra una pregunta de confirmación con dos botones y devuelve true si
/// se presiona el botón aceptar.
Future<bool> funcMostrarConfirmar(
  BuildContext oContexto,
  String        sIdioma,
  String        sTitulo,
  String        sTexto,
  String        sAceptar,
  String        sCancelar,
  int           iAnchoColumnas,
) async {
  bool bAceptar = false;
  await showDialog<void>(
    context            : oContexto,
    barrierDismissible : false,
    builder            : (oContextoDialogo) {
      return AlertDialog(
        title: Row(
          children: <Widget>[
            Expanded(
              child: Text(sTitulo,
                  style: ClaseGenEstilosTexto.subtituloMediano(oContextoDialogo)),
            ),
            IconButton(
              tooltip   : ClaseIdiomas.getTexto(sIdioma, 'cerrar'),
              icon      : const Icon(Icons.close),
              onPressed : () => Navigator.of(oContextoDialogo).pop(),
            ),
          ],
        ),
        content: SizedBox(
          width : iAnchoColumnas * ClaseGenLayout.dAnchoCaracter,
          child : Text(sTexto,
              style: ClaseGenEstilosTexto.normalMediano(oContextoDialogo)),
        ),
        actions: <Widget>[
          OutlinedButton.icon(
            onPressed : () => Navigator.of(oContextoDialogo).pop(),
            icon      : const Icon(Icons.cancel_outlined),
            label     : Text(sCancelar,
                style: ClaseGenEstilosTexto.normalMediano(oContextoDialogo)),
          ),
          FilledButton.icon(
            onPressed : () {
              bAceptar = true;
              Navigator.of(oContextoDialogo).pop();
            },
            icon      : const Icon(Icons.check),
            label     : Text(sAceptar,
                style: ClaseGenEstilosTexto.normalMediano(oContextoDialogo)),
          ),
        ],
      );
    },
  );
  return bAceptar;
}



