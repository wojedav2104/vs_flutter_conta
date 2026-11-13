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


/// Estado de un formulario ABM.
enum EnumEstadoAbm { agregando, encontrando, inicial, modificando }


/// Clase común para todos los formularios ABM.
///
/// Si los campos tienen sGrupo, la AppBar muestra los nombres de los grupos
/// como pestañas. Los campos sin sGrupo se muestran siempre, fuera de las
/// pestañas (datos comunes).
///
/// La grilla lateral se ordena con clic en la cabecera de la columna
/// (ascendente/descendente, con flecha indicadora) y tiene menú contextual
/// con clic derecho (escritorio/web) o presión larga (teléfono).
class ClaseFormularioAbm extends StatefulWidget {

  const ClaseFormularioAbm({
    super.key,
    required this.listCampos,
    required this.listRegistros,
    required this.oPreferencias,
    required this.sTitulo,
    this.bPermitirEncontrar   = true,
    this.bTablaUnSoloRegistro = false,
    this.funcAlActualizar,
    this.funcAlBorrar,
    this.funcAlGrabar,
    this.funcActualizarCampos,
    this.funcValidarRegistro,
  });

  final bool bPermitirEncontrar;
  final bool bTablaUnSoloRegistro;
  final Future<String?> Function()?                                              funcAlActualizar;
  final Future<String?> Function(Map<String, dynamic> oRegistro)?                funcAlBorrar;
  final Future<String?> Function(Map<String, dynamic> oRegistro, bool bEsNuevo)? funcAlGrabar;
  final List<ClaseCampoAbm>                                                      listCampos;
  final List<Map<String, dynamic>>                                               listRegistros;
  final ClasePreferencias                                                        oPreferencias;
  final String                                                                   sTitulo;

  /// Devuelve un mapa de campos a actualizar automáticamente, o null.
  final Map<String, String>? Function(Map<String, String> mapValores)?           funcActualizarCampos;

  /// Validación cruzada del registro completo.
  final String? Function(Map<String, dynamic> oRegistro)?                        funcValidarRegistro;

  @override
  State<ClaseFormularioAbm> createState() => ClaseEstadoFormularioAbm();
}

class ClaseEstadoFormularioAbm extends State<ClaseFormularioAbm>
    with SingleTickerProviderStateMixin {

  bool bGrillaExpandida = false;
  bool bOrdenAscendente = true;

  EnumEstadoAbm enumEstado = EnumEstadoAbm.inicial;

  int iColOrden = -1;
  int iPagina   = 0;
  int iRegistro = -1;

  late TabController oControlPestanas;

  final Map<String, FocusNode>             mapFocos         = <String, FocusNode>{};
  final Map<String, TextEditingController> mapControladores = <String, TextEditingController>{};

  List<Map<String, dynamic>> listFiltrada = <Map<String, dynamic>>[];
  List<String>               listGrupos   = <String>[];

  @override
  void initState() {
    super.initState();
    for (final ClaseCampoAbm oCampo in widget.listCampos) {
      mapControladores[oCampo.sClave] = TextEditingController();
      mapFocos[oCampo.sClave]         = FocusNode();
      if (oCampo.sGrupo != null && !listGrupos.contains(oCampo.sGrupo)) {
        listGrupos.add(oCampo.sGrupo!);
      }
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

  /// Ancho en caracteres de un campo dentro de la grilla (máximo 20).
  int getAnchoGrilla(ClaseCampoAbm oCampo) {
    return (oCampo.iAnchoCaracteres > ClaseGenLayout.iMaxCaracteresCampoGrilla)
        ? ClaseGenLayout.iMaxCaracteresCampoGrilla
        : oCampo.iAnchoCaracteres;
  }

  /// Campos visibles en la grilla según el ancho disponible.
  List<ClaseCampoAbm> getCamposGrilla() {
    final int iLimite = bGrillaExpandida
        ? ClaseGenLayout.iCaracteresGrillaAbierta
        : ClaseGenLayout.iCaracteresGrillaCerrada;
    int iAcumulado = 0;
    final List<ClaseCampoAbm> listVisibles = <ClaseCampoAbm>[];
    for (final ClaseCampoAbm oCampo in widget.listCampos.where((o) => o.bEnGrilla)) {
      final int iAncho = getAnchoGrilla(oCampo);
      if (listVisibles.length >= 2 && iAcumulado + iAncho > iLimite) break;
      listVisibles.add(oCampo);
      iAcumulado += iAncho;
    }
    return listVisibles;
  }

  /// Texto truncado para la grilla (máximo 20 caracteres por campo).
  String truncarTextoGrilla(String sValor, ClaseCampoAbm oCampo) {
    final int iAncho = getAnchoGrilla(oCampo);
    return (sValor.length > iAncho) ? sValor.substring(0, iAncho) : sValor;
  }

  /// Obtiene los valores actuales de todos los campos.
  Map<String, String> getValoresActuales() {
    final Map<String, String> mapValores = <String, String>{};
    for (final ClaseCampoAbm oCampo in widget.listCampos) {
      mapValores[oCampo.sClave] = mapControladores[oCampo.sClave]!.text;
    }
    return mapValores;
  }

  /// Se llama cuando cambia cualquier campo. Actualiza campos dependientes.
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

  // ── Orden de la grilla ──────────────────────────────────────────────────
  /// Número con separadores de miles/decimales a num (para ordenar).
  num? getNumeroOrden(String sValor) {
    final String sLimpio = sValor.trim()
        .replaceAll(' ', '')
        .replaceAll('.', '')
        .replaceAll(',', '.');
    return num.tryParse(sLimpio);
  }

  /// Fecha (dd/mm/aaaa o similar) a DateTime (para ordenar).
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

  /// Hora (hh:mm) a minutos totales (para ordenar).
  int? getMinutosOrden(String sValor) {
    final List<String> listPartes = sValor.split(':');
    if (listPartes.length != 2) return null;
    final int? iHora   = int.tryParse(listPartes[0]);
    final int? iMinuto = int.tryParse(listPartes[1]);
    if (iHora == null || iMinuto == null) return null;
    return iHora * 60 + iMinuto;
  }

  /// Compara dos registros según la columna ordenada (iColOrden).
  /// Los valores vacíos van siempre al final, en ambos sentidos.
  int compararRegistros(Map<String, dynamic> oA, Map<String, dynamic> oB) {
    if (iColOrden < 0) return 0;
    final ClaseCampoAbm oCampo = widget.listCampos[iColOrden];
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

  /// Ordena la lista según iColOrden (si hay columna ordenada).
  void aplicarOrden(List<Map<String, dynamic>> listDatos) {
    if (iColOrden < 0) return;
    listDatos.sort(compararRegistros);
  }

  /// Ordena la grilla por una columna: alterna ascendente/descendente.
  void ordenarPor(ClaseCampoAbm oCampo) {
    final Map<String, dynamic>? oSel = (iRegistro >= 0 && iRegistro < listFiltrada.length)
        ? listFiltrada[iRegistro] : null;
    setState(() {
      final int iNueva = widget.listCampos.indexOf(oCampo);
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

  // ── Acciones ────────────────────────────────────────────────────────────
  void agregar() {
    setState(() {
      enumEstado = EnumEstadoAbm.agregando;
      for (final ClaseCampoAbm oCampo in widget.listCampos) {
        mapControladores[oCampo.sClave]!.clear();
      }
    });
  }

  /// Actualiza la grilla: limpia el filtro y, si hay funcAlActualizar,
  /// recarga los registros desde la Base de Datos.
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
    if (widget.funcAlBorrar != null) {
      sError = await widget.funcAlBorrar!(oRegistro);
    }
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
      enumEstado   = EnumEstadoAbm.inicial;
    });
    if (iRegistro >= 0) cargarRegistro(iRegistro);
  }

  void buscar() {
    final List<Map<String, dynamic>> listResultados = <Map<String, dynamic>>[];
    for (final Map<String, dynamic> oRegistro in widget.listRegistros) {
      bool bCumple = true;
      for (final ClaseCampoAbm oCampo in widget.listCampos) {
        final String sBuscado = mapControladores[oCampo.sClave]!.text.trim().toLowerCase();
        if (sBuscado.isEmpty) continue;
        final String sValor = (oRegistro[oCampo.sClave] ?? '').toString().toLowerCase();
        if (!sValor.contains(sBuscado)) {
          bCumple = false;
          break;
        }
      }
      if (bCumple) listResultados.add(oRegistro);
    }
    aplicarOrden(listResultados);
    setState(() {
      listFiltrada = listResultados;
      iPagina      = 0;
      iRegistro    = listFiltrada.isEmpty ? -1 : 0;
      enumEstado   = EnumEstadoAbm.inicial;
    });
    if (iRegistro >= 0) cargarRegistro(iRegistro);
  }

  /// Precarga Encontrar con el valor de la celda y ejecuta la búsqueda.
  void buscarPorValor(int iIndice, ClaseCampoAbm oCampo) {
    if (iIndice < 0 || iIndice >= listFiltrada.length) return;
    final String sValor = (listFiltrada[iIndice][oCampo.sClave] ?? '').toString();
    enumEstado = EnumEstadoAbm.encontrando;
    for (final ClaseCampoAbm oCampo2 in widget.listCampos) {
      mapControladores[oCampo2.sClave]!.clear();
    }
    mapControladores[oCampo.sClave]!.text = sValor;
    buscar();
  }

  void cargarRegistro(int iIndice) {
    final Map<String, dynamic> oRegistro = listFiltrada[iIndice];
    for (final ClaseCampoAbm oCampo in widget.listCampos) {
      mapControladores[oCampo.sClave]!.text = (oRegistro[oCampo.sClave] ?? '').toString();
    }
    alCambiarCampo();
  }

  void cancelar() {
    setState(() => enumEstado = EnumEstadoAbm.inicial);
    if (iRegistro >= 0) {
      cargarRegistro(iRegistro);
    } else {
      for (final ClaseCampoAbm oCampo in widget.listCampos) {
        mapControladores[oCampo.sClave]!.clear();
      }
      alCambiarCampo();
    }
  }

  /// Copia el valor crudo de una celda al portapapeles.
  Future<void> copiarValor(int iIndice, ClaseCampoAbm oCampo) async {
    if (iIndice < 0 || iIndice >= listFiltrada.length) return;
    final String sValor = (listFiltrada[iIndice][oCampo.sClave] ?? '').toString();
    await Clipboard.setData(ClipboardData(text: sValor));
    if (!mounted) return;
    await funcMostrarMensaje(
        context, getIdioma(), widget.sTitulo, getTexto('copiadoPortapapeles'));
  }

  /// Copia la fila de la grilla (columnas visibles separadas por tabulación).
  Future<void> copiarFila(int iIndice) async {
    if (iIndice < 0 || iIndice >= listFiltrada.length) return;
    final List<String> listValores = <String>[];
    for (final ClaseCampoAbm oCampo in getCamposGrilla()) {
      listValores.add((listFiltrada[iIndice][oCampo.sClave] ?? '').toString());
    }
    await Clipboard.setData(ClipboardData(text: listValores.join('\t')));
    if (!mounted) return;
    await funcMostrarMensaje(
        context, getIdioma(), widget.sTitulo, getTexto('copiadoPortapapeles'));
  }

  void encontrar() {
    setState(() {
      enumEstado = EnumEstadoAbm.encontrando;
      for (final ClaseCampoAbm oCampo in widget.listCampos) {
        mapControladores[oCampo.sClave]!.clear();
      }
    });
  }

  void fin() {
    Navigator.of(context).pop();
  }

  Future<void> grabar() async {
    if (enumEstado == EnumEstadoAbm.encontrando) {
      buscar();
      return;
    }
    if (!validar()) return;

    final Map<String, dynamic> oRegistro = <String, dynamic>{};
    for (final ClaseCampoAbm oCampo in widget.listCampos) {
      oRegistro[oCampo.sClave] = mapControladores[oCampo.sClave]!.text;
    }
    final bool bEsNuevo = enumEstado == EnumEstadoAbm.agregando;

    String? sError;
    if (widget.funcAlGrabar != null) {
      sError = await widget.funcAlGrabar!(oRegistro, bEsNuevo);
    }
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
    setState(() => enumEstado = EnumEstadoAbm.inicial);
    await funcMostrarMensaje(context, getIdioma(), widget.sTitulo, getTexto('grabacionExitosa'));
  }

  /// Selecciona una fila de la grilla y la muestra en los campos.
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
    setState(() => enumEstado = EnumEstadoAbm.modificando);
  }

  void paginaAnterior() {
    if (iPagina <= 0) return;
    setState(() => iPagina--);
  }

  void paginaSiguiente() {
    if (iPagina >= getTotalPaginas() - 1) return;
    setState(() => iPagina++);
  }

  bool validar() {
    for (final ClaseCampoAbm oCampo in widget.listCampos) {
      final String sValor = mapControladores[oCampo.sClave]!.text.trim();
      // 1) Obligatorio (siempre primero)
      if (oCampo.bObligatorio) {
        final String? sError = ClaseCapValidar.validarObligatorio(sValor, oCampo.sEtiqueta, getIdioma());
        if (sError != null) {
          mapFocos[oCampo.sClave]!.requestFocus();
          funcMostrarMensaje(context, getIdioma(), widget.sTitulo, sError);
          return false;
        }
      }
      // 2) Validación específica del campo
      if (oCampo.funcValidarCampo != null) {
        final String? sError = oCampo.funcValidarCampo!(sValor);
        if (sError != null) {
          mapFocos[oCampo.sClave]!.requestFocus();
          funcMostrarMensaje(context, getIdioma(), widget.sTitulo, sError);
          return false;
        }
      }
    }
    // 3) Validación cruzada del registro completo
    if (widget.funcValidarRegistro != null) {
      final Map<String, dynamic> oRegistro = <String, dynamic>{};
      for (final ClaseCampoAbm oCampo in widget.listCampos) {
        oRegistro[oCampo.sClave] = mapControladores[oCampo.sClave]!.text;
      }
      final String? sError = widget.funcValidarRegistro!(oRegistro);
      if (sError != null) {
        funcMostrarMensaje(context, getIdioma(), widget.sTitulo, sError);
        return false;
      }
    }
    return true;
  }

  // ── Construcción de la interfaz ─────────────────────────────────────────
  @override
  Widget build(BuildContext oContexto) {
    return Scaffold(
      appBar : construirBarra(oContexto),
      body   : Column(
        children: <Widget>[
          Expanded(
            child: Row(
              crossAxisAlignment : CrossAxisAlignment.stretch,
              children: <Widget>[
                if (!widget.bTablaUnSoloRegistro) construirGrilla(oContexto),
                Expanded(child: construirAreaCampos(oContexto)),
              ],
            ),
          ),
          construirBotones(oContexto),
        ],
      ),
    );
  }

  PreferredSizeWidget construirBarra(BuildContext oContexto) {
    return AppBar(
      title : Text(widget.sTitulo,
                  style: ClaseGenEstilosTexto.subtituloGrande(oContexto)),
      bottom: (listGrupos.isEmpty)
          ? null
          : TabBar(
              controller : oControlPestanas,
              tabs       : <Widget>[
                for (final String sGrupo in listGrupos)
                  Tab(text: getTexto(sGrupo)),
              ],
            ),
    );
  }

  Widget construirAreaCampos(BuildContext oContexto) {
    final List<ClaseCampoAbm> listSinGrupo =
        widget.listCampos.where((o) => o.sGrupo == null).toList();

    if (listGrupos.isEmpty) {
      return construirCampos(oContexto, widget.listCampos);
    }

    if (listSinGrupo.isEmpty) {
      return TabBarView(
        controller : oControlPestanas,
        children   : <Widget>[
          for (final String sGrupo in listGrupos)
            construirCampos(
              oContexto,
              widget.listCampos.where((o) => o.sGrupo == sGrupo).toList(),
            ),
        ],
      );
    }

    // Campos comunes arriba, pestañas debajo
    return Column(
      crossAxisAlignment : CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding : const EdgeInsets.fromLTRB(
            ClaseGenEspacios.dEspacio24,
            ClaseGenEspacios.dEspacio16,
            ClaseGenEspacios.dEspacio24,
            ClaseGenEspacios.dEspacio04,
          ),
          child: Wrap(
            runSpacing : ClaseGenEspacios.dEspacio12,
            spacing    : ClaseGenEspacios.dEspacio24,
            children   : <Widget>[
              for (final ClaseCampoAbm oCampo in listSinGrupo)
                construirCampo(oContexto, oCampo),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller : oControlPestanas,
            children   : <Widget>[
              for (final String sGrupo in listGrupos)
                construirCampos(
                  oContexto,
                  widget.listCampos.where((o) => o.sGrupo == sGrupo).toList(),
                ),
            ],
          ),
        ),
      ],
    );
  }

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
                for (final ClaseCampoAbm oCampo in getCamposGrilla())
                  Expanded(
                    flex : getAnchoGrilla(oCampo),
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
                    padding : const EdgeInsets.symmetric(
                      horizontal : ClaseGenEspacios.dEspacio08,
                    ),
                    child: Row(
                      children: <Widget>[
                        for (final ClaseCampoAbm oCampo in getCamposGrilla())
                          Expanded(
                            flex : getAnchoGrilla(oCampo),
                            child: GestureDetector(
                              behavior           : HitTestBehavior.opaque,
                              onSecondaryTapDown : (oDet) => mostrarMenuGrilla(
                                  oContexto, oDet.globalPosition, iGlobal, oCampo),
                              onLongPressStart   : (oDet) => mostrarMenuGrilla(
                                  oContexto, oDet.globalPosition, iGlobal, oCampo),
                              child : Text(
                                truncarTextoGrilla(
                                    (listPagina[iIndice][oCampo.sClave] ?? '').toString(),
                                    oCampo),
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

  /// Cabecera de columna de la grilla: clic para ordenar, con flecha de estado.
  Widget construirCabeceraColumna(BuildContext oContexto, ClaseCampoAbm oCampo) {
    final bool bActivo = iColOrden == widget.listCampos.indexOf(oCampo);
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

  /// Menú contextual de la grilla: clic derecho (escritorio/web)
  /// o presión larga (teléfono) sobre una celda.
  Future<void> mostrarMenuGrilla(
    BuildContext  oContexto,
    Offset        oPosicion,
    int           iIndice,
    ClaseCampoAbm oCampo,
  ) async {
    final bool bEnEdicion = enumEstado == EnumEstadoAbm.agregando ||
                            enumEstado == EnumEstadoAbm.modificando ||
                            enumEstado == EnumEstadoAbm.encontrando;
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

  /// Ítem con icono para los menús contextuales.
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

  Widget construirCampos(BuildContext oContexto, List<ClaseCampoAbm> listCampos) {
    return SingleChildScrollView(
      padding : const EdgeInsets.all(ClaseGenEspacios.dEspacio24),
      child   : Wrap(
        runSpacing : ClaseGenEspacios.dEspacio20,
        spacing    : ClaseGenEspacios.dEspacio24,
        children   : <Widget>[
          for (final ClaseCampoAbm oCampo in listCampos)
            construirCampo(oContexto, oCampo),
        ],
      ),
    );
  }

  Widget construirCampo(BuildContext oContexto, ClaseCampoAbm oCampo) {
    final bool bHabilitado = enumEstado != EnumEstadoAbm.inicial &&
                             !oCampo.bSiempreDeshabilitado &&
                             !oCampo.bSoloLecturaPorRol;
    final TextEditingController oControl = mapControladores[oCampo.sClave]!;
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

    final Widget wEtiqueta = Row(
      mainAxisSize : MainAxisSize.min,
      children     : <Widget>[
        Text(oCampo.sEtiqueta, style: ClaseGenEstilosTexto.etiquetaCampo(oContexto)),
        if (oCampo.bObligatorio)
          Text(' *', style: ClaseGenEstilosTexto.etiquetaCampo(oContexto)
                            .copyWith(color: ClaseGenColores.colorError)),
        if (oCampo.oTipo == EnumTipoCampoAbm.comentario) ...<Widget>[
          const SizedBox(width: ClaseGenEspacios.dEspacio08),
          Text('${oControl.text.length}/${oCampo.iMaxComentario}',
               style: ClaseGenEstilosTexto.normalChico(oContexto)),
        ],
      ],
    );

    return Column(
      crossAxisAlignment : CrossAxisAlignment.start,
      mainAxisSize        : MainAxisSize.min,
      children: <Widget>[
        wEtiqueta,
        const SizedBox(height: ClaseGenEspacios.dEspacio04),
        SizedBox(
          width : dAncho,
          child : construirControl(oContexto, oCampo, oControl, bHabilitado),
        ),
      ],
    );
  }

  Widget construirControl(
    BuildContext          oContexto,
    ClaseCampoAbm         oCampo,
    TextEditingController oControl,
    bool                  bHabilitado,
  ) {
    if (oCampo.oTipo == EnumTipoCampoAbm.casillas) {
      final Set<String> setSeleccionadas = oControl.text
          .split(',')
          .where((s) => s.isNotEmpty)
          .toSet();
      return Column(
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
              onChanged       : bHabilitado ? (bValor) {
                setState(() {
                  final Set<String> setActual = oControl.text
                      .split(',')
                      .where((s) => s.isNotEmpty)
                      .toSet();
                  if (bValor == true) {
                    setActual.add(sOpcion);
                  } else {
                    setActual.remove(sOpcion);
                  }
                  oControl.text = setActual.join(',');
                });
                alCambiarCampo();
              } : null,
            ),
        ],
      );
    }

    if (oCampo.oTipo == EnumTipoCampoAbm.lista) {
      return DropdownButton<String>(
        borderRadius : BorderRadius.circular(ClaseGenRadios.dPequeno),
        isExpanded   : true,
        items        : <DropdownMenuItem<String>>[
          for (final String sOpcion in (oCampo.listOpciones ?? <String>[]))
            DropdownMenuItem<String>(
              value : sOpcion,
              child : Text(sOpcion, style: ClaseGenEstilosTexto.textoCampo(oContexto)),
            ),
        ],
        onChanged : bHabilitado ? (sValor) {
          oControl.text = sValor ?? '';
          alCambiarCampo();
        } : null,
        underline : const SizedBox.shrink(),
        value     : (oCampo.listOpciones ?? <String>[]).contains(oControl.text)
                        ? oControl.text : null,
      );
    }

    if (oCampo.oTipo == EnumTipoCampoAbm.logico) {
      return CheckboxListTile(
        contentPadding  : EdgeInsets.zero,
        controlAffinity : ListTileControlAffinity.leading,
        dense           : true,
        title           : Text(oCampo.sEtiqueta,
                           style: ClaseGenEstilosTexto.textoCampo(oContexto)),
        value           : oControl.text.toUpperCase() == 'S',
        onChanged       : bHabilitado ? (bValor) {
          oControl.text = (bValor ?? false) ? 'S' : 'N';
          alCambiarCampo();
        } : null,
      );
    }

    // ── Fecha: campo readOnly con date picker ─────────────────────────────
    if (oCampo.oTipo == EnumTipoCampoAbm.fecha) {
      return TextField(
        controller : oControl,
        enabled    : bHabilitado,
        readOnly   : true,
        onTap      : bHabilitado ? () async {
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
              if (bHabilitado)
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
      );
    }

    // ── Hora: campo readOnly con time picker ──────────────────────────────
    if (oCampo.oTipo == EnumTipoCampoAbm.hora) {
      return TextField(
        controller : oControl,
        enabled    : bHabilitado,
        readOnly   : true,
        onTap      : bHabilitado ? () async {
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
              if (bHabilitado)
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
      );
    }

    // ── Texto / Número (genérico) ─────────────────────────────────────────
    final bool bNumero = oCampo.oTipo == EnumTipoCampoAbm.numero;
    return Focus(
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
        controller       : oControl,
        enabled          : bHabilitado,
        focusNode        : mapFocos[oCampo.sClave],
        maxLength        : oCampo.oTipo == EnumTipoCampoAbm.comentario ? oCampo.iMaxComentario : null,
        maxLines         : oCampo.oTipo == EnumTipoCampoAbm.comentario ? 3 : 1,
        onChanged        : (sValor) => alCambiarCampo(),
        style            : ClaseGenEstilosTexto.textoCampo(oContexto),
        textAlign        : bNumero ? TextAlign.right : TextAlign.left,
        inputFormatters  : (oCampo.sMascara != null && oCampo.oTipo == EnumTipoCampoAbm.texto)
                               ? <TextInputFormatter>[ClaseFormatoMascara(sMascara: oCampo.sMascara!)]
                               : null,
        decoration       : InputDecoration(
          counterText : '',
          hintText    : oCampo.sHint,
          hintStyle   : ClaseGenEstilosTexto.textoCampo(oContexto)
                          .copyWith(color: Theme.of(oContexto).colorScheme.onSurfaceVariant),
          suffixIcon  : bHabilitado
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
    );
  }

  // ── Botones ABM ─────────────────────────────────────────────────────────
  /// Barra de botones ABM. Estados según reglas 11-13.
  /// Colores tomados de ColorScheme (temas.dart): se adaptan automáticamente
  /// al tema claro y al tema oscuro.
  /// Si solo Grabar y Cancelar están habilitados (modo edición),
  /// Grabar usa un color más llamativo.
  Widget construirBotones(BuildContext oContexto) {
    final bool bEnEdicion      = enumEstado == EnumEstadoAbm.agregando ||
                                 enumEstado == EnumEstadoAbm.modificando ||
                                 enumEstado == EnumEstadoAbm.encontrando;
    final bool bHayDatos       = widget.listRegistros.isNotEmpty;
    final bool bPuedeAgregar   = !bEnEdicion &&
                                 (!widget.bTablaUnSoloRegistro || widget.listRegistros.isEmpty);
    final bool bPuedeEncontrar = !bEnEdicion && bHayDatos && widget.bPermitirEncontrar;

    final String sTextoGrabar = (enumEstado == EnumEstadoAbm.encontrando)
        ? getTexto('abmBuscar') : getTexto('abmGrabar');

    return Container(
      color   : Theme.of(oContexto).colorScheme.surfaceContainerLow,
      padding : const EdgeInsets.all(ClaseGenEspacios.dEspacio08),
      child   : Wrap(
        alignment  : WrapAlignment.center,
        spacing    : ClaseGenEspacios.dEspacio08,
        runSpacing : ClaseGenEspacios.dEspacio08,
        children   : <Widget>[
          construirBoton(oContexto, oIcono: Icons.add,                 sTexto: getTexto('abmAgregar'),
              funcAlPulsar: bPuedeAgregar ? agregar : null),
          construirBoton(oContexto, oIcono: Icons.remove,              sTexto: getTexto('abmBorrar'),
              funcAlPulsar: (!bEnEdicion && bHayDatos && iRegistro >= 0) ? borrar : null),
          construirBoton(oContexto, oIcono: Icons.edit_outlined,       sTexto: getTexto('abmModificar'),
              funcAlPulsar: (!bEnEdicion && bHayDatos && iRegistro >= 0) ? modificar : null),
          construirBoton(oContexto, oIcono: Icons.check,               sTexto: sTextoGrabar,
              funcAlPulsar: bEnEdicion ? grabar : null, bEsDestacado: true),
          construirBoton(oContexto, oIcono: Icons.cancel_outlined,     sTexto: getTexto('abmCancelar'),
              funcAlPulsar: bEnEdicion ? cancelar : null),
          construirBoton(oContexto, oIcono: Icons.search,              sTexto: getTexto('abmEncontrar'),
              funcAlPulsar: bPuedeEncontrar ? encontrar : null),
          construirBoton(oContexto, oIcono: Icons.power_settings_new,  sTexto: getTexto('abmFin'),
              funcAlPulsar: bEnEdicion ? null : fin),
        ],
      ),
    );
  }

  /// Botón ABM uniforme: mismo ancho y alto, icono a la izquierda.
  /// Colores tomados de ColorScheme (temas.dart): se adaptan al tema
  /// claro y oscuro automáticamente.
  /// bEsDestacado = true solo para Grabar en modo edición (más llamativo).
  Widget construirBoton(
    BuildContext oContexto, {
    required IconData      oIcono,
    required String        sTexto,
    required VoidCallback? funcAlPulsar,
    bool                   bEsDestacado = false,
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
