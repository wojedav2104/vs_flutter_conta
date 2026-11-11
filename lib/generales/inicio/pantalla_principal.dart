import 'package:flutter/material.dart';

import '../../rutas/generador_rutas.dart';
import '../idiomas/idiomas.dart';
import '../preferencias/preferencias.dart';
import '../temas/espacios.dart';
import '../temas/estilos_textos.dart';
import '../widgets/controles_preferencias.dart';
import '../widgets/ventana_configuracion.dart';
import 'menu_lateral.dart';


/// Pantalla principal de VS_CONTA.
///
/// El drawer se abre automáticamente al ingresar y cada vez que el usuario
/// regresa desde un formulario, para que nunca se sienta perdido.
class ClasePantallaPrincipal extends StatefulWidget {

  const ClasePantallaPrincipal({
    super.key,
    required this.oPreferencias,
    required this.funcAlCambiar,
  });

  final ClasePreferencias oPreferencias;
  final VoidCallback      funcAlCambiar;

  @override
  State<ClasePantallaPrincipal> createState() => ClaseEstadoPantallaPrincipal();
}

class ClaseEstadoPantallaPrincipal extends State<ClasePantallaPrincipal>
    with RouteAware {

  final GlobalKey<ScaffoldState> oClaveAndamio = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    abrirDrawer();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final ModalRoute<dynamic>? oRuta = ModalRoute.of(context);
    if (oRuta is PageRoute<dynamic>) {
      oObservadorRutas.subscribe(this, oRuta);
    }
  }

  @override
  void dispose() {
    oObservadorRutas.unsubscribe(this);
    super.dispose();
  }

  /// Se ejecuta cuando el usuario regresa a esta pantalla desde otra.
  @override
  void didPopNext() {
    abrirDrawer();
  }

  void abrirDrawer() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      oClaveAndamio.currentState?.openDrawer();
    });
  }

  @override
  Widget build(BuildContext oContexto) {
    return Scaffold(
      key   : oClaveAndamio,
      appBar: AppBar(
        title : Text(ClaseIdiomas.getTexto(widget.oPreferencias.getIdioma(), 'aplicacion'),
                  style: ClaseGenEstilosTexto.subtituloGrande(oContexto)),
        actions: <Widget>[
          ClaseControlesPreferencias(
            oPreferencias : widget.oPreferencias,
            funcAlCambiar : widget.funcAlCambiar,
          ),
          IconButton(
            tooltip   : ClaseIdiomas.getTexto(widget.oPreferencias.getIdioma(), 'configuracion'),
            icon      : const Icon(Icons.settings),
            onPressed : () => funcMostrarConfiguracion(oContexto, widget.oPreferencias, widget.funcAlCambiar),
          ),
          const SizedBox(width: ClaseGenEspacios.dEspacio16),
        ],
      ),
      drawer : ClaseMenuLateral(oPreferencias: widget.oPreferencias),
      body   : const SizedBox.shrink(),
    );
  }

}

