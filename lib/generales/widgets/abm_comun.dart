import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../idiomas/idiomas.dart';
import '../modelos/campo_abm.dart';
import '../modelos/permisos.dart';
import '../modelos/sesion.dart';
import '../temas/espacios.dart';
import '../temas/estilos_textos.dart';
import '../temas/layout.dart';
import '../temas/radios.dart';
import '../temas/temas.dart';
import '../utilitarios/formatos.dart';
import '../validaciones/cap_validar.dart';
import 'campo_formulario.dart';
import 'ventana_mensaje.dart';

/// Botones de la botonera ABM.
enum EnumBotonAbm { agregar, borrar, cancelar, encontrar, fin, grabar, modificar }


/// Valida el valor de un campo: obligatorio, longitud máxima (según
/// iAnchoCaracteres) y la validación específica del campo.
String? funcValidarCampoAbm(ClaseCampoAbm oCampo, String sValor, String sIdioma) {
  String? sError;
  if (oCampo.bObligatorio) {
    sError = ClaseCapValidar.validarObligatorio(sValor, oCampo.sEtiqueta, sIdioma);
  }
  if (sError == null
      && (oCampo.oTipo == EnumTipoCampoAbm.texto || oCampo.oTipo == EnumTipoCampoAbm.numero)) {
    sError = ClaseCapValidar.validarLongitudMaxima(
        sValor, oCampo.sEtiqueta, oCampo.iAnchoCaracteres, sIdioma);
  }
  return sError ?? oCampo.funcValidarCampo?.call(sValor, sIdioma);
}


/// Diálogo de Encontrar: devuelve el texto buscado (o null si se cancela o
/// queda vacío).
Future<String?> funcMostrarEncontrar(
  BuildContext  oContexto,
  String        sIdioma,
  ClaseCampoAbm oCampo,
) async {
  final TextEditingController oControl = TextEditingController();
  await showDialog<void>(
    context : oContexto,
    builder : (oContextoDialogo) => AlertDialog(
      title: Row(
        children: <Widget>[
          Expanded(
            child: Text(ClaseIdiomas.getTexto('abmEncontrar', sIdioma),
                style: ClaseGenEstilosTexto.subtituloMediano(oContextoDialogo)),
          ),
          IconButton(
            tooltip   : ClaseIdiomas.getTexto('cerrar', sIdioma),
            icon      : const Icon(Icons.close),
            onPressed : () => Navigator.of(oContextoDialogo).pop(),
          ),
        ],
      ),
      content: TextField(
        controller  : oControl,
        autofocus   : true,
        style       : ClaseGenEstilosTexto.textoCampo(oContextoDialogo),
        decoration  : InputDecoration(
          labelText : oCampo.sEtiqueta,
          hintText  : oCampo.sHint,
          border    : const OutlineInputBorder(),
        ),
        onSubmitted : (String sValor) => Navigator.of(oContextoDialogo).pop(),
      ),
      actions: <Widget>[
        FilledButton.icon(
          onPressed : () => Navigator.of(oContextoDialogo).pop(),
          icon      : const Icon(Icons.search),
          label     : Text(ClaseIdiomas.getTexto('abmBuscar', sIdioma),
              style: ClaseGenEstilosTexto.normalMediano(oContextoDialogo)),
        ),
      ],
    ),
  );
  final String sTexto = oControl.text.trim();
  oControl.dispose();
  return sTexto.isEmpty ? null : sTexto;
}

/// Título de los AppBar: el nombre de la pantalla y, debajo, la Base de
/// Datos conectada y el país (regla: la Base de Datos se muestra en el
/// drawer y en todos los AppBar de la aplicación).
Widget funcConstruirTituloAppBar(BuildContext oContexto, String sIdioma, String sTitulo) {
  return Column(
    crossAxisAlignment : CrossAxisAlignment.start,
    mainAxisAlignment  : MainAxisAlignment.center,
    children: <Widget>[
      Text(sTitulo,
           style: ClaseGenEstilosTexto.tituloMediano(oContexto)
                    .copyWith(fontWeight: FontWeight.w600)),
      Text('${ClaseSesion.getBaseDatos()} · ${ClaseIdiomas.getTexto(ClaseSesion.getClavePais(), sIdioma)}',
           style: ClaseGenEstilosTexto.normalChico(oContexto)),
    ],
  );
}


/// Formulario de campos de cabecera: sin grupo, una sola columna; con grupos,
/// los campos comunes arriba y una pestaña por grupo.
class ClaseFormularioCampos extends StatefulWidget {

  const ClaseFormularioCampos({
    super.key,
    this.bAutoFocus = false,
    required this.funcAlCambiarCampo,
    this.funcAlPerderFoco,
    required this.funcEsHabilitado,
    this.funcEtiquetaGrupo,
    required this.listCampos,
    required this.mapValores,
    required this.sIdioma,
  });

  /// true para mover el foco al primer campo habilitado (item 10).
  final bool                                       bAutoFocus;
  final void Function(String sClave, String sValor) funcAlCambiarCampo;

  /// Transformación del valor al salir del campo (devuelve el valor nuevo
  /// o null si no cambia). Recibe la clave del campo, el valor actual y los
  /// valores internos del formulario. Se pasa a cada ClaseCampoFormulario.
  final String? Function(String sClave, String sValor, Map<String, String> mapValores)? funcAlPerderFoco;

  final bool Function(ClaseCampoAbm oCampo)        funcEsHabilitado;

  /// Etiqueta personalizada de cada pestaña de grupo (opcional). Recibe la
  /// clave del grupo; si no se provee, se usa el texto traducido de la clave.
  final String Function(String sClaveGrupo)?       funcEtiquetaGrupo;

  final List<ClaseCampoAbm>                        listCampos;
  final Map<String, String>                        mapValores;
  final String                                     sIdioma;

  @override
  State<ClaseFormularioCampos> createState() => ClaseEstadoFormularioCampos();
}

class ClaseEstadoFormularioCampos extends State<ClaseFormularioCampos>
    with SingleTickerProviderStateMixin {

  /// Controlador de las pestañas de los grupos (si los hay).
  late final TabController oControladorPestanas;

  /// Un nodo de foco por campo: lo usa el campo y también el formulario
  /// para colocar el foco en el primer campo con error (item 14).
  late final Map<String, FocusNode> mapFocos;

  @override
  void initState() {
    super.initState();
    final List<String> listGrupos = _getListGrupos();
    oControladorPestanas = TabController(
      length : listGrupos.isEmpty ? 1 : listGrupos.length,
      vsync  : this,
    );
    mapFocos = <String, FocusNode>{
      for (final ClaseCampoAbm oCampo in widget.listCampos)
        oCampo.sClave: FocusNode(),
    };
  }

  @override
  void dispose() {
    oControladorPestanas.dispose();
    for (final FocusNode oFoco in mapFocos.values) {
      oFoco.dispose();
    }
    super.dispose();
  }

  /// Coloca el foco del teclado en el campo indicado (item 14). Si el campo
  /// está en una pestaña, primero la muestra y luego pide el foco.
  void enfocarCampo(String sClave) {
    final List<String> listGrupos = _getListGrupos();
    int iGrupo = -1;
    for (final ClaseCampoAbm oCampo in widget.listCampos) {
      if (oCampo.sClave != sClave) continue;
      if (oCampo.sGrupo != null) iGrupo = listGrupos.indexOf(oCampo.sGrupo!);
      break;
    }
    if (iGrupo >= 0 && iGrupo != oControladorPestanas.index) {
      oControladorPestanas.animateTo(iGrupo);
      WidgetsBinding.instance.addPostFrameCallback((_) => _pedirFoco(sClave));
    } else {
      _pedirFoco(sClave);
    }
  }

  void _pedirFoco(String sClave) {
    if (mounted) mapFocos[sClave]?.requestFocus();
  }

  List<String> _getListGrupos() {
    final List<String> listSalida = <String>[];
    for (final ClaseCampoAbm oCampo in widget.listCampos) {
      final String? sGrupo = oCampo.sGrupo;
      if (sGrupo != null && !listSalida.contains(sGrupo)) listSalida.add(sGrupo);
    }
    return listSalida;
  }

  @override
  Widget build(BuildContext oContexto) {

    // Primer campo habilitado → recibir foco al entrar en edición.
    ClaseCampoAbm? oPrimeroHabilitado;
    for (final ClaseCampoAbm oCampo in widget.listCampos) {
      if (widget.funcEsHabilitado(oCampo)) {
        oPrimeroHabilitado = oCampo;
        break;
      }
    }

    final List<String> listGrupos = _getListGrupos();

    if (listGrupos.isEmpty) {
      return SingleChildScrollView(
        padding : const EdgeInsets.all(ClaseGenEspacios.dEspacio16),
        child   : Column(
          crossAxisAlignment : CrossAxisAlignment.start,
          children: <Widget>[
            for (final ClaseCampoAbm oCampo in widget.listCampos)
              _construirCampo(oCampo,
                  bAutoFocus: widget.bAutoFocus && oCampo == oPrimeroHabilitado), // ← CAMBIO item 10
          ],
        ),
      );
    }

    final List<ClaseCampoAbm> listComunes =
        widget.listCampos.where((ClaseCampoAbm o) => o.sGrupo == null).toList();

    return Column(
      crossAxisAlignment : CrossAxisAlignment.stretch,
      children: <Widget>[
        if (listComunes.isNotEmpty)
          Padding(
            padding : const EdgeInsets.symmetric(horizontal: ClaseGenEspacios.dEspacio16),
            child   : Column(
              crossAxisAlignment : CrossAxisAlignment.start,
              children: <Widget>[
                for (final ClaseCampoAbm oCampo in listComunes)
                  _construirCampo(oCampo,
                      bAutoFocus: widget.bAutoFocus && oCampo == oPrimeroHabilitado), // ← CAMBIO item 10
              ],
            ),
          ),
        TabBar(
          controller : oControladorPestanas,                // ← CAMBIO item 14
          tabs: <Widget>[
            for (final String sGrupo in listGrupos)
              Tab(text: widget.funcEtiquetaGrupo?.call(sGrupo)   // ← CAMBIO etiqueta de grupo
                  ?? ClaseIdiomas.getTexto(sGrupo, widget.sIdioma)),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller : oControladorPestanas,              // ← CAMBIO item 14
            children: <Widget>[
              for (final String sGrupo in listGrupos)
                SingleChildScrollView(
                  padding : const EdgeInsets.all(ClaseGenEspacios.dEspacio16),
                  child   : Column(
                    crossAxisAlignment : CrossAxisAlignment.start,
                    children: <Widget>[
                      for (final ClaseCampoAbm oCampo in widget.listCampos
                          .where((ClaseCampoAbm o) => o.sGrupo == sGrupo))
                        _construirCampo(oCampo,
                            bAutoFocus: widget.bAutoFocus && oCampo == oPrimeroHabilitado), // ← CAMBIO item 10
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  // ← CAMBIO item 10: aceptar y propagar bAutoFocus
  // ← CAMBIO item 14: inyectar el nodo de foco del campo.
  Widget _construirCampo(ClaseCampoAbm oCampo, {bool bAutoFocus = false}) {
    return ClaseCampoFormulario(
      bAutoFocus       : bAutoFocus,
      bHabilitado      : widget.funcEsHabilitado(oCampo),
      funcAlCambiar    : (String sValor) => widget.funcAlCambiarCampo(oCampo.sClave, sValor),
      funcAlPerderFoco : widget.funcAlPerderFoco,
      mapValores       : widget.mapValores,
      oCampo           : oCampo,
      oFocoExterno     : mapFocos[oCampo.sClave],
      sIdioma          : widget.sIdioma,
      sValor           : widget.mapValores[oCampo.sClave] ?? '',
    );
  }

}


/// Grilla lateral de registros: filtro, orden por columna, paginación, menú
/// contextual por celda y contraer/expandir. Lleva su propio estado; solo la
/// selección (iRegistro) vive en el padre.
///
/// El foco del teclado vive en la grilla (item 23): al ingresar recibe el
/// foco y las flechas arriba/abajo mueven la selección entre las filas.
class ClaseGrillaRegistros extends StatefulWidget {

  const ClaseGrillaRegistros({
    super.key,
    required this.funcSeleccionar,
    required this.iRegistro,
    required this.listCampos,
    required this.listRegistros,
    this.oFocoExterno,
    required this.sIdioma,
  });

  /// Selecciona el registro por su índice en listRegistros.
  final void Function(int iIndice) funcSeleccionar;

  /// Índice en listRegistros del registro seleccionado (-1 si ninguno).
  final int                        iRegistro;
  final List<ClaseCampoAbm>        listCampos;
  final List<Map<String, dynamic>> listRegistros;

  /// Nodo de foco externo (opcional): el formulario lo usa para devolverle el foco a la grilla, ej: al cancelar la edición.
  final FocusNode?                 oFocoExterno;
  final String                     sIdioma;

  @override
  State<ClaseGrillaRegistros> createState() => ClaseEstadoGrillaRegistros();
}

class ClaseEstadoGrillaRegistros extends State<ClaseGrillaRegistros> {

  bool   bOrdenDesc  = false;
  bool   bVisible    = true;
  int    iPagina     = 0;
  String sClaveOrden = '';
  String sFiltro     = '';

  final TextEditingController oControlFiltro = TextEditingController();

  /// Nodo de foco interno de la grilla (item 23).
  final FocusNode _oFocoInterno = FocusNode();

  /// Nodo de foco que usa la grilla: el externo si el formulario lo provee, o el propio. Se elige una sola vez en initState.
  late final FocusNode oFocoGrilla = widget.oFocoExterno ?? _oFocoInterno;

  @override
  void initState() {
    super.initState();
    // ← CAMBIO item 23: al ingresar al formulario, el foco del teclado queda
    //   en la grilla (sobre la primera fila seleccionada) si hay registros.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && bVisible && widget.listRegistros.isNotEmpty) {
        oFocoGrilla.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    oControlFiltro.dispose();
    _oFocoInterno.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant ClaseGrillaRegistros oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Al seleccionar un registro (ej: con Encontrar) se salta a su página.
    if (oldWidget.iRegistro != widget.iRegistro
        && widget.iRegistro >= 0
        && widget.iRegistro < widget.listRegistros.length) {
      final int iPosicion = _listFiltrados().indexOf(widget.listRegistros[widget.iRegistro]);
      if (iPosicion >= 0) iPagina = iPosicion ~/ ClaseGenLayout.iFilasPorPagina;
    }
  }

  // ── Navegación con el teclado ────────────────────────────────────────────

  /// Flechas arriba/abajo: mueven la selección a la fila anterior o
  /// siguiente (item 23). La navegación respeta el filtro y el orden
  /// actuales de la grilla.
  KeyEventResult _alPulsarTecla(FocusNode oNodo, KeyEvent oEvento) {
    if (oEvento is! KeyDownEvent) return KeyEventResult.ignored;
    if (oEvento.logicalKey != LogicalKeyboardKey.arrowDown
        && oEvento.logicalKey != LogicalKeyboardKey.arrowUp) {
      return KeyEventResult.ignored;
    }
    final List<Map<String, dynamic>> listFiltrados = _listFiltrados();
    if (listFiltrados.isEmpty) return KeyEventResult.ignored;

    int iPosicion = (widget.iRegistro >= 0 && widget.iRegistro < widget.listRegistros.length)
        ? listFiltrados.indexOf(widget.listRegistros[widget.iRegistro])
        : -1;

    final int iNueva = (oEvento.logicalKey == LogicalKeyboardKey.arrowDown)
        ? math.min(iPosicion + 1, listFiltrados.length - 1)
        : math.max(iPosicion - 1, 0);
    if (iNueva < 0 || iNueva == iPosicion) return KeyEventResult.handled;

    final int iIndice = widget.listRegistros.indexOf(listFiltrados[iNueva]);
    if (iIndice >= 0) widget.funcSeleccionar(iIndice);
    return KeyEventResult.handled;
  }

  // ── Registros filtrados, ordenados y paginados ───────────────────────────

  List<Map<String, dynamic>> _listFiltrados() {
    Iterable<Map<String, dynamic>> list = widget.listRegistros;
    final String sTexto = sFiltro.trim().toLowerCase();
    if (sTexto.isNotEmpty) {
      list = list.where((Map<String, dynamic> o) => o.entries.any(
          (MapEntry<String, dynamic> e) =>
              e.value is! List && e.value.toString().toLowerCase().contains(sTexto)));
    }
    final List<Map<String, dynamic>> listSalida = list.toList();
    if (sClaveOrden.isNotEmpty) {
      // ← CAMBIO: orden real según el tipo de campo (los importes se ordenan
      //   como números y las fechas como fechas, no como texto).
      final EnumTipoCampoAbm oTipo = widget.listCampos
          .firstWhere((ClaseCampoAbm o) => o.sClave == sClaveOrden,
              orElse: () => widget.listCampos.first)
          .oTipo;
      listSalida.sort((Map<String, dynamic> a, Map<String, dynamic> b) {
        final String sA = (a[sClaveOrden] ?? '').toString();
        final String sB = (b[sClaveOrden] ?? '').toString();
        if (oTipo == EnumTipoCampoAbm.numero) {
          return (funcNumeroOrden(sA) ?? 0).compareTo(funcNumeroOrden(sB) ?? 0);
        }
        if (oTipo == EnumTipoCampoAbm.fecha) {
          return (funcFechaOrden(sA) ?? DateTime(0))
              .compareTo(funcFechaOrden(sB) ?? DateTime(0));
        }
        return sA.compareTo(sB);
      });
      if (bOrdenDesc) return listSalida.reversed.toList();
    }
    return listSalida;
  }

  // ── Menú contextual por celda ────────────────────────────────────────────

  Future<void> _mostrarMenuCelda(
    BuildContext         oContexto,
    Map<String, dynamic> oRegistro,
    ClaseCampoAbm        oCampo,
    Offset               oPosicion,
  ) async {
    final String sValor = (oRegistro[oCampo.sClave] ?? '').toString();
    final String? sAccion = await showMenu<String>(
      context  : oContexto,
      position : RelativeRect.fromLTRB(oPosicion.dx, oPosicion.dy, oPosicion.dx, oPosicion.dy),
      items    : <PopupMenuEntry<String>>[
        PopupMenuItem<String>(
          value : 'copiarValor',
          child : Text(ClaseIdiomas.getTexto('menuCopiarValor', widget.sIdioma)),
        ),
        PopupMenuItem<String>(
          value : 'buscarValor',
          child : Text(ClaseIdiomas.getTexto('menuBuscarValor', widget.sIdioma)),
        ),
        PopupMenuItem<String>(
          value : 'copiarFila',
          child : Text(ClaseIdiomas.getTexto('menuCopiarFila', widget.sIdioma)),
        ),
      ],
    );
    if (!mounted || sAccion == null) return;
    if (sAccion == 'copiarValor' || sAccion == 'copiarFila') {
      final String sTexto = (sAccion == 'copiarValor')
          ? sValor
          : widget.listCampos
                .map((ClaseCampoAbm o) => (oRegistro[o.sClave] ?? '').toString())
                .join('\t');
      await Clipboard.setData(ClipboardData(text: sTexto));
      if (!mounted) return;
      await funcMostrarInformacion(
        context,
        widget.sIdioma,
        ClaseIdiomas.getTexto('aplicacion', widget.sIdioma),
        ClaseIdiomas.getTexto('copiadoPortapapeles', widget.sIdioma),
      );
    } else {
      setState(() {
        sFiltro            = sValor;
        oControlFiltro.text = sValor;
        iPagina            = 0;
      });
    }
  }

  // ── Construcción de la interfaz ──────────────────────────────────────────

  @override
  Widget build(BuildContext oContexto) {
    if (!bVisible) {
      return SizedBox(
        width : ClaseGenLayout.dAnchoTiraGrilla,
        child : Column(
          children: <Widget>[
            const SizedBox(height: ClaseGenEspacios.dEspacio08),
            IconButton(
              tooltip   : ClaseIdiomas.getTexto('expandirGrilla', widget.sIdioma),
              icon      : const Icon(Icons.last_page),
              onPressed : () => setState(() => bVisible = true),
            ),
          ],
        ),
      );
    }

    // Regla: los campos Comentarios nunca se muestran en la grilla lateral.
    final List<ClaseCampoAbm> listColumnas = widget.listCampos
        .where((ClaseCampoAbm o) =>
            o.bEnGrilla && o.oTipo != EnumTipoCampoAbm.comentario)
        .take(3)
        .toList();

    final List<Map<String, dynamic>> listFiltrados = _listFiltrados();
    final int iTotalPaginas = math.max(1,
        (listFiltrados.length + ClaseGenLayout.iFilasPorPagina - 1) ~/ ClaseGenLayout.iFilasPorPagina);
    final int iPaginaActual = (iPagina < iTotalPaginas) ? iPagina : iTotalPaginas - 1;
    final int iInicio = iPaginaActual * ClaseGenLayout.iFilasPorPagina;
    final int iFin    = math.min(iInicio + ClaseGenLayout.iFilasPorPagina, listFiltrados.length);
    final List<Map<String, dynamic>> listPagina = (iInicio < listFiltrados.length)
        ? listFiltrados.sublist(iInicio, iFin)
        : <Map<String, dynamic>>[];

    // ← CAMBIO item 23: el foco del teclado queda en la grilla y las
    //   flechas arriba/abajo mueven la selección.
    return Focus(
      focusNode     : oFocoGrilla,
      onKeyEvent    : _alPulsarTecla,
      onFocusChange : (bool bTieneFoco) {
        if (mounted) setState(() {});
      },
      child: SizedBox(
        width : ClaseGenLayout.dAnchoGrillaRegistros,
        child : Column(
          children: <Widget>[
            Padding(
              padding : const EdgeInsets.all(ClaseGenEspacios.dEspacio08),
              child   : Row(
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller : oControlFiltro,
                      style      : ClaseGenEstilosTexto.normalChico(oContexto),
                      decoration : InputDecoration(
                        isDense    : true,
                        hintText   : ClaseIdiomas.getTexto('abmBuscar', widget.sIdioma),
                        prefixIcon : const Icon(Icons.search),
                        border     : OutlineInputBorder(
                          borderRadius: BorderRadius.circular(ClaseGenRadios.dPequeno),
                        ),
                      ),
                      onChanged: (String sValor) => setState(() {
                        sFiltro = sValor;
                        iPagina = 0;
                      }),
                    ),
                  ),
                  IconButton(
                    tooltip   : ClaseIdiomas.getTexto('menuActualizar', widget.sIdioma),
                    icon      : const Icon(Icons.refresh),
                    onPressed : () => setState(() {
                      sFiltro            = '';
                      oControlFiltro.text = '';
                      iPagina            = 0;
                    }),
                  ),
                  IconButton(
                    tooltip   : ClaseIdiomas.getTexto('contraerGrilla', widget.sIdioma),
                    icon      : const Icon(Icons.first_page),
                    onPressed : () => setState(() => bVisible = false),
                  ),
                ],
              ),
            ),
            Padding(
              padding : const EdgeInsets.symmetric(horizontal: ClaseGenEspacios.dEspacio08),
              child   : Row(
                children: <Widget>[
                  for (final ClaseCampoAbm oCampo in listColumnas)
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() {
                          if (sClaveOrden == oCampo.sClave) {
                            bOrdenDesc = !bOrdenDesc;
                          } else {
                            sClaveOrden = oCampo.sClave;
                            bOrdenDesc  = false;
                          }
                        }),
                        child: Tooltip(
                          message : ClaseIdiomas.getTexto('ordenarPor', widget.sIdioma),
                          child   : Text(
                            oCampo.sEtiqueta,
                            // ← CAMBIO item 8: alinear números a la derecha en encabezados
                            textAlign : (oCampo.oTipo == EnumTipoCampoAbm.numero)
                                ? TextAlign.right
                                : TextAlign.left,
                            style    : ClaseGenEstilosTexto.normalChico(oContexto),
                            maxLines : 1,
                            overflow : TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const Divider(height: ClaseGenEspacios.dEspacio01),
            Expanded(
              child: ListView.builder(
                itemCount : listPagina.length,
                itemBuilder: (oContextoFila, i) {
                  final Map<String, dynamic> oRegistro = listPagina[i];
                  final int  iIndice      = widget.listRegistros.indexOf(oRegistro);
                  final bool bSeleccionado = (iIndice == widget.iRegistro);
                  return InkWell(
                    canRequestFocus : false,                 // ← CAMBIO item 23
                    onTap: () {                              // ← CAMBIO item 23
                      oFocoGrilla.requestFocus();
                      widget.funcSeleccionar(iIndice);
                    },
                    child : Container(
                      decoration : BoxDecoration(
                        color  : bSeleccionado
                            ? Theme.of(oContexto).colorScheme.primaryContainer
                            : null,
                        // ← CAMBIO item 23: aro visible del foco del teclado
                        //   en la fila seleccionada.
                        border : (bSeleccionado && oFocoGrilla.hasFocus)
                            ? Border.all(
                                color : Theme.of(oContexto).colorScheme.primary,
                              )
                            : null,
                      ),
                      padding : const EdgeInsets.symmetric(
                        horizontal : ClaseGenEspacios.dEspacio08,
                        vertical   : ClaseGenEspacios.dEspacio04,
                      ),
                      child: Row(
                        children: <Widget>[
                          for (final ClaseCampoAbm oCampo in listColumnas)
                            Expanded(
                              child: GestureDetector(
                                onLongPressStart: (oDetalle) => _mostrarMenuCelda(
                                    oContexto, oRegistro, oCampo, oDetalle.globalPosition),
                                child: Text(
                                  (oRegistro[oCampo.sClave] ?? '').toString(),
                                  // ← CAMBIO item 8: alinear números a la derecha en celdas
                                  textAlign : (oCampo.oTipo == EnumTipoCampoAbm.numero)
                                      ? TextAlign.right
                                      : TextAlign.left,
                                  style    : ClaseGenEstilosTexto.normalChico(oContexto),
                                  maxLines : 1,
                                  overflow : TextOverflow.ellipsis,
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
            const Divider(height: ClaseGenEspacios.dEspacio01),
            Padding(
              padding : const EdgeInsets.symmetric(horizontal: ClaseGenEspacios.dEspacio04),
              child   : Row(
                children: <Widget>[
                  IconButton(
                    tooltip   : ClaseIdiomas.getTexto('menuPrimeraFila', widget.sIdioma),
                    icon      : const Icon(Icons.first_page),
                    onPressed : (iPaginaActual > 0) ? () => setState(() => iPagina = 0) : null,
                  ),
                  IconButton(
                    tooltip   : ClaseIdiomas.getTexto('paginaAnterior', widget.sIdioma),
                    icon      : const Icon(Icons.chevron_left),
                    onPressed : (iPaginaActual > 0)
                        ? () => setState(() => iPagina = iPaginaActual - 1)
                        : null,
                  ),
                  Expanded(
                    child: Text(
                      '${iPaginaActual + 1} / $iTotalPaginas',
                      textAlign : TextAlign.center,
                      style     : ClaseGenEstilosTexto.normalChico(oContexto),
                    ),
                  ),
                  IconButton(
                    tooltip   : ClaseIdiomas.getTexto('paginaSiguiente', widget.sIdioma),
                    icon      : const Icon(Icons.chevron_right),
                    onPressed : (iPaginaActual < iTotalPaginas - 1)
                        ? () => setState(() => iPagina = iPaginaActual + 1)
                        : null,
                  ),
                  IconButton(
                    tooltip   : ClaseIdiomas.getTexto('menuUltimaFila', widget.sIdioma),
                    icon      : const Icon(Icons.last_page),
                    onPressed : (iPaginaActual < iTotalPaginas - 1)
                        ? () => setState(() => iPagina = iTotalPaginas - 1)
                        : null,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

}


/// Estructura común de un formulario ABM: título, grilla lateral de registros
/// y el área de formulario (pasada como widget) a la derecha.
/// La botonera se ubica al pie del formulario.
class ClaseAndamiajeAbm extends StatelessWidget {

  const ClaseAndamiajeAbm({
    super.key,
    required this.funcAlClicar,
    required this.funcSeleccionar,
    required this.iRegistro,
    required this.listCampos,
    required this.listRegistros,
    this.oFocoGrilla,
    required this.oFormulario,
    required this.setHabilitados,
    required this.sIdioma,
    required this.sTitulo,
  });

  final void Function(EnumBotonAbm oBoton) funcAlClicar;
  final void Function(int iIndice)         funcSeleccionar;
  final int                                iRegistro;
  final List<ClaseCampoAbm>                listCampos;
  final List<Map<String, dynamic>>         listRegistros;
  /// Nodo de foco de la grilla lateral (opcional): para devolverle el foco desde el formulario, ej: al cancelar la edición.
  final FocusNode?                         oFocoGrilla;
  
  /// Área derecha: el formulario (campos, o cabecera + detalles).
  final Widget                             oFormulario;

  final Set<EnumBotonAbm>                  setHabilitados;
  final String                             sIdioma;
  final String                             sTitulo;

  @override
  Widget build(BuildContext oContexto) {
    return Scaffold(
      appBar : AppBar(
        title: funcConstruirTituloAppBar(oContexto, sIdioma, sTitulo),
      ),
      body: Column(
        children: <Widget>[
          // ← CAMBIO item 3: contenido arriba, botonera abajo
          Expanded(
            child: Row(
              crossAxisAlignment : CrossAxisAlignment.stretch,
              children: <Widget>[
                ClaseGrillaRegistros(
                  funcSeleccionar : funcSeleccionar,
                  iRegistro       : iRegistro,
                  listCampos      : listCampos,
                  listRegistros   : listRegistros,
                  oFocoExterno    : oFocoGrilla,
                  sIdioma         : sIdioma,
                ),
                const VerticalDivider(width: ClaseGenEspacios.dEspacio01),
                Expanded(child: oFormulario),
              ],
            ),
          ),
          // ← CAMBIO items 1,2,3,6: botonera al pie, delegada a ClaseBotoneraAbm
          ClaseBotoneraAbm(
            esHabilitado : (EnumBotonAbm oBoton) => setHabilitados.contains(oBoton),
            funcAccion   : funcAlClicar,
            sIdioma      : sIdioma,
          ),
        ],
      ),
    );
  }

}


/// Barra de botones ABM al pie del formulario.
///
/// Orden visual fijo, tamaño uniforme y colores consistentes: mismo color
/// para todos los habilitados, mismo color para todos los deshabilitados.
/// Los colores provienen de ClaseGenTemas (respetan el modo claro/oscuro).
///
/// Los botones de edición quedan deshabilitados en los países sin permiso
/// de edición (Francia: solo visualización). La confirmación de Borrar
/// vive en el borrar() de cada formulario, no aquí.
class ClaseBotoneraAbm extends StatelessWidget {

  const ClaseBotoneraAbm({
    super.key,
    required this.esHabilitado,
    required this.funcAccion,
    required this.sIdioma,
  });

  /// Devuelve true si el botón debe estar habilitado en el estado actual.
  final bool Function(EnumBotonAbm oBoton) esHabilitado;

  /// Acción a ejecutar cuando se presiona un botón.
  final void Function(EnumBotonAbm oBoton) funcAccion;

  final String sIdioma;

  /// Orden visual fijo de los botones (item 1).
  static const List<EnumBotonAbm> _listOrden = <EnumBotonAbm>[
    EnumBotonAbm.agregar,
    EnumBotonAbm.borrar,
    EnumBotonAbm.modificar,
    EnumBotonAbm.grabar,
    EnumBotonAbm.cancelar,
    EnumBotonAbm.encontrar,
    EnumBotonAbm.fin,
  ];

  /// Botones de edición: no operan en países solo visualización.
  static const Set<EnumBotonAbm> _setBotonesEdicion = <EnumBotonAbm>{
    EnumBotonAbm.agregar,
    EnumBotonAbm.borrar,
    EnumBotonAbm.modificar,
    EnumBotonAbm.grabar,
    EnumBotonAbm.cancelar,
  };

  /// Devuelve true si el país conectado permite edición.
  bool _puedeOperar(EnumBotonAbm oBoton) =>
      !_setBotonesEdicion.contains(oBoton)
      || ClasePermisos.puedeEditar(ClaseSesion.getPais());

  String _getEtiqueta(EnumBotonAbm oBoton) {
    switch (oBoton) {
      case EnumBotonAbm.agregar:   return ClaseIdiomas.getTexto('abmAgregar', sIdioma);
      case EnumBotonAbm.borrar:    return ClaseIdiomas.getTexto('abmBorrar', sIdioma);
      case EnumBotonAbm.cancelar:  return ClaseIdiomas.getTexto('abmCancelar', sIdioma);
      case EnumBotonAbm.encontrar: return ClaseIdiomas.getTexto('abmEncontrar', sIdioma);
      case EnumBotonAbm.fin:       return ClaseIdiomas.getTexto('abmFin', sIdioma);
      case EnumBotonAbm.grabar:    return ClaseIdiomas.getTexto('abmGrabar', sIdioma);
      case EnumBotonAbm.modificar: return ClaseIdiomas.getTexto('abmModificar', sIdioma);
    }
  }

  @override
  Widget build(BuildContext oContexto) {
    return Padding(
      padding : const EdgeInsets.symmetric(
        horizontal : ClaseGenEspacios.dEspacio16,
        vertical   : ClaseGenEspacios.dEspacio12,
      ),
      child : Row(
        mainAxisAlignment : MainAxisAlignment.center,
        children : <Widget>[
          for (int i = 0; i < _listOrden.length; i++) ...<Widget>[
            if (i > 0) const SizedBox(width: ClaseGenEspacios.dEspacio08),
            _construirBoton(_listOrden[i], oContexto),
          ],
        ],
      ),
    );
  }

  Widget _construirBoton(EnumBotonAbm oBoton, BuildContext oContexto) {
    final bool bHabilitado = esHabilitado(oBoton) && _puedeOperar(oBoton);
    return SizedBox(
      width  : ClaseGenLayout.dAnchoBotonAbm,   // item 2: mismo ancho
      height : ClaseGenLayout.dAltoBotonAbm,    // item 2: mismo alto
      child  : ElevatedButton(
        onPressed : bHabilitado ? () => funcAccion(oBoton) : null,
        style     : ElevatedButton.styleFrom(
          backgroundColor         : bHabilitado
              ? ClaseGenTemas.colorBotonHabilitado(oContexto)          // item 6
              : ClaseGenTemas.colorBotonDeshabilitado(oContexto),
          foregroundColor         : bHabilitado
              ? ClaseGenTemas.colorTextoBotonHabilitado(oContexto)
              : ClaseGenTemas.colorTextoBotonDeshabilitado(oContexto),
          disabledBackgroundColor : ClaseGenTemas.colorBotonDeshabilitado(oContexto),
          disabledForegroundColor : ClaseGenTemas.colorTextoBotonDeshabilitado(oContexto),
          shape  : RoundedRectangleBorder(
            borderRadius : BorderRadius.circular(ClaseGenRadios.dPequeno),
          ),
          padding : EdgeInsets.zero,
        ),
        child : Text(
          _getEtiqueta(oBoton),
          style : ClaseGenEstilosTexto.botonGrande(oContexto).copyWith(
            color : bHabilitado
                ? ClaseGenTemas.colorTextoBotonHabilitado(oContexto)
                : ClaseGenTemas.colorTextoBotonDeshabilitado(oContexto),
          ),
        ),
      ),
    );
  }

}

