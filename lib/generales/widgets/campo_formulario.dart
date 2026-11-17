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
    this.funcAlPerderFoco,
    required this.mapValores,
    required this.oCampo,
    this.oFocoExterno,
    required this.sIdioma,
    required this.sValor,
  });

  /// true para mover el foco a este campo al entrar en modo edición.
  final bool                                bAutoFocus;
  final bool                                bHabilitado;
  final void Function(String sValor)         funcAlCambiar;

  /// Transformación del valor al salir del campo (devuelve el valor nuevo
  /// o null si no cambia). Recibe la clave del campo, el valor actual y los
  /// valores internos del formulario. Ej: completar el guion y el dígito
  /// verificador del RUC ('8003214' → '8003214-5') al salir de la identificación.
  final String? Function(String sClave, String sValor, Map<String, String> mapValores)? funcAlPerderFoco;

  final Map<String, String>                  mapValores;
  final ClaseCampoAbm                        oCampo;

  /// Nodo de foco externo (item 14): permite al formulario colocar el foco
  /// en este campo cuando el grabado encuentra un error en él.
  final FocusNode?                           oFocoExterno;
  final String                               sIdioma;
  final String                               sValor;

  @override
  State<ClaseCampoFormulario> createState() => _ClaseEstadoCampoFormulario();
}

class _ClaseEstadoCampoFormulario extends State<ClaseCampoFormulario> {

  late TextEditingController oControl;
  final FocusNode oFocoInterno = FocusNode();
  String sMascaraActual = '';

  /// Máscaras de la fecha (99/99/9999) y de la hora (99:99): el usuario teclea solo dígitos y los separadores se insertan solos (spec 00_00_03).
  static const String _sMascaraFecha = '99/99/9999';
  static const String _sMascaraHora  = '99:99';

  /// Nodo de foco que usa el campo: el externo (item 14) si el formulario lo provee, o el propio. Se elige una sola vez en initState.
  late final FocusNode oFoco;

  @override
  void initState() {
    super.initState();
    oFoco = widget.oFocoExterno ?? oFocoInterno;
    oControl = TextEditingController(text: widget.sValor);
    oFoco.addListener(_alCambiarFoco);                       // ← CAMBIO item 9
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
      if (!oFoco.hasFocus) _mostrarNumeroFormateado();       // ← CAMBIO item 9
    }
    if (widget.bAutoFocus && !oldWidget.bAutoFocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) oFoco.requestFocus();
      });
    }
  }

  @override
  void dispose() {
    oFoco.removeListener(_alCambiarFoco);                    // ← CAMBIO item 9
    oControl.dispose();
    oFocoInterno.dispose();
    super.dispose();
  }

  // ── Máscara dinámica ─────────────────────────────────────────────────────

  String? _getMascara() {
    final String? sMascara = widget.oCampo.funcMascara?.call(widget.mapValores);
    return sMascara ?? widget.oCampo.sMascara;
  }

  // ── Entrada y salida del foco ────────────────────────────────────────────

  /// Al recibir el foco, los números con máscara muestran el valor plano
  /// (item 9). Al perderlo: los números se formatean según la máscara
  /// (item 9) y se ejecuta la transformación del campo (funcAlPerderFoco,
  /// ej: completar el guion y el dígito verificador del RUC).
  void _alCambiarFoco() {
    if (oFoco.hasFocus) {
      if (widget.oCampo.oTipo == EnumTipoCampoAbm.numero
          && _getMascara() != null
          && oControl.text != widget.sValor) {
        oControl.text = widget.sValor;
      }
      return;
    }
    _mostrarNumeroFormateado();
    // Completa la fecha u hora según lo que alcanzó a teclear el usuario.
    if (widget.oCampo.oTipo == EnumTipoCampoAbm.fecha) _completarFecha();
    if (widget.oCampo.oTipo == EnumTipoCampoAbm.hora)  _completarHora();
    // Muestra la ventana de error si la fecha u hora no es posible, pero
    // SOLO si el usuario se movió a otro campo de entrada. Si hizo clic en
    // un botón (Cancelar, Fin, Grabar, selector de fecha, borrar) — con o
    // sin foco, habilitado o deshabilitado — no se valida: termina o
    // descarta la edición, o corrige con un botón, y Grabar valida todo al
    // grabar. Se espera al próximo frame para saber dónde quedó el foco.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted)            return;
      if (oFoco.hasFocus)      return;
      if (!_focoEnOtroCampo()) return;
      _validarFechaHora();
    });

    // Transformación del campo al salir del foco (ej: completar el RUC).

    final String? sNuevo = widget.funcAlPerderFoco
        ?.call(widget.oCampo.sClave, widget.sValor, widget.mapValores);
    if (sNuevo != null && sNuevo != widget.sValor) {
      oControl.text = sNuevo;
      widget.funcAlCambiar(sNuevo);
    }
  }

  /// Muestra el número formateado según la máscara. Solo cambia el texto
  /// visible: el valor interno queda plano.
  void _mostrarNumeroFormateado() {
    if (widget.oCampo.oTipo != EnumTipoCampoAbm.numero) return;
    final String? sMascara = _getMascara();
    if (sMascara == null) return;
    final String sFormato = _formatearNumeroParaMostrar(widget.sValor, sMascara);
    if (sFormato != oControl.text) oControl.text = sFormato;
  }

  /// Formatea un valor plano según la máscara del campo. funcFormatearNumero
  /// espera la coma como separador decimal y el separador de miles sale de la
  /// propia máscara ('999.999.999' → '.').
  String _formatearNumeroParaMostrar(String sValor, String sMascara) {
    if (sValor.trim().isEmpty) return '';
    String sSeparadorMiles = '.';
    for (int i = 0; i < sMascara.length; i++) {
      if (sMascara[i] != '9') {
        sSeparadorMiles = sMascara[i];
        break;
      }
    }
    return funcFormatearNumero(sValor.replaceAll('.', ','), sMascara, sSeparadorMiles);
  }

  // ── Ancho del campo según máscara o cantidad de caracteres ──────────────

  // ── Ancho del campo ──────────────────────────────────────────────────────

  /// El ancho lo calcula ClaseCampoAbm.getAnchoCampo con la máscara efectiva
  /// (que puede ser dinámica, de funcMascara). Único punto de cambio.
  double _getAnchoCampo() =>
      widget.oCampo.getAnchoCampo(sMascaraEfectiva: _getMascara());

  // ── Decoración común de los controles ───────────────────────────────────

  /// Borde, padding interior generoso (objetivos táctiles cómodos para
  /// usuarios noveles) e hint. Un solo punto de cambio para todos los
  /// controles del campo.
  InputDecoration _getDecoracion({
    String? sHint,
    Widget? oIconoDerecha,
  }) {
    return InputDecoration(
      isDense        : true,
      hintText       : sHint,
      suffixIcon     : oIconoDerecha,
      border         : const OutlineInputBorder(),
      contentPadding : const EdgeInsets.symmetric(
        horizontal : ClaseGenEspacios.dEspacio12,
        vertical   : ClaseGenEspacios.dEspacio12,
      ),
    );
  }

  // ── Etiqueta del campo ──────────────────────────────────────────────────

  /// Etiqueta a la derecha, con asterisco rojo si el campo es obligatorio
  /// (item 4).
  Widget _construirEtiqueta(BuildContext oContexto) {
    return Text.rich(
      TextSpan(
        style : ClaseGenEstilosTexto.etiquetaCampo(oContexto),
        children: <InlineSpan>[
          TextSpan(text: widget.oCampo.sEtiqueta),
          if (widget.oCampo.bObligatorio)
            TextSpan(
              text  : ' *',
              style : ClaseGenEstilosTexto.etiquetaCampo(oContexto)
                          .copyWith(color: Theme.of(oContexto).colorScheme.error),
            ),
        ],
      ),
      textAlign : TextAlign.right,
    );
  }

  // ── Botón de borrar el contenido del campo ─────────────────────────────

  /// Muestra el botón de borrar solo si el campo está habilitado y tiene
  /// contenido (compartido por texto, fecha y hora).
  bool _getMostrarBorrarCampo() =>
      widget.bHabilitado && widget.sValor.isNotEmpty;

  Widget _construirBotonBorrarCampo() {
    return IconButton(
      tooltip   : ClaseIdiomas.getTexto('borrarCampo', widget.sIdioma),
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
  /// bConMascara=false para el comentario (sin máscara) y para los números
  /// (la máscara de números se aplica al salir del campo, item 9).
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

  // ── Máscara de la fecha y error de fecha/hora ────────────────────────────

  /// Máscara 99/99/9999: el usuario teclea solo dígitos y las barras se
  /// insertan solas mientras escribe (spec 00_00_03).
  void _alCambiarFecha(String sValor) {
    final String sDigitos    = sValor.replaceAll(RegExp(r'[^0-9]'), '');
    final String sConMascara = funcAplicarMascara(sDigitos, _sMascaraFecha);
    if (sConMascara != oControl.text) {
      oControl.value = TextEditingValue(
        text      : sConMascara,
        selection : TextSelection.collapsed(offset: sConMascara.length),
      );
    }
    widget.funcAlCambiar(sConMascara);
    // Con los 8 dígitos escritos se valida la fecha (29022026 → error).
    if (sDigitos.length >= 8) _validarFechaHora();
  }

  /// true si el widget del contexto es un botón (botonera ABM, iconos de
  /// los campos, botones de las ventanas), directa o indirectamente.
  static bool _esBoton(BuildContext oContexto) {
    if (oContexto.widget is ButtonStyleButton
        || oContexto.widget is IconButton) return true;
    bool bBoton = false;
    oContexto.visitAncestorElements((Element oElement) {
      if (oElement.widget is ButtonStyleButton
          || oElement.widget is IconButton) {
        bBoton = true;
        return false;
      }
      return true;
    });
    return bBoton;
  }

  /// true si el foco terminó en otro campo de entrada (otro campo del
  /// formulario o una celda de la grilla de detalles). Es la condición
  /// POSITIVA para validar al salir del campo: si el foco está en un
  /// botón, en una ventana o en ningún lugar, se devuelve false y no se
  /// valida (regla 00_00_03 y el criterio de que Cancelar/Fin/Grabar no
  /// deben interrumpirse con ventanas de validación).
  bool _focoEnOtroCampo() {
    final BuildContext? oContexto =
        FocusManager.instance.primaryFocus?.context;
    if (oContexto == null) return false;
    if (_esBoton(oContexto)) return false;
    final ClaseCampoFormulario? oCampo =
        oContexto.findAncestorWidgetOfExactType<ClaseCampoFormulario>();
    if (oCampo != null) return !identical(oCampo, widget);
    // Celda de la grilla de detalles u otra entrada de texto.
    return (oContexto.widget is EditableText)
        || (oContexto.findAncestorWidgetOfExactType<EditableText>() != null);
  }

  /// Muestra la ventana de error si la fecha u hora no es posible, no solo
  /// si no tiene el formato (spec 00_00_03: la ventana error es para avisar

  /// al usuario que se detectó un error). El campo vacío no se valida acá
  /// (lo obligatorio se controla al grabar).
  ///
  /// Regla 00_00_03 (Input focus): si se detectó un error, el foco se
  /// mantiene en el campo donde se detectó. La ventana de error se roba el
  /// foco, así que al cerrarla se vuelve a pedir el foco para este campo.
  Future<void> _validarFechaHora() async {
    if (!mounted) return;
    final String sValor = oControl.text.trim();
    if (sValor.isEmpty) return;
    final bool bFecha = (widget.oCampo.oTipo == EnumTipoCampoAbm.fecha);
    final bool bHora  = (widget.oCampo.oTipo == EnumTipoCampoAbm.hora);
    if (!bFecha && !bHora) return;
    final bool bValida = bFecha
        ? (funcParsearFecha(sValor) != null)
        : (funcParsearHora(sValor) != null);
    if (bValida) return;
    await funcMostrarError(
      context,
      widget.sIdioma,
      ClaseIdiomas.getTexto('aplicacion', widget.sIdioma),
      ClaseIdiomas.getTexto(
          bFecha ? 'validFechaInvalida' : 'validHoraInvalida', widget.sIdioma)
          .replaceAll('{0}', widget.oCampo.sEtiqueta),
    );
    if (mounted) oFoco.requestFocus();
  }

  // ── Fecha y hora inteligentes ────────────────────────────────────────────

  /// Completa la fecha según los dígitos que alcanzó a teclear el usuario.
  /// Se ejecuta al salir del campo o con Enter (para poder seguir tecleando
  /// sin que el campo se complete a mitad de camino):
  ///   16     → 16/mm/aaaa con el mes y el año actuales
  ///   127    → 12/07/aaaa: día de 2, mes de 1 dígito (07), año actual
  ///   1611   → 16/11/aaaa con el año actual
  ///   161126 → 16/11/2026: el año de 2 dígitos lleva "20" delante
  /// El año de 1 o 3 dígitos se completa igual: 2 → 2022, 026 → 2026.
  void _completarFecha() {
    final String sDigitos = oControl.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (sDigitos.isEmpty) return;
    final DateTime fHoy = DateTime.now();
    String sDia;
    String sMes;
    String sAno;
    if (sDigitos.length <= 2) {
      sDia = sDigitos.padLeft(2, '0');
      sMes = fHoy.month.toString().padLeft(2, '0');
      sAno = fHoy.year.toString();
    } else if (sDigitos.length == 3) {
      sDia = sDigitos.substring(0, 2);
      sMes = sDigitos.substring(2).padLeft(2, '0');
      sAno = fHoy.year.toString();
    } else if (sDigitos.length == 4) {
      sDia = sDigitos.substring(0, 2);
      sMes = sDigitos.substring(2, 4);
      sAno = fHoy.year.toString();
    } else {
      sDia = sDigitos.substring(0, 2);
      sMes = sDigitos.substring(2, 4);
      final String sAnoTecleado = (sDigitos.length > 8)
          ? sDigitos.substring(4, 8)
          : sDigitos.substring(4);
      sAno = (sAnoTecleado.length >= 4)
          ? sAnoTecleado
          : '202'.substring(0, 4 - sAnoTecleado.length) + sAnoTecleado;
    }
    final String sFecha = '$sDia/$sMes/$sAno';
    if (sFecha == oControl.text) return;
    oControl.value = TextEditingValue(
      text      : sFecha,
      selection : TextSelection.collapsed(offset: sFecha.length),
    );
    widget.funcAlCambiar(sFecha);
  }

  /// Completa la hora al salir del campo o con Enter: los minutos que
  /// faltan son 00 (16 → 16:00, 163 → 16:03).
  void _completarHora() {
    final String sDigitos = oControl.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (sDigitos.isEmpty) return;
    String sHora;
    if (sDigitos.length <= 2) {
      sHora = '${sDigitos.padLeft(2, '0')}:00';
    } else {
      final String sMinutos = (sDigitos.length > 4)
          ? sDigitos.substring(2, 4)
          : sDigitos.substring(2);
      sHora = '${sDigitos.substring(0, 2)}:${sMinutos.padLeft(2, '0')}';
    }
    if (sHora == oControl.text) return;
    oControl.value = TextEditingValue(
      text      : sHora,
      selection : TextSelection.collapsed(offset: sHora.length),
    );
    widget.funcAlCambiar(sHora);
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
              child : _construirEtiqueta(oContexto),          // ← CAMBIO item 4
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

    // Si hay máscara y cambió, re-aplicarla al valor actual. Solo texto:
    // el número se formatea al salir del campo (item 9).
    if (!bNumero && sMascara != null && sMascara != sMascaraActual) {
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
      onChanged       : (String sValor) =>
          _alCambiarTexto(sValor, bConMascara: !bNumero),    // ← CAMBIO item 9
      decoration      : _getDecoracion(
        sHint        : widget.oCampo.sHint,
        oIconoDerecha : _getMostrarBorrarCampo() ? _construirBotonBorrarCampo() : null,
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
    // Número: decimales o enteros. El límite de dígitos es el de la máscara
    // (el ancho visual incluye los separadores de miles).
    final String? sMascara = _getMascara();
    final int    iLimite   = (sMascara != null && !widget.oCampo.bTieneDecimales)
        ? sMascara.split('').where((String s) => s == '9').length
        : widget.oCampo.iAnchoCaracteres;
    return <TextInputFormatter>[
      if (widget.oCampo.bTieneDecimales)
        ClaseFormateadorImporte()
      else
        FilteringTextInputFormatter.digitsOnly,
      if (iLimite > 0)
        LengthLimitingTextInputFormatter(iLimite),
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
            onChanged    : _alCambiarFecha,
            onSubmitted  : (_) { _completarFecha(); _validarFechaHora(); },
            decoration   : _getDecoracion(sHint: 'dd/mm/aaaa'),
          ),
        ),
        const SizedBox(width: ClaseGenEspacios.dEspacio04),
        IconButton(
          tooltip   : ClaseIdiomas.getTexto('campoElegirFecha', widget.sIdioma),
          icon      : const Icon(Icons.calendar_month),
          onPressed : widget.bHabilitado
              ? () async {
                  final DateTime? fElegida = await funcMostrarSelectorFecha(
                    oContexto,
                    widget.sIdioma,
                    funcParsearFecha(widget.sValor) ?? DateTime.now(),
                    DateTime(ClaseFechas.iAnoMinimo, 1, 1),
                    DateTime(
                      widget.oCampo.bVigencia
                          ? ClaseFechas.getAnoMaximoVigencia()
                          : ClaseFechas.getAnoMaximo(),
                      12, 31),
                  );
                  if (fElegida != null) {
                    final String sFecha = funcFormatearFecha(fElegida);
                    oControl.text = sFecha;
                    widget.funcAlCambiar(sFecha);
                  }
                }
              : null,
        ),
        if (_getMostrarBorrarCampo()) _construirBotonBorrarCampo(),
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
            onSubmitted  : (_) { _completarHora(); _validarFechaHora(); },
            decoration   : _getDecoracion(sHint: 'hh:mm'),
          ),
        ),
        const SizedBox(width: ClaseGenEspacios.dEspacio04),
        IconButton(
          tooltip   : ClaseIdiomas.getTexto('campoElegirHora', widget.sIdioma),
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
        if (_getMostrarBorrarCampo()) _construirBotonBorrarCampo(),
      ],
    );
  }

  /// Normaliza la hora mientras se teclea: el valor interno siempre queda
  /// en formato hh:mm. El display solo se corrige cuando los minutos ya
  /// tienen 2 dígitos (hora completa), para no interrumpir al usuario.
  void _alCambiarHora(String sValor) {
    // Máscara 99:99: el usuario teclea solo dígitos y los dos puntos se
    // insertan solos (spec 00_00_03).
    final String sDigitos = sValor.replaceAll(RegExp(r'[^0-9]'), '');
    String sHora = funcAplicarMascara(sDigitos, _sMascaraHora);
    // Normaliza solo con los 4 dígitos escritos: mientras tanto '16:3' se
    // deja como está para poder seguir tecleando (1630 → 16:30). Con menos
    // dígitos la completación ocurre al perder el foco (_completarHora).
    if (sDigitos.length >= 4) {
      final int? iMinutos = funcParsearHora(sHora);
      if (iMinutos != null) {
        sHora = funcFormatearHora(iMinutos ~/ 60, iMinutos % 60);
      }
    }
    if (sHora != oControl.text) {
      oControl.value = TextEditingValue(
        text      : sHora,
        selection : TextSelection.collapsed(offset: sHora.length),
      );
    }
    widget.funcAlCambiar(sHora);
    // Con los 4 dígitos escritos se valida la hora (1630 → 16:30 o error).
    if (sDigitos.length >= 4) _validarFechaHora();
  }

  // ── Lista (dropdown) ─────────────────────────────────────────────────────

  Widget _construirLista(BuildContext oContexto) {
    final List<String> listOpciones = widget.oCampo.listOpciones ?? <String>[];
    final List<String> listValores  = widget.oCampo.listValores  ?? listOpciones;
    return DropdownButtonFormField<String>(
      key          : ValueKey<String>('${widget.oCampo.sClave}_${widget.sValor}'),
      initialValue : listValores.contains(widget.sValor) ? widget.sValor : null,
      isExpanded   : true,
      // ← CAMBIO item 7: tipografía monoespaciada también en las listas.
      style        : ClaseGenEstilosTexto.textoCampo(oContexto),
      decoration   : _getDecoracion(),
      items: <DropdownMenuItem<String>>[
        for (int i = 0; i < listOpciones.length; i++)
          DropdownMenuItem<String>(
            value : listValores[i],
            child : Text(listOpciones[i],
                style: ClaseGenEstilosTexto.textoCampo(oContexto)),
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
  // Varios valores seleccionados se guardan separados por comas, en el orden
  // de listValores (ej: 'FAC,NCR'). Un valor vacío = ninguna casilla marcada.

  Widget _construirCasillas(BuildContext oContexto) {
    final List<String> listOpciones = widget.oCampo.listOpciones ?? <String>[];
    final List<String> listValores  = widget.oCampo.listValores  ?? listOpciones;
    final List<String> listMarcados = widget.sValor.trim().isEmpty
        ? <String>[]
        : widget.sValor.trim().split(',');
    return Wrap(
      spacing    : ClaseGenEspacios.dEspacio16,
      runSpacing : ClaseGenEspacios.dEspacio04,
      children: <Widget>[
        for (int i = 0; i < listOpciones.length; i++)
          Row(
            mainAxisSize : MainAxisSize.min,
            children     : <Widget>[
              Checkbox(
                value    : listMarcados.contains(listValores[i]),
                onChanged: widget.bHabilitado
                    ? (bool? bMarcado) {
                        final Set<String> setNuevos = listMarcados.toSet();
                        if (bMarcado == true) {
                          setNuevos.add(listValores[i]);
                        } else {
                          setNuevos.remove(listValores[i]);
                        }
                        widget.funcAlCambiar(listValores
                            .where((String s) => setNuevos.contains(s))
                            .join(','));
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
    return Column(
      crossAxisAlignment : CrossAxisAlignment.stretch,
      children: <Widget>[
        // ← CAMBIO item 5: contador de caracteres a la derecha, en la misma
        //   fila que la etiqueta.
        if (widget.oCampo.iMaxComentario > 0)
          Padding(
            padding : const EdgeInsets.only(
              top   : ClaseGenEspacios.dEspacio14,
              right : ClaseGenEspacios.dEspacio04,
            ),
            child : Text(
              '${widget.sValor.length}/${widget.oCampo.iMaxComentario}',
              textAlign : TextAlign.right,
              style     : ClaseGenEstilosTexto.normalChico(oContexto),
            ),
          ),
        TextField(
          controller      : oControl,
          enabled         : widget.bHabilitado,
          focusNode       : oFoco,
          maxLines        : 3,
          style           : ClaseGenEstilosTexto.textoCampo(oContexto),
          // El comentario respeta iMaxComentario (antes solo lo mostraba).
          inputFormatters : (widget.oCampo.iMaxComentario > 0)
              ? <TextInputFormatter>[
                  LengthLimitingTextInputFormatter(widget.oCampo.iMaxComentario),
                ]
              : null,
          onChanged       : (String sValor) => _alCambiarTexto(sValor, bConMascara: false),
          decoration      : _getDecoracion(sHint: widget.oCampo.sHint),
        ),
      ],
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
              ? ClaseIdiomas.getTexto('si', widget.sIdioma)
              : ClaseIdiomas.getTexto('no', widget.sIdioma),
          style : ClaseGenEstilosTexto.normalMediano(oContexto),
        ),
      ],
    );
  }

}
