import 'package:flutter/material.dart';

import '../idiomas/idiomas.dart';
import '../modelos/campo_abm.dart';
import '../preferencias/preferencias.dart';
import '../utilitarios/formatos.dart';
import 'abm_comun.dart';
import 'ventana_mensaje.dart';

/// Formulario ABM genérico para tablas de múltiples registros.
///
/// Cabecera con los botones ABM, formulario a la derecha (con pestañas si
/// los campos tienen grupo) y grilla de registros a la izquierda.
/// La estructura compartida vive en abm_comun.dart.
///
/// Los valores de los registros y del formulario son internos (códigos):
/// la traducción se hace al mostrar. Con listValores se guardan los códigos
/// de listOpciones; con sValorDefecto se inicializan los campos al agregar;
/// con bCompletarCeros el valor se completa a la izquierda al grabar.
class ClaseFormularioAbm extends StatefulWidget {

  const ClaseFormularioAbm({
    super.key,
    this.bPermitirEncontrar   = true,
    this.bTablaUnSoloRegistro = false,
    this.funcActualizarCampos,
    this.funcAlPerderFoco,
    this.funcEtiquetaGrupo,
    this.funcValidarRegistro,
    required this.listCampos,
    required this.listRegistros,
    required this.oPreferencias,
    required this.sTitulo,
  });

  /// false deshabilita el botón Encontrar (ej: la tabla Empresa).
  final bool bPermitirEncontrar;

  /// true si la tabla admite un solo registro (ej: la tabla Empresa).
  final bool bTablaUnSoloRegistro;

  /// Auto-cálculos: recibe los valores internos y devuelve los campos a
  /// actualizar (o null si no hay cambios).
  final Map<String, String>? Function(Map<String, String> mapValores)? funcActualizarCampos;

  /// Transformación del valor al salir del campo (devuelve el valor nuevo
  /// o null si no cambia). Recibe la clave del campo, el valor actual y los
  /// valores internos del formulario. Ej: completar el RUC al salir del
  /// campo de la identificación.
  final String? Function(String sClave, String sValor, Map<String, String> mapValores)? funcAlPerderFoco;

  /// Etiqueta personalizada de cada pestaña de grupo (opcional). Recibe la
  /// clave del grupo; si no se provee, se usa el texto traducido de la clave.
  final String Function(String sClaveGrupo)? funcEtiquetaGrupo;

  /// Validación cruzada del registro completo (o null si es válido).
  final String? Function(Map<String, dynamic> oRegistro)? funcValidarRegistro;

  /// Especificación de los campos del formulario.
  final List<ClaseCampoAbm> listCampos;

  /// Registros de la tabla (se modifica al grabar y borrar).
  final List<Map<String, dynamic>> listRegistros;

  final ClasePreferencias oPreferencias;
  final String            sTitulo;

  @override
  State<ClaseFormularioAbm> createState() => ClaseEstadoFormularioAbm();
}

class ClaseEstadoFormularioAbm extends State<ClaseFormularioAbm> {

  bool   bModoEdicion = false;
  int    iRegistro    = -1;

  /// Registro que se estaba viendo antes de hacer clic en Agregar (-1 si
  /// ninguno): al cancelar se vuelve a él y se muestra de nuevo.
  int    iRegistroAnterior = -1;

  /// true después de Agregar/Modificar → mover foco al primer campo.
  bool   bPedirFoco   = false;                          // ← CAMBIO item 10

  /// Llave del formulario de campos: para colocar el foco en el primer
  /// campo con error al fallar el grabado (item 14).
  final GlobalKey<ClaseEstadoFormularioCampos> _oLlaveFormulario =
      GlobalKey<ClaseEstadoFormularioCampos>();           // ← CAMBIO item 14

  /// Nodo de foco de la grilla lateral: al cancelar la edición, el foco
  /// vuelve a la grilla.
  final FocusNode _oFocoGrilla = FocusNode();

  Map<String, String> mapValores = <String, String>{};

  @override
  void initState() {
    super.initState();
    // ← CAMBIO item 23: al ingresar, seleccionar la primera fila de la
    //   grilla si hay registros, para que el formulario muestre sus datos.
    if (widget.listRegistros.isNotEmpty) {
      iRegistro  = 0;
      mapValores = _desdeRegistro(widget.listRegistros[0]);
    }
  }

  @override
  void dispose() {
    _oFocoGrilla.dispose();
    super.dispose();
  }

  String getIdioma() => widget.oPreferencias.getIdioma();

  // ── Acciones del formulario ──────────────────────────────────────────────

  void agregar() {
    setState(() {
      mapValores = <String, String>{
        for (final ClaseCampoAbm oCampo in widget.listCampos)
          oCampo.sClave: oCampo.sValorDefecto ?? '',
      };
      iRegistroAnterior = iRegistro;                    // para Cancelar
      iRegistro    = -1;
      bModoEdicion = true;
      bPedirFoco   = true;                              // ← CAMBIO item 10
    });
  }

  void modificar() {
    if (iRegistro < 0) return;
    setState(() {
      iRegistroAnterior = iRegistro;                    // para Cancelar
      mapValores   = _desdeRegistro(widget.listRegistros[iRegistro]);
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
      iRegistro    = -1;
      iRegistroAnterior = -1;
      bModoEdicion = false;
    });
    await _mostrarInformacion(ClaseIdiomas.getTexto('mensajeBorrado', getIdioma()));
  }

  void cancelar() {
    setState(() {
      // Si se estaba agregando, volver al registro que se estaba viendo.
      if (iRegistro < 0 && iRegistroAnterior >= 0) {
        iRegistro = iRegistroAnterior;
      }
      mapValores = (iRegistro >= 0)
          ? _desdeRegistro(widget.listRegistros[iRegistro])
          : <String, String>{};
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

    // 0) Ceros a la izquierda ANTES de validar (regla de la subcuenta:
    //    '1' → '00001' y recién entonces se valida como de 5 dígitos).
    for (final ClaseCampoAbm oCampo in widget.listCampos) {
      if (oCampo.bCompletarCeros) {
        mapValores[oCampo.sClave] =
            funcCompletarCeros(mapValores[oCampo.sClave] ?? '', oCampo.iAnchoCaracteres);
      }
    }

    // 1) Obligatorios, longitud máxima (regla 14) y validación por campo.
    for (final ClaseCampoAbm oCampo in widget.listCampos) {
      final String? sError =
          funcValidarCampoAbm(oCampo, mapValores[oCampo.sClave] ?? '', sIdioma);
      if (sError != null) {
        await _mostrarError(sError);
        // ← CAMBIO item 14: el foco se coloca en el primer campo con error.
        _oLlaveFormulario.currentState?.enfocarCampo(oCampo.sClave);
        return;
      }
    }

    // 2) Validación cruzada del registro.
    final String? sError = widget.funcValidarRegistro
        ?.call(Map<String, dynamic>.from(mapValores));
    if (sError != null) {
      await _mostrarError(sError);
      return;
    }

    // 3) Grabación.
    setState(() {
      if (iRegistro < 0) {
        widget.listRegistros.add(Map<String, dynamic>.from(mapValores));
        iRegistro = widget.listRegistros.length - 1;
      } else {
        widget.listRegistros[iRegistro] = Map<String, dynamic>.from(mapValores);
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
    final String? sTexto =
        await funcMostrarEncontrar(context, sIdioma, widget.listCampos.first);
    if (sTexto == null) return;
    final String sBusqueda = sTexto.toLowerCase();
    for (int i = 0; i < widget.listRegistros.length; i++) {
      if ((widget.listRegistros[i][widget.listCampos.first.sClave] ?? '')
          .toString().toLowerCase().contains(sBusqueda)) {
        seleccionar(i);
        return;
      }
    }
    await _mostrarInformacion(ClaseIdiomas.getTexto('abmNoEncontrado', sIdioma));
  }

  // ── Selección y auto-cálculos ────────────────────────────────────────────

  void seleccionar(int iIndice) {
    setState(() {
      iRegistro    = iIndice;
      mapValores   = _desdeRegistro(widget.listRegistros[iIndice]);
      bModoEdicion = false;
    });
  }

  Map<String, String> _desdeRegistro(Map<String, dynamic> oRegistro) {
    return <String, String>{
      for (final ClaseCampoAbm oCampo in widget.listCampos)
        oCampo.sClave: (oRegistro[oCampo.sClave] ?? '').toString(),
    };
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

    // Resetear el pedido de foco después de este frame.                   ← CAMBIO item 10
    if (bPedirFoco) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        bPedirFoco = false;
      });
    }

    return ClaseAndamiajeAbm(
      funcAlClicar    : _alClicarBoton,
      funcSeleccionar : seleccionar,
      iRegistro       : iRegistro,
      listCampos      : widget.listCampos,
      listRegistros   : widget.listRegistros,
      oFocoGrilla     : _oFocoGrilla,
      oFormulario     : ClaseFormularioCampos(
        key                : _oLlaveFormulario,            // ← CAMBIO item 14
        bAutoFocus         : bPedirFoco,                   // ← CAMBIO item 10
        funcAlCambiarCampo : _alCambiarCampo,
        funcAlPerderFoco   : widget.funcAlPerderFoco,
        funcEsHabilitado   : _getHabilitado,
        funcEtiquetaGrupo  : widget.funcEtiquetaGrupo,     // ← CAMBIO etiqueta de grupo
        listCampos         : widget.listCampos,
        mapValores         : mapValores,
        sIdioma            : getIdioma(),
      ),
      setHabilitados : _getBotonesHabilitados(),
      sIdioma        : getIdioma(),
      sTitulo        : widget.sTitulo,
    );
  }

}

