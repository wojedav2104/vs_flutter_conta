import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../idiomas/idiomas.dart';
import '../modelos/campo_abm.dart';
import '../preferencias/preferencias.dart';
import '../temas/espacios.dart';
import '../temas/estilos_textos.dart';
import '../temas/layout.dart';
import '../utilitarios/formatos.dart';
import '../validaciones/cap_validar.dart';
import 'abm_comun.dart';
import 'ventana_mensaje.dart';

/// Formulario ABM con grilla editable de detalles (Asientos, Libro Compras).
///
/// Cabecera (con pestañas si los campos tienen grupo) + grilla de filas con
/// totales. Cada registro lleva la cabecera en sus claves y la lista de
/// filas en la clave 'detalles'.
///
/// Validaciones de detalle centralizadas en ClaseCapValidar:
///   · Cada fila con contenido valida sus campos ("Fila N: …").
///   · Debe o Haber: uno solo de los dos por fila.
///   · Al menos una fila de detalle.
///   · La suma del Debe debe ser igual a la suma del Haber.
class ClaseFormularioCabeceraDetalle extends StatefulWidget {

  const ClaseFormularioCabeceraDetalle({
    super.key,
    this.bPermitirEncontrar   = true,
    this.bTablaUnSoloRegistro = false,
    this.funcActualizarCampos,
    this.funcActualizarFila,
    this.funcValidarRegistro,
    required this.listCamposCabecera,
    required this.listCamposDetalle,
    required this.listRegistros,
    required this.oPreferencias,
    this.sClaveDebe  = 'debe',
    this.sClaveHaber = 'haber',
    required this.sTitulo,
  });

  /// Clave del registro donde se guarda la lista de filas de detalle.
  static const String sClaveDetalles = 'detalles';

  /// false deshabilita el botón Encontrar.
  final bool bPermitirEncontrar;

  /// true si la tabla admite un solo registro.
  final bool bTablaUnSoloRegistro;

  /// Auto-cálculos de la cabecera: recibe los valores internos y devuelve
  /// los campos a actualizar (o null si no hay cambios).
  final Map<String, String>? Function(Map<String, String> mapValores)? funcActualizarCampos;

  /// Auto-cálculos por fila de detalle: recibe los valores internos de la
  /// fila y devuelve los campos a actualizar (o null si no hay cambios).
  final Map<String, String>? Function(Map<String, String> mapFila)? funcActualizarFila;

  /// Validación cruzada del registro completo (cabecera + detalles).
  final String? Function(Map<String, dynamic> oRegistro)? funcValidarRegistro;

  /// Campos de la cabecera.
  final List<ClaseCampoAbm> listCamposCabecera;

  /// Columnas de la grilla de detalles (una por campo).
  final List<ClaseCampoAbm> listCamposDetalle;

  /// Registros de la tabla (se modifica al grabar y borrar).
  final List<Map<String, dynamic>> listRegistros;

  final ClasePreferencias oPreferencias;

  /// Claves de las columnas del Debe y del Haber.
  final String sClaveDebe;
  final String sClaveHaber;
  final String sTitulo;

  @override
  State<ClaseFormularioCabeceraDetalle> createState() =>
      ClaseEstadoFormularioCabeceraDetalle();
}

class ClaseEstadoFormularioCabeceraDetalle
    extends State<ClaseFormularioCabeceraDetalle> {

  bool   bModoEdicion = false;
  int    iRegistro    = -1;

  /// Filas de detalle que se están editando (valores internos).
  List<Map<String, String>> listDetalles = <Map<String, String>>[];

  /// Un control por celda, para conservar el cursor y actualizar valores
  /// derivados (ej: el nombre de la cuenta).
  List<Map<String, TextEditingController>> listControles =
      <Map<String, TextEditingController>>[];

  Map<String, String> mapValores = <String, String>{};

  @override
  void dispose() {
    _liberarControles();
    super.dispose();
  }

  String getIdioma() => widget.oPreferencias.getIdioma();

  // ── Controles de las celdas ──────────────────────────────────────────────

  Map<String, TextEditingController> _crearControles(Map<String, String> mapFila) {
    return <String, TextEditingController>{
      for (final ClaseCampoAbm oCampo in widget.listCamposDetalle)
        oCampo.sClave: TextEditingController(text: mapFila[oCampo.sClave] ?? ''),
    };
  }

  void _liberarControles() {
    for (final Map<String, TextEditingController> mapCtrl in listControles) {
      for (final TextEditingController oCtrl in mapCtrl.values) {
        oCtrl.dispose();
      }
    }
    listControles = <Map<String, TextEditingController>>[];
  }

  void _reemplazarDetalles(List<Map<String, String>> listNuevas) {
    _liberarControles();
    listDetalles  = listNuevas;
    listControles = <Map<String, TextEditingController>>[
      for (final Map<String, String> mapFila in listDetalles) _crearControles(mapFila),
    ];
  }

  void _sincronizarControles(int iFila, Map<String, String> mapFila) {
    for (final ClaseCampoAbm oCampo in widget.listCamposDetalle) {
      final TextEditingController? oCtrl = listControles[iFila][oCampo.sClave];
      final String sValor = mapFila[oCampo.sClave] ?? '';
      if (oCtrl != null && oCtrl.text != sValor) oCtrl.text = sValor;
    }
  }

  // ── Acciones del formulario ──────────────────────────────────────────────

  void agregar() {
    setState(() {
      mapValores = <String, String>{
        for (final ClaseCampoAbm oCampo in widget.listCamposCabecera)
          oCampo.sClave: oCampo.sValorDefecto ?? '',
      };
      _reemplazarDetalles(<Map<String, String>>[_crearFilaVacia()]);
      iRegistro    = -1;
      bModoEdicion = true;
    });
  }

  void modificar() {
    if (iRegistro < 0) return;
    final Map<String, dynamic> oRegistro = widget.listRegistros[iRegistro];
    setState(() {
      mapValores = _desdeRegistro(oRegistro);
      _reemplazarDetalles(_desdeDetalles(oRegistro));
      bModoEdicion = true;
    });
  }

  Future<void> borrar() async {
    if (iRegistro < 0) return;
    final bool bAceptar = await funcMostrarConfirmar(
      context,
      getIdioma(),
      widget.sTitulo,
      ClaseIdiomas.getTexto(getIdioma(), 'confirmarBorrar'),
      ClaseIdiomas.getTexto(getIdioma(), 'aceptar'),
      ClaseIdiomas.getTexto(getIdioma(), 'cancelar'),
      ClaseGenLayout.iAnchoColumnasMensaje,
    );
    if (!bAceptar || !mounted) return;
    setState(() {
      widget.listRegistros.removeAt(iRegistro);
      mapValores   = <String, String>{};
      _reemplazarDetalles(<Map<String, String>>[]);
      iRegistro    = -1;
      bModoEdicion = false;
    });
  }

  void cancelar() {
    setState(() {
      if (iRegistro >= 0) {
        final Map<String, dynamic> oRegistro = widget.listRegistros[iRegistro];
        mapValores = _desdeRegistro(oRegistro);
        _reemplazarDetalles(_desdeDetalles(oRegistro));
      } else {
        mapValores = <String, String>{};
        _reemplazarDetalles(<Map<String, String>>[]);
      }
      bModoEdicion = false;
    });
  }

  Future<void> grabar() async {
    final String sIdioma = getIdioma();

    // 1) Campos de cabecera.
    for (final ClaseCampoAbm oCampo in widget.listCamposCabecera) {
      final String? sError =
          funcValidarCampoAbm(oCampo, mapValores[oCampo.sClave] ?? '', sIdioma);
      if (sError != null) {
        await _mostrarMensaje(sError);
        return;
      }
    }

    // 2) Filas de detalle.
    final String? sErrorDetalle = _validarDetalles(sIdioma);
    if (sErrorDetalle != null) {
      await _mostrarMensaje(sErrorDetalle);
      return;
    }

    // 3) Validación cruzada del registro completo.
    final List<Map<String, String>> listLimpias = _listDetallesLimpias();
    final Map<String, dynamic> oRegistro = Map<String, dynamic>.from(mapValores)
      ..[ClaseFormularioCabeceraDetalle.sClaveDetalles] = listLimpias;
    final String? sError = widget.funcValidarRegistro?.call(oRegistro);
    if (sError != null) {
      await _mostrarMensaje(sError);
      return;
    }

    // 4) Ceros a la izquierda y grabación.
    setState(() {
      for (final ClaseCampoAbm oCampo in widget.listCamposCabecera) {
        if (oCampo.bCompletarCeros) {
          mapValores[oCampo.sClave] =
              funcCompletarCeros(mapValores[oCampo.sClave] ?? '', oCampo.iAnchoCaracteres);
        }
      }
      _reemplazarDetalles(_clonarDetalles(listLimpias));
      final Map<String, dynamic> oNuevo = Map<String, dynamic>.from(mapValores)
        ..[ClaseFormularioCabeceraDetalle.sClaveDetalles] = _clonarDetalles(listLimpias);
      if (iRegistro < 0) {
        widget.listRegistros.add(oNuevo);
        iRegistro = widget.listRegistros.length - 1;
      } else {
        widget.listRegistros[iRegistro] = oNuevo;
      }
      bModoEdicion = false;
    });
    await _mostrarMensaje(ClaseIdiomas.getTexto(sIdioma, 'grabacionExitosa'));
  }

  Future<void> encontrar() async {
    final String sIdioma = getIdioma();
    final String? sTexto = await funcMostrarEncontrar(
        context, sIdioma, widget.listCamposCabecera.first);
    if (sTexto == null) return;
    final String sBusqueda = sTexto.toLowerCase();
    for (int i = 0; i < widget.listRegistros.length; i++) {
      if ((widget.listRegistros[i][widget.listCamposCabecera.first.sClave] ?? '')
          .toString().toLowerCase().contains(sBusqueda)) {
        seleccionar(i);
        return;
      }
    }
    await _mostrarMensaje(ClaseIdiomas.getTexto(sIdioma, 'abmNoEncontrado'));
  }

  // ── Filas de detalle ─────────────────────────────────────────────────────

  Map<String, String> _crearFilaVacia() {
    return <String, String>{
      for (final ClaseCampoAbm oCampo in widget.listCamposDetalle)
        oCampo.sClave: oCampo.sValorDefecto ?? '',
    };
  }

  void agregarFila() {
    setState(() {
      listDetalles.add(_crearFilaVacia());
      listControles.add(_crearControles(listDetalles.last));
    });
  }

  void borrarFila(int iFila) {
    setState(() {
      for (final TextEditingController oCtrl in listControles[iFila].values) {
        oCtrl.dispose();
      }
      listControles.removeAt(iFila);
      listDetalles.removeAt(iFila);
    });
  }

  void subirFila(int iFila) {
    if (iFila <= 0) return;
    setState(() {
      listDetalles.insert(iFila - 1, listDetalles.removeAt(iFila));
      listControles.insert(iFila - 1, listControles.removeAt(iFila));
    });
  }

  void bajarFila(int iFila) {
    if (iFila >= listDetalles.length - 1) return;
    setState(() {
      listDetalles.insert(iFila + 1, listDetalles.removeAt(iFila));
      listControles.insert(iFila + 1, listControles.removeAt(iFila));
    });
  }

  void _alCambiarFila(int iFila, String sClave, String sValor) {
    String sSalida = sValor;
    for (final ClaseCampoAbm oCampo in widget.listCamposDetalle) {
      if (oCampo.sClave == sClave && oCampo.bMayusculas) {
        sSalida = sValor.toUpperCase();
        final TextEditingController? oCtrl = listControles[iFila][sClave];
        if (oCtrl != null && oCtrl.text != sSalida) {
          oCtrl.value = TextEditingValue(
            text      : sSalida,
            selection : TextSelection.collapsed(offset: sSalida.length),
          );
        }
        break;
      }
    }
    setState(() {
      listDetalles[iFila][sClave] = sSalida;
      final Map<String, String>? mapActualizaciones =
          widget.funcActualizarFila?.call(listDetalles[iFila]);
      if (mapActualizaciones != null) {
        listDetalles[iFila].addAll(mapActualizaciones);
        _sincronizarControles(iFila, listDetalles[iFila]);
      }
    });
  }

  // ── Validación de las filas de detalle ───────────────────────────────────

  String? _validarDetalles(String sIdioma) {

    // Al menos una fila de detalle.
    final bool bAlgunaConContenido = listDetalles.any((Map<String, String> mapFila) =>
        mapFila.values.any((String s) => s.trim().isNotEmpty));
    if (!bAlgunaConContenido) {
      return ClaseIdiomas.getTexto(sIdioma, 'detDetalleVacio');
    }

    int iFila = 0;
    for (final Map<String, String> mapFila in listDetalles) {
      iFila++;
      final bool bConContenido =
          mapFila.values.any((String s) => s.trim().isNotEmpty);
      if (!bConContenido) continue;

      // Validación de cada campo de la fila.
      for (final ClaseCampoAbm oCampo in widget.listCamposDetalle) {
        final String? sError =
            funcValidarCampoAbm(oCampo, mapFila[oCampo.sClave] ?? '', sIdioma);
        if (sError != null) {
          return _traducirFila(sIdioma, iFila, sError);
        }
      }

      // Debe o Haber: uno solo de los dos.
      final String sDebe  = (mapFila[widget.sClaveDebe]  ?? '').trim();
      final String sHaber = (mapFila[widget.sClaveHaber] ?? '').trim();
      if (sDebe.isNotEmpty == sHaber.isNotEmpty) {
        return _traducirFila(
            sIdioma, iFila, ClaseIdiomas.getTexto(sIdioma, 'detErrorDebeHaber'));
      }
    }

    // La suma del Debe debe ser igual a la suma del Haber.
    double dDebe  = 0;
    double dHaber = 0;
    for (final Map<String, String> mapFila in listDetalles) {
      dDebe  += funcParsearNumero(mapFila[widget.sClaveDebe]  ?? '') ?? 0;
      dHaber += funcParsearNumero(mapFila[widget.sClaveHaber] ?? '') ?? 0;
    }
    return ClaseCapValidar.validarSumaDebeHaber(dDebe, dHaber, sIdioma);
  }

  String _traducirFila(String sIdioma, int iFila, String sError) {
    return ClaseIdiomas.getTexto(sIdioma, 'detErrorFila')
        .replaceAll('{0}', '$iFila')
        .replaceAll('{1}', sError);
  }

  List<Map<String, String>> _listDetallesLimpias() {
    return _clonarDetalles(listDetalles
        .where((Map<String, String> mapFila) =>
            mapFila.values.any((String s) => s.trim().isNotEmpty))
        .toList());
  }

  List<Map<String, String>> _clonarDetalles(List<Map<String, String>> listOrigen) {
    return <Map<String, String>>[
      for (final Map<String, String> mapFila in listOrigen)
        Map<String, String>.from(mapFila),
    ];
  }

  // ── Selección y auto-cálculos de la cabecera ─────────────────────────────

  void seleccionar(int iIndice) {
    final Map<String, dynamic> oRegistro = widget.listRegistros[iIndice];
    setState(() {
      iRegistro    = iIndice;
      mapValores   = _desdeRegistro(oRegistro);
      _reemplazarDetalles(_desdeDetalles(oRegistro));
      bModoEdicion = false;
    });
  }

  Map<String, String> _desdeRegistro(Map<String, dynamic> oRegistro) {
    return <String, String>{
      for (final ClaseCampoAbm oCampo in widget.listCamposCabecera)
        oCampo.sClave: (oRegistro[oCampo.sClave] ?? '').toString(),
    };
  }

  List<Map<String, String>> _desdeDetalles(Map<String, dynamic> oRegistro) {
    final dynamic oValor =
        oRegistro[ClaseFormularioCabeceraDetalle.sClaveDetalles];
    if (oValor is! List) return <Map<String, String>>[];
    return <Map<String, String>>[
      for (final dynamic oFila in oValor)
        <String, String>{
          for (final ClaseCampoAbm oCampo in widget.listCamposDetalle)
            oCampo.sClave: ((oFila as Map)[oCampo.sClave] ?? '').toString(),
        },
    ];
  }

  void _alCambiarCampo(String sClave, String sValor) {
    setState(() {
      mapValores[sClave] = sValor;
      final Map<String, String>? mapActualizaciones =
          widget.funcActualizarCampos?.call(mapValores);
      if (mapActualizaciones != null) mapValores.addAll(mapActualizaciones);
    });
  }

  bool _getHabilitado(ClaseCampoAbm oCampo) {
    return bModoEdicion
        && !oCampo.bSiempreDeshabilitado
        && !oCampo.bSoloLecturaPorRol
        && (oCampo.funcActualizarEstado?.call(mapValores) ?? true);
  }

  // ── Botonera ─────────────────────────────────────────────────────────────

  Set<EnumBotonAbm> _getBotonesHabilitados() {
    return <EnumBotonAbm>{
      if (!bModoEdicion
          && !(widget.bTablaUnSoloRegistro && widget.listRegistros.isNotEmpty))
        EnumBotonAbm.agregar,
      if (iRegistro >= 0 && !bModoEdicion) ...<EnumBotonAbm>[
        EnumBotonAbm.modificar,
        EnumBotonAbm.borrar,
      ],
      if (widget.bPermitirEncontrar && !widget.bTablaUnSoloRegistro && !bModoEdicion)
        EnumBotonAbm.encontrar,
      if (bModoEdicion) ...<EnumBotonAbm>[
        EnumBotonAbm.grabar,
        EnumBotonAbm.cancelar,
      ],
      EnumBotonAbm.fin,
    };
  }

  void _alClicarBoton(EnumBotonAbm oBoton) {
    switch (oBoton) {
      case EnumBotonAbm.agregar:   agregar();
      case EnumBotonAbm.borrar:    borrar();
      case EnumBotonAbm.cancelar:  cancelar();
      case EnumBotonAbm.encontrar: encontrar();
      case EnumBotonAbm.fin:       Navigator.of(context).pop();
      case EnumBotonAbm.grabar:    grabar();
      case EnumBotonAbm.modificar: modificar();
    }
  }

  Future<void> _mostrarMensaje(String sTexto) async {
    if (!mounted) return;
    await funcMostrarMensaje(
      context,
      getIdioma(),
      ClaseIdiomas.getTexto(getIdioma(), 'aplicacion'),
      sTexto,
      ClaseIdiomas.getTexto(getIdioma(), 'aceptar'),
      ClaseGenLayout.iAnchoColumnasMensaje,
    );
  }

  // ── Construcción de la interfaz ──────────────────────────────────────────

  @override
  Widget build(BuildContext oContexto) {
    return ClaseAndamiajeAbm(
      funcAlClicar    : _alClicarBoton,
      funcSeleccionar : seleccionar,
      iRegistro       : iRegistro,
      listCampos      : widget.listCamposCabecera,
      listRegistros   : widget.listRegistros,
      oFormulario: Column(
        crossAxisAlignment : CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            flex  : 2,
            child : ClaseFormularioCampos(
              funcAlCambiarCampo : _alCambiarCampo,
              funcEsHabilitado   : _getHabilitado,
              listCampos         : widget.listCamposCabecera,
              mapValores         : mapValores,
              sIdioma            : getIdioma(),
            ),
          ),
          const Divider(height: ClaseGenEspacios.dEspacio01),
          Expanded(
            flex  : 3,
            child : _construirDetalle(oContexto),
          ),
        ],
      ),
      setHabilitados : _getBotonesHabilitados(),
      sIdioma        : getIdioma(),
      sTitulo        : widget.sTitulo,
    );
  }

  // ── Grilla editable de detalles ──────────────────────────────────────────

  double _getAnchoDetalle() {
    double dAncho = ClaseGenLayout.dAnchoNumeroFila + ClaseGenLayout.dAnchoAccionesFila;
    for (final ClaseCampoAbm oCampo in widget.listCamposDetalle) {
      dAncho += oCampo.getAnchoColumna();
    }
    return dAncho;
  }

  Widget _construirDetalle(BuildContext oContexto) {
    return Column(
      crossAxisAlignment : CrossAxisAlignment.stretch,
      children: <Widget>[
        Expanded(
          child: SingleChildScrollView(
            scrollDirection : Axis.horizontal,
            child: SizedBox(
              width  : _getAnchoDetalle(),
              child  : ListView(
                children: <Widget>[
                  _construirFilaEncabezado(oContexto),
                  for (int i = 0; i < listDetalles.length; i++)
                    _construirFilaDetalle(oContexto, i),
                ],
              ),
            ),
          ),
        ),
        _construirFilaTotales(oContexto),
        Padding(
          padding : const EdgeInsets.all(ClaseGenEspacios.dEspacio08),
          child   : Align(
            alignment : Alignment.centerLeft,
            child     : OutlinedButton.icon(
              onPressed : bModoEdicion ? agregarFila : null,
              icon      : const Icon(Icons.add),
              label     : Text(ClaseIdiomas.getTexto(getIdioma(), 'detAgregarFila'),
                  style: ClaseGenEstilosTexto.normalMediano(oContexto)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _construirFilaEncabezado(BuildContext oContexto) {
    return Padding(
      padding : const EdgeInsets.symmetric(
        horizontal : ClaseGenEspacios.dEspacio08,
        vertical   : ClaseGenEspacios.dEspacio04,
      ),
      child: Row(
        children: <Widget>[
          SizedBox(
            width : ClaseGenLayout.dAnchoNumeroFila,
            child : Text(ClaseIdiomas.getTexto(getIdioma(), 'detFila'),
                style: ClaseGenEstilosTexto.etiquetaCampo(oContexto)),
          ),
          for (final ClaseCampoAbm oCampo in widget.listCamposDetalle)
            SizedBox(
              width : oCampo.getAnchoColumna(),
              child : Text(oCampo.sEtiqueta,
                  style    : ClaseGenEstilosTexto.etiquetaCampo(oContexto),
                  maxLines : 1,
                  overflow : TextOverflow.ellipsis),
            ),
          const SizedBox(width: ClaseGenLayout.dAnchoAccionesFila),
        ],
      ),
    );
  }

  Widget _construirFilaDetalle(BuildContext oContexto, int iFila) {
    return Padding(
      padding : const EdgeInsets.symmetric(
        horizontal : ClaseGenEspacios.dEspacio08,
        vertical   : ClaseGenEspacios.dEspacio04,
      ),
      child: Row(
        children: <Widget>[
          SizedBox(
            width : ClaseGenLayout.dAnchoNumeroFila,
            child : Text('${iFila + 1}',
                style: ClaseGenEstilosTexto.normalChico(oContexto)),
          ),
          for (final ClaseCampoAbm oCampo in widget.listCamposDetalle)
            SizedBox(
              width : oCampo.getAnchoColumna(),
              child : Padding(
                padding : const EdgeInsets.only(right: ClaseGenEspacios.dEspacio04),
                child   : _construirCelda(oContexto, iFila, oCampo),
              ),
            ),
          SizedBox(
            width : ClaseGenLayout.dAnchoAccionesFila,
            child : Row(
              mainAxisSize : MainAxisSize.min,
              children     : <Widget>[
                IconButton(
                  tooltip   : ClaseIdiomas.getTexto(getIdioma(), 'menuSubirFila'),
                  icon      : const Icon(Icons.keyboard_arrow_up),
                  onPressed : (bModoEdicion && iFila > 0) ? () => subirFila(iFila) : null,
                ),
                IconButton(
                  tooltip   : ClaseIdiomas.getTexto(getIdioma(), 'menuBajarFila'),
                  icon      : const Icon(Icons.keyboard_arrow_down),
                  onPressed : (bModoEdicion && iFila < listDetalles.length - 1)
                      ? () => bajarFila(iFila)
                      : null,
                ),
                IconButton(
                  tooltip   : ClaseIdiomas.getTexto(getIdioma(), 'detBorrarFila'),
                  icon      : const Icon(Icons.delete_outline),
                  onPressed : bModoEdicion ? () => borrarFila(iFila) : null,
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
          value      : listValores.contains(sValor) ? sValor : null,
          isExpanded : true,
          decoration : const InputDecoration(isDense: true, border: OutlineInputBorder()),
          items: <DropdownMenuItem<String>>[
            for (int i = 0; i < listOpciones.length; i++)
              DropdownMenuItem<String>(
                value : listValores[i],
                child : Text(listOpciones[i],
                    style: ClaseGenEstilosTexto.normalChico(oContexto)),
              ),
          ],
          onChanged: bHabilitado
              ? (String? sNuevo) => _alCambiarFila(iFila, oCampo.sClave, sNuevo ?? '')
              : null,
        );
      case EnumTipoCampoAbm.numero:
        return TextField(
          controller      : listControles[iFila][oCampo.sClave],
          enabled         : bHabilitado,
          style           : ClaseGenEstilosTexto.normalChico(oContexto),
          textAlign       : TextAlign.right,
          inputFormatters : <TextInputFormatter>[oCampo.bTieneDecimales ? ClaseFormateadorImporte() : FilteringTextInputFormatter.digitsOnly,],          onChanged       : (String sValor) => _alCambiarFila(iFila, oCampo.sClave, sValor),
          decoration      : const InputDecoration(isDense: true, border: OutlineInputBorder()),
        );
      default:
        return TextField(
          controller : listControles[iFila][oCampo.sClave],
          enabled    : bHabilitado,
          style      : ClaseGenEstilosTexto.normalChico(oContexto),
          onChanged  : (String sValor) => _alCambiarFila(iFila, oCampo.sClave, sValor),
          decoration : const InputDecoration(isDense: true, border: OutlineInputBorder()),
        );
    }
  }

  Widget _construirFilaTotales(BuildContext oContexto) {

    // Sumas de las columnas numéricas.
    final Map<String, double> mapSumas = <String, double>{};
    for (final ClaseCampoAbm oCampo in widget.listCamposDetalle) {
      if (oCampo.oTipo != EnumTipoCampoAbm.numero) continue;
      double dSuma = 0;
      for (final Map<String, String> mapFila in listDetalles) {
        dSuma += funcParsearNumero(mapFila[oCampo.sClave] ?? '') ?? 0;
      }
      mapSumas[oCampo.sClave] = dSuma;
    }

    // El rótulo TOTALES va en la columna previa a la primera numérica.
    int iPrimeraSuma = -1;
    for (int i = 0; i < widget.listCamposDetalle.length; i++) {
      if (widget.listCamposDetalle[i].oTipo == EnumTipoCampoAbm.numero) {
        iPrimeraSuma = i;
        break;
      }
    }
    final int iRotulo = (iPrimeraSuma > 0)
        ? iPrimeraSuma - 1
        : widget.listCamposDetalle.length - 1;

    final String sFormato = widget.oPreferencias.getFormatoNumeros();
    final TextStyle oEstilo =
        ClaseGenEstilosTexto.textoDestacado(oContexto);

    return Container(
      color : Theme.of(oContexto).colorScheme.surfaceContainerLow,
      padding : const EdgeInsets.symmetric(
        horizontal : ClaseGenEspacios.dEspacio08,
        vertical   : ClaseGenEspacios.dEspacio04,
      ),
      child: Row(
        children: <Widget>[
          const SizedBox(width: ClaseGenLayout.dAnchoNumeroFila),
          for (int i = 0; i < widget.listCamposDetalle.length; i++)
            SizedBox(
              width : widget.listCamposDetalle[i].getAnchoColumna(),
              child : Text(
                (i == iRotulo)
                    ? ClaseIdiomas.getTexto(getIdioma(), 'detTotales')
                    : ((i == iPrimeraSuma || mapSumas
                            .containsKey(widget.listCamposDetalle[i].sClave))
                        ? funcFormatearNumero(
                            mapSumas[widget.listCamposDetalle[i].sClave] ?? 0, sFormato)
                        : ''),
                style     : oEstilo,
                textAlign : TextAlign.right,
              ),
            ),
          const SizedBox(width: ClaseGenLayout.dAnchoAccionesFila),
        ],
      ),
    );
  }

}
