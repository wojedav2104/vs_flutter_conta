import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../idiomas/idiomas.dart';
import '../modelos/campo_abm.dart';
import '../temas/espacios.dart';
import '../temas/estilos_textos.dart';
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
    required this.bHabilitado,
    required this.funcAlCambiar,
    required this.mapValores,
    required this.oCampo,
    required this.sIdioma,
    required this.sValor,
  });

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
  String sMascaraActual = '';

  @override
  void initState() {
    super.initState();
    oControl = TextEditingController(text: widget.sValor);
  }

  @override
  void didUpdateWidget(covariant ClaseCampoFormulario oAntiguo) {
    super.didUpdateWidget(oAntiguo);
    if (oAntiguo.sValor != widget.sValor && oControl.text != widget.sValor) {
      oControl.text = widget.sValor;
    }
  }

  @override
  void dispose() {
    oControl.dispose();
    super.dispose();
  }

  // ── Máscara dinámica ─────────────────────────────────────────────────────

  String? _getMascara() {
    final String? sMascara = widget.oCampo.funcMascara?.call(widget.mapValores);
    return sMascara ?? widget.oCampo.sMascara;
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
            width : 220,
            child : Padding(
              padding : const EdgeInsets.only(top: ClaseGenEspacios.dEspacio14),
              child   : Text(
                widget.oCampo.sEtiqueta,
                style : ClaseGenEstilosTexto.etiquetaCampo(oContexto),
              ),
            ),
          ),
          const SizedBox(width: ClaseGenEspacios.dEspacio12),
          Expanded(child: _construirControl(oContexto)),
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
      style           : ClaseGenEstilosTexto.textoCampo(oContexto),
      textAlign       : bNumero ? TextAlign.right : TextAlign.left,
      inputFormatters : _getFormateadores(bNumero),
      onChanged       : (String sValor) {
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
        // Aplicar máscara dinámica si existe.
        final String? sMascaraActual = _getMascara();
        if (sMascaraActual != null) {
          final String sDigitos = sSalida.replaceAll(RegExp(r'[^0-9]'), '');
          final String sConMascara = funcAplicarMascara(sDigitos, sMascaraActual);
          if (sConMascara != sSalida) {
            sSalida = sConMascara;
            oControl.value = TextEditingValue(
              text      : sSalida,
              selection : TextSelection.collapsed(offset: sSalida.length),
            );
          }
        }
        widget.funcAlCambiar(sSalida);
      },
      decoration : InputDecoration(
        isDense    : true,
        hintText   : widget.oCampo.sHint,
        border     : const OutlineInputBorder(),
        suffixIcon : widget.bHabilitado && widget.sValor.isNotEmpty
            ? IconButton(
                tooltip   : ClaseIdiomas.getTexto(widget.sIdioma, 'borrarCampo'),
                icon      : const Icon(Icons.close, size: 18),
                onPressed : () {
                  oControl.text = '';
                  widget.funcAlCambiar('');
                },
              )
            : null,
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
            controller : oControl,
            enabled    : widget.bHabilitado,
            style      : ClaseGenEstilosTexto.textoCampo(oContexto),
            onChanged  : (String sValor) => widget.funcAlCambiar(sValor),
            decoration : InputDecoration(
              isDense    : true,
              hintText   : 'dd/mm/aaaa',
              border     : const OutlineInputBorder(),
            ),
          ),
        ),
        const SizedBox(width: ClaseGenEspacios.dEspacio04),
        IconButton(
          tooltip   : ClaseIdiomas.getTexto(widget.sIdioma, 'elegirFecha'),
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
        if (widget.bHabilitado && widget.sValor.isNotEmpty)
          IconButton(
            tooltip   : ClaseIdiomas.getTexto(widget.sIdioma, 'borrarCampo'),
            icon      : const Icon(Icons.close, size: 18),
            onPressed : () {
              oControl.text = '';
              widget.funcAlCambiar('');
            },
          ),
      ],
    );
  }

  // ── Hora ─────────────────────────────────────────────────────────────────

  Widget _construirHora(BuildContext oContexto) {
    return Row(
      children: <Widget>[
        Expanded(
          child: TextField(
            controller : oControl,
            enabled    : widget.bHabilitado,
            style      : ClaseGenEstilosTexto.textoCampo(oContexto),
            onChanged  : (String sValor) => widget.funcAlCambiar(sValor),
            decoration : InputDecoration(
              isDense    : true,
              hintText   : 'hh:mm',
              border     : const OutlineInputBorder(),
            ),
          ),
        ),
        const SizedBox(width: ClaseGenEspacios.dEspacio04),
        IconButton(
          tooltip   : ClaseIdiomas.getTexto(widget.sIdioma, 'elegirHora'),
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
        if (widget.bHabilitado && widget.sValor.isNotEmpty)
          IconButton(
            tooltip   : ClaseIdiomas.getTexto(widget.sIdioma, 'borrarCampo'),
            icon      : const Icon(Icons.close, size: 18),
            onPressed : () {
              oControl.text = '';
              widget.funcAlCambiar('');
            },
          ),
      ],
    );
  }

  // ── Lista (dropdown) ─────────────────────────────────────────────────────

  Widget _construirLista(BuildContext oContexto) {
    final List<String> listOpciones = widget.oCampo.listOpciones ?? <String>[];
    final List<String> listValores  = widget.oCampo.listValores  ?? listOpciones;
    return DropdownButtonFormField<String>(
      key          : ValueKey<String>('${widget.oCampo.sClave}_${widget.sValor}'),
      initialValue : listValores.contains(widget.sValor) ? widget.sValor : null,
      isExpanded   : true,
      decoration   : const InputDecoration(isDense: true, border: OutlineInputBorder()),
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
      controller    : oControl,
      enabled       : widget.bHabilitado,
      maxLines      : 3,
      style         : ClaseGenEstilosTexto.textoCampo(oContexto),
      onChanged     : (String sValor) {
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
        widget.funcAlCambiar(sSalida);
      },
      decoration    : InputDecoration(
        isDense     : true,
        hintText    : widget.oCampo.sHint,
        border      : const OutlineInputBorder(),
        counterText : '${widget.sValor.length}/${widget.oCampo.iMaxComentario}',
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
