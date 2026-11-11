import 'dart:math' show min;

import 'package:flutter/material.dart';

import '../idiomas/idiomas.dart';
import '../modelos/campo_abm.dart';
import '../preferencias/preferencias.dart';
import '../temas/colores.dart';
import '../temas/espacios.dart';
import '../temas/estilos_textos.dart';
import '../temas/layout.dart';
import '../temas/radios.dart';
import '../utilitarios/formatos.dart';
import 'ventana_mensaje.dart';


/// Estado de un formulario ABM.
enum EnumEstadoAbm { agregando, encontrando, inicial, modificando }


/// Clase común para todos los formularios ABM.
///
/// Si los campos tienen sGrupo, la AppBar muestra los nombres de los grupos
/// como pestañas y cada pestaña muestra los campos de su grupo.
class ClaseFormularioAbm extends StatefulWidget {

  const ClaseFormularioAbm({
    super.key,
    required this.listCampos,
    required this.listRegistros,
    required this.oPreferencias,
    required this.sTitulo,
    this.bPermitirEncontrar   = true,
    this.bTablaUnSoloRegistro = false,
    this.funcAlBorrar,
    this.funcAlGrabar,
  });

  final bool bPermitirEncontrar;
  final bool bTablaUnSoloRegistro;
  final Future<String?> Function(Map<String, dynamic> oRegistro)?               funcAlBorrar;
  final Future<String?> Function(Map<String, dynamic> oRegistro, bool bEsNuevo)? funcAlGrabar;
  final List<ClaseCampoAbm>                                                     listCampos;
  final List<Map<String, dynamic>>                                              listRegistros;
  final ClasePreferencias                                                       oPreferencias;
  final String                                                                  sTitulo;

  @override
  State<ClaseFormularioAbm> createState() => ClaseEstadoFormularioAbm();
}

class ClaseEstadoFormularioAbm extends State<ClaseFormularioAbm> with SingleTickerProviderStateMixin {

  bool bGrillaExpandida = false;

  EnumEstadoAbm enumEstado = EnumEstadoAbm.inicial;

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
  /// Cerrada: máximo 25 caracteres (2 o 3 campos). Abierta: máximo 75.
  /// Siempre muestra al menos 2 campos para no dejar la grilla vacía.
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

  // ── Acciones ────────────────────────────────────────────────────────────
  void agregar() {
    setState(() {
      enumEstado = EnumEstadoAbm.agregando;
      for (final ClaseCampoAbm oCampo in widget.listCampos) {
        mapControladores[oCampo.sClave]!.clear();
      }
    });
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
    setState(() {
      listFiltrada = listResultados;
      iPagina      = 0;
      iRegistro    = listFiltrada.isEmpty ? -1 : 0;
      enumEstado   = EnumEstadoAbm.inicial;
    });
    if (iRegistro >= 0) cargarRegistro(iRegistro);
  }

  void cargarRegistro(int iIndice) {
    final Map<String, dynamic> oRegistro = listFiltrada[iIndice];
    for (final ClaseCampoAbm oCampo in widget.listCampos) {
      mapControladores[oCampo.sClave]!.text = (oRegistro[oCampo.sClave] ?? '').toString();
    }
    setState(() => iRegistro = iIndice);
  }

  void cancelar() {
    setState(() => enumEstado = EnumEstadoAbm.inicial);
    if (iRegistro >= 0) {
      cargarRegistro(iRegistro);
    } else {
      for (final ClaseCampoAbm oCampo in widget.listCampos) {
        mapControladores[oCampo.sClave]!.clear();
      }
    }
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
      iRegistro    = listFiltrada.indexOf(oRegistro);
    } else {
      final Map<String, dynamic> oActual = listFiltrada[iRegistro];
      oActual.clear();
      oActual.addAll(oRegistro);
    }
    setState(() => enumEstado = EnumEstadoAbm.inicial);
    await funcMostrarMensaje(context, getIdioma(), widget.sTitulo, getTexto('grabacionExitosa'));
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
      if (oCampo.bObligatorio &&
          mapControladores[oCampo.sClave]!.text.trim().isEmpty) {
        mapFocos[oCampo.sClave]!.requestFocus();
        funcMostrarMensaje(context, getIdioma(), widget.sTitulo,
            getTexto('campoObligatorio'));
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
    if (listGrupos.isEmpty) {
      return construirCampos(oContexto, widget.listCampos);
    }
    return TabBarView(
      controller : oControlPestanas,
      children   : <Widget>[
        for (final String sGrupo in listGrupos)
          construirCampos(
            oContexto,
            widget.listCampos.where((oCampo) => oCampo.sGrupo == sGrupo).toList(),
          ),
      ],
    );
  }

  Widget construirGrilla(BuildContext oContexto) {
    final ThemeData oTema   = Theme.of(oContexto);
    final int       iInicio = iPagina * ClaseGenLayout.iFilasPorPagina;
    final int       iFin    = min(iInicio + ClaseGenLayout.iFilasPorPagina, listFiltrada.length);
    final List<Map<String, dynamic>> listPagina =
        (iInicio < listFiltrada.length) ? listFiltrada.sublist(iInicio, iFin) : <Map<String, dynamic>>[];

    return AnimatedContainer(
      duration  : const Duration(milliseconds: 250),
      width     : bGrillaExpandida ? ClaseGenLayout.dAnchoReferencia * 0.75
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
                    flex  : getAnchoGrilla(oCampo),
                    child : Text(oCampo.sEtiqueta,
                        overflow : TextOverflow.ellipsis,
                        style    : ClaseGenEstilosTexto.etiquetaCampo(oContexto)),
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
                            flex  : getAnchoGrilla(oCampo),
                            child : Text(
                              truncarTextoGrilla(
                                  (listPagina[iIndice][oCampo.sClave] ?? '').toString(), oCampo),
                              overflow : TextOverflow.ellipsis,
                              style    : ClaseGenEstilosTexto.textoCampo(oContexto),
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
    } else if (oCampo.oTipo == EnumTipoCampoAbm.lista) {
      // La flecha de la lista ocupa espacio a la derecha
      dAncho = oCampo.iAnchoCaracteres * ClaseGenLayout.dAnchoCaracter
               + ClaseGenLayout.dAnchoIconoFlecha;
    } else {
      // El icono "X" de borrado y el relleno interno ocupan espacio
      dAncho = oCampo.iAnchoCaracteres * ClaseGenLayout.dAnchoCaracter
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
          setState(() => oControl.text = sValor ?? '');
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
          setState(() => oControl.text = (bValor ?? false) ? 'S' : 'N');
        } : null,
      );
    }




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
        controller : oControl,
        enabled    : bHabilitado,
        focusNode  : mapFocos[oCampo.sClave],
        maxLength  : oCampo.oTipo == EnumTipoCampoAbm.comentario ? oCampo.iMaxComentario : null,
        maxLines   : oCampo.oTipo == EnumTipoCampoAbm.comentario ? 3 : 1,
        onChanged  : (sValor) {
          setState(() {});
        },
        style      : ClaseGenEstilosTexto.textoCampo(oContexto),
        textAlign  : bNumero ? TextAlign.right : TextAlign.left,
        decoration : InputDecoration(
          counterText : '',
          hintText    : oCampo.sHint ??
                        (oCampo.oTipo == EnumTipoCampoAbm.fecha ? 'dd/mm/aaaa' :
                         oCampo.oTipo == EnumTipoCampoAbm.hora  ? 'hh:mm' : null),
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
    );
  }

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
              funcAlPulsar: bEnEdicion ? grabar : null, bEsPrimario: true),
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

  Widget construirBoton(
    BuildContext oContexto, {
    required IconData      oIcono,
    required String        sTexto,
    required VoidCallback? funcAlPulsar,
    bool                   bEsPrimario = false,
  }) {
    final Widget wEtiqueta = Text(sTexto,
        overflow : TextOverflow.ellipsis,
        style    : ClaseGenEstilosTexto.normalMediano(oContexto));
    return SizedBox(
      width  : ClaseGenLayout.dAnchoBotonAbm,
      height : ClaseGenLayout.dAltoBotonAbm,
      child  : bEsPrimario
          ? FilledButton.icon(
              onPressed : funcAlPulsar,
              icon      : Icon(oIcono),
              label     : wEtiqueta,
            )
          : OutlinedButton.icon(
              onPressed : funcAlPulsar,
              icon      : Icon(oIcono),
              label     : wEtiqueta,
            ),
    );
  }

}
