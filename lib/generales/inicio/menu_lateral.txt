import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../rutas/rutas.dart';
import '../idiomas/idiomas.dart';
import '../modelos/opcion_menu.dart';
import '../modelos/sesion.dart';
import '../preferencias/preferencias.dart';
import '../temas/colores.dart';
import '../temas/espacios.dart';
import '../temas/estilos_textos.dart';


/// Menú lateral (drawer) de la pantalla principal.
///
/// Muestra las opciones del país de la Base de Datos conectada.
/// Por ejemplo: ASUNCION muestra Marangatú (Paraguay); LIMA no lo muestra.
class ClaseMenuLateral extends StatelessWidget {
  
  const ClaseMenuLateral({
    super.key,
    required this.oPreferencias,
  });

  final ClasePreferencias oPreferencias;

  // ── Opciones del menú ───────────────────────────────────────────────────
  static final List<ClaseOpcionMenu> _listArchivos = <ClaseOpcionMenu>[
    ClaseOpcionMenu(oIcono: Icons.account_tree_outlined,        sClave: 'menuPlanCuentas',         sRuta: ClaseRutas.rutaCuentas),
    ClaseOpcionMenu(oIcono: Icons.edit_note,                    sClave: 'menuAsientos',            sRuta: ClaseRutas.rutaAsientos),
    ClaseOpcionMenu(oIcono: Icons.shopping_cart_outlined,       sClave: 'menuLibroCompras',        sRuta: ClaseRutas.rutaCompras),
    ClaseOpcionMenu(oIcono: Icons.point_of_sale_outlined,       sClave: 'menuLibroVentas',         sRuta: ClaseRutas.rutaVentas),
    ClaseOpcionMenu(oIcono: Icons.people_outline,               sClave: 'menuRetencionesClientes', sRuta: ClaseRutas.rutaRetencionesClientes),
    ClaseOpcionMenu(oIcono: Icons.business_outlined,            sClave: 'menuRetencionesProveedores', sRuta: ClaseRutas.rutaRetencionesProveedores),
  ];

  static final List<ClaseOpcionMenu> _listInformes = <ClaseOpcionMenu>[
    ClaseOpcionMenu(oIcono: Icons.fact_check_outlined,    sClave: 'menuVerificacionDatos',   sRuta: ClaseRutas.rutaVerificacionDatos),
    ClaseOpcionMenu(oIcono: Icons.account_tree_outlined,  sClave: 'menuPlanCuentas',         sRuta: ClaseRutas.rutaPlanCuentas),
    ClaseOpcionMenu(oIcono: Icons.menu_book_outlined,     sClave: 'menuLibroDiario',         sRuta: ClaseRutas.rutaLibroDiario),
    ClaseOpcionMenu(oIcono: Icons.auto_stories_outlined,  sClave: 'menuLibroMayor',          sRuta: ClaseRutas.rutaLibroMayor),
    ClaseOpcionMenu(oIcono: Icons.balance_outlined,       sClave: 'menuBalanceSumasSaldos',  sRuta: ClaseRutas.rutaBalanceSumasSaldos),
    ClaseOpcionMenu(oIcono: Icons.pie_chart_outline,      sClave: 'menuBalanceGeneral',      sRuta: ClaseRutas.rutaBalanceGeneral),
    ClaseOpcionMenu(oIcono: Icons.trending_up,            sClave: 'menuEstadoResultados',    sRuta: ClaseRutas.rutaEstadoResultados),
    ClaseOpcionMenu(oIcono: Icons.shopping_cart_outlined, sClave: 'menuLibroCompras',        sRuta: ClaseRutas.rutaCompras),
    ClaseOpcionMenu(oIcono: Icons.point_of_sale_outlined, sClave: 'menuLibroVentas',         sRuta: ClaseRutas.rutaVentas),
  ];

  static final List<ClaseOpcionMenu> _listProcesos = <ClaseOpcionMenu>[
    ClaseOpcionMenu(oIcono: Icons.sort,                    sClave: 'menuReorganizarAsientos', sRuta: ClaseRutas.rutaReorganizarAsientos),
    ClaseOpcionMenu(oIcono: Icons.event_busy_outlined,     sClave: 'menuCierreAnual',         sRuta: ClaseRutas.rutaCierreAnual),
    ClaseOpcionMenu(oIcono: Icons.lock_open_outlined,      sClave: 'menuReaperturaCuentas',   sRuta: ClaseRutas.rutaReaperturaCuentas),
    ClaseOpcionMenu(oIcono: Icons.upload_file_outlined,    sClave: 'menuMarangatu',           sRuta: ClaseRutas.rutaMarangatu,
                    listPaises: <String>[ClaseSesion.paisParaguay]),
  ];

  static final List<ClaseOpcionMenu> _listSistema = <ClaseOpcionMenu>[
    ClaseOpcionMenu(oIcono: Icons.storage_outlined, sClave: 'menuBasesDatos', sRuta: ClaseRutas.rutaBasesDatos),
  ];

  static final List<ClaseOpcionMenu> _listTablas = <ClaseOpcionMenu>[
    ClaseOpcionMenu(oIcono: Icons.business,                  sClave: 'menuEmpresa',             sRuta: ClaseRutas.rutaEmpresa),
    ClaseOpcionMenu(oIcono: Icons.settings_outlined,         sClave: 'menuConfiguracion',       sRuta: ClaseRutas.rutaConfiguracion),
    ClaseOpcionMenu(oIcono: Icons.store_outlined,            sClave: 'menuSucursales',          sRuta: ClaseRutas.rutaSucursales),
    ClaseOpcionMenu(oIcono: Icons.person_outline,            sClave: 'menuClientes',            sRuta: ClaseRutas.rutaClientes),
    ClaseOpcionMenu(oIcono: Icons.local_shipping_outlined,   sClave: 'menuProveedores',         sRuta: ClaseRutas.rutaProveedores),
    ClaseOpcionMenu(oIcono: Icons.confirmation_number_outlined, sClave: 'menuTimbradosPropios', sRuta: ClaseRutas.rutaTimbradosPropios),
    ClaseOpcionMenu(oIcono: Icons.confirmation_num_outlined, sClave: 'menuTimbradosProveedores', sRuta: ClaseRutas.rutaTimbradosProveedores),
    ClaseOpcionMenu(oIcono: Icons.assignment_ind_outlined,   sClave: 'menuCuentasAsignadas',    sRuta: ClaseRutas.rutaCuentasAsignadas),
  ];

  static final List<ClaseOpcionMenu> _listUtilitarios = <ClaseOpcionMenu>[
    ClaseOpcionMenu(oIcono: Icons.manage_accounts_outlined, sClave: 'menuUsuarios', sRuta: ClaseRutas.rutaUsuarios),
  ];

  // ── Acciones ────────────────────────────────────────────────────────────
  void elegirOpcion(BuildContext oContexto, ClaseOpcionMenu oOpcion) {
    final String sTitulo = ClaseIdiomas.getTexto(oPreferencias.getIdioma(), oOpcion.sClave);
    Navigator.pop(oContexto);
    Navigator.pushNamed(oContexto, oOpcion.sRuta, arguments: sTitulo);
  }

  void finalizar() {
    SystemNavigator.pop();
  }

  // ── Construcción de la interfaz ─────────────────────────────────────────
  @override
  Widget build(BuildContext oContexto) {
    final String sIdioma = oPreferencias.getIdioma();
    final String sPais   = ClaseSesion.getPais();
    return Drawer(
      child: ListView(
        padding : EdgeInsets.zero,
        children: <Widget>[
          construirCabecera(oContexto, sIdioma),
          construirSeccion(oContexto, sPais, 'menuArchivos',    _listArchivos),
          construirSeccion(oContexto, sPais, 'menuTablas',      _listTablas),
          construirSeccion(oContexto, sPais, 'menuProcesos',    _listProcesos),
          construirSeccion(oContexto, sPais, 'menuInformes',    _listInformes),
          construirSeccion(oContexto, sPais, 'menuUtilitarios', _listUtilitarios),
          construirSeccion(oContexto, sPais, 'menuSistema',     _listSistema),
          const Divider(),
          construirFin(oContexto, sIdioma),
          const SizedBox(height: ClaseGenEspacios.dEspacio16),
        ],
      ),
    );
  }

  Widget construirCabecera(BuildContext oContexto, String sIdioma) {
    final ThemeData oTema = Theme.of(oContexto);
    return DrawerHeader(
      decoration: BoxDecoration(color: oTema.colorScheme.primaryContainer),
      child: Column(
        crossAxisAlignment : CrossAxisAlignment.start,
        mainAxisAlignment  : MainAxisAlignment.end,
        children: <Widget>[
          Text(ClaseIdiomas.getTexto(sIdioma, 'aplicacion'),
               style: ClaseGenEstilosTexto.tituloMediano(oContexto)
                        .copyWith(color: oTema.colorScheme.onPrimaryContainer)),
          const SizedBox(height: ClaseGenEspacios.dEspacio04),
          Text(ClaseIdiomas.getTexto(sIdioma, 'baseConectada'),
               style: ClaseGenEstilosTexto.normalChico(oContexto)),
          Text(ClaseSesion.sBaseDatos,
               style: ClaseGenEstilosTexto.textoCampo(oContexto)
                        .copyWith(color: oTema.colorScheme.onPrimaryContainer,
                                  fontWeight: FontWeight.w600)),
          Text(ClaseIdiomas.getTexto(sIdioma, ClaseSesion.getClavePais()),
               style: ClaseGenEstilosTexto.normalChico(oContexto)),
        ],
      ),
    );
  }

  Widget construirSeccion(BuildContext oContexto, String sPais, String sClaveTitulo,
                          List<ClaseOpcionMenu> listOpciones) {
    final List<ClaseOpcionMenu> listVisibles = listOpciones
        .where((oOpcion) => oOpcion.puedeMostrar(sPais))
        .toList();
    if (listVisibles.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment : CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding : const EdgeInsets.fromLTRB(
            ClaseGenEspacios.dEspacio16,
            ClaseGenEspacios.dEspacio16,
            ClaseGenEspacios.dEspacio16,
            ClaseGenEspacios.dEspacio04,
          ),
          child: Text(
            ClaseIdiomas.getTexto(oPreferencias.getIdioma(), sClaveTitulo).toUpperCase(),
            style: ClaseGenEstilosTexto.etiquetaCampo(oContexto)
                     .copyWith(color: Theme.of(oContexto).colorScheme.primary),
          ),
        ),
        for (final ClaseOpcionMenu oOpcion in listVisibles)
          construirOpcion(oContexto, oOpcion),
      ],
    );
  }

  Widget construirOpcion(BuildContext oContexto, ClaseOpcionMenu oOpcion) {
    final ThemeData oTema = Theme.of(oContexto);
    return ListTile(
      dense   : true,
      leading : Icon(oOpcion.oIcono, color: oTema.colorScheme.onSurfaceVariant),
      title   : Text(ClaseIdiomas.getTexto(oPreferencias.getIdioma(), oOpcion.sClave),
                     style: ClaseGenEstilosTexto.normalMediano(oContexto)),
      onTap   : () => elegirOpcion(oContexto, oOpcion),
    );
  }

  Widget construirFin(BuildContext oContexto, String sIdioma) {
    return ListTile(
      dense   : true,
      leading : const Icon(Icons.power_settings_new, color: ClaseGenColores.colorError),
      title   : Text(ClaseIdiomas.getTexto(sIdioma, 'menuFin'),
                     style: ClaseGenEstilosTexto.normalMediano(oContexto)
                              .copyWith(color: ClaseGenColores.colorError,
                                        fontWeight: FontWeight.w600)),
      onTap   : finalizar,
    );
  }

}