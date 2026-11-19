import 'dart:async';

import 'package:flutter/material.dart';

import '../idiomas/idiomas.dart';
import '../temas/espacios.dart';
import '../temas/estilos_textos.dart';
import '../temas/layout.dart';
import '../temas/temas.dart';
import '../utilitarios/formatos.dart';


/// Respuesta de la ventana de confirmación.
enum EnumRespuestaConfirmacion { si, no, cancelar }


/// Ventanas popup de la aplicación (documento 00-00):
///
///   · funcMostrarAdvertencia  — algo puede ser potencialmente peligroso.
///   · funcMostrarConfirmacion — pregunta con los botones Sí, No y Cancelar;
///     cada botón se muestra u oculta según bMostrarSi, bMostrarNo y
///     bMostrarCancelar.
///   · funcMostrarError        — se detectó un error.
///   · funcMostrarInformacion  — informar algo al usuario.
///
/// Todas las ventanas muestran un icono que las identifica. Los colores
/// provienen de temas.dart / Theme.of (regla de colores del proyecto) y los
/// textos de los botones se traducen con ClaseIdiomas.getTexto.
///
/// También viven aquí los selectores de fecha y de hora.

// ── Ventana advertencia ─────────────────────────────────────────────────────

Future<void> funcMostrarAdvertencia(
  BuildContext oContexto,
  String        sIdioma,
  String        sTitulo,
  String        sTexto,
) async {
  await showDialog<void>(
    context            : oContexto,
    barrierDismissible : false,
    builder            : (BuildContext oContextoVentana) {
      return funcConstruirVentana(
        oContexto    : oContextoVentana,
        sIdioma      : sIdioma,
        sTitulo      : sTitulo,
        sTexto       : sTexto,
        oIcono       : Icons.warning_amber_rounded,
        colorIcono   : ClaseGenTemas.colorIconoAdvertencia(oContextoVentana),
        listAcciones : <Widget>[funcConstruirBotonAceptar(oContextoVentana, sIdioma)],
      );
    },
  );
}

// ── Ventana confirmación ────────────────────────────────────────────────────

/// Pregunta de confirmación con los botones Sí, No y Cancelar (el código
/// decide cuáles se muestran). Devuelve la respuesta del usuario; si se
/// cierra sin elegir (botón X o tecla Atrás) se considera Cancelar.
Future<EnumRespuestaConfirmacion> funcMostrarConfirmacion(
  BuildContext oContexto,
  String        sIdioma,
  String        sTitulo,
  String        sTexto, {
  bool bMostrarSi       = true,
  bool bMostrarNo       = true,
  bool bMostrarCancelar = true,
}) async {
  final EnumRespuestaConfirmacion? oRespuesta =
      await showDialog<EnumRespuestaConfirmacion>(
    context            : oContexto,
    barrierDismissible : false,
    builder            : (BuildContext oContextoVentana) {
      return funcConstruirVentana(
        oContexto    : oContextoVentana,
        sIdioma      : sIdioma,
        sTitulo      : sTitulo,
        sTexto       : sTexto,
        oIcono       : Icons.help_outline,
        colorIcono   : Theme.of(oContextoVentana).colorScheme.primary,
        listAcciones : <Widget>[
          if (bMostrarCancelar)
            funcConstruirBoton(
              oContexto : oContextoVentana,
              sTexto    : ClaseIdiomas.getTexto('cancelar', sIdioma),
              oIcono    : Icons.cancel_outlined,
              bRelleno  : false,
              oAlClicar : () => Navigator.of(oContextoVentana)
                  .pop(EnumRespuestaConfirmacion.cancelar),
            ),
          if (bMostrarNo)
            funcConstruirBoton(
              oContexto : oContextoVentana,
              sTexto    : ClaseIdiomas.getTexto('no', sIdioma),
              oIcono    : Icons.close,
              bRelleno  : false,
              oAlClicar : () => Navigator.of(oContextoVentana)
                  .pop(EnumRespuestaConfirmacion.no),
            ),
          if (bMostrarSi)
            funcConstruirBoton(
              oContexto : oContextoVentana,
              sTexto    : ClaseIdiomas.getTexto('si', sIdioma),
              oIcono    : Icons.check,
              oAlClicar : () => Navigator.of(oContextoVentana)
                  .pop(EnumRespuestaConfirmacion.si),
            ),
        ],
      );
    },
  );
  return oRespuesta ?? EnumRespuestaConfirmacion.cancelar;
}

// ── Ventana error ───────────────────────────────────────────────────────────

Future<void> funcMostrarError(
  BuildContext oContexto,
  String        sIdioma,
  String        sTitulo,
  String        sTexto,
) async {
  await showDialog<void>(
    context            : oContexto,
    barrierDismissible : false,
    builder            : (BuildContext oContextoVentana) {
      return funcConstruirVentana(
        oContexto    : oContextoVentana,
        sIdioma      : sIdioma,
        sTitulo      : sTitulo,
        sTexto       : sTexto,
        oIcono       : Icons.error_outline,
        colorIcono   : Theme.of(oContextoVentana).colorScheme.error,
        listAcciones : <Widget>[funcConstruirBotonAceptar(oContextoVentana, sIdioma)],
      );
    },
  );
}

// ── Ventana información ─────────────────────────────────────────────────────

Future<void> funcMostrarInformacion(
  BuildContext oContexto,
  String        sIdioma,
  String        sTitulo,
  String        sTexto, {
  int iSegundosAutoCierre = 0,
}) async {
  // Contexto de la ventana abierta: lo usa el temporizador para cerrarla y
  // para saber si el usuario ya la cerró a mano (mounted == false).
  BuildContext? oContextoVentanaAbierta;
  final Future<void> oVentana = showDialog<void>(
    context            : oContexto,
    barrierDismissible : false,
    builder            : (BuildContext oContextoVentana) {
      oContextoVentanaAbierta = oContextoVentana;
      return funcConstruirVentana(
        oContexto    : oContextoVentana,
        sIdioma      : sIdioma,
        sTitulo      : sTitulo,
        sTexto       : sTexto,
        oIcono       : Icons.info_outline,
        colorIcono   : Theme.of(oContextoVentana).colorScheme.primary,
        listAcciones : <Widget>[funcConstruirBotonAceptar(oContextoVentana, sIdioma)],
      );
    },
  );
  // Regla UI/UX: cierre automático de las ventanas informativas. Si el
  // usuario no la cierra (Aceptar o "X"), se cierra sola luego de
  // iSegundosAutoCierre. Si la cierra antes, se cancela el temporizador.
  Timer? oTemporizador;
  if (iSegundosAutoCierre > 0) {
    oTemporizador = Timer(Duration(seconds: iSegundosAutoCierre), () {
      if (oContextoVentanaAbierta?.mounted == true) {
        Navigator.of(oContextoVentanaAbierta!).pop();
      }
    });
  }
  await oVentana;
  oTemporizador?.cancel();
}

// ── Piezas compartidas (uso interno de este archivo) ────────────────────────

/// Cuerpo común de las ventanas: icono identificatorio, título, botón X para
/// cerrar y el texto del mensaje.
Widget funcConstruirVentana({
  required BuildContext oContexto,
  required String       sIdioma,
  required String       sTitulo,
  required String       sTexto,
  required IconData     oIcono,
  required Color        colorIcono,
  required List<Widget> listAcciones,
}) {
  return AlertDialog(
    title: Row(
      children: <Widget>[
        Icon(oIcono, color: colorIcono, size: ClaseGenLayout.dTamanoIconoVentana),
        const SizedBox(width: ClaseGenEspacios.dEspacio08),
        Expanded(
          child: Text(sTitulo, style: ClaseGenEstilosTexto.subtituloMediano(oContexto)),
        ),
        IconButton(
          tooltip   : ClaseIdiomas.getTexto('cerrar', sIdioma),
          icon      : const Icon(Icons.close),
          onPressed : () => Navigator.of(oContexto).pop(),
        ),
      ],
    ),
    content: SizedBox(
      width : ClaseGenLayout.iAnchoColumnasMensaje * ClaseGenLayout.dAnchoCaracter,
      child : Text(sTexto, style: ClaseGenEstilosTexto.normalMediano(oContexto)),
    ),
    actions: listAcciones,
  );
}

/// Botón con icono a la izquierda (regla 00-00). bRelleno=false para los
/// botones secundarios (No, Cancelar).
Widget funcConstruirBoton({
  required BuildContext oContexto,
  required String       sTexto,
  required IconData     oIcono,
  required VoidCallback oAlClicar,
  bool                  bRelleno = true,
}) {
  final TextStyle oEstilo = ClaseGenEstilosTexto.normalMediano(oContexto);
  return bRelleno
      ? FilledButton.icon(
          onPressed : oAlClicar,
          icon      : Icon(oIcono),
          label     : Text(sTexto, style: oEstilo),
        )
      : OutlinedButton.icon(
          onPressed : oAlClicar,
          icon      : Icon(oIcono),
          label     : Text(sTexto, style: oEstilo),
        );
}

/// Botón Aceptar estándar de las ventanas advertencia, error e información.
Widget funcConstruirBotonAceptar(BuildContext oContexto, String sIdioma) {
  return funcConstruirBoton(
    oContexto : oContexto,
    sTexto    : ClaseIdiomas.getTexto('aceptar', sIdioma),
    oIcono    : Icons.check,
    oAlClicar : () => Navigator.of(oContexto).pop(),
  );
}

// ── Selectores de fecha y de hora (sin cambios) ─────────────────────────────

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

// ── Ventana de entrada de texto (ej: e-mail de recuperación) ────────────────

/// Pide un texto al usuario (campo único). Devuelve el texto escrito
/// (recortado) o null si se cancela o se cierra la ventana.
Future<String?> funcMostrarPedirTexto(
  BuildContext oContexto,
  String        sIdioma,
  String        sTitulo,
  String        sTexto,
  String        sEtiquetaCampo, {
  bool bMostrarCancelar = true,
}) async {
  final TextEditingController oControl = TextEditingController();
  final String? sAccion = await showDialog<String>(
    context            : oContexto,
    barrierDismissible : false,
    builder            : (BuildContext oContextoVentana) {
      return AlertDialog(
        title: Row(
          children: <Widget>[
            Icon(Icons.edit_outlined,
                 color: Theme.of(oContextoVentana).colorScheme.primary,
                 size : ClaseGenLayout.dTamanoIconoVentana),
            const SizedBox(width: ClaseGenEspacios.dEspacio08),
            Expanded(
              child: Text(sTitulo,
                  style: ClaseGenEstilosTexto.subtituloMediano(oContextoVentana)),
            ),
            IconButton(
              tooltip   : ClaseIdiomas.getTexto('cerrar', sIdioma),
              icon      : const Icon(Icons.close),
              onPressed : () => Navigator.of(oContextoVentana).pop(),
            ),
          ],
        ),
        content: SizedBox(
          width : ClaseGenLayout.iAnchoColumnasMensaje * ClaseGenLayout.dAnchoCaracter,
          child : Column(
            mainAxisSize : MainAxisSize.min,
            crossAxisAlignment : CrossAxisAlignment.start,
            children: <Widget>[
              Text(sTexto,
                  style: ClaseGenEstilosTexto.normalMediano(oContextoVentana)),
              const SizedBox(height: ClaseGenEspacios.dEspacio16),
              TextField(
                controller   : oControl,
                autofocus    : true,
                keyboardType : TextInputType.emailAddress,
                style        : ClaseGenEstilosTexto.textoCampo(oContextoVentana),
                decoration   : InputDecoration(
                  labelText : sEtiquetaCampo,
                  border    : const OutlineInputBorder(),
                ),
                onSubmitted : (String sValor) =>
                    Navigator.of(oContextoVentana).pop('aceptar'),
              ),
            ],
          ),
        ),
        actions: <Widget>[
          if (bMostrarCancelar)
            funcConstruirBoton(
              oContexto : oContextoVentana,
              sTexto    : ClaseIdiomas.getTexto('cancelar', sIdioma),
              oIcono    : Icons.cancel_outlined,
              bRelleno  : false,
              oAlClicar : () => Navigator.of(oContextoVentana).pop(),
            ),
          funcConstruirBoton(
            oContexto : oContextoVentana,
            sTexto    : ClaseIdiomas.getTexto('aceptar', sIdioma),
            oIcono    : Icons.check,
            oAlClicar : () => Navigator.of(oContextoVentana).pop('aceptar'),
          ),
        ],
      );
    },
  );
  final String sTextoIngresado = oControl.text.trim();
  oControl.dispose();
  return (sAccion == null) ? null : sTextoIngresado;
}

