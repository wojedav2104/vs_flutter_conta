import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../idiomas/idiomas.dart';
import '../modelos/campo_abm.dart';
import '../temas/espacios.dart';
import '../temas/estilos_textos.dart';
import '../temas/layout.dart';
import '../utilitarios/formatos.dart';
import '../varios/listas.dart';
import 'ventana_mensaje.dart';

/// Admite dígitos y, como máximo, un separador decimal (',' o '.').
class ClaseFormateadorImporte extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oViejo, TextEditingValue oNuevo) {
    final StringBuffer oSalida = StringBuffer();
    int iSeparadores = 0;
    for (int i = 0; i < oNuevo.text.length; i++) {
      final String c = oNuevo.text[i];
      if (RegExp(r'[0-9]').hasMatch(c)) {
        oSalida.write(c);
      } else if ((c == ',' || c == '.') && iSeparadores == 0) {
        iSeparadores++;
        oSalida.write(c);
      }
    }
    final String sFinal = oSalida.toString();
    return TextEditingValue(
      text      : sFinal,
      selection : TextSelection.collapsed(offset: sFinal.length),
    );
  }
}


/// Campo individual de un formulario ABM: etiqueta + control de entrada.
///
/// Cada campo renderiza según su tipo (texto, número, fecha, hora, lista,
/// casillas, comentario, lógico). El texto visible se traduce con ClaseIdiomas;
/// el valor interno es el código que se guarda en el registro.
class ClaseCampoFormulario extends StatefulWidget {

  const ClaseCampoFormulario({
    super.key,
    this.bAutoFocus = false,
    required this.bHabilitado,
    required this.funcAlCambiar,
    required this.mapValores,
    required this.oCampo,
    required this.sIdioma,
    required this.sValor,
  });

  /// true para mover el foco a este campo al entrar en modo edición.
  final bool                                bAutoFocus;
  final bool                                bHabilitado;
  final void Function(String sValor)         funcAlCambiar;
  final Map<String, String>                  mapValores;
  final ClaseCampoAbm                        oCampo;
  final String                               sIdioma;
  final String                               sValor;

  @override
  State<ClaseCampoFormulario> createState() => _ClaseEstadoCampoFormulario();
}

class _ClaseEstadoCampoFormulario extends State<ClaseCampoFormulario> {

  late TextEditingController oControl;
  final FocusNode oFoco = FocusNode();
  String sMascaraActual = '';

  @override
  void initState() {
    super.initState();
    oControl = TextEditingController(text: widget.sValor);
    if (widget.bAutoFocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) oFoco.requestFocus();
      });
    }
  }

  @override
  void didUpdateWidget(covariant ClaseCampoFormulario oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.sValor != widget.sValor && oControl.text != widget.sValor) {
      oControl.text = widget.sValor;
    }
    if (widget.bAutoFocus && !oldWidget.bAutoFocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) oFoco.requestFocus();
      });
    }
  }

  @override
  void dispose() {
    oControl.dispose();
    oFoco.dispose();
    super.dispose();
  }

  // ── Máscara dinámica ─────────────────────────────────────────────────────

  String? _getMascara() {
    final String? sMascara = widget.oCampo.funcMascara?.call(widget.mapValores);
    return sMascara ?? widget.oCampo.sMascara;
  }

  // ── Ancho del campo según máscara o cantidad de caracteres ──────────────

  double _getAnchoCampo() {
    final String? sMascara = _getMascara();
    final int iCaracteres = (sMascara != null)
        ? sMascara.length
        : widget.oCampo.iAnchoCaracteres;
    switch (widget.oCampo.oTipo) {
      case EnumTipoCampoAbm.comentario:
        return ClaseGenLayout.dAnchoCampoComentario;
      case EnumTipoCampoAbm.casillas:
      case EnumTipoCampoAbm.lista:
        return iCaracteres * ClaseGenLayout.dAnchoCaracter
             + ClaseGenLayout.dAnchoIconoFlecha;
      case EnumTipoCampoAbm.fecha:
      case EnumTipoCampoAbm.hora:
        return iCaracteres * ClaseGenLayout.dAnchoCaracter
             + ClaseGenEspacios.dEspacio24
             + ClaseGenLayout.dAnchoIconoBorrar
             + ClaseGenLayout.dAnchoIconoFlecha;
      default:
        return iCaracteres * ClaseGenLayout.dAnchoCaracter
             + ClaseGenEspacios.dEspacio24
             + ClaseGenLayout.dAnchoIconoBorrar;
    }
  }

  // ── Decoración común de los controles ───────────────────────────────────

  /// Borde, padding interior generoso (objetivos táctiles cómodos para
  /// usuarios noveles) e hint. Un solo punto de cambio para todos los
  /// controles del campo.
  InputDecoration _getDecoracion({
    String? sHint,
    Widget? oIconoDerecha,
    String? sContador,
  }) {
    return InputDecoration(
      isDense        : true,
      hintText       : sHint,
      suffixIcon     : oIconoDerecha,
      counterText    : sContador,
      border         : const OutlineInputBorder(),
      contentPadding : const EdgeInsets.symmetric(
        horizontal : ClaseGenEspacios.dEspacio12,
        vertical   : ClaseGenEspacios.dEspacio12,
      ),
    );
  }

  // ── Botón de borrar el contenido del campo ─────────────────────────────

  /// Compartido por texto, fecha y hora (antes duplicado en los tres).
  bool get _bMostrarBorrarCampo =>
      widget.bHabilitado && widget.sValor.isNotEmpty;

  Widget _construirBotonBorrarCampo() {
    return IconButton(
      tooltip   : ClaseIdiomas.getTexto(widget.sIdioma, 'borrarCampo'),
      icon      : const Icon(Icons.close, size: 18),
      onPressed : () {
        oControl.text = '';
        widget.funcAlCambiar('');
      },
    );
  }

  // ── Mayúsculas y máscara al cambiar el valor ───────────────────────────

  /// Conversión a mayúsculas y aplicación de la máscara (si existe);
  /// actualiza el display solo si el valor cambió.
  /// bConMascara=false para el comentario (sin máscara).
  void _alCambiarTexto(String sValor, {bool bConMascara = true}) {
    String sSalida = sValor;
    if (widget.oCampo.bMayusculas) {
      sSalida = sValor.toUpperCase();
      if (sSalida != oControl.text) {
        oControl.value = TextEditingValue(
          text      : sSalida,
          selection : TextSelection.collapsed(offset: sSalida.length),
        );
      }
    }
    if (bConMascara) {
      final String? sMascaraNueva = _getMascara();
      if (sMascaraNueva != null) {
        final String sDigitos = sSalida.replaceAll(RegExp(r'[^0-9]'), '');
        final String sConMascara = funcAplicarMascara(sDigitos, sMascaraNueva);
        if (sConMascara != sSalida) {
          sSalida = sConMascara;
          oControl.value = TextEditingValue(
            text      : sSalida,
            selection : TextSelection.collapsed(offset: sSalida.length),
          );
        }
      }
    }
    widget.funcAlCambiar(sSalida);
  }

  // ── Construcción de la interfaz ──────────────────────────────────────────

  @override
  Widget build(BuildContext oContexto) {
    return Padding(
      padding : const EdgeInsets.only(bottom: ClaseGenEspacios.dEspacio12),
      child   : Row(
        crossAxisAlignment : CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width : ClaseGenLayout.dAnchoEtiquetaCampo,
            child : Padding(
              padding : const EdgeInsets.only(
                top   : ClaseGenEspacios.dEspacio14,
                right : ClaseGenEspacios.dEspacio04,
              ),
              child : Text(
                widget.oCampo.sEtiqueta,
                textAlign : TextAlign.right,
                style     : ClaseGenEstilosTexto.etiquetaCampo(oContexto),
              ),
            ),
          ),
          SizedBox(
            width : _getAnchoCampo(),
            child : _construirControl(oContexto),
          ),
        ],
      ),
    );
  }

  Widget _construirControl(BuildContext oContexto) {
    switch (widget.oCampo.oTipo) {
      case EnumTipoCampoAbm.casillas:
        return _construirCasillas(oContexto);
      case EnumTipoCampoAbm.comentario:
        return _construirComentario(oContexto);
      case EnumTipoCampoAbm.fecha:
        return _construirFecha(oContexto);
      case EnumTipoCampoAbm.hora:
        return _construirHora(oContexto);
      case EnumTipoCampoAbm.lista:
        return _construirLista(oContexto);
      case EnumTipoCampoAbm.logico:
        return _construirLogico(oContexto);
      case EnumTipoCampoAbm.numero:
        return _construirTexto(oContexto, bNumero: true);
      case EnumTipoCampoAbm.texto:
        return _construirTexto(oContexto);
    }
  }

  // ── Texto y número ──────────────────────────────────────────────────────

  Widget _construirTexto(BuildContext oContexto, {bool bNumero = false}) {

    final String? sMascara = _getMascara();

    // Si hay máscara y cambió, re-aplicarla al valor actual.
    if (sMascara != null && sMascara != sMascaraActual) {
      sMascaraActual = sMascara;
      final String sDigitos = widget.sValor.replaceAll(RegExp(r'[^0-9]'), '');
      final String sConMascara = funcAplicarMascara(sDigitos, sMascara);
      if (sConMascara != widget.sValor) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            oControl.text = sConMascara;
            widget.funcAlCambiar(sConMascara);
          }
        });
      }
    }

    return TextField(
      controller      : oControl,
      enabled         : widget.bHabilitado,
      focusNode       : oFoco,
      style           : ClaseGenEstilosTexto.textoCampo(oContexto),
      textAlign       : bNumero ? TextAlign.right : TextAlign.left,
      keyboardType    : bNumero
          ? (widget.oCampo.bTieneDecimales
              ? const TextInputType.numberWithOptions(decimal: true)
              : TextInputType.number)
          : null,
      inputFormatters : _getFormateadores(bNumero),
      onChanged       : (String sValor) => _alCambiarTexto(sValor),
      decoration      : _getDecoracion(
        sHint        : widget.oCampo.sHint,
        oIconoDerecha : _bMostrarBorrarCampo ? _construirBotonBorrarCampo() : null,
      ),
    );
  }

  List<TextInputFormatter>? _getFormateadores(bool bNumero) {
    if (!bNumero) {
      return widget.oCampo.iAnchoCaracteres > 0
          ? <TextInputFormatter>[
              LengthLimitingTextInputFormatter(widget.oCampo.iAnchoCaracteres),
            ]
          : null;
    }
    // Número: decimales o enteros.
    return <TextInputFormatter>[
      if (widget.oCampo.bTieneDecimales)
        ClaseFormateadorImporte()
      else
        FilteringTextInputFormatter.digitsOnly,
      if (widget.oCampo.iAnchoCaracteres > 0)
        LengthLimitingTextInputFormatter(widget.oCampo.iAnchoCaracteres),
    ];
  }

  // ── Fecha ────────────────────────────────────────────────────────────────

  Widget _construirFecha(BuildContext oContexto) {
    return Row(
      children: <Widget>[
        Expanded(
          child: TextField(
            controller   : oControl,
            enabled      : widget.bHabilitado,
            focusNode    : oFoco,
            style        : ClaseGenEstilosTexto.textoCampo(oContexto),
            keyboardType : TextInputType.datetime,
            onChanged    : (String sValor) => widget.funcAlCambiar(sValor),
            decoration   : _getDecoracion(sHint: 'dd/mm/aaaa'),
          ),
        ),
        const SizedBox(width: ClaseGenEspacios.dEspacio04),
        IconButton(
          tooltip   : ClaseIdiomas.getTexto(widget.sIdioma, 'campoElegirFecha'),
          icon      : const Icon(Icons.calendar_month),
          onPressed : widget.bHabilitado
              ? () async {
                  final DateTime? fElegida = await funcMostrarSelectorFecha(
                    oContexto,
                    widget.sIdioma,
                    funcParsearFecha(widget.sValor) ?? DateTime.now(),
                    DateTime(ClaseFechas.iAnioMinimo, 1, 1),
                    DateTime(ClaseFechas.iAnioMaximo, 12, 31),
                  );
                  if (fElegida != null) {
                    final String sFecha = funcFormatearFecha(fElegida);
                    oControl.text = sFecha;
                    widget.funcAlCambiar(sFecha);
                  }
                }
              : null,
        ),
        if (_bMostrarBorrarCampo) _construirBotonBorrarCampo(),
      ],
    );
  }

  // ── Hora ─────────────────────────────────────────────────────────────────

  Widget _construirHora(BuildContext oContexto) {
    return Row(
      children: <Widget>[
        Expanded(
          child: TextField(
            controller   : oControl,
            enabled      : widget.bHabilitado,
            focusNode    : oFoco,
            style        : ClaseGenEstilosTexto.textoCampo(oContexto),
            keyboardType : TextInputType.datetime,
            onChanged    : _alCambiarHora,
            onSubmitted  : (_) => _normalizarHora(),
            decoration   : _getDecoracion(sHint: 'hh:mm'),
          ),
        ),
        const SizedBox(width: ClaseGenEspacios.dEspacio04),
        IconButton(
          tooltip   : ClaseIdiomas.getTexto(widget.sIdioma, 'campoElegirHora'),
          icon      : const Icon(Icons.schedule),
          onPressed : widget.bHabilitado
              ? () async {
                  final int? iMinutos = await funcMostrarSelectorHora(
                    oContexto,
                    widget.sIdioma,
                    widget.sValor,
                  );
                  if (iMinutos != null) {
                    final String sHora = funcFormatearHora(iMinutos ~/ 60, iMinutos % 60);
                    oControl.text = sHora;
                    widget.funcAlCambiar(sHora);
                  }
                }
              : null,
        ),
        if (_bMostrarBorrarCampo) _construirBotonBorrarCampo(),
      ],
    );
  }

  /// Normaliza la hora mientras se teclea: el valor interno siempre queda
  /// en formato hh:mm. El display solo se corrige cuando los minutos ya
  /// tienen 2 dígitos (hora completa), para no interrumpir al usuario.
  void _alCambiarHora(String sValor) {
    final int? iMinutos = funcParsearHora(sValor);
    final String sHora = (iMinutos != null)
        ? funcFormatearHora(iMinutos ~/ 60, iMinutos % 60)
        : sValor;
    widget.funcAlCambiar(sHora);
    if (sHora != oControl.text && RegExp(r':\d{2}$').hasMatch(sValor.trim())) {
      oControl.value = TextEditingValue(
        text      : sHora,
        selection : TextSelection.collapsed(offset: sHora.length),
      );
    }
  }

  /// Normaliza el display al confirmar (Enter): rellena con ceros.
  /// Ej: '1:30' → '01:30', '12:5' → '12:05', '9:8' → '09:08'.
  void _normalizarHora() {
    final int? iMinutos = funcParsearHora(oControl.text);
    if (iMinutos != null) {
      final String sHora = funcFormatearHora(iMinutos ~/ 60, iMinutos % 60);
      if (sHora != oControl.text) {
        oControl.text = sHora;
        widget.funcAlCambiar(sHora);
      }
    }
  }

  // ── Lista (dropdown) ─────────────────────────────────────────────────────

  Widget _construirLista(BuildContext oContexto) {
    final List<String> listOpciones = widget.oCampo.listOpciones ?? <String>[];
    final List<String> listValores  = widget.oCampo.listValores  ?? listOpciones;
    return DropdownButtonFormField<String>(
      key          : ValueKey<String>('${widget.oCampo.sClave}_${widget.sValor}'),
      initialValue : listValores.contains(widget.sValor) ? widget.sValor : null,
      isExpanded   : true,
      decoration   : _getDecoracion(),
      items: <DropdownMenuItem<String>>[
        for (int i = 0; i < listOpciones.length; i++)
          DropdownMenuItem<String>(
            value : listValores[i],
            child : Text(listOpciones[i], style: ClaseGenEstilosTexto.normalMediano(oContexto)),
          ),
      ],
      onChanged: widget.bHabilitado
          ? (String? sNuevo) {
              if (sNuevo != null) widget.funcAlCambiar(sNuevo);
            }
          : null,
    );
  }

  // ── Casillas (checkboxes múltiples) ──────────────────────────────────────

  Widget _construirCasillas(BuildContext oContexto) {
    final List<String> listOpciones = widget.oCampo.listOpciones ?? <String>[];
    final List<String> listValores  = widget.oCampo.listValores  ?? listOpciones;
    final String sValorActual = widget.sValor;
    return Wrap(
      spacing  : ClaseGenEspacios.dEspacio16,
      runSpacing : ClaseGenEspacios.dEspacio04,
      children: <Widget>[
        for (int i = 0; i < listOpciones.length; i++)
          Row(
            mainAxisSize : MainAxisSize.min,
            children     : <Widget>[
              Checkbox(
                value    : sValorActual == listValores[i],
                onChanged: widget.bHabilitado
                    ? (bool? bMarcado) {
                        widget.funcAlCambiar(bMarcado == true ? listValores[i] : '');
                      }
                    : null,
              ),
              Text(listOpciones[i], style: ClaseGenEstilosTexto.normalMediano(oContexto)),
            ],
          ),
      ],
    );
  }

  // ── Comentario (textarea) ────────────────────────────────────────────────

  Widget _construirComentario(BuildContext oContexto) {
    return TextField(
      controller      : oControl,
      enabled         : widget.bHabilitado,
      focusNode       : oFoco,
      maxLines        : 3,
      style           : ClaseGenEstilosTexto.textoCampo(oContexto),
      // El comentario ahora respeta iMaxComentario (antes solo lo mostraba).
      inputFormatters : (widget.oCampo.iMaxComentario > 0)
          ? <TextInputFormatter>[
              LengthLimitingTextInputFormatter(widget.oCampo.iMaxComentario),
            ]
          : null,
      onChanged       : (String sValor) => _alCambiarTexto(sValor, bConMascara: false),
      decoration      : _getDecoracion(
        sHint     : widget.oCampo.sHint,
        sContador : '${widget.sValor.length}/${widget.oCampo.iMaxComentario}',
      ),
    );
  }

  // ── Lógico (switch Sí/No) ────────────────────────────────────────────────

  Widget _construirLogico(BuildContext oContexto) {
    final bool bActivo = widget.sValor == ClaseSiNo.si;
    return Row(
      children: <Widget>[
        Switch(
          value    : bActivo,
          onChanged: widget.bHabilitado
              ? (bool bNuevo) => widget.funcAlCambiar(bNuevo ? ClaseSiNo.si : ClaseSiNo.no)
              : null,
        ),
        const SizedBox(width: ClaseGenEspacios.dEspacio08),
        Text(
          bActivo
              ? ClaseIdiomas.getTexto(widget.sIdioma, 'si')
              : ClaseIdiomas.getTexto(widget.sIdioma, 'no'),
          style : ClaseGenEstilosTexto.normalMediano(oContexto),
        ),
      ],
    );
  }

}
