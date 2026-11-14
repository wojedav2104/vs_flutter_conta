import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../idiomas/idiomas.dart';
import '../modelos/campo_abm.dart';
import '../temas/espacios.dart';
import '../temas/estilos_textos.dart';
import '../temas/layout.dart';
import '../temas/radios.dart';
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
            child: Text(ClaseIdiomas.getTexto(sIdioma, 'abmEncontrar'),
                style: ClaseGenEstilosTexto.subtituloMediano(oContextoDialogo)),
          ),
          IconButton(
            tooltip   : ClaseIdiomas.getTexto(sIdioma, 'cerrar'),
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
          label     : Text(ClaseIdiomas.getTexto(sIdioma, 'abmBuscar'),
              style: ClaseGenEstilosTexto.normalMediano(oContextoDialogo)),
        ),
      ],
    ),
  );
  final String sTexto = oControl.text.trim();
  oControl.dispose();
  return sTexto.isEmpty ? null : sTexto;
}


/// Formulario de campos de cabecera: sin grupo, una sola columna; con grupos,
/// los campos comunes arriba y una pestaña por grupo.
class ClaseFormularioCampos extends StatelessWidget {

  const ClaseFormularioCampos({
    super.key,
    required this.funcAlCambiarCampo,
    required this.funcEsHabilitado,
    required this.listCampos,
    required this.mapValores,
    required this.sIdioma,
  });

  final void Function(String sClave, String sValor) funcAlCambiarCampo;
  final bool Function(ClaseCampoAbm oCampo)          funcEsHabilitado;
  final List<ClaseCampoAbm>                          listCampos;
  final Map<String, String>                          mapValores;
  final String                                       sIdioma;

  @override
  Widget build(BuildContext oContexto) {
    final List<String> listGrupos = <String>[];
    for (final ClaseCampoAbm oCampo in listCampos) {
      final String? sGrupo = oCampo.sGrupo;
      if (sGrupo != null && !listGrupos.contains(sGrupo)) listGrupos.add(sGrupo);
    }

    if (listGrupos.isEmpty) {
      return SingleChildScrollView(
        padding : const EdgeInsets.all(ClaseGenEspacios.dEspacio16),
        child   : Column(
          crossAxisAlignment : CrossAxisAlignment.start,
          children: <Widget>[
            for (final ClaseCampoAbm oCampo in listCampos) _construirCampo(oCampo),
          ],
        ),
      );
    }

    final List<ClaseCampoAbm> listComunes =
        listCampos.where((ClaseCampoAbm o) => o.sGrupo == null).toList();

    return DefaultTabController(
      length : listGrupos.length,
      child  : Column(
        crossAxisAlignment : CrossAxisAlignment.stretch,
        children: <Widget>[
          if (listComunes.isNotEmpty)
            Padding(
              padding : const EdgeInsets.symmetric(horizontal: ClaseGenEspacios.dEspacio16),
              child   : Column(
                crossAxisAlignment : CrossAxisAlignment.start,
                children: <Widget>[
                  for (final ClaseCampoAbm oCampo in listComunes) _construirCampo(oCampo),
                ],
              ),
            ),
          TabBar(
            tabs: <Widget>[
              for (final String sGrupo in listGrupos)
                Tab(text: ClaseIdiomas.getTexto(sIdioma, sGrupo)),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: <Widget>[
                for (final String sGrupo in listGrupos)
                  SingleChildScrollView(
                    padding : const EdgeInsets.all(ClaseGenEspacios.dEspacio16),
                    child   : Column(
                      crossAxisAlignment : CrossAxisAlignment.start,
                      children: <Widget>[
                        for (final ClaseCampoAbm oCampo in listCampos
                            .where((ClaseCampoAbm o) => o.sGrupo == sGrupo))
                          _construirCampo(oCampo),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _construirCampo(ClaseCampoAbm oCampo) {
    return ClaseCampoFormulario(
      bHabilitado   : funcEsHabilitado(oCampo),
      funcAlCambiar : (String sValor) => funcAlCambiarCampo(oCampo.sClave, sValor),
      mapValores    : mapValores,
      oCampo        : oCampo,
      sIdioma       : sIdioma,
      sValor        : mapValores[oCampo.sClave] ?? '',
    );
  }

}


/// Grilla lateral de registros: filtro, orden por columna, paginación, menú
/// contextual por celda y contraer/expandir. Lleva su propio estado; solo la
/// selección (iRegistro) vive en el padre.
class ClaseGrillaRegistros extends StatefulWidget {

  const ClaseGrillaRegistros({
    super.key,
    required this.funcSeleccionar,
    required this.iRegistro,
    required this.listCampos,
    required this.listRegistros,
    required this.sIdioma,
  });

  /// Selecciona el registro por su índice en listRegistros.
  final void Function(int iIndice) funcSeleccionar;

  /// Índice en listRegistros del registro seleccionado (-1 si ninguno).
  final int                        iRegistro;
  final List<ClaseCampoAbm>        listCampos;
  final List<Map<String, dynamic>> listRegistros;
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

  @override
  void dispose() {
    oControlFiltro.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant ClaseGrillaRegistros oAntiguo) {
    super.didUpdateWidget(oAntiguo);
    // Al seleccionar un registro (ej: con Encontrar) se salta a su página.
    if (oAntiguo.iRegistro != widget.iRegistro
        && widget.iRegistro >= 0
        && widget.iRegistro < widget.listRegistros.length) {
      final int iPosicion = _listFiltrados().indexOf(widget.listRegistros[widget.iRegistro]);
      if (iPosicion >= 0) iPagina = iPosicion ~/ ClaseGenLayout.iFilasPagina;
    }
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
      listSalida.sort((Map<String, dynamic> a, Map<String, dynamic> b) =>
          (a[sClaveOrden] ?? '').toString().compareTo((b[sClaveOrden] ?? '').toString()));
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
          child : Text(ClaseIdiomas.getTexto(widget.sIdioma, 'menuCopiarValor')),
        ),
        PopupMenuItem<String>(
          value : 'buscarValor',
          child : Text(ClaseIdiomas.getTexto(widget.sIdioma, 'menuBuscarValor')),
        ),
        PopupMenuItem<String>(
          value : 'copiarFila',
          child : Text(ClaseIdiomas.getTexto(widget.sIdioma, 'menuCopiarFila')),
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
      await funcMostrarMensaje(
        context,
        widget.sIdioma,
        ClaseIdiomas.getTexto(widget.sIdioma, 'aplicacion'),
        ClaseIdiomas.getTexto(widget.sIdioma, 'copiadoPortapapeles'),
        ClaseIdiomas.getTexto(widget.sIdioma, 'aceptar'),
        ClaseGenLayout.iAnchoColumnasMensaje,
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
              tooltip   : ClaseIdiomas.getTexto(widget.sIdioma, 'expandirGrilla'),
              icon      : const Icon(Icons.last_page),
              onPressed : () => setState(() => bVisible = true),
            ),
          ],
        ),
      );
    }

    final List<ClaseCampoAbm> listColumnas =
        widget.listCampos.where((ClaseCampoAbm o) => o.bEnGrilla).take(3).toList();
    final List<Map<String, dynamic>> listFiltrados = _listFiltrados();
    final int iTotalPaginas = math.max(1,
        (listFiltrados.length + ClaseGenLayout.iFilasPagina - 1) ~/ ClaseGenLayout.iFilasPagina);
    final int iPaginaActual = (iPagina < iTotalPaginas) ? iPagina : iTotalPaginas - 1;
    final int iInicio = iPaginaActual * ClaseGenLayout.iFilasPagina;
    final int iFin    = math.min(iInicio + ClaseGenLayout.iFilasPagina, listFiltrados.length);
    final List<Map<String, dynamic>> listPagina = (iInicio < listFiltrados.length)
        ? listFiltrados.sublist(iInicio, iFin)
        : <Map<String, dynamic>>[];

    return SizedBox(
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
                      hintText   : ClaseIdiomas.getTexto(widget.sIdioma, 'abmBuscar'),
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
                  tooltip   : ClaseIdiomas.getTexto(widget.sIdioma, 'menuActualizar'),
                  icon      : const Icon(Icons.refresh),
                  onPressed : () => setState(() {
                    sFiltro            = '';
                    oControlFiltro.text = '';
                    iPagina            = 0;
                  }),
                ),
                IconButton(
                  tooltip   : ClaseIdiomas.getTexto(widget.sIdioma, 'contraerGrilla'),
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
                        message : ClaseIdiomas.getTexto(widget.sIdioma, 'ordenarPor'),
                        child   : Text(
                          oCampo.sEtiqueta,
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
                  onTap : () => widget.funcSeleccionar(iIndice),
                  child : Container(
                    color  : bSeleccionado
                        ? Theme.of(oContexto).colorScheme.primaryContainer
                        : null,
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
                  tooltip   : ClaseIdiomas.getTexto(widget.sIdioma, 'menuPrimeraFila'),
                  icon      : const Icon(Icons.first_page),
                  onPressed : (iPaginaActual > 0) ? () => setState(() => iPagina = 0) : null,
                ),
                IconButton(
                  tooltip   : ClaseIdiomas.getTexto(widget.sIdioma, 'paginaAnterior'),
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
                  tooltip   : ClaseIdiomas.getTexto(widget.sIdioma, 'paginaSiguiente'),
                  icon      : const Icon(Icons.chevron_right),
                  onPressed : (iPaginaActual < iTotalPaginas - 1)
                      ? () => setState(() => iPagina = iPaginaActual + 1)
                      : null,
                ),
                IconButton(
                  tooltip   : ClaseIdiomas.getTexto(widget.sIdioma, 'menuUltimaFila'),
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
    );
  }

}


/// Estructura común de un formulario ABM: título, botonera, grilla lateral de
/// registros y el área de formulario (pasada como widget) a la derecha.
class ClaseAndamiajeAbm extends StatelessWidget {

  const ClaseAndamiajeAbm({
    super.key,
    required this.funcAlClicar,
    required this.funcSeleccionar,
    required this.iRegistro,
    required this.listCampos,
    required this.listRegistros,
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

  /// Área derecha: el formulario (campos, o cabecera + detalles).
  final Widget                             oFormulario;
  final Set<EnumBotonAbm>                  setHabilitados;
  final String                             sIdioma;
  final String                             sTitulo;

  @override
  Widget build(BuildContext oContexto) {
    return Scaffold(
      appBar : AppBar(
        title: Text(sTitulo, style: ClaseGenEstilosTexto.tituloMediano(oContexto)),
      ),
      body: Column(
        children: <Widget>[
          _construirBotonera(oContexto),
          Expanded(
            child: Row(
              crossAxisAlignment : CrossAxisAlignment.stretch,
              children: <Widget>[
                ClaseGrillaRegistros(
                  funcSeleccionar : funcSeleccionar,
                  iRegistro       : iRegistro,
                  listCampos      : listCampos,
                  listRegistros   : listRegistros,
                  sIdioma         : sIdioma,
                ),
                const VerticalDivider(width: ClaseGenEspacios.dEspacio01),
                Expanded(child: oFormulario),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _construirBotonera(BuildContext oContexto) {
    return Padding(
      padding : const EdgeInsets.all(ClaseGenEspacios.dEspacio08),
      child   : Wrap(
        spacing    : ClaseGenEspacios.dEspacio08,
        runSpacing : ClaseGenEspacios.dEspacio04,
        children   : <Widget>[
          _construirBoton(oContexto, EnumBotonAbm.agregar,   Icons.add,             'abmAgregar',   bPrimario: true),
          _construirBoton(oContexto, EnumBotonAbm.modificar, Icons.edit,            'abmModificar'),
          _construirBoton(oContexto, EnumBotonAbm.borrar,    Icons.delete,          'abmBorrar'),
          _construirBoton(oContexto, EnumBotonAbm.encontrar, Icons.search,          'abmEncontrar'),
          _construirBoton(oContexto, EnumBotonAbm.grabar,    Icons.save,            'abmGrabar',    bPrimario: true),
          _construirBoton(oContexto, EnumBotonAbm.cancelar,  Icons.cancel_outlined, 'abmCancelar'),
          _construirBoton(oContexto, EnumBotonAbm.fin,       Icons.close,           'abmFin'),
        ],
      ),
    );
  }

  Widget _construirBoton(
    BuildContext oContexto,
    EnumBotonAbm oBoton,
    IconData     oIcono,
    String       sClave, {
    bool bPrimario = false,
  }) {
    final Widget oEtiqueta = Text(ClaseIdiomas.getTexto(sIdioma, sClave),
        style: ClaseGenEstilosTexto.normalMediano(oContexto));
    final Widget oIconoWidget = Icon(oIcono);
    final void Function()? funcAccion =
        setHabilitados.contains(oBoton) ? () => funcAlClicar(oBoton) : null;
    if (bPrimario) {
      return FilledButton.icon(
        onPressed : funcAccion,
        icon      : oIconoWidget,
        label     : oEtiqueta,
      );
    }
    return OutlinedButton.icon(
      onPressed : funcAccion,
      icon      : oIconoWidget,
      label     : oEtiqueta,
    );
  }

}
