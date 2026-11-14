import 'package:flutter/material.dart';

import '../idiomas/idiomas.dart';
import '../modelos/campo_abm.dart';
import '../preferencias/preferencias.dart';
import '../temas/layout.dart';
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
  Map<String, String> mapValores = <String, String>{};

  String getIdioma() => widget.oPreferencias.getIdioma();

  // ── Acciones del formulario ──────────────────────────────────────────────

  void agregar() {
    setState(() {
      mapValores = <String, String>{
        for (final ClaseCampoAbm oCampo in widget.listCampos)
          oCampo.sClave: oCampo.sValorDefecto ?? '',
      };
      iRegistro    = -1;
      bModoEdicion = true;
    });
  }

  void modificar() {
    if (iRegistro < 0) return;
    setState(() {
      mapValores   = _desdeRegistro(widget.listRegistros[iRegistro]);
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
      iRegistro    = -1;
      bModoEdicion = false;
    });
  }

  void cancelar() {
    setState(() {
      mapValores = (iRegistro >= 0)
          ? _desdeRegistro(widget.listRegistros[iRegistro])
          : <String, String>{};
      bModoEdicion = false;
    });
  }

  Future<void> grabar() async {
    final String sIdioma = getIdioma();

    // 1) Obligatorios, longitud máxima (regla 14) y validación por campo.
    for (final ClaseCampoAbm oCampo in widget.listCampos) {
      final String? sError =
          funcValidarCampoAbm(oCampo, mapValores[oCampo.sClave] ?? '', sIdioma);
      if (sError != null) {
        await _mostrarMensaje(sError);
        return;
      }
    }

    // 2) Validación cruzada del registro.
    final String? sError = widget.funcValidarRegistro
        ?.call(Map<String, dynamic>.from(mapValores));
    if (sError != null) {
      await _mostrarMensaje(sError);
      return;
    }

    // 3) Ceros a la izquierda y grabación.
    setState(() {
      for (final ClaseCampoAbm oCampo in widget.listCampos) {
        if (oCampo.bCompletarCeros) {
          mapValores[oCampo.sClave] =
              funcCompletarCeros(mapValores[oCampo.sClave] ?? '', oCampo.iAnchoCaracteres);
        }
      }
      if (iRegistro < 0) {
        widget.listRegistros.add(Map<String, dynamic>.from(mapValores));
        iRegistro = widget.listRegistros.length - 1;
      } else {
        widget.listRegistros[iRegistro] = Map<String, dynamic>.from(mapValores);
      }
      bModoEdicion = false;
    });
    await _mostrarMensaje(ClaseIdiomas.getTexto(sIdioma, 'grabacionExitosa'));
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
    await _mostrarMensaje(ClaseIdiomas.getTexto(sIdioma, 'abmNoEncontrado'));
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
      listCampos      : widget.listCampos,
      listRegistros   : widget.listRegistros,
      oFormulario     : ClaseFormularioCampos(
        funcAlCambiarCampo : _alCambiarCampo,
        funcEsHabilitado   : _getHabilitado,
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