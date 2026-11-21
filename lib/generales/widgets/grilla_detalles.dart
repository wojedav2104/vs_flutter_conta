import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vs_conta/generales/widgets/campo_formulario.dart';

import '../idiomas/idiomas.dart';
import '../modelos/campo_abm.dart';
import '../temas/espacios.dart';
import '../temas/estilos_textos.dart';
import '../temas/layout.dart';
import '../temas/radios.dart';
import '../temas/temas.dart';
import '../utilitarios/formatos.dart';

/// Grilla editable de detalles de ClaseFormularioCabeceraDetalle: encabezado
/// fijo arriba, filas editables con acciones (subir, bajar y borrar), fila de
/// totales con el botón "Agregar fila" a la izquierda, y el campo de la
/// cabecera al pie (ej: el Comentarios).
///
/// Regla UI/UX: el encabezado, las filas y la fila de totales comparten el
/// mismo desplazamiento horizontal; las columnas expansibles (Concepto)
/// absorben el sobrante de ancho de la ventana.
class ClaseGrillaDetalles extends StatelessWidget {

  const ClaseGrillaDetalles({
    super.key,
    required this.bModoEdicion,
    required this.funcAgregarFila,
    required this.funcAlCambiarFila,
    required this.funcBorrarFila,
    required this.funcBajarFila,
    required this.funcSubirFila,
    required this.listCamposDetalle,
    required this.listControles,
    required this.listDetalles,
    this.oPie,
    required this.sFormatoNumeros,
    required this.sIdioma,
  });

  /// true mientras se edita el registro: habilita celdas y acciones.
  final bool bModoEdicion;

  /// Acciones de las filas; el resto del estado vive en el formulario padre.
  final VoidCallback                                     funcAgregarFila;
  final void Function(int iFila, String sClave, String sValor) funcAlCambiarFila;
  final void Function(int iFila)                         funcBorrarFila;
  final void Function(int iFila)                         funcBajarFila;
  final void Function(int iFila)                         funcSubirFila;

  /// Columnas de la grilla de detalles (una por campo).
  final List<ClaseCampoAbm> listCamposDetalle;

  /// Un control por celda, para conservar el cursor y actualizar valores
  /// derivados (ej: el nombre de la cuenta).
  final List<Map<String, TextEditingController>> listControles;

  /// Filas de detalle que se están editando (valores internos).
  final List<Map<String, String>> listDetalles;

  /// Campo de la cabecera que se muestra debajo de la fila de totales (ej:
  /// el Comentarios); null si el formulario no tiene campo al pie.
  final Widget? oPie;

  /// Formo de números de las preferencias del usuario (latino/francés).
  final String sFormatoNumeros;
  final String sIdioma;

  @override
  Widget build(BuildContext oContexto) {
    return _construirDetalle(oContexto);
  }

  // ── Grilla editable de detalles ──────────────────────────────────────────

  double _getAnchoDetalle() {
    double dAncho = ClaseGenLayout.dAnchoNumeroFila + ClaseGenLayout.dAnchoAccionesFila;
    for (final ClaseCampoAbm oCampo in listCamposDetalle) {
      dAncho += oCampo.getAnchoColumna();
    }
    return dAncho;
  }

  /// Anchos efectivos de las columnas de la grilla de detalles: el ancho base
  /// de cada campo más el espacio sobrante de la ventana, repartido entre las
  /// columnas expansibles (ej: Concepto). Así, al contraer la grilla lateral,
  /// la columna Concepto se ensancha y se ven más caracteres (regla UI/UX).
  List<double> _listAnchosColumnas(BoxConstraints oLimites) {
    final List<double> listAnchos = <double>[
      for (final ClaseCampoAbm oCampo in listCamposDetalle)
        oCampo.getAnchoColumna(),
    ];
    final double dSobrante = oLimites.maxWidth
        - (_getAnchoDetalle() + ClaseGenEspacios.dEspacio08 * 2);
    if (dSobrante <= 0) return listAnchos;
    final List<int> listExpansible = <int>[
      for (int i = 0; i < listCamposDetalle.length; i++)
        if (listCamposDetalle[i].bColumnaExpansible) i,
    ];
    if (listExpansible.isEmpty) return listAnchos;
    final double dExtra = dSobrante / listExpansible.length;
    for (final int i in listExpansible) {
      listAnchos[i] += dExtra;
    }
    return listAnchos;
  }

  Widget _construirDetalle(BuildContext oContexto) {
    // Regla UI/UX: el encabezado, las filas y la fila de totales comparten
    // el mismo desplazamiento horizontal: las columnas quedan siempre
    // alineadas, el encabezado queda fijo arriba y la fila de totales no
    // desborda el ancho de la pantalla. Con LayoutBuilder, las columnas
    // expansibles (Concepto) absorben el sobrante de la ventana.
    return LayoutBuilder(
      builder: (oContexto, oLimites) {
        final List<double> listAnchos = _listAnchosColumnas(oLimites);
        double dAnchoTotal =
            ClaseGenLayout.dAnchoNumeroFila + ClaseGenLayout.dAnchoAccionesFila;
        for (final double dAncho in listAnchos) {
          dAnchoTotal += dAncho;
        }
        return Column(
          crossAxisAlignment : CrossAxisAlignment.stretch,
          children: <Widget>[
            Expanded(
              child: SingleChildScrollView(
                scrollDirection : Axis.horizontal,
                child: SizedBox(
                  // El padding horizontal de las filas (dEspacio08 por lado) forma
                  // parte del ancho total de la grilla: sin estas dos columnas, la
                  // fila desborda 16 px a la derecha (rayas de OVERFLOW).
                  width : dAnchoTotal + ClaseGenEspacios.dEspacio08 * 2,
                  child : Column(
                    crossAxisAlignment : CrossAxisAlignment.stretch,
                    children: <Widget>[
                      _construirFilaEncabezado(oContexto, listAnchos),
                      Expanded(
                        child: ListView(
                          children: <Widget>[
                            for (int i = 0; i < listDetalles.length; i++)
                              _construirFilaDetalle(oContexto, i, listAnchos),
                          ],
                        ),
                      ),
                      _construirFilaTotales(oContexto, listAnchos),
                    ],
                  ),
                ),
              ),
            ),
            oPie ?? const SizedBox.shrink(),
          ],
        );
      },
    );
  }

  /// Alineación del texto de una columna (encabezado y fila de totales):
  /// la misma que la de sus celdas, resuelta por getAlineacion (números a
  /// la derecha, resto a la izquierda; regla 24 de 00_03_02_ABMs.txt).
  TextAlign _getTextAlignColumna(ClaseCampoAbm oCampo) {
    switch (oCampo.getAlineacion()) {
      case EnumAlineacion.centro:
        return TextAlign.center;
      case EnumAlineacion.derecha:
        return TextAlign.right;
      case EnumAlineacion.izquierda:
        return TextAlign.left;
    }
  }

  /// Padding del texto dentro de una columna (encabezado y fila de totales):
  /// el mismo que el de los valores de sus celdas (el padding de la fila más
  /// el borde y el padding interior del control), para que el valor quede
  /// alineado con su encabezado y los nombres de las columnas vecinas nunca
  /// se peguen (regla 24).
  EdgeInsets _getPaddingColumna() {
    return EdgeInsets.only(
      left  : ClaseGenLayout.dAnchoBordeCampo + ClaseGenEspacios.dEspacio08,
      right : ClaseGenEspacios.dEspacio04 + ClaseGenLayout.dAnchoBordeCampo
              + ClaseGenEspacios.dEspacio08,
    );
  }

  Widget _construirFilaEncabezado(BuildContext oContexto, List<double> listAnchos) {
    // Regla UI/UX: mismos colores de encabezado que la grilla lateral de
    // los ABM (backcolor del tema + texto en negritas).
    return Container(
      color   : ClaseGenTemas.colorFondoEncabezadoGrilla(oContexto),
      padding : const EdgeInsets.symmetric(
        horizontal : ClaseGenEspacios.dEspacio08,
        vertical   : ClaseGenEspacios.dEspacio04,
      ),
      child: Row(
        children: <Widget>[
          SizedBox(
            width : ClaseGenLayout.dAnchoNumeroFila,
            child : Text(ClaseIdiomas.getTexto('detFila', sIdioma),
                style: ClaseGenEstilosTexto.encabezadoGrillaDetalle(oContexto).copyWith(
                    color: ClaseGenTemas.colorTextoEncabezadoGrilla(oContexto))),
          ),
          for (int i = 0; i < listCamposDetalle.length; i++)
            SizedBox(
              width : listAnchos[i],
              child : Padding(
                padding : _getPaddingColumna(),
                child   : Text(listCamposDetalle[i].sEtiqueta,
                    style    : ClaseGenEstilosTexto.encabezadoGrillaDetalle(oContexto).copyWith(
                                 color: ClaseGenTemas.colorTextoEncabezadoGrilla(oContexto)),
                    textAlign: _getTextAlignColumna(listCamposDetalle[i]),
                    maxLines : 1,
                    overflow : TextOverflow.ellipsis),
              ),
            ),
          const SizedBox(width: ClaseGenLayout.dAnchoAccionesFila),
        ],
      ),
    );
  }

  Widget _construirFilaDetalle(BuildContext oContexto, int iFila, List<double> listAnchos) {
    return Padding(
      padding : const EdgeInsets.symmetric(
        horizontal : ClaseGenEspacios.dEspacio08,
        vertical   : ClaseGenEspacios.dEspacio02 / 3,   // separación entre filas: 1/3 de la actual
      ),
      child: Row(
        children: <Widget>[
          SizedBox(
            width : ClaseGenLayout.dAnchoNumeroFila,
            child : Text('${iFila + 1}',
                style: ClaseGenEstilosTexto.normalChico(oContexto)),
          ),
          for (int i = 0; i < listCamposDetalle.length; i++)
            SizedBox(
              width : listAnchos[i],
              child : Padding(
                padding : const EdgeInsets.only(right: ClaseGenEspacios.dEspacio04),
                child   : _construirCelda(oContexto, iFila, listCamposDetalle[i]),
              ),
            ),
          SizedBox(
            width : ClaseGenLayout.dAnchoAccionesFila,
            child : Row(
              mainAxisSize : MainAxisSize.min,
              children     : <Widget>[
                IconButton(
                  visualDensity : VisualDensity.compact,
                  tooltip   : ClaseIdiomas.getTexto('menuSubirFila', sIdioma),
                  icon      : const Icon(Icons.keyboard_arrow_up, size: 18),
                  onPressed : (bModoEdicion && iFila > 0)
                      ? () => funcSubirFila(iFila)
                      : null,
                ),
                IconButton(
                  visualDensity : VisualDensity.compact,
                  tooltip   : ClaseIdiomas.getTexto('menuBajarFila', sIdioma),
                  icon      : const Icon(Icons.keyboard_arrow_down, size: 18),
                  onPressed : (bModoEdicion && iFila < listDetalles.length - 1)
                      ? () => funcBajarFila(iFila)
                      : null,
                ),
                IconButton(
                  visualDensity : VisualDensity.compact,
                  tooltip   : ClaseIdiomas.getTexto('detBorrarFila', sIdioma),
                  icon      : const Icon(Icons.delete_outline, size: 18),
                  onPressed : bModoEdicion ? () => funcBorrarFila(iFila) : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _construirCelda(BuildContext oContexto, int iFila, ClaseCampoAbm oCampo) {
    final String sValor = listDetalles[iFila][oCampo.sClave] ?? '';
    final bool bHabilitado = bModoEdicion
        && !oCampo.bSiempreDeshabilitado
        && !oCampo.bSoloLecturaPorRol;
    switch (oCampo.oTipo) {
      case EnumTipoCampoAbm.lista:
        final List<String> listOpciones = oCampo.listOpciones ?? <String>[];
        final List<String> listValores  = oCampo.listValores  ?? listOpciones;
        return DropdownButtonFormField<String>(
          key          : ValueKey<String>('${oCampo.sClave}_${iFila}_$sValor'),
          initialValue : listValores.contains(sValor) ? sValor : null,
          isExpanded   : true,
          style        : bHabilitado
              ? ClaseGenEstilosTexto.textoCampo(oContexto).copyWith(
                  color: ClaseGenTemas.colorTextoCampoHabilitado(oContexto))
              : ClaseGenEstilosTexto.textoCampo(oContexto),
          decoration   : InputDecoration(
            isDense   : true,
            filled    : true,
            fillColor : bHabilitado
                ? ClaseGenTemas.colorFondoCampoHabilitado(oContexto)
                : ClaseGenTemas.colorFondoCampoDeshabilitado(oContexto),
            contentPadding : const EdgeInsets.symmetric(
              horizontal : ClaseGenEspacios.dEspacio08,
              vertical   : ClaseGenEspacios.dEspacio08,
            ),
            border    : const OutlineInputBorder(),
          ),
          items: <DropdownMenuItem<String>>[
            for (int i = 0; i < listOpciones.length; i++)
              DropdownMenuItem<String>(
                value : listValores[i],
                child : Text(listOpciones[i],
                    style: ClaseGenEstilosTexto.textoCampo(oContexto)),
              ),
          ],
          onChanged: bHabilitado
              ? (String? sNuevo) => funcAlCambiarFila(iFila, oCampo.sClave, sNuevo ?? '')
              : null,
        );
      case EnumTipoCampoAbm.numero:
        return ClaseCeldaNumero(
          bHabilitado   : bHabilitado,
          funcAlCambiar : (String sValor) => funcAlCambiarFila(iFila, oCampo.sClave, sValor),
          oCampo        : oCampo,
          oControl      : listControles[iFila][oCampo.sClave]!,
          sValor        : sValor,
        );
      default:
        return TextField(
          controller      : listControles[iFila][oCampo.sClave],
          enabled         : bHabilitado,
          style           : bHabilitado
              ? ClaseGenEstilosTexto.textoCampo(oContexto).copyWith(
                  color: ClaseGenTemas.colorTextoCampoHabilitado(oContexto))
              : ClaseGenEstilosTexto.textoCampo(oContexto),
          inputFormatters : (oCampo.iAnchoCaracteres > 0)
              ? <TextInputFormatter>[LengthLimitingTextInputFormatter(oCampo.iAnchoCaracteres)]
              : null,
          onChanged       : (String sValor) => funcAlCambiarFila(iFila, oCampo.sClave, sValor),
          decoration      : InputDecoration(
            isDense   : true,
            filled    : true,
            fillColor : bHabilitado
                ? ClaseGenTemas.colorFondoCampoHabilitado(oContexto)
                : ClaseGenTemas.colorFondoCampoDeshabilitado(oContexto),
            contentPadding : const EdgeInsets.symmetric(
              horizontal : ClaseGenEspacios.dEspacio08,
              vertical   : ClaseGenEspacios.dEspacio08,
            ),
            border    : const OutlineInputBorder(),
          ),
        );
    }
  }

  Widget _construirFilaTotales(BuildContext oContexto, List<double> listAnchos) {

    // Sumas de las columnas numéricas.
    final Map<String, double> mapSumas = <String, double>{};
    for (final ClaseCampoAbm oCampo in listCamposDetalle) {
      if (oCampo.oTipo != EnumTipoCampoAbm.numero) continue;
      double dSuma = 0;
      for (final Map<String, String> mapFila in listDetalles) {
        dSuma += funcParsearNumero(mapFila[oCampo.sClave] ?? '') ?? 0;
      }
      mapSumas[oCampo.sClave] = dSuma;
    }

    // El rótulo TOTALES va en la columna previa a la primera numérica.
    int iPrimeraSuma = -1;
    for (int i = 0; i < listCamposDetalle.length; i++) {
      if (listCamposDetalle[i].oTipo == EnumTipoCampoAbm.numero) {
        iPrimeraSuma = i;
        break;
      }
    }
    final int iRotulo = (iPrimeraSuma > 0)
        ? iPrimeraSuma - 1
        : listCamposDetalle.length - 1;

    // Regla UI/UX: el botón Agregar fila ocupa el ancho de las columnas
    // previas al rótulo (quedan vacías en la fila de totales) y así se
    // muestra a la izquierda de la grilla, en la misma fila que TOTALES.
    double dAnchoIzquierda = ClaseGenLayout.dAnchoNumeroFila;
    for (int i = 0; i < iRotulo; i++) {
      dAnchoIzquierda += listAnchos[i];
    }

    // Regla UI/UX: la suma de las columnas numéricas (Debe, Haber) es un
    // resultado de suma: se muestra en negritas y con un relleno distinto
    // al de los datos sumados.
    final TextStyle oEstilo =
        ClaseGenEstilosTexto.textoDestacado(oContexto).copyWith(
            fontWeight: FontWeight.bold);

    return Container(
      color   : ClaseGenTemas.colorFondoCampoTotal(oContexto),
      padding : const EdgeInsets.symmetric(
        horizontal : ClaseGenEspacios.dEspacio08,
        vertical   : ClaseGenEspacios.dEspacio04,
      ),
      child: Row(
        children: <Widget>[
          SizedBox(
            width : dAnchoIzquierda,
            child : Align(
              alignment : Alignment.centerLeft,
              // Regla UI/UX: el botón usa el estilo de los botones ABM
              // (fondo resaltado, texto blanco) para distinguirse del fondo
              // de la fila de totales; gris cuando está deshabilitado y
              // amarillo cuando tiene el foco del teclado.
              child     : ElevatedButton.icon(
                onPressed : bModoEdicion ? funcAgregarFila : null,
                icon      : const Icon(Icons.add),
                style     : ElevatedButton.styleFrom(
                  disabledBackgroundColor : ClaseGenTemas.colorBotonDeshabilitado(oContexto),
                  disabledForegroundColor : ClaseGenTemas.colorTextoBotonDeshabilitado(oContexto),
                  shape  : RoundedRectangleBorder(
                    borderRadius : BorderRadius.circular(ClaseGenRadios.dPequeno),
                  ),
                ).copyWith(
                  backgroundColor : WidgetStateProperty.resolveWith<Color>(
                    (Set<WidgetState> setEstados) {
                      if (setEstados.contains(WidgetState.focused)) {
                        return ClaseGenTemas.colorBotonConFoco(oContexto);
                      }
                      if (setEstados.contains(WidgetState.disabled)) {
                        return ClaseGenTemas.colorBotonDeshabilitado(oContexto);
                      }
                      return ClaseGenTemas.colorBotonHabilitado(oContexto);
                    },
                  ),
                  foregroundColor : WidgetStateProperty.resolveWith<Color>(
                    (Set<WidgetState> setEstados) {
                      if (setEstados.contains(WidgetState.focused)) {
                        return ClaseGenTemas.colorTextoBotonConFoco(oContexto);
                      }
                      if (setEstados.contains(WidgetState.disabled)) {
                        return ClaseGenTemas.colorTextoBotonDeshabilitado(oContexto);
                      }
                      return ClaseGenTemas.colorTextoBotonHabilitado(oContexto);
                    },
                  ),
                ),
                label     : Text(ClaseIdiomas.getTexto('detAgregarFila', sIdioma),
                    style: ClaseGenEstilosTexto.normalMediano(oContexto)),
              ),
            ),
          ),
          for (int i = iRotulo; i < listCamposDetalle.length; i++)
            SizedBox(
              width : listAnchos[i],
              child : Padding(
                padding : _getPaddingColumna(),
                child   : Text(
                  (i == iRotulo)
                      ? ClaseIdiomas.getTexto('detTotales', sIdioma)
                      : ((i == iPrimeraSuma || mapSumas
                              .containsKey(listCamposDetalle[i].sClave))
                          ? funcFormatearImporte(
                              mapSumas[listCamposDetalle[i].sClave] ?? 0, sFormatoNumeros)
                          : ''),
                  style     : oEstilo,
                  textAlign : TextAlign.right,
                ),
              ),
            ),
          const SizedBox(width: ClaseGenLayout.dAnchoAccionesFila),
        ],
      ),
    );
  }

}

/// Celda numérica de la grilla de detalles: guarda el valor plano y lo
/// muestra formateado con la máscara cuando pierde el foco (regla 9).
class ClaseCeldaNumero extends StatefulWidget {
  const ClaseCeldaNumero({
    required this.bHabilitado,
    required this.funcAlCambiar,
    required this.oCampo,
    required this.oControl,
    required this.sValor,
  });

  final bool                         bHabilitado;
  final void Function(String sValor) funcAlCambiar;
  final ClaseCampoAbm                oCampo;
  final TextEditingController        oControl;
  final String                       sValor;

  @override
  State<ClaseCeldaNumero> createState() => ClaseEstadoCeldaNumero();
}

class ClaseEstadoCeldaNumero extends State<ClaseCeldaNumero> {

  final FocusNode oFoco = FocusNode();

  @override
  void initState() {
    super.initState();
    oFoco.addListener(_alCambiarFoco);
    // Regla UI/UX: la celda muestra el número formateado desde el primer
    // momento; el valor plano solo se ve mientras se edita.
    _mostrarFormateado();
  }

  @override
  void didUpdateWidget(covariant ClaseCeldaNumero oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Al cambiar el valor desde afuera (selección de otro registro), volver a
    // mostrar el número formateado si la celda no está en edición.
    if (oldWidget.sValor != widget.sValor && !oFoco.hasFocus) {
      _mostrarFormateado();
    }
  }

  @override
  void dispose() {
    oFoco.removeListener(_alCambiarFoco);
    super.dispose();
  }

  void _alCambiarFoco() {
    if (oFoco.hasFocus) {
      if (widget.oControl.text != widget.sValor) widget.oControl.text = widget.sValor;
      return;
    }
    _mostrarFormateado();
  }

  void _mostrarFormateado() {
    final String? sMascara = widget.oCampo.sMascara;
    if (sMascara == null) return;
    String sSeparadorMiles = '.';
    for (int i = 0; i < sMascara.length; i++) {
      if (sMascara[i] != '9') {
        sSeparadorMiles = sMascara[i];
        break;
      }
    }
    final String sFormato = (widget.sValor.trim().isEmpty)
        ? ''
        : funcFormatearNumero(widget.sValor.replaceAll('.', ','), sMascara, sSeparadorMiles);
    if (sFormato != widget.oControl.text) widget.oControl.text = sFormato;
  }

  @override
  Widget build(BuildContext oContexto) {
    final int iLimite = widget.oCampo.sMascara
            ?.split('')
            .where((String s) => s == '9')
            .length ??
        widget.oCampo.iAnchoCaracteres;
    return TextField(
      controller      : widget.oControl,
      enabled         : widget.bHabilitado,
      focusNode       : oFoco,
      style           : widget.bHabilitado
          ? ClaseGenEstilosTexto.textoCampo(oContexto).copyWith(
              color: ClaseGenTemas.colorTextoCampoHabilitado(oContexto))
          : ClaseGenEstilosTexto.textoCampo(oContexto),
      textAlign       : TextAlign.right,
      inputFormatters : <TextInputFormatter>[
        if (widget.oCampo.bTieneDecimales)
          ClaseFormateadorImporte()
        else
          FilteringTextInputFormatter.digitsOnly,
        if (iLimite > 0)
          LengthLimitingTextInputFormatter(iLimite),
      ],
      onChanged       : widget.funcAlCambiar,
      decoration      : InputDecoration(
        isDense   : true,
        filled    : true,
        fillColor : widget.bHabilitado
            ? ClaseGenTemas.colorFondoCampoHabilitado(oContexto)
            : ClaseGenTemas.colorFondoCampoDeshabilitado(oContexto),
        contentPadding : const EdgeInsets.symmetric(
          horizontal : ClaseGenEspacios.dEspacio08,
          vertical   : ClaseGenEspacios.dEspacio08,
        ),
        border    : const OutlineInputBorder(),
      ),
    );
  }
}

