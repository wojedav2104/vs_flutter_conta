import 'package:flutter/material.dart';

import 'generales/idiomas/idiomas.dart';
import 'generales/inicio/login.dart';
import 'generales/preferencias/preferencias.dart';
import 'generales/temas/temas.dart';
import 'generales/utilitarios/menu_navegador_web.dart'
    if (dart.library.io) 'generales/utilitarios/menu_navegador_movil.dart';

import 'rutas/generador_rutas.dart';


/// Punto de entrada de VS_CONTA.
Future<void> main() async {
  funcDesactivarMenuNavegador();
  WidgetsFlutterBinding.ensureInitialized();
  final ClasePreferencias oPreferencias = ClasePreferencias();
  await oPreferencias.cargar();
  runApp(ClaseAplicacion(oPreferencias: oPreferencias));
}


/// Aplicación raíz de VS_CONTA.
class ClaseAplicacion extends StatefulWidget {

  const ClaseAplicacion({
    super.key,
    required this.oPreferencias,
  });

  final ClasePreferencias oPreferencias;

  @override
  State<ClaseAplicacion> createState() => ClaseEstadoAplicacion();
}

class ClaseEstadoAplicacion extends State<ClaseAplicacion> {

  void alCambiar() {
    setState(() {});
  }

  @override
  Widget build(BuildContext oContexto) {
    return MaterialApp(
      title                       : ClaseIdiomas.getTexto(widget.oPreferencias.getIdioma(), 'aplicacion'),
      debugShowCheckedModeBanner  : false,
      theme                       : ClaseGenTemas.getTemaClaro,
      darkTheme                   : ClaseGenTemas.getTemaOscuro,
      themeMode                   : (widget.oPreferencias.getTema() == 'oscuro') ? ThemeMode.dark : ThemeMode.light,
      navigatorObservers          : <NavigatorObserver>[oObservadorRutas],
      onGenerateRoute             : (oConfiguracion) => funcGenerarRuta(oConfiguracion, widget.oPreferencias),
      home                        : ClaseLogin(
                                     oPreferencias : widget.oPreferencias,
                                     funcAlCambiar : alCambiar,
                                   ),
    );
  }

}



