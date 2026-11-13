import 'dart:math' show max, min;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../idiomas/idiomas.dart';
import '../modelos/campo_abm.dart';
import '../preferencias/preferencias.dart';
import '../temas/colores.dart';
import '../temas/espacios.dart';
import '../temas/estilos_textos.dart';
import '../temas/layout.dart';
import '../temas/radios.dart';
import '../utilitarios/formatos.dart';
import '../validaciones/cap_validar.dart';
import 'ventana_mensaje.dart';

/// Estado de un formulario ABM cabecera/detalle.
enum EnumEstadoCabDet { agregando, encontrando, inicial, modificando }

/// Formulario ABM de tipo cabecera/detalle.
///
/// Soporta pestañas si los campos de cabecera tienen sGrupo.
/// La grilla lateral se ordena con clic en la cabecera de la columna
/// (ascendente/descendente, con flecha indicadora) y tiene menú contextual
/// con clic derecho (escritorio/web) o presión larga (teléfono).
/// La grilla editable de detalles permite subir/bajar filas por menú
/// contextual (el orden de las filas es el orden contable del asiento).
/// La grilla de detalles es responsive: en pantallas anchas se muestra como
/// grilla horizontal con todas las columnas; en pantallas angostas (teléfono)
/// se muestra como tarjetas verticales con todos los campos de cada fila
/// apilados.
class ClaseFormularioCabeceraDetalle extends StatefulWidget {

  const ClaseFormularioCabeceraDetalle({
    super.key,
    required this.listCamposCabecera,
    required this.listCamposDetalle,
    required this.listCamposPie,
    required this.listRegistros,
    required this.oPreferencias,
    required this.sTitulo,
    this.bPermitirEncontrar   = true,
    this.funcAlActualizar,
    this.funcAlBorrar,
    this.funcAlGrabar,
    this.funcActualizarCampos,
    this.funcValidarRegistro,
  });

  final bool bPermitirEncontrar;
  final Future<String?> Function()?                                              funcAlActualizar;
  final Future<String?> Function(Map<String, dynamic> oRegistro)?                funcAlBorrar;
  final Future<String?> Function(Map<String, dynamic> oRegistro, bool bEsNuevo)? funcAlGrabar;
  final Map<String, String>? Function(Map<String, String> mapValores)?           funcActualizarCampos;
  final List<ClaseCampoAbm>                                                      listCamposCabecera;
  final List<ClaseCampoAbm>                                                      listCamposDetalle;
  final List<ClaseCampoAbm>                                                      listCamposPie;
  final List<Map<String, dynamic>>                                               listRegistros;
  final ClasePreferencias                                                        oPreferencias;
  final String                                                                   sTitulo;
  final String? Function(Map<String, dynamic> oRegistro)?                        funcValidarRegistro;

  @override
  State<ClaseFormularioCabeceraDetalle> createState() => ClaseEstadoCabDet();
}

class ClaseEstadoCabDet extends State<ClaseFormularioCabeceraDetalle>
    with SingleTickerProviderStateMixin {

  bool bGrillaExpandida = false;
  bool bOrdenAscendente = true;

  EnumEstadoCabDet enumEstado = EnumEstadoCabDet.inicial;

  int iColOrden = -1;
  int iPagina   = 0;
  int iRegistro = -1;

  late TabController oControlPestanas;

  final Map<String, FocusNode>              mapFocos         = <String, FocusNode>{};
  final Map<String, TextEditingController>  mapControladores = <String, TextEditingController>{};

  List<Map<String, dynamic>>               listFiltrada    = <Map<String, dynamic>>[];
  List<Map<String, TextEditingController>> listDetalles    = <Map<String, TextEditingController>>[];
  List<String>                             listGrupos      = <String>[];
  List<GlobalKey>                          listLlavesFilas = <GlobalKey>[];

  @override
  void initState() {
    super.initState();
    for (final ClaseCampoAbm oCampo in widget.listCamposCabecera) {
      mapControladores[oCampo.sClave] = TextEditingController();
      mapFocos[oCampo.sClave]         = FocusNode();
      if (oCampo.sGrupo != null && !listGrupos.contains(oCampo.sGrupo)) {
        listGrupos.add(oCampo.sGrupo!);
      }
    }
    for (final ClaseCampoAbm oCampo in widget.listCamposPie) {
      mapControladores[oCampo.sClave] = TextEditingController();
      mapFocos[oCampo.sClave]         = FocusNode();
    }
    oControlPestanas = TabController(
      vsync  : this,
      length : listGrupos.isEmpty ? 1 : listGrupos.length,
    );
    listFiltrada = List<Map<String, dynamic>>.of(widget.listRegistros);
    if (listFiltrada.isNotEmpty) {
      iRegistro = 0;
      WidgetsBinding.instance.addPostFrameCallback((_) => cargarRegistro(0));
    }
  }

  @override
  void dispose() {
    for (final TextEditingController oControl in mapControladores.values) {
      oControl.dispose();
    }
    for (final FocusNode oFoco in mapFocos.values) {
      oFoco.dispose();
    }
    for (final Map<String, TextEditingController> oFila in listDetalles) {
      for (final TextEditingController oControl in oFila.values) {
        oControl.dispose();
      }
    }
    oControlPestanas.dispose();
    super.dispose();
  }

  // ── Utilidades ──────────────────────────────────────────────────────────
  int getTotalPaginas() {
    if (listFiltrada.isEmpty) return 1;
    return (listFiltrada.length / ClaseGenLayout.iFilasPorPagina).ceil();
  }

  String getIdioma() => widget.oPreferencias.getIdioma();

  String getTexto(String sClave) => ClaseIdiomas.getTexto(getIdioma(), sClave);

  double calcularAnchoCampo(ClaseCampoAbm oCampo) {
    final int iCaracteres = (oCampo.sMascara != null)
        ? oCampo.sMascara!.length
        : oCampo.iAnchoCaracteres;
    return iCaracteres * ClaseGenLayout.dAnchoCaracter + ClaseGenEspacios.dEspacio48;
  }

  double calcularAnchoAntesDelDebe() {
    double dTotal = 0;
    for (final ClaseCampoAbm oCampo in widget.listCamposDetalle) {
      if (oCampo.sClave == 'debe') break;
      dTotal += calcularAnchoCampo(oCampo);
    }
    return dTotal;
  }

  String getValorGrilla(Map<String, dynamic> oRegistro, ClaseCampoAbm oCampo) {
    String sValor = (oRegistro[oCampo.sClave] ?? '').toString();
    if (oCampo.oTipo == EnumTipoCampoAbm.numero &&
        sValor.isNotEmpty && RegExp(r'^\d+$').hasMatch(sValor)) {
      sValor = (int.tryParse(sValor) ?? 0).toString();
    }
    return (sValor.length > 20) ? sValor.substring(0, 20) : sValor;
  }

  Map<String, String> getValoresActuales() {
    final Map<String, String> mapValores = <String, String>{};
    for (final ClaseCampoAbm oCampo in widget.listCamposCabecera) {
      mapValores[oCampo.sClave] = mapControladores[oCampo.sClave]!.text;
    }
    for (final ClaseCampoAbm oCampo in widget.listCamposPie) {
      mapValores[oCampo.sClave] = mapControladores[oCampo.sClave]!.text;
    }
    return mapValores;
  }

  void alCambiarCampo() {
    if (widget.funcActualizarCampos != null) {
      final Map<String, String>? mapActualizaciones =
          widget.funcActualizarCampos!(getValoresActuales());
      if (mapActualizaciones != null) {
        for (final MapEntry<String, String> oEntrada in mapActualizaciones.entries) {
          mapControladores[oEntrada.key]?.text = oEntrada.value;
        }
      }
    }
    setState(() {});
  }

  // ── Orden de la grilla lateral ──────────────────────────────────────────
  num? getNumeroOrden(String sValor) {
    final String sLimpio = sValor.trim()
        .replaceAll(' ', '')
        .replaceAll('.', '')
        .replaceAll(',', '.');
    return num.tryParse(sLimpio);
  }

  DateTime? getFechaOrden(String sValor) {
    final List<String> listPartes = sValor.split(RegExp(r'[/-]'));
    if (listPartes.length == 3) {
      final int? iDia = int.tryParse(listPartes[0]);
      final int? iMes = int.tryParse(listPartes[1]);
      final int? iAno = int.tryParse(listPartes[2]);
      if (iDia != null && iMes != null && iAno != null) {
        return DateTime(iAno, iMes, iDia);
      }
    }
    return DateTime.tryParse(sValor);
  }

  int? getMinutosOrden(String sValor) {
    final List<String> listPartes = sValor.split(':');
    if (listPartes.length != 2) return null;
    final int? iHora   = int.tryParse(listPartes[0]);
    final int? iMinuto = int.tryParse(listPartes[1]);
    if (iHora == null || iMinuto == null) return null;
    return iHora * 60 + iMinuto;
  }

  int compararRegistros(Map<String, dynamic> oA, Map<String, dynamic> oB) {
    if (iColOrden < 0) return 0;
    final ClaseCampoAbm oCampo = widget.listCamposCabecera[iColOrden];
    final String sA = (oA[oCampo.sClave] ?? '').toString().trim();
    final String sB = (oB[oCampo.sClave] ?? '').toString().trim();
    if (sA.isEmpty && sB.isEmpty) return 0;
    if (sA.isEmpty) return 1;
    if (sB.isEmpty) return -1;

    int iComp = 0;
    if (oCampo.oTipo == EnumTipoCampoAbm.numero) {
      final num? nA = getNumeroOrden(sA);
      final num? nB = getNumeroOrden(sB);
      if (nA == null && nB == null) {
        iComp = sA.toLowerCase().compareTo(sB.toLowerCase());
      } else if (nA == null) {
        return 1;
      } else if (nB == null) {
        return -1;
      } else {
        iComp = nA.compareTo(nB);
      }
    } else if (oCampo.oTipo == EnumTipoCampoAbm.fecha) {
      final DateTime? fA = getFechaOrden(sA);
      final DateTime? fB = getFechaOrden(sB);
      if (fA == null && fB == null) {
        iComp = sA.toLowerCase().compareTo(sB.toLowerCase());
      } else if (fA == null) {
        return 1;
      } else if (fB == null) {
        return -1;
      } else {
        iComp = fA.compareTo(fB);
      }
    } else if (oCampo.oTipo == EnumTipoCampoAbm.hora) {
      final int? iA = getMinutosOrden(sA);
      final int? iB = getMinutosOrden(sB);
      if (iA == null && iB == null) {
        iComp = sA.toLowerCase().compareTo(sB.toLowerCase());
      } else if (iA == null) {
        return 1;
      } else if (iB == null) {
        return -1;
      } else {
        iComp = iA.compareTo(iB);
      }
    } else if (oCampo.oTipo == EnumTipoCampoAbm.logico) {
      final int iA = (sA.toUpperCase() == 'S') ? 1 : 0;
      final int iB = (sB.toUpperCase() == 'S') ? 1 : 0;
      iComp = iA.compareTo(iB);
    } else {
      iComp = sA.toLowerCase().compareTo(sB.toLowerCase());
    }
    return bOrdenAscendente ? iComp : -iComp;
  }

  void aplicarOrden(List<Map<String, dynamic>> listDatos) {
    if (iColOrden < 0) return;
    listDatos.sort(compararRegistros);
  }

  void ordenarPor(ClaseCampoAbm oCampo) {
    final Map<String, dynamic>? oSel = (iRegistro >= 0 && iRegistro < listFiltrada.length)
        ? listFiltrada[iRegistro] : null;
    setState(() {
      final int iNueva = widget.listCamposCabecera.indexOf(oCampo);
      if (iNueva == iColOrden) {
        bOrdenAscendente = !bOrdenAscendente;
      } else {
        iColOrden        = iNueva;
        bOrdenAscendente = true;
      }
      aplicarOrden(listFiltrada);
      iRegistro = (oSel == null)
          ? (listFiltrada.isEmpty ? -1 : 0)
          : listFiltrada.indexOf(oSel);
      iPagina = (iRegistro < 0) ? 0 : iRegistro ~/ ClaseGenLayout.iFilasPorPagina;
    });
  }

  // ── Detalle: filas ──────────────────────────────────────────────────────
  void agregarDetalle() {
    final Map<String, TextEditingController> oFila = <String, TextEditingController>{};
    for (final ClaseCampoAbm oCampo in widget.listCamposDetalle) {
      oFila[oCampo.sClave] = TextEditingController();
    }
    setState(() {
      listDetalles.add(oFila);
      listLlavesFilas.add(GlobalKey());
    });
  }

  void borrarDetalle(int iIndice) {
    for (final TextEditingController oControl in listDetalles[iIndice].values) {
      oControl.dispose();
    }
    setState(() {
      listDetalles.removeAt(iIndice);
      listLlavesFilas.removeAt(iIndice);
    });
  }

  void subirFila(int iFila) {
    if (iFila <= 0 || iFila >= listDetalles.length) return;
    setState(() {
      final Map<String, TextEditingController> oFilaTemp = listDetalles[iFila - 1];
      listDetalles[iFila - 1] = listDetalles[iFila];
      listDetalles[iFila]     = oFilaTemp;
      final GlobalKey oLlaveTemp = listLlavesFilas[iFila - 1];
      listLlavesFilas[iFila - 1] = listLlavesFilas[iFila];
      listLlavesFilas[iFila]     = oLlaveTemp;
    });
  }

  void bajarFila(int iFila) {
    if (iFila < 0 || iFila >= listDetalles.length - 1) return;
    setState(() {
      final Map<String, TextEditingController> oFilaTemp = listDetalles[iFila + 1];
      listDetalles[iFila + 1] = listDetalles[iFila];
      listDetalles[iFila]     = oFilaTemp;
      final GlobalKey oLlaveTemp = listLlavesFilas[iFila + 1];
      listLlavesFilas[iFila + 1] = listLlavesFilas[iFila];
      listLlavesFilas[iFila]     = oLlaveTemp;
    });
  }

  Future<void> irAFilaDetalle(int iFila) async {
    if (iFila < 0 || iFila >= listLlavesFilas.length) return;
    final BuildContext? oCtxFila = listLlavesFilas[iFila].currentContext;
    if (oCtxFila == null) return;
    await Scrollable.ensureVisible(
      oCtxFila,
      duration : const Duration(milliseconds: 300),
      alignment: 0.5,
    );
  }

  int getSumaDebe() {
    int iTotal = 0;
    for (final Map<String, TextEditingController> oFila in listDetalles) {
      iTotal += funcParsearEnteroMiles(oFila['debe']?.text ?? '');
    }
    return iTotal;
  }

  int getSumaHaber() {
    int iTotal = 0;
    for (final Map<String, TextEditingController> oFila in listDetalles) {
      iTotal += funcParsearEnteroMiles(oFila['haber']?.text ?? '');
    }
    return iTotal;
  }

  // ── Acciones ABM ────────────────────────────────────────────────────────
  void agregar() {
    setState(() {
      enumEstado = EnumEstadoCabDet.agregando;
      for (final TextEditingController oControl in mapControladores.values) {
        oControl.clear();
      }
      for (final Map<String, TextEditingController> oFila in listDetalles) {
        for (final TextEditingController oControl in oFila.values) {
          oControl.dispose();
        }
      }
      listDetalles.clear();
      listLlavesFilas.clear();
    });
    alCambiarCampo();
  }

  Future<void> actualizar() async {
    String? sError;
    if (widget.funcAlActualizar != null) {
      sError = await widget.funcAlActualizar!();
    }
    if (!mounted) return;
    if (sError != null) {
      await funcMostrarMensaje(context, getIdioma(), widget.sTitulo, sError);
      return;
    }
    final Map<String, dynamic>? oSel = (iRegistro >= 0 && iRegistro < listFiltrada.length)
        ? listFiltrada[iRegistro] : null;
    setState(() {
      listFiltrada = List<Map<String, dynamic>>.of(widget.listRegistros);
      aplicarOrden(listFiltrada);
      iRegistro = (oSel == null)
          ? (listFiltrada.isEmpty ? -1 : 0)
          : listFiltrada.indexOf(oSel);
      if (iRegistro < 0 && listFiltrada.isNotEmpty) iRegistro = 0;
      iPagina = (iRegistro < 0) ? 0 : iRegistro ~/ ClaseGenLayout.iFilasPorPagina;
    });
    if (iRegistro >= 0) cargarRegistro(iRegistro);
  }

  Future<void> borrar() async {
    if (iRegistro < 0 || iRegistro >= listFiltrada.length) return;
    final bool bConfirmo = await funcMostrarConfirmacion(
        context, getIdioma(), getTexto('confirmarBorrar'));
    if (!bConfirmo || !mounted) return;
    final Map<String, dynamic> oRegistro = listFiltrada[iRegistro];
    String? sError;
    if (widget.funcAlBorrar != null) sError = await widget.funcAlBorrar!(oRegistro);
    if (!mounted) return;
    if (sError != null) {
      await funcMostrarMensaje(context, getIdioma(), widget.sTitulo, sError);
      return;
    }
    widget.listRegistros.remove(oRegistro);
    setState(() {
      listFiltrada = List<Map<String, dynamic>>.of(widget.listRegistros);
      aplicarOrden(listFiltrada);
      iRegistro    = listFiltrada.isEmpty ? -1 : min(iRegistro, listFiltrada.length - 1);
      enumEstado   = EnumEstadoCabDet.inicial;
    });
    if (iRegistro >= 0) cargarRegistro(iRegistro);
  }

  void buscar() {
    final List<Map<String, dynamic>> listResultados = <Map<String, dynamic>>[];
    for (final Map<String, dynamic> oRegistro in widget.listRegistros) {
      bool bCumple = true;
      for (final ClaseCampoAbm oCampo in widget.listCamposCabecera) {
        final String sBuscado = mapControladores[oCampo.sClave]!.text.trim().toLowerCase();
        if (sBuscado.isEmpty) continue;
        final String sValor = (oRegistro[oCampo.sClave] ?? '').toString().toLowerCase();
        if (!sValor.contains(sBuscado)) { bCumple = false; break; }
      }
      if (bCumple) listResultados.add(oRegistro);
    }
    aplicarOrden(listResultados);
    setState(() {
      listFiltrada = listResultados;
      iPagina      = 0;
      iRegistro    = listFiltrada.isEmpty ? -1 : 0;
      enumEstado   = EnumEstadoCabDet.inicial;
    });
    if (iRegistro >= 0) cargarRegistro(iRegistro);
  }

  void buscarPorValor(int iIndice, ClaseCampoAbm oCampo) {
    if (iIndice < 0 || iIndice >= listFiltrada.length) return;
    final String sValor = (listFiltrada[iIndice][oCampo.sClave] ?? '').toString();
    enumEstado = EnumEstadoCabDet.encontrando;
    for (final TextEditingController oControl in mapControladores.values) {
      oControl.clear();
    }
    mapControladores[oCampo.sClave]!.text = sValor;
    buscar();
  }

  void cargarRegistro(int iIndice) {
    final Map<String, dynamic> oRegistro = listFiltrada[iIndice];
    for (final ClaseCampoAbm oCampo in widget.listCamposCabecera) {
      String sValor = (oRegistro[oCampo.sClave] ?? '').toString();
      if (oCampo.oTipo == EnumTipoCampoAbm.numero &&
          sValor.isNotEmpty && RegExp(r'^\d+$').hasMatch(sValor)) {
        sValor = (int.tryParse(sValor) ?? 0).toString();
      }
      mapControladores[oCampo.sClave]!.text = sValor;
    }
    for (final ClaseCampoAbm oCampo in widget.listCamposPie) {
      mapControladores[oCampo.sClave]!.text = (oRegistro[oCampo.sClave] ?? '').toString();
    }
    for (final Map<String, TextEditingController> oFila in listDetalles) {
      for (final TextEditingController oControl in oFila.values) {
        oControl.dispose();
      }
    }
    listDetalles.clear();
    listLlavesFilas.clear();
    final List<dynamic> listDet = oRegistro['detalles'] as List<dynamic>? ?? <dynamic>[];
    for (final dynamic oD in listDet) {
      final Map<String, dynamic> mapDet = oD as Map<String, dynamic>;
      final Map<String, TextEditingController> oFila = <String, TextEditingController>{};
      for (final ClaseCampoAbm oCampo in widget.listCamposDetalle) {
        oFila[oCampo.sClave] = TextEditingController(
            text: (mapDet[oCampo.sClave] ?? '').toString());
      }
      listDetalles.add(oFila);
      listLlavesFilas.add(GlobalKey());
    }
    setState(() => iRegistro = iIndice);
    alCambiarCampo();
  }

  void cancelar() {
    setState(() => enumEstado = EnumEstadoCabDet.inicial);
    if (iRegistro >= 0) {
      cargarRegistro(iRegistro);
    } else {
      for (final TextEditingController oControl in mapControladores.values) {
        oControl.clear();
      }
      for (final Map<String, TextEditingController> oFila in listDetalles) {
        for (final TextEditingController oControl in oFila.values) {
          oControl.dispose();
        }
      }
      listDetalles.clear();
      listLlavesFilas.clear();
      alCambiarCampo();
    }
  }

  Future<void> copiarValor(int iIndice, ClaseCampoAbm oCampo) async {
    if (iIndice < 0 || iIndice >= listFiltrada.length) return;
    final String sValor = (listFiltrada[iIndice][oCampo.sClave] ?? '').toString();
    await Clipboard.setData(ClipboardData(text: sValor));
    if (!mounted) return;
    await funcMostrarMensaje(
        context, getIdioma(), widget.sTitulo, getTexto('copiadoPortapapeles'));
  }

  Future<void> copiarFila(int iIndice) async {
    if (iIndice < 0 || iIndice >= listFiltrada.length) return;
    final List<String> listValores = <String>[];
    for (final ClaseCampoAbm oCampo in widget.listCamposCabecera.where((o) => o.bEnGrilla)) {
      listValores.add((listFiltrada[iIndice][oCampo.sClave] ?? '').toString());
    }
    await Clipboard.setData(ClipboardData(text: listValores.join('\t')));
    if (!mounted) return;
    await funcMostrarMensaje(
        context, getIdioma(), widget.sTitulo, getTexto('copiadoPortapapeles'));
  }

  void encontrar() {
    setState(() {
      enumEstado = EnumEstadoCabDet.encontrando;
      for (final TextEditingController oControl in mapControladores.values) {
        oControl.clear();
      }
    });
  }

  void fin() {
    Navigator.of(context).pop();
  }

  Future<void> grabar() async {
    if (enumEstado == EnumEstadoCabDet.encontrando) { buscar(); return; }
    if (!validar()) return;

    final Map<String, dynamic> oRegistro = <String, dynamic>{};
    for (final ClaseCampoAbm oCampo in widget.listCamposCabecera) {
      oRegistro[oCampo.sClave] = mapControladores[oCampo.sClave]!.text;
    }
    for (final ClaseCampoAbm oCampo in widget.listCamposPie) {
      oRegistro[oCampo.sClave] = mapControladores[oCampo.sClave]!.text;
    }
    final List<Map<String, dynamic>> listDet = <Map<String, dynamic>>[];
    for (final Map<String, TextEditingController> oFila in listDetalles) {
      final Map<String, dynamic> mapDet = <String, dynamic>{};
      for (final ClaseCampoAbm oCampo in widget.listCamposDetalle) {
        mapDet[oCampo.sClave] = oFila[oCampo.sClave]?.text ?? '';
      }
      listDet.add(mapDet);
    }
    oRegistro['detalles'] = listDet;

    final bool bEsNuevo = enumEstado == EnumEstadoCabDet.agregando;
    String? sError;
    if (widget.funcAlGrabar != null) sError = await widget.funcAlGrabar!(oRegistro, bEsNuevo);
    if (!mounted) return;
    if (sError != null) {
      await funcMostrarMensaje(context, getIdioma(), widget.sTitulo, sError);
      return;
    }
    if (bEsNuevo) {
      widget.listRegistros.add(oRegistro);
      listFiltrada = List<Map<String, dynamic>>.of(widget.listRegistros);
      aplicarOrden(listFiltrada);
      iRegistro    = listFiltrada.indexOf(oRegistro);
    } else {
      final Map<String, dynamic> oActual = listFiltrada[iRegistro];
      oActual.clear();
      oActual.addAll(oRegistro);
    }
    setState(() => enumEstado = EnumEstadoCabDet.inicial);
    await funcMostrarMensaje(context, getIdioma(), widget.sTitulo, getTexto('grabacionExitosa'));
  }

  void irAFila(int iIndice) {
    if (iIndice < 0 || iIndice >= listFiltrada.length) return;
    setState(() {
      iRegistro = iIndice;
      iPagina   = iIndice ~/ ClaseGenLayout.iFilasPorPagina;
    });
    cargarRegistro(iIndice);
  }

  void modificar() {
    if (iRegistro < 0) return;
    setState(() => enumEstado = EnumEstadoCabDet.modificando);
  }

  void paginaAnterior() { if (iPagina > 0) setState(() => iPagina--); }
  void paginaSiguiente() { if (iPagina < getTotalPaginas() - 1) setState(() => iPagina++); }

  bool validar() {
    final List<ClaseCampoAbm> listTodos = <ClaseCampoAbm>[
      ...widget.listCamposCabecera, ...widget.listCamposPie,
    ];
    for (final ClaseCampoAbm oCampo in listTodos) {
      final String sValor = mapControladores[oCampo.sClave]!.text.trim();
      if (oCampo.bObligatorio) {
        final String? sError = ClaseCapValidar.validarObligatorio(sValor, oCampo.sEtiqueta, getIdioma());
        if (sError != null) {
          mapFocos[oCampo.sClave]!.requestFocus();
          funcMostrarMensaje(context, getIdioma(), widget.sTitulo, sError);
          return false;
        }
      }
      if (oCampo.funcValidarCampo != null) {
        final String? sError = oCampo.funcValidarCampo!(sValor);
        if (sError != null) {
          mapFocos[oCampo.sClave]!.requestFocus();
          funcMostrarMensaje(context, getIdioma(), widget.sTitulo, sError);
          return false;
        }
      }
    }
    bool bTieneCuenta = false;
    for (final Map<String, TextEditingController> oFila in listDetalles) {
      final String sCuenta = (oFila['cuentaNumero']?.text ?? '').trim();
      if (sCuenta.isNotEmpty) {
        bTieneCuenta = true;
        for (final ClaseCampoAbm oCampo in widget.listCamposDetalle) {
          final String sValor = (oFila[oCampo.sClave]?.text ?? '').trim();
          if (oCampo.funcValidarCampo != null) {
            final String? sError = oCampo.funcValidarCampo!(sValor);
            if (sError != null) {
              funcMostrarMensaje(context, getIdioma(), widget.sTitulo, sError);
              return false;
            }
          }
        }
      }
    }
    if (!bTieneCuenta) {
      funcMostrarMensaje(context, getIdioma(), widget.sTitulo, getTexto('asiDetalleVacio'));
      return false;
    }
    if (widget.funcValidarRegistro != null) {
      final Map<String, dynamic> oRegistro = <String, dynamic>{};
      for (final ClaseCampoAbm oCampo in listTodos) {
        oRegistro[oCampo.sClave] = mapControladores[oCampo.sClave]!.text;
      }
      oRegistro['_sumaDebe']  = getSumaDebe().toString();
      oRegistro['_sumaHaber'] = getSumaHaber().toString();
      final String? sError = widget.funcValidarRegistro!(oRegistro);
      if (sError != null) {
        funcMostrarMensaje(context, getIdioma(), widget.sTitulo, sError);
        return false;
      }
    }
    final String? sErrorSuma = ClaseCapValidar.validarSumaDebeHaber(
        getSumaDebe(), getSumaHaber(), getIdioma());
    if (sErrorSuma != null) {
      funcMostrarMensaje(context, getIdioma(), widget.sTitulo, sErrorSuma);
      return false;
    }
    return true;
  }

  // ── Construcción de la interfaz ─────────────────────────────────────────
  @override
  Widget build(BuildContext oContexto) {
    final bool bConPestanas = listGrupos.isNotEmpty;

    return Scaffold(
      appBar : AppBar(
        title : Text(widget.sTitulo,
                    style: ClaseGenEstilosTexto.subtituloGrande(oContexto)),
        bottom: bConPestanas
            ? TabBar(
                controller : oControlPestanas,
                tabs       : <Widget>[
                  for (final String sGrupo in listGrupos)
                    Tab(text: getTexto(sGrupo)),
                ],
              )
            : null,
      ),
      body   : Column(
        children: <Widget>[
          Expanded(
            child: Row(
              crossAxisAlignment : CrossAxisAlignment.stretch,
              children: <Widget>[
                construirGrilla(oContexto),
                Expanded(
                  child: Column(
                    children: <Widget>[
                      if (bConPestanas)
                        Expanded(
                          child: TabBarView(
                            controller : oControlPestanas,
                            children   : <Widget>[
                              for (final String sGrupo in listGrupos)
                                SingleChildScrollView(
                                  padding : const EdgeInsets.all(ClaseGenEspacios.dEspacio16),
                                  child   : construirCamposCabecera(oContexto, sGrupo),
                                ),
                            ],
                          ),
                        )
                      else
                        Expanded(
                          child: SingleChildScrollView(
                            padding : const EdgeInsets.all(ClaseGenEspacios.dEspacio16),
                            child   : construirCamposCabecera(oContexto, null),
                          ),
                        ),
                      Padding(
                        padding : const EdgeInsets.symmetric(
                          horizontal : ClaseGenEspacios.dEspacio16,
                        ),
                        child: Column(
                          crossAxisAlignment : CrossAxisAlignment.start,
                          children          : <Widget>[
                            construirGrillaDetalle(oContexto),
                            const SizedBox(height: ClaseGenEspacios.dEspacio16),
                            construirCampoComentarios(oContexto),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          construirBotones(oContexto),
        ],
      ),
    );
  }

  Widget construirCamposCabecera(BuildContext oContexto, String? sGrupo) {
    final bool bHabilitado = enumEstado == EnumEstadoCabDet.agregando ||
                             enumEstado == EnumEstadoCabDet.modificando;
    final List<ClaseCampoAbm> listFiltrados = (sGrupo == null)
        ? widget.listCamposCabecera.where((o) => o.sGrupo == null).toList()
        : widget.listCamposCabecera.where((o) => o.sGrupo == sGrupo).toList();

    return Wrap(
      runSpacing : ClaseGenEspacios.dEspacio12,
      spacing    : ClaseGenEspacios.dEspacio24,
      children   : <Widget>[
        for (final ClaseCampoAbm oCampo in listFiltrados)
          construirCampoCabecera(oContexto, oCampo, bHabilitado),
      ],
    );
  }

  // ── Campo cabecera (casillas / lista / logico / fecha / hora / texto) ──
  Widget construirCampoCabecera(BuildContext oContexto, ClaseCampoAbm oCampo, bool bHabilitado) {
    final TextEditingController oControl = mapControladores[oCampo.sClave]!;
    final bool bEdit = bHabilitado &&
        !oCampo.bSiempreDeshabilitado &&
        !oCampo.bSoloLecturaPorRol &&
        (oCampo.funcActualizarEstado == null ||
         oCampo.funcActualizarEstado!(getValoresActuales()));

    double dAncho;
    if (oCampo.oTipo == EnumTipoCampoAbm.comentario) {
      dAncho = ClaseGenLayout.dAnchoCampoComentario;
    } else if (oCampo.oTipo == EnumTipoCampoAbm.lista ||
               oCampo.oTipo == EnumTipoCampoAbm.casillas) {
      dAncho = oCampo.iAnchoCaracteres * ClaseGenLayout.dAnchoCaracter
               + ClaseGenLayout.dAnchoIconoFlecha;
    } else if (oCampo.oTipo == EnumTipoCampoAbm.fecha ||
               oCampo.oTipo == EnumTipoCampoAbm.hora) {
      dAncho = oCampo.iAnchoCaracteres * ClaseGenLayout.dAnchoCaracter
               + ClaseGenEspacios.dEspacio24 + ClaseGenLayout.dAnchoIconoBorrar
               + ClaseGenLayout.dAnchoIconoFlecha;
    } else {
      final int iCaracteres = (oCampo.sMascara != null)
          ? oCampo.sMascara!.length
          : oCampo.iAnchoCaracteres;
      dAncho = iCaracteres * ClaseGenLayout.dAnchoCaracter
               + ClaseGenEspacios.dEspacio24 + ClaseGenLayout.dAnchoIconoBorrar;
    }

    // Punto 20: etiquetas de campos numéricos justificadas a la derecha
    final bool bEtiquetaDerecha = oCampo.oTipo == EnumTipoCampoAbm.numero;
    final Widget wEtiqueta = Row(
      mainAxisSize : MainAxisSize.min,
      children     : <Widget>[
        Text(oCampo.sEtiqueta,
            overflow : TextOverflow.ellipsis,
            style    : ClaseGenEstilosTexto.etiquetaCampo(oContexto)),
        if (oCampo.bObligatorio)
          Text(' *',
              style: ClaseGenEstilosTexto.etiquetaCampo(oContexto)
                        .copyWith(color: ClaseGenColores.colorError)),
      ],
    );

    // ── Casillas (checkbox múltiple) ─────────────────────────────────────
    if (oCampo.oTipo == EnumTipoCampoAbm.casillas) {
      final Set<String> setSeleccionadas = oControl.text
          .split(',').where((s) => s.isNotEmpty).toSet();
      return Column(
        crossAxisAlignment : CrossAxisAlignment.start,
        mainAxisSize        : MainAxisSize.min,
        children: <Widget>[
          wEtiqueta,
          const SizedBox(height: ClaseGenEspacios.dEspacio04),
          SizedBox(
            width : dAncho,
            child : Column(
              crossAxisAlignment : CrossAxisAlignment.start,
              children           : <Widget>[
                for (final String sOpcion in (oCampo.listOpciones ?? <String>[]))
                  CheckboxListTile(
                    contentPadding  : EdgeInsets.zero,
                    controlAffinity : ListTileControlAffinity.leading,
                    dense           : true,
                    title           : Text(sOpcion,
                                        style: ClaseGenEstilosTexto.textoCampo(oContexto)),
                    value           : setSeleccionadas.contains(sOpcion),
                    onChanged       : bEdit ? (bValor) {
                      final Set<String> setActual = oControl.text
                          .split(',').where((s) => s.isNotEmpty).toSet();
                      if (bValor == true) {
                        setActual.add(sOpcion);
                      } else {
                        setActual.remove(sOpcion);
                      }
                      oControl.text = setActual.join(',');
                      alCambiarCampo();
                    } : null,
                  ),
              ],
            ),
          ),
        ],
      );
    }

    // ── Lista (dropdown) ─────────────────────────────────────────────────
    if (oCampo.oTipo == EnumTipoCampoAbm.lista) {
      return Column(
        crossAxisAlignment : CrossAxisAlignment.start,
        mainAxisSize        : MainAxisSize.min,
        children: <Widget>[
          wEtiqueta,
          const SizedBox(height: ClaseGenEspacios.dEspacio04),
          SizedBox(
            width : dAncho,
            child : DropdownButton<String>(
              borderRadius : BorderRadius.circular(ClaseGenRadios.dPequeno),
              isExpanded   : true,
              items        : <DropdownMenuItem<String>>[
                for (final String sOpcion in (oCampo.listOpciones ?? <String>[]))
                  DropdownMenuItem<String>(
                    value : sOpcion,
                    child : Text(sOpcion,
                        overflow : TextOverflow.ellipsis,
                        style    : ClaseGenEstilosTexto.textoCampo(oContexto)),
                  ),
              ],
              onChanged : bEdit ? (sValor) {
                oControl.text = sValor ?? '';
                alCambiarCampo();
              } : null,
              underline : const SizedBox.shrink(),
              value     : (oCampo.listOpciones ?? <String>[]).contains(oControl.text)
                              ? oControl.text : null,
            ),
          ),
        ],
      );
    }

    // ── Lógico (Sí/No con checkbox) ──────────────────────────────────────
    if (oCampo.oTipo == EnumTipoCampoAbm.logico) {
      return Column(
        crossAxisAlignment : CrossAxisAlignment.start,
        mainAxisSize        : MainAxisSize.min,
        children: <Widget>[
          wEtiqueta,
          CheckboxListTile(
            contentPadding  : EdgeInsets.zero,
            controlAffinity : ListTileControlAffinity.leading,
            dense           : true,
            title           : Text(oCampo.sEtiqueta,
                               style: ClaseGenEstilosTexto.textoCampo(oContexto)),
            value           : oControl.text.toUpperCase() == 'S',
            onChanged       : bEdit ? (bValor) {
              oControl.text = (bValor ?? false) ? 'S' : 'N';
              alCambiarCampo();
            } : null,
          ),
        ],
      );
    }

    // ── Campo fecha (date picker) ────────────────────────────────────────
    if (oCampo.oTipo == EnumTipoCampoAbm.fecha) {
      return Column(
        crossAxisAlignment : CrossAxisAlignment.start,
        mainAxisSize        : MainAxisSize.min,
        children: <Widget>[
          wEtiqueta,
          const SizedBox(height: ClaseGenEspacios.dEspacio04),
          SizedBox(
            width : dAncho,
            child : TextField(
              controller : oControl,
              enabled    : bEdit,
              readOnly   : true,
              onTap      : bEdit ? () async {
                final String? sFecha = await funcMostrarSelectorFecha(oContexto, oControl.text);
                if (sFecha != null) { oControl.text = sFecha; alCambiarCampo(); }
              } : null,
              style      : ClaseGenEstilosTexto.textoCampo(oContexto),
              decoration : InputDecoration(
                hintText  : oCampo.sHint ?? 'dd/mm/aaaa',
                hintStyle : ClaseGenEstilosTexto.textoCampo(oContexto)
                              .copyWith(color: Theme.of(oContexto).colorScheme.onSurfaceVariant),
                suffixIcon: Row(
                  mainAxisSize : MainAxisSize.min,
                  children     : <Widget>[
                    const Icon(Icons.calendar_month, size: 18),
                    if (bEdit)
                      IconButton(
                        tooltip   : getTexto('borrarCampo'),
                        icon      : const Icon(Icons.close, size: 18),
                        onPressed : () { oControl.clear(); alCambiarCampo(); },
                      ),
                  ],
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(ClaseGenRadios.dPequeno),
                ),
              ),
            ),
          ),
        ],
      );
    }

    // ── Campo hora (time picker) ─────────────────────────────────────────
    if (oCampo.oTipo == EnumTipoCampoAbm.hora) {
      return Column(
        crossAxisAlignment : CrossAxisAlignment.start,
        mainAxisSize        : MainAxisSize.min,
        children: <Widget>[
          wEtiqueta,
          const SizedBox(height: ClaseGenEspacios.dEspacio04),
          SizedBox(
            width : dAncho,
            child : TextField(
              controller : oControl,
              enabled    : bEdit,
              readOnly   : true,
              onTap      : bEdit ? () async {
                final String? sHora = await funcMostrarSelectorHora(oContexto, oControl.text);
                if (sHora != null) { oControl.text = sHora; alCambiarCampo(); }
              } : null,
              style      : ClaseGenEstilosTexto.textoCampo(oContexto),
              decoration : InputDecoration(
                hintText  : oCampo.sHint ?? 'hh:mm',
                hintStyle : ClaseGenEstilosTexto.textoCampo(oContexto)
                              .copyWith(color: Theme.of(oContexto).colorScheme.onSurfaceVariant),
                suffixIcon: Row(
                  mainAxisSize : MainAxisSize.min,
                  children     : <Widget>[
                    const Icon(Icons.schedule, size: 18),
                    if (bEdit)
                      IconButton(
                        tooltip   : getTexto('borrarCampo'),
                        icon      : const Icon(Icons.close, size: 18),
                        onPressed : () { oControl.clear(); alCambiarCampo(); },
                      ),
                  ],
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(ClaseGenRadios.dPequeno),
                ),
              ),
            ),
          ),
        ],
      );
    }

    // ── Campo genérico (texto/número/comentario) ─────────────────────────
    final bool bNumero = oCampo.oTipo == EnumTipoCampoAbm.numero;
    return Column(
      crossAxisAlignment : CrossAxisAlignment.start,
      mainAxisSize        : MainAxisSize.min,
      children: <Widget>[
        wEtiqueta,
        const SizedBox(height: ClaseGenEspacios.dEspacio04),
        SizedBox(
          width : dAncho,
          child : Focus(
            onFocusChange: (bTieneFoco) {
              if (!bTieneFoco && bNumero && oCampo.sMascara != null) {
                final String sSeparador =
                    (widget.oPreferencias.getFormatoNumeros() == 'frances') ? ' ' : '.';
                setState(() {
                  oControl.text = funcFormatearNumero(oControl.text, oCampo.sMascara!, sSeparador);
                });
              }
            },
            child: TextField(
              controller      : oControl,
              enabled         : bEdit,
              focusNode       : mapFocos[oCampo.sClave],
              maxLength       : oCampo.oTipo == EnumTipoCampoAbm.comentario ? oCampo.iMaxComentario : null,
              maxLines        : oCampo.oTipo == EnumTipoCampoAbm.comentario ? 3 : 1,
              onChanged       : (sValor) => alCambiarCampo(),
              style           : ClaseGenEstilosTexto.textoCampo(oContexto),
              textAlign       : bNumero ? TextAlign.right : TextAlign.left,
              inputFormatters : (oCampo.sMascara != null)
                  ? (bNumero)
                      ? <TextInputFormatter>[ClaseFormatoMiles(
                          iMaxDigitos: oCampo.sMascara!.split('')
                              .where((c) => c == '9').length)]
                      : <TextInputFormatter>[ClaseFormatoMascara(sMascara: oCampo.sMascara!)]
                  : null,
              decoration      : InputDecoration(
                counterText : '',
                hintText    : oCampo.sHint,
                hintStyle   : ClaseGenEstilosTexto.textoCampo(oContexto)
                                .copyWith(color: Theme.of(oContexto).colorScheme.onSurfaceVariant),
                suffixIcon  : bEdit
                    ? IconButton(
                        tooltip   : getTexto('borrarCampo'),
                        icon      : const Icon(Icons.close, size: 18),
                        onPressed : () { oControl.clear(); alCambiarCampo(); },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(ClaseGenRadios.dPequeno),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Grilla de detalles (editable, responsive) ───────────────────────────
  Widget construirGrillaDetalle(BuildContext oContexto) {
    final bool bHabilitado = enumEstado == EnumEstadoCabDet.agregando ||
                             enumEstado == EnumEstadoCabDet.modificando;

    return LayoutBuilder(
      builder: (BuildContext oCtxLayout, BoxConstraints oRestricciones) {
        final bool bTarjetas = oRestricciones.maxWidth <
            ClaseGenLayout.dAnchoMinimoGrillaDetalles;
        return bTarjetas
            ? construirDetalleEnTarjetas(oContexto, bHabilitado)
            : construirDetalleEnGrilla(oContexto, bHabilitado);
      },
    );
  }

  // ── Detalle en grilla horizontal (pantallas anchas) ─────────────────────
  Widget construirDetalleEnGrilla(BuildContext oContexto, bool bHabilitado) {
    final ThemeData oTema = Theme.of(oContexto);

    return Container(
      decoration : BoxDecoration(
        border       : Border.all(color: oTema.colorScheme.outlineVariant),
        borderRadius : BorderRadius.circular(ClaseGenRadios.dPequeno),
      ),
      child: SingleChildScrollView(
        scrollDirection : Axis.horizontal,
        child: Column(
          crossAxisAlignment : CrossAxisAlignment.start,
          children          : <Widget>[
            construirEncabezadoDetalle(oContexto),
            for (int iFila = 0; iFila < listDetalles.length; iFila++)
              construirFilaDetalle(oContexto, iFila, bHabilitado),
            construirFilaBotonYTotales(oContexto, bHabilitado),
          ],
        ),
      ),
    );
  }

  Widget construirEncabezadoDetalle(BuildContext oContexto) {
    final ThemeData oTema = Theme.of(oContexto);

    return Container(
      color   : oTema.colorScheme.secondaryContainer,
      padding : const EdgeInsets.symmetric(
        horizontal : ClaseGenEspacios.dEspacio04,
        vertical   : ClaseGenEspacios.dEspacio04,
      ),
      child: Row(
        children: <Widget>[
          for (final ClaseCampoAbm oCampo in widget.listCamposDetalle)
            SizedBox(
              width : calcularAnchoCampo(oCampo),
              child : Padding(
                padding : const EdgeInsets.symmetric(horizontal: ClaseGenEspacios.dEspacio04),
                child   : Text(oCampo.sEtiqueta,
                    textAlign  : (oCampo.oTipo == EnumTipoCampoAbm.numero)
                                     ? TextAlign.right : TextAlign.left,
                    overflow   : TextOverflow.ellipsis,
                    style      : ClaseGenEstilosTexto.etiquetaCampo(oContexto)),
              ),
            ),
          SizedBox(
            width : ClaseGenLayout.dAnchoIconoBorrar,
            child : Text('', style: ClaseGenEstilosTexto.etiquetaCampo(oContexto)),
          ),
        ],
      ),
    );
  }

  Widget construirFilaDetalle(BuildContext oContexto, int iFila, bool bHabilitado) {
    final Map<String, TextEditingController> oFila = listDetalles[iFila];

    return GestureDetector(
      key                : listLlavesFilas[iFila],
      behavior           : HitTestBehavior.opaque,
      onSecondaryTapDown : (oDet) => mostrarMenuDetalle(oContexto, oDet.globalPosition, iFila),
      onLongPressStart   : (oDet) => mostrarMenuDetalle(oContexto, oDet.globalPosition, iFila),
      child: Container(
        padding : const EdgeInsets.symmetric(
          horizontal : ClaseGenEspacios.dEspacio04,
          vertical   : ClaseGenEspacios.dEspacio02,
        ),
        decoration : BoxDecoration(
          border : Border(bottom: BorderSide(
              color: Theme.of(oContexto).colorScheme.outlineVariant)),
        ),
        child: Row(
          children: <Widget>[
            for (final ClaseCampoAbm oCampo in widget.listCamposDetalle)
              SizedBox(
                width : calcularAnchoCampo(oCampo),
                child : Padding(
                  padding : const EdgeInsets.symmetric(horizontal: ClaseGenEspacios.dEspacio02),
                  child   : TextField(
                    controller      : oFila[oCampo.sClave],
                    enabled         : bHabilitado,
                    style           : ClaseGenEstilosTexto.textoCampo(oContexto),
                    textAlign       : (oCampo.oTipo == EnumTipoCampoAbm.numero)
                                          ? TextAlign.right : TextAlign.left,
                    onChanged       : (sValor) {
                      if (oCampo.sClave == 'debe' && sValor.isNotEmpty) {
                        oFila['haber']?.text = '0';
                      } else if (oCampo.sClave == 'haber' && sValor.isNotEmpty) {
                        oFila['debe']?.text = '0';
                      }
                      setState(() {});
                    },
                    inputFormatters : (oCampo.sMascara != null)
                        ? (oCampo.oTipo == EnumTipoCampoAbm.numero)
                            ? <TextInputFormatter>[ClaseFormatoMiles(
                                iMaxDigitos: oCampo.sMascara!.split('')
                                    .where((c) => c == '9').length)]
                            : <TextInputFormatter>[ClaseFormatoMascara(sMascara: oCampo.sMascara!)]
                        : null,
                    decoration      : InputDecoration(
                      isDense   : true,
                      hintText  : oCampo.sHint,
                      hintStyle : ClaseGenEstilosTexto.textoCampo(oContexto)
                                    .copyWith(color: Theme.of(oContexto).colorScheme.onSurfaceVariant),
                      border    : OutlineInputBorder(
                        borderRadius: BorderRadius.circular(ClaseGenRadios.dMuyPequeno),
                      ),
                    ),
                  ),
                ),
              ),
            SizedBox(
              width : ClaseGenLayout.dAnchoIconoBorrar,
              child : bHabilitado
                  ? IconButton(
                      tooltip   : getTexto('asiBorrarFila'),
                      icon      : const Icon(Icons.delete_outline, size: 18),
                      onPressed : () => borrarDetalle(iFila),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget construirFilaBotonYTotales(BuildContext oContexto, bool bHabilitado) {
    final bool  bSumasIguales = getSumaDebe() == getSumaHaber();
    final int   iIndiceDebe   = widget.listCamposDetalle.indexWhere((o) => o.sClave == 'debe');
    final Color colorFondo    = bSumasIguales
        ? ClaseGenColores.colorVerde1
        : ClaseGenColores.colorNaranja1;
    final Color colorTexto    = ClaseGenColores.colorBlanco;

    final double dAnchoAntes = calcularAnchoAntesDelDebe();
    final double dAnchoDebe  = calcularAnchoCampo(widget.listCamposDetalle[iIndiceDebe]);
    final double dAnchoHaber = calcularAnchoCampo(widget.listCamposDetalle[iIndiceDebe + 1]);

    return Container(
      padding : const EdgeInsets.symmetric(
        horizontal : ClaseGenEspacios.dEspacio04,
        vertical   : ClaseGenEspacios.dEspacio04,
      ),
      child: Row(
        crossAxisAlignment : CrossAxisAlignment.center,
        children: <Widget>[
          SizedBox(
            width : dAnchoAntes,
            child : Row(
              children: <Widget>[
                if (bHabilitado)
                  OutlinedButton.icon(
                    onPressed : agregarDetalle,
                    icon      : const Icon(Icons.add),
                    label     : Text(getTexto('asiAgregarFila'),
                                style: ClaseGenEstilosTexto.normalChico(oContexto)),
                  ),
                const Spacer(),
                Padding(
                  padding : const EdgeInsets.only(right: ClaseGenEspacios.dEspacio08),
                  child   : Text(getTexto('asiTotales'),
                              style: ClaseGenEstilosTexto.subtituloMediano(oContexto)),
                ),
              ],
            ),
          ),
          Container(
            width      : dAnchoDebe,
            padding    : const EdgeInsets.symmetric(
              horizontal : ClaseGenEspacios.dEspacio08,
              vertical   : ClaseGenEspacios.dEspacio04,
            ),
            decoration : BoxDecoration(
              color        : colorFondo,
              borderRadius : BorderRadius.circular(ClaseGenRadios.dMuyPequeno),
            ),
            child : Text(funcFormatearEnteroMiles(getSumaDebe()),
                     textAlign : TextAlign.right,
                     style     : ClaseGenEstilosTexto.textoCampo(oContexto)
                                   .copyWith(fontWeight: FontWeight.w700, color: colorTexto)),
          ),
          Container(
            width      : dAnchoHaber,
            padding    : const EdgeInsets.symmetric(
              horizontal : ClaseGenEspacios.dEspacio08,
              vertical   : ClaseGenEspacios.dEspacio04,
            ),
            decoration : BoxDecoration(
              color        : colorFondo,
              borderRadius : BorderRadius.circular(ClaseGenRadios.dMuyPequeno),
            ),
            child : Text(funcFormatearEnteroMiles(getSumaHaber()),
                     textAlign : TextAlign.right,
                     style     : ClaseGenEstilosTexto.textoCampo(oContexto)
                                   .copyWith(fontWeight: FontWeight.w700, color: colorTexto)),
          ),
        ],
      ),
    );
  }

  // ── Detalle en tarjetas (pantallas angostas / teléfono) ─────────────────
  Widget construirDetalleEnTarjetas(BuildContext oContexto, bool bHabilitado) {
    final ThemeData oTema = Theme.of(oContexto);

    return Container(
      decoration : BoxDecoration(
        border       : Border.all(color: oTema.colorScheme.outlineVariant),
        borderRadius : BorderRadius.circular(ClaseGenRadios.dPequeno),
      ),
      child: Column(
        mainAxisSize : MainAxisSize.min,
        children     : <Widget>[
          for (int iFila = 0; iFila < listDetalles.length; iFila++)
            construirTarjetaDetalle(oContexto, iFila, bHabilitado),
          construirFilaTotalesTarjeta(oContexto, bHabilitado),
        ],
      ),
    );
  }

  Widget construirTarjetaDetalle(BuildContext oContexto, int iFila, bool bHabilitado) {
    final int iNumeroFila = iFila + 1;

    return GestureDetector(
      key                : listLlavesFilas[iFila],
      behavior           : HitTestBehavior.opaque,
      onSecondaryTapDown : (oDet) => mostrarMenuDetalle(oContexto, oDet.globalPosition, iFila),
      onLongPressStart   : (oDet) => mostrarMenuDetalle(oContexto, oDet.globalPosition, iFila),
      child: Card(
        margin : const EdgeInsets.symmetric(
          horizontal : ClaseGenEspacios.dEspacio08,
          vertical   : ClaseGenEspacios.dEspacio04,
        ),
        child: Padding(
          padding : const EdgeInsets.all(ClaseGenEspacios.dEspacio08),
          child   : Column(
            crossAxisAlignment : CrossAxisAlignment.start,
            children            : <Widget>[
              Row(
                children: <Widget>[
                  Text('${getTexto('asiFila')} $iNumeroFila',
                      style: ClaseGenEstilosTexto.subtituloMediano(oContexto)),
                  const Spacer(),
                  if (bHabilitado)
                    IconButton(
                      tooltip   : getTexto('asiBorrarFila'),
                      icon      : const Icon(Icons.delete_outline, size: 20),
                      onPressed : () => borrarDetalle(iFila),
                    ),
                ],
              ),
              const SizedBox(height: ClaseGenEspacios.dEspacio04),
              for (final ClaseCampoAbm oCampo in widget.listCamposDetalle)
                construirCampoTarjetaDetalle(oContexto, iFila, oCampo, bHabilitado),
            ],
          ),
        ),
      ),
    );
  }

  Widget construirCampoTarjetaDetalle(
    BuildContext  oContexto,
    int           iFila,
    ClaseCampoAbm oCampo,
    bool          bHabilitado,
  ) {
    final Map<String, TextEditingController> oFila       = listDetalles[iFila];
    final TextEditingController              oControl    = oFila[oCampo.sClave]!;
    final bool                               bComentario = oCampo.oTipo == EnumTipoCampoAbm.comentario;
    final bool                               bNumero     = oCampo.oTipo == EnumTipoCampoAbm.numero;

    // Punto 20: etiquetas de campos numéricos justificadas a la derecha
    final Widget wEtiqueta = bComentario
        ? SizedBox(
            width : double.infinity,
            child : Row(
              mainAxisAlignment : MainAxisAlignment.spaceBetween,
              children          : <Widget>[
                Row(
                  mainAxisSize : MainAxisSize.min,
                  children     : <Widget>[
                    Text(oCampo.sEtiqueta,
                        overflow : TextOverflow.ellipsis,
                        style    : ClaseGenEstilosTexto.etiquetaCampo(oContexto)),
                    if (oCampo.bObligatorio)
                      Text(' *',
                          style: ClaseGenEstilosTexto.etiquetaCampo(oContexto)
                                    .copyWith(color: ClaseGenColores.colorError)),
                  ],
                ),
                Text('${oControl.text.length}/${oCampo.iMaxComentario}',
                     style: ClaseGenEstilosTexto.normalChico(oContexto)),
              ],
            ),
          )
        : Row(
            mainAxisSize : MainAxisSize.min,
            children     : <Widget>[
              Text(oCampo.sEtiqueta,
                  overflow : TextOverflow.ellipsis,
                  style    : ClaseGenEstilosTexto.etiquetaCampo(oContexto)),
              if (oCampo.bObligatorio)
                Text(' *',
                    style: ClaseGenEstilosTexto.etiquetaCampo(oContexto)
                              .copyWith(color: ClaseGenColores.colorError)),
            ],
          );
    return Padding(
      padding : const EdgeInsets.only(bottom: ClaseGenEspacios.dEspacio08),
    // Después:
        child   : Column(
          crossAxisAlignment : bNumero
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
        children            : <Widget>[
          wEtiqueta,
          const SizedBox(height: ClaseGenEspacios.dEspacio04),
          TextField(
            controller      : oControl,
            enabled         : bHabilitado,
            maxLength       : bComentario ? oCampo.iMaxComentario : null,
            maxLines        : bComentario ? 3 : 1,
            onChanged       : (sValor) {
              if (oCampo.sClave == 'debe' && sValor.isNotEmpty) {
                oFila['haber']?.text = '0';
              } else if (oCampo.sClave == 'haber' && sValor.isNotEmpty) {
                oFila['debe']?.text = '0';
              }
              setState(() {});
            },
            style           : ClaseGenEstilosTexto.textoCampo(oContexto),
            textAlign       : bNumero ? TextAlign.right : TextAlign.left,
            inputFormatters : (oCampo.sMascara != null)
                ? (bNumero)
                    ? <TextInputFormatter>[ClaseFormatoMiles(
                        iMaxDigitos: oCampo.sMascara!.split('')
                            .where((c) => c == '9').length)]
                    : <TextInputFormatter>[ClaseFormatoMascara(sMascara: oCampo.sMascara!)]
                : null,
            decoration      : InputDecoration(
              counterText : '',
              hintText    : oCampo.sHint,
              hintStyle   : ClaseGenEstilosTexto.textoCampo(oContexto)
                              .copyWith(color: Theme.of(oContexto).colorScheme.onSurfaceVariant),
              suffixIcon  : bHabilitado
                  ? IconButton(
                      tooltip   : getTexto('borrarCampo'),
                      icon      : const Icon(Icons.close, size: 18),
                      onPressed : () => setState(() => oControl.clear()),
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(ClaseGenRadios.dPequeno),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget construirFilaTotalesTarjeta(BuildContext oContexto, bool bHabilitado) {
    final bool  bSumasIguales = getSumaDebe() == getSumaHaber();
    final Color colorFondo    = bSumasIguales
        ? ClaseGenColores.colorVerde1
        : ClaseGenColores.colorNaranja1;
    final Color colorTexto    = ClaseGenColores.colorBlanco;

    return Padding(
      padding : const EdgeInsets.all(ClaseGenEspacios.dEspacio08),
      child   : Column(
        children: <Widget>[
          if (bHabilitado)
            SizedBox(
              width  : double.infinity,
              child  : OutlinedButton.icon(
                onPressed : agregarDetalle,
                icon      : const Icon(Icons.add),
                label     : Text(getTexto('asiAgregarFila'),
                            style: ClaseGenEstilosTexto.normalChico(oContexto)),
              ),
            ),
          const SizedBox(height: ClaseGenEspacios.dEspacio08),
          Container(
            width      : double.infinity,
            padding    : const EdgeInsets.all(ClaseGenEspacios.dEspacio08),
            decoration : BoxDecoration(
              color        : colorFondo,
              borderRadius : BorderRadius.circular(ClaseGenRadios.dPequeno),
            ),
            child: Column(
              children: <Widget>[
                Text(getTexto('asiTotales'),
                    style: ClaseGenEstilosTexto.subtituloMediano(oContexto)
                        .copyWith(color: colorTexto)),
                const SizedBox(height: ClaseGenEspacios.dEspacio04),
                Row(
                  mainAxisAlignment : MainAxisAlignment.spaceBetween,
                  children          : <Widget>[
                    Text(getTexto('asiDebe'),
                        style: ClaseGenEstilosTexto.textoCampo(oContexto)
                            .copyWith(fontWeight: FontWeight.w700, color: colorTexto)),
                    Text(funcFormatearEnteroMiles(getSumaDebe()),
                        style: ClaseGenEstilosTexto.textoCampo(oContexto)
                            .copyWith(fontWeight: FontWeight.w700, color: colorTexto)),
                  ],
                ),
                Row(
                  mainAxisAlignment : MainAxisAlignment.spaceBetween,
                  children          : <Widget>[
                    Text(getTexto('asiHaber'),
                        style: ClaseGenEstilosTexto.textoCampo(oContexto)
                            .copyWith(fontWeight: FontWeight.w700, color: colorTexto)),
                    Text(funcFormatearEnteroMiles(getSumaHaber()),
                        style: ClaseGenEstilosTexto.textoCampo(oContexto)
                            .copyWith(fontWeight: FontWeight.w700, color: colorTexto)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Menú contextual de filas de detalle ─────────────────────────────────
  Future<void> mostrarMenuDetalle(
    BuildContext oContexto,
    Offset      oPosicion,
    int         iFila,
  ) async {
    final bool bHabilitado = enumEstado == EnumEstadoCabDet.agregando ||
                             enumEstado == EnumEstadoCabDet.modificando;
    final String? sElegido = await showMenu<String>(
      context  : oContexto,
      position : RelativeRect.fromRect(
        Rect.fromLTWH(oPosicion.dx, oPosicion.dy, 0, 0),
        Offset.zero & MediaQuery.sizeOf(oContexto),
      ),
      items: <PopupMenuEntry<String>>[
        crearItemMenu(oContexto, 'subirFila', getTexto('menuSubirFila'), Icons.arrow_upward,
            bHabilitado: bHabilitado && iFila > 0),
        crearItemMenu(oContexto, 'bajarFila', getTexto('menuBajarFila'), Icons.arrow_downward,
            bHabilitado: bHabilitado && iFila < listDetalles.length - 1),
        const PopupMenuDivider(),
        crearItemMenu(oContexto, 'primeraFila', getTexto('menuPrimeraFila'), Icons.first_page,
            bHabilitado: listDetalles.isNotEmpty),
        crearItemMenu(oContexto, 'ultimaFila', getTexto('menuUltimaFila'), Icons.last_page,
            bHabilitado: listDetalles.isNotEmpty),
      ],
    );
    if (sElegido == null) return;
    if (sElegido == 'subirFila') {
      subirFila(iFila);
    } else if (sElegido == 'bajarFila') {
      bajarFila(iFila);
    } else if (sElegido == 'primeraFila') {
      await irAFilaDetalle(0);
    } else if (sElegido == 'ultimaFila') {
      await irAFilaDetalle(listDetalles.length - 1);
    }
  }

  PopupMenuItem<String> crearItemMenu(
    BuildContext oContexto,
    String       sValor,
    String       sTexto,
    IconData     oIcono, {
    bool bHabilitado = true,
  }) {
    return PopupMenuItem<String>(
      value   : sValor,
      enabled : bHabilitado,
      child   : Row(
        children: <Widget>[
          Icon(oIcono, size: 18),
          const SizedBox(width: ClaseGenEspacios.dEspacio08),
          Flexible(
            child: Text(sTexto,
                overflow : TextOverflow.ellipsis,
                style    : ClaseGenEstilosTexto.normalChico(oContexto)),
          ),
        ],
      ),
    );
  }

  // ── Campo Comentarios ───────────────────────────────────────────────────
  Widget construirCampoComentarios(BuildContext oContexto) {
    final ClaseCampoAbm oCampo = widget.listCamposPie.first;
    final TextEditingController oControl = mapControladores[oCampo.sClave]!;
    final bool bHabilitado = enumEstado == EnumEstadoCabDet.agregando ||
                             enumEstado == EnumEstadoCabDet.modificando;

    return Column(
      crossAxisAlignment : CrossAxisAlignment.start,
      children          : <Widget>[
        Row(
          children: <Widget>[
            Text(oCampo.sEtiqueta, style: ClaseGenEstilosTexto.etiquetaCampo(oContexto)),
            const Spacer(),
            Text('${oControl.text.length}/${oCampo.iMaxComentario}',
                 style: ClaseGenEstilosTexto.normalChico(oContexto)),
          ],
        ),
        const SizedBox(height: ClaseGenEspacios.dEspacio04),
        TextField(
          controller  : oControl,
          enabled     : bHabilitado,
          maxLines    : 3,
          maxLength   : oCampo.iMaxComentario,
          onChanged   : (sValor) => alCambiarCampo(),
          style       : ClaseGenEstilosTexto.textoCampo(oContexto),
          decoration  : InputDecoration(
            counterText : '',
            hintText    : oCampo.sHint,
            hintStyle   : ClaseGenEstilosTexto.textoCampo(oContexto)
                            .copyWith(color: Theme.of(oContexto).colorScheme.onSurfaceVariant),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(ClaseGenRadios.dPequeno),
            ),
          ),
        ),
      ],
    );
  }

  // ── Grilla de registros (izquierda) ─────────────────────────────────────
  Widget construirGrilla(BuildContext oContexto) {
    final ThemeData oTema   = Theme.of(oContexto);
    final int       iInicio = iPagina * ClaseGenLayout.iFilasPorPagina;
    final int       iFin    = min(iInicio + ClaseGenLayout.iFilasPorPagina, listFiltrada.length);
    final double    dAnchoExpandido = max(
        ClaseGenLayout.dAnchoGrillaAbm,
        min(ClaseGenLayout.dAnchoReferencia * 0.75,
            MediaQuery.sizeOf(oContexto).width * 0.75),
    );
    final List<Map<String, dynamic>> listPagina =
        (iInicio < listFiltrada.length) ? listFiltrada.sublist(iInicio, iFin) : <Map<String, dynamic>>[];

    return AnimatedContainer(
      duration  : const Duration(milliseconds: 250),
      width     : bGrillaExpandida ? dAnchoExpandido
                                   : ClaseGenLayout.dAnchoGrillaAbm,
      decoration: BoxDecoration(
        color  : oTema.colorScheme.surfaceContainerLow,
        border : Border(right: BorderSide(color: oTema.colorScheme.outlineVariant)),
      ),
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment : MainAxisAlignment.center,
            children          : <Widget>[
              IconButton(
                tooltip   : getTexto('paginaAnterior'),
                icon      : const Icon(Icons.arrow_upward),
                onPressed : iPagina > 0 ? paginaAnterior : null,
              ),
              Text('${iPagina + 1} / ${getTotalPaginas()}',
                   style: ClaseGenEstilosTexto.normalChico(oContexto)),
              IconButton(
                tooltip   : getTexto('paginaSiguiente'),
                icon      : const Icon(Icons.arrow_downward),
                onPressed : iPagina < getTotalPaginas() - 1 ? paginaSiguiente : null,
              ),
            ],
          ),
          Container(
            color   : oTema.colorScheme.secondaryContainer,
            padding : const EdgeInsets.symmetric(
              horizontal : ClaseGenEspacios.dEspacio08,
              vertical   : ClaseGenEspacios.dEspacio04,
            ),
            child: Row(
              children: <Widget>[
                for (final ClaseCampoAbm oCampo in widget.listCamposCabecera.where((o) => o.bEnGrilla))
                  Expanded(
                    child: construirCabeceraColumna(oContexto, oCampo),
                  ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount  : listPagina.length,
              itemBuilder: (oContextoLista, iIndice) {
                final int  iGlobal = iInicio + iIndice;
                final bool bSel    = iGlobal == iRegistro;
                return InkWell(
                  onTap : () => cargarRegistro(iGlobal),
                  child : Container(
                    height  : ClaseGenLayout.dAltoFilaGrillaAbm,
                    color   : bSel ? oTema.colorScheme.primaryContainer : null,
                    padding : const EdgeInsets.symmetric(horizontal: ClaseGenEspacios.dEspacio08),
                    child: Row(
                      children: <Widget>[
                        for (final ClaseCampoAbm oCampo in widget.listCamposCabecera.where((o) => o.bEnGrilla))
                          Expanded(
                            child: GestureDetector(
                              behavior           : HitTestBehavior.opaque,
                              onSecondaryTapDown : (oDet) => mostrarMenuGrilla(
                                  oContexto, oDet.globalPosition, iGlobal, oCampo),
                              onLongPressStart   : (oDet) => mostrarMenuGrilla(
                                  oContexto, oDet.globalPosition, iGlobal, oCampo),
                              child : Text(
                                getValorGrilla(listPagina[iIndice], oCampo),
                                overflow : TextOverflow.ellipsis,
                                style    : ClaseGenEstilosTexto.textoCampo(oContexto),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Row(
            children: <Widget>[
              IconButton(
                tooltip   : getTexto('informes'),
                icon      : const Icon(Icons.print_outlined),
                onPressed : null,
              ),
              IconButton(
                tooltip   : bGrillaExpandida ? getTexto('contraerGrilla') : getTexto('expandirGrilla'),
                icon      : const Icon(Icons.swap_horiz),
                onPressed : () => setState(() => bGrillaExpandida = !bGrillaExpandida),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget construirCabeceraColumna(BuildContext oContexto, ClaseCampoAbm oCampo) {
    final bool bActivo = iColOrden == widget.listCamposCabecera.indexOf(oCampo);
    return Tooltip(
      message : '${getTexto('ordenarPor')}: ${oCampo.sEtiqueta}',
      child   : GestureDetector(
        behavior : HitTestBehavior.opaque,
        onTap    : () => ordenarPor(oCampo),
        child    : Row(
          mainAxisSize : MainAxisSize.min,
          children     : <Widget>[
            Flexible(
              child: Text(oCampo.sEtiqueta,
                  overflow : TextOverflow.ellipsis,
                  style    : ClaseGenEstilosTexto.etiquetaCampo(oContexto).copyWith(
                      fontWeight: bActivo ? FontWeight.w700 : null)),
            ),
            if (bActivo)
              Padding(
                padding : const EdgeInsets.only(left: ClaseGenEspacios.dEspacio04),
                child   : Icon(
                  bOrdenAscendente ? Icons.arrow_upward : Icons.arrow_downward,
                  size  : 14,
                  color : Theme.of(oContexto).colorScheme.primary,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> mostrarMenuGrilla(
    BuildContext  oContexto,
    Offset        oPosicion,
    int           iIndice,
    ClaseCampoAbm oCampo,
  ) async {
    final bool bEnEdicion = enumEstado == EnumEstadoCabDet.agregando ||
                            enumEstado == EnumEstadoCabDet.modificando ||
                            enumEstado == EnumEstadoCabDet.encontrando;
    final bool bHayFilas  = listFiltrada.isNotEmpty;
    final String? sElegido = await showMenu<String>(
      context  : oContexto,
      position : RelativeRect.fromRect(
        Rect.fromLTWH(oPosicion.dx, oPosicion.dy, 0, 0),
        Offset.zero & MediaQuery.sizeOf(oContexto),
      ),
      items: <PopupMenuEntry<String>>[
        crearItemMenu(oContexto, 'copiarValor', getTexto('menuCopiarValor'), Icons.copy),
        crearItemMenu(oContexto, 'copiarFila',  getTexto('menuCopiarFila'), Icons.copy_all),
        crearItemMenu(oContexto, 'buscarValor', getTexto('menuBuscarValor'), Icons.search,
            bHabilitado: !bEnEdicion),
        const PopupMenuDivider(),
        crearItemMenu(oContexto, 'primeraFila', getTexto('menuPrimeraFila'), Icons.first_page,
            bHabilitado: !bEnEdicion && bHayFilas),
        crearItemMenu(oContexto, 'ultimaFila',  getTexto('menuUltimaFila'), Icons.last_page,
            bHabilitado: !bEnEdicion && bHayFilas),
        const PopupMenuDivider(),
        crearItemMenu(oContexto, 'actualizar',  getTexto('menuActualizar'), Icons.refresh,
            bHabilitado: !bEnEdicion),
      ],
    );
    if (sElegido == null || !mounted) return;
    if (sElegido == 'copiarValor') {
      await copiarValor(iIndice, oCampo);
    } else if (sElegido == 'copiarFila') {
      await copiarFila(iIndice);
    } else if (sElegido == 'buscarValor') {
      buscarPorValor(iIndice, oCampo);
    } else if (sElegido == 'primeraFila') {
      irAFila(0);
    } else if (sElegido == 'ultimaFila') {
      irAFila(listFiltrada.length - 1);
    } else if (sElegido == 'actualizar') {
      await actualizar();
    }
  }

  // ── Botones ABM ─────────────────────────────────────────────────────────
  Widget construirBotones(BuildContext oContexto) {
    final bool bEnEdicion      = enumEstado == EnumEstadoCabDet.agregando ||
                                 enumEstado == EnumEstadoCabDet.modificando ||
                                 enumEstado == EnumEstadoCabDet.encontrando;
    final bool bHayDatos       = widget.listRegistros.isNotEmpty;
    final bool bPuedeAgregar   = !bEnEdicion;
    final bool bPuedeEncontrar = !bEnEdicion && bHayDatos && widget.bPermitirEncontrar;
    final String sTextoGrabar  = (enumEstado == EnumEstadoCabDet.encontrando)
        ? getTexto('abmBuscar') : getTexto('abmGrabar');

    return Container(
      color   : Theme.of(oContexto).colorScheme.surfaceContainerLow,
      padding : const EdgeInsets.all(ClaseGenEspacios.dEspacio08),
      child   : Wrap(
        alignment  : WrapAlignment.center,
        spacing    : ClaseGenEspacios.dEspacio08,
        runSpacing : ClaseGenEspacios.dEspacio08,
        children   : <Widget>[
          construirBoton(oContexto, Icons.add,                getTexto('abmAgregar'),   bPuedeAgregar ? agregar : null),
          construirBoton(oContexto, Icons.remove,             getTexto('abmBorrar'),    (!bEnEdicion && bHayDatos && iRegistro >= 0) ? borrar : null),
          construirBoton(oContexto, Icons.edit_outlined,      getTexto('abmModificar'), (!bEnEdicion && bHayDatos && iRegistro >= 0) ? modificar : null),
          construirBoton(oContexto, Icons.check,              sTextoGrabar,             bEnEdicion ? grabar : null, bEsDestacado: true),
          construirBoton(oContexto, Icons.cancel_outlined,    getTexto('abmCancelar'),  bEnEdicion ? cancelar : null),
          construirBoton(oContexto, Icons.search,             getTexto('abmEncontrar'), bPuedeEncontrar ? encontrar : null),
          construirBoton(oContexto, Icons.power_settings_new, getTexto('abmFin'),       bEnEdicion ? null : fin),
        ],
      ),
    );
  }

  Widget construirBoton(
    BuildContext  oContexto,
    IconData      oIcono,
    String        sTexto,
    VoidCallback? funcAlPulsar, {
    bool bEsDestacado = false,
  }) {
    final ColorScheme oEsquema = Theme.of(oContexto).colorScheme;
    final Widget wEtiqueta = Text(sTexto,
        overflow : TextOverflow.ellipsis,
        style    : ClaseGenEstilosTexto.normalMediano(oContexto));
    return SizedBox(
      width  : ClaseGenLayout.dAnchoBotonAbm,
      height : ClaseGenLayout.dAltoBotonAbm,
      child  : FilledButton.icon(
        onPressed : funcAlPulsar,
        icon      : Icon(oIcono),
        label     : wEtiqueta,
        style     : FilledButton.styleFrom(
          backgroundColor         : bEsDestacado
                                      ? oEsquema.tertiary
                                      : oEsquema.primary,
          foregroundColor         : bEsDestacado
                                      ? oEsquema.onTertiary
                                      : oEsquema.onPrimary,
          disabledBackgroundColor : oEsquema.surfaceContainerHigh,
          disabledForegroundColor : oEsquema.onSurfaceVariant,
        ),
      ),
    );
  }

}
