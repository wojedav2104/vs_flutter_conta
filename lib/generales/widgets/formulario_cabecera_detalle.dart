import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../idiomas/idiomas.dart';
import '../modelos/campo_abm.dart';
import '../preferencias/preferencias.dart';
import '../temas/espacios.dart';
import '../utilitarios/formatos.dart';
import 'abm_comun.dart';
import 'campo_formulario.dart';
import 'detalle_validar.dart';
import 'grilla_detalles.dart';
import 'ventana_mensaje.dart';

/// Formulario ABM con grilla editable de detalles (Asientos, Libro Compras y
/// Libro Ventas).
///
/// Cabecera (con pestañas si los campos tienen grupo) + grilla de filas con
/// totales. Cada registro lleva la cabecera en sus claves y la lista de
/// filas en la clave 'detalles'.
///
/// La grilla editable vive en grilla_detalles.dart y las validaciones de
/// detalle en detalle_validar.dart (ClaseDetalleValidar):
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
    this.funcAlPerderFoco,
    this.funcValidarRegistro,
    required this.listCamposCabecera,
    required this.listCamposDetalle,
    required this.listRegistros,
    required this.oPreferencias,
    this.sClaveCampoAlPie,
    this.sClaveDebe  = 'debe',
    this.sClaveHaber = 'haber',
    this.sGrupoConDetalles,
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
  final String? sClaveCampoAlPie;
  final String sClaveDebe;
  final String sClaveHaber;
  /// Grupo cuya pestaña contiene la grilla de detalles (ej: Compras,
  /// 'comDetalles'). Si es null, la grilla se muestra al pie del formulario
  /// (ej: Asientos).
  final String? sGrupoConDetalles;
  final String sTitulo;

  final String? Function(String sClave, String sValor, Map<String, String> mapValores)? funcAlPerderFoco;

  @override
  State<ClaseFormularioCabeceraDetalle> createState() =>
      ClaseEstadoFormularioCabeceraDetalle();
}

class ClaseEstadoFormularioCabeceraDetalle

    extends State<ClaseFormularioCabeceraDetalle> {

  bool   bModoEdicion = false;
  int    iRegistro    = -1;

  /// Registro que se estaba viendo antes de hacer clic en Agregar (-1 si
  /// ninguno): al cancelar se vuelve a él y se muestra de nuevo.
  int    iRegistroAnterior = -1;

  /// true después de Agregar/Modificar → mover foco al primer campo.
  bool   bPedirFoco   = false;                          // ← CAMBIO item 10

  /// Llave del formulario de cabecera: para colocar el foco en el primer
  /// campo con error al fallar el grabado (item 14).
  final GlobalKey<ClaseEstadoFormularioCampos> _oLlaveFormulario =
      GlobalKey<ClaseEstadoFormularioCampos>();           // ← CAMBIO item 14

  /// Nodo de foco de la grilla lateral: al cancelar la edición, el foco
  /// vuelve a la grilla.
  final FocusNode _oFocoGrilla = FocusNode();

  /// Filas de detalle que se están editando (valores internos).
  List<Map<String, String>> listDetalles = <Map<String, String>>[];

  /// Un control por celda, para conservar el cursor y actualizar valores
  /// derivados (ej: el nombre de la cuenta).
  List<Map<String, TextEditingController>> listControles =
      <Map<String, TextEditingController>>[];

  Map<String, String> mapValores = <String, String>{};

  @override
  void initState() {
    super.initState();
    // ← CAMBIO item 23: al ingresar, seleccionar la primera fila de la
    //   grilla si hay registros, para que el formulario muestre sus datos.
    if (widget.listRegistros.isNotEmpty) {
      iRegistro  = 0;
      mapValores = _desdeRegistro(widget.listRegistros[0]);
      _reemplazarDetalles(_desdeDetalles(widget.listRegistros[0]));
    }
  }

  @override
  void dispose() {
    _liberarControles();
    _oFocoGrilla.dispose();
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
      iRegistroAnterior = iRegistro;                    // para Cancelar
      iRegistro    = -1;
      bModoEdicion = true;
      bPedirFoco   = true;                              // ← CAMBIO item 10
    });
  }

  void modificar() {
    if (iRegistro < 0) return;
    final Map<String, dynamic> oRegistro = widget.listRegistros[iRegistro];
    setState(() {
      iRegistroAnterior = iRegistro;                    // para Cancelar
      mapValores        = _desdeRegistro(oRegistro);
      _reemplazarDetalles(_desdeDetalles(oRegistro));
      bModoEdicion = true;
      bPedirFoco   = true;                              // ← CAMBIO item 10
    });
  }

  Future<void> borrar() async {
    if (iRegistro < 0) return;
    final EnumRespuestaConfirmacion oRespuesta = await funcMostrarConfirmacion(
      context,
      getIdioma(),
      widget.sTitulo,
      ClaseIdiomas.getTexto('confirmarBorrar', getIdioma()),
      bMostrarCancelar : false,
    );
    if (oRespuesta != EnumRespuestaConfirmacion.si || !mounted) return;
    setState(() {
      widget.listRegistros.removeAt(iRegistro);
      mapValores   = <String, String>{};
      _reemplazarDetalles(<Map<String, String>>[]);
      iRegistro         = -1;
      iRegistroAnterior = -1;
      bModoEdicion      = false;
    });
    await _mostrarInformacion(ClaseIdiomas.getTexto('mensajeBorrado', getIdioma()));
  }

  void cancelar() {
    setState(() {
      // Si se estaba agregando, volver al registro que se estaba viendo.
      if (iRegistro < 0 && iRegistroAnterior >= 0) {
        iRegistro = iRegistroAnterior;
      }
      if (iRegistro >= 0) {
        final Map<String, dynamic> oRegistro = widget.listRegistros[iRegistro];
        mapValores = _desdeRegistro(oRegistro);
        _reemplazarDetalles(_desdeDetalles(oRegistro));
      } else {
        mapValores = <String, String>{};
        _reemplazarDetalles(<Map<String, String>>[]);
      }
      iRegistroAnterior = -1;
      bModoEdicion      = false;
    });
    // El foco vuelve a la grilla lateral: el usuario sigue viendo el registro.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _oFocoGrilla.requestFocus();
    });
  }

  Future<void> grabar() async {
    final String sIdioma = getIdioma();

    // 0) Ceros a la izquierda en cabecera y detalles ANTES de validar
    //    (regla de la subcuenta: '1' → '00001').
    for (final ClaseCampoAbm oCampo in widget.listCamposCabecera) {
      if (oCampo.bCompletarCeros) {
        mapValores[oCampo.sClave] =
            funcCompletarCeros(mapValores[oCampo.sClave] ?? '', oCampo.iAnchoCaracteres);
      }
    }
    for (int i = 0; i < listDetalles.length; i++) {
      for (final ClaseCampoAbm oCampo in widget.listCamposDetalle) {
        if (oCampo.bCompletarCeros) {
          listDetalles[i][oCampo.sClave] = funcCompletarCeros(
              listDetalles[i][oCampo.sClave] ?? '', oCampo.iAnchoCaracteres);
        }
      }
      _sincronizarControles(i, listDetalles[i]);
    }

    // 1) Campos de cabecera.
    for (final ClaseCampoAbm oCampo in widget.listCamposCabecera) {
      final String? sError =
          funcValidarCampoAbm(oCampo, mapValores[oCampo.sClave] ?? '', sIdioma);
      if (sError != null) {
        await _mostrarError(sError);
        // ← CAMBIO item 14: el foco se coloca en el primer campo con error.
        _oLlaveFormulario.currentState?.enfocarCampo(oCampo.sClave);
        return;
      }
    }

    // 2) Filas de detalle (validación en detalle_validar.dart).
    final String? sErrorDetalle = ClaseDetalleValidar.validarDetalles(
      listDetalles,
      widget.listCamposDetalle,
      widget.sClaveDebe,
      widget.sClaveHaber,
      sIdioma,
    );
    if (sErrorDetalle != null) {
      await _mostrarError(sErrorDetalle);
      return;
    }

    // 3) Validación cruzada del registro completo.
    final List<Map<String, String>> listLimpias =
        ClaseDetalleValidar.listDetallesLimpias(listDetalles);
    final Map<String, dynamic> oRegistro = Map<String, dynamic>.from(mapValores)
      ..[ClaseFormularioCabeceraDetalle.sClaveDetalles] = listLimpias;
    final String? sError = widget.funcValidarRegistro?.call(oRegistro);
    if (sError != null) {
      await _mostrarError(sError);
      return;
    }

    // 4) Grabación (los ceros ya se aplicaron en el paso 0).
    setState(() {
      _reemplazarDetalles(ClaseDetalleValidar.clonarDetalles(listLimpias));
      final Map<String, dynamic> oNuevo = Map<String, dynamic>.from(mapValores)
        ..[ClaseFormularioCabeceraDetalle.sClaveDetalles] =
            ClaseDetalleValidar.clonarDetalles(listLimpias);
      if (iRegistro < 0) {
        widget.listRegistros.add(oNuevo);
        iRegistro = widget.listRegistros.length - 1;
      } else {
        widget.listRegistros[iRegistro] = oNuevo;
      }
      iRegistroAnterior = -1;
      bModoEdicion      = false;
    });
    // Regla UI/UX: la ventana de "grabación exitosa" se cierra sola a los 3
    // segundos si el usuario no la cierra antes.
    await _mostrarInformacion(
      ClaseIdiomas.getTexto('grabacionExitosa', sIdioma),
      iSegundosAutoCierre : 3,
    );
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
    await _mostrarInformacion(ClaseIdiomas.getTexto('abmNoEncontrado', sIdioma));
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
      if (!bModoEdicion) EnumBotonAbm.fin,
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

  // ── Ventanas de mensajes ─────────────────────────────────────────────────

  Future<void> _mostrarError(String sTexto) async {
    if (!mounted) return;
    await funcMostrarError(
      context,
      getIdioma(),
      ClaseIdiomas.getTexto('aplicacion', getIdioma()),
      sTexto,
    );
  }

  Future<void> _mostrarInformacion(
    String sTexto, {
    int iSegundosAutoCierre = 0,
  }) async {
    if (!mounted) return;
    await funcMostrarInformacion(
      context,
      getIdioma(),
      ClaseIdiomas.getTexto('aplicacion', getIdioma()),
      sTexto,
      iSegundosAutoCierre : iSegundosAutoCierre,
    );
  }

  // ── Construcción de la interfaz ──────────────────────────────────────────

  @override
  Widget build(BuildContext oContexto) {
    final List<ClaseCampoAbm> listCabecera = (widget.sClaveCampoAlPie == null)
        ? widget.listCamposCabecera
        : widget.listCamposCabecera
            .where((ClaseCampoAbm oCampo) => oCampo.sClave != widget.sClaveCampoAlPie)
            .toList();
    // Resetear el pedido de foco después de este frame.
    if (bPedirFoco) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        bPedirFoco = false;
      });
    }

    // Regla UI/UX: sin pestañas la cabecera se ajusta a su contenido y la
    // grilla queda justo debajo del último campo; con pestañas la cabecera
    // necesita altura propia y se mantiene la proporción 2:3.
    final bool bConPestanas = widget.listCamposCabecera
        .any((ClaseCampoAbm oCampo) => oCampo.sGrupo != null);
    final Widget oGrilla = ClaseGrillaDetalles(
      bModoEdicion      : bModoEdicion,
      funcAgregarFila   : agregarFila,
      funcAlCambiarFila : _alCambiarFila,
      funcBorrarFila    : borrarFila,
      funcBajarFila     : bajarFila,
      funcSubirFila     : subirFila,
      listCamposDetalle : widget.listCamposDetalle,
      listControles     : listControles,
      listDetalles      : listDetalles,
      oPie              : _construirCampoAlPie(oContexto),
      sFormatoNumeros   : widget.oPreferencias.getFormatoNumeros(),
      sIdioma           : getIdioma(),
    );
    final Widget oCabecera = ClaseFormularioCampos(
      key                 : _oLlaveFormulario,       // ← CAMBIO item 14
      bAutoFocus          : bPedirFoco,              // ← CAMBIO item 10
      funcAlCambiarCampo  : _alCambiarCampo,
      funcAlPerderFoco    : widget.funcAlPerderFoco,
      funcEsHabilitado    : _getHabilitado,
      // Regla UI/UX (Compras): la grilla de detalles se muestra dentro de su
      // pestaña, debajo de los campos del grupo.
      funcExtraGrupo      : (widget.sGrupoConDetalles == null)
          ? null
          : (String sGrupo) => (sGrupo == widget.sGrupoConDetalles)
              ? oGrilla
              : null,
      listCampos          : listCabecera,
      mapValores          : mapValores,
      sIdioma             : getIdioma(),
    );

    return ClaseAndamiajeAbm(
      funcAlClicar    : _alClicarBoton,
      funcSeleccionar : seleccionar,
      iRegistro       : iRegistro,
      listCampos      : widget.listCamposCabecera,
      listRegistros   : widget.listRegistros,
      oFocoGrilla     : _oFocoGrilla,
      // Regla UI/UX: con sGrupoConDetalles la grilla de detalles vive dentro
      // de su pestaña (ej: Compras, pestaña Detalles); sin él, la grilla
      // queda al pie del formulario (ej: Asientos).
      oFormulario: (widget.sGrupoConDetalles != null)
          ? oCabecera
          : Column(
              crossAxisAlignment : CrossAxisAlignment.stretch,
              children: <Widget>[
                if (bConPestanas)
                  Expanded(
                    flex  : 2,
                    child : oCabecera,
                  )
                else
                  oCabecera,
                const Divider(height: ClaseGenEspacios.dEspacio01),
                Expanded(
                  flex  : 3,
                  child : oGrilla,
                ),
              ],
            ),
      setHabilitados : _getBotonesHabilitados(),
      sIdioma        : getIdioma(),
      sTitulo        : widget.sTitulo,
    );
  }

  /// Campo de la cabecera que se muestra al pie, debajo de la fila de totales
  /// (spec 02_02, 02_03 y 02_04: el campo Comentarios).
  /// Regla UI/UX: la etiqueta queda arriba, en la misma fila que el contador
  /// de caracteres, y el campo ocupa el ancho de la grilla.
  Widget _construirCampoAlPie(BuildContext oContexto) {
    for (final ClaseCampoAbm oCampo in widget.listCamposCabecera) {
      if (oCampo.sClave != widget.sClaveCampoAlPie) continue;
      return Padding(
        padding : const EdgeInsets.symmetric(
          horizontal : ClaseGenEspacios.dEspacio08,
          vertical   : ClaseGenEspacios.dEspacio04,
        ),
        child : ClaseCampoFormulario(
          bEtiquetaArriba : true,
          bHabilitado   : _getHabilitado(oCampo),
          funcAlCambiar : (String sValor) => _alCambiarCampo(oCampo.sClave, sValor),
          mapValores    : mapValores,
          oCampo        : oCampo,
          sIdioma       : getIdioma(),
          sValor        : mapValores[oCampo.sClave] ?? '',
        ),
      );
    }
    return const SizedBox.shrink();
  }

}

