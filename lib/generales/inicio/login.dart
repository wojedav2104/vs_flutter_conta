import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../idiomas/idiomas.dart';
import '../preferencias/preferencias.dart';
import '../temas/colores.dart';
import '../temas/espacios.dart';
import '../temas/estilos_textos.dart';
import '../temas/layout.dart';
import '../temas/radios.dart';
import '../widgets/controles_preferencias.dart';
import '../widgets/ventana_mensaje.dart';
import 'pantalla_principal.dart';


/// Pantalla de login de VS_CONTA.
class ClaseLogin extends StatefulWidget {
  const ClaseLogin({
    super.key,
    required this.funcAlCambiar,
    required this.oPreferencias,
  });

  final VoidCallback      funcAlCambiar;
  final ClasePreferencias oPreferencias;

  @override
  State<ClaseLogin> createState() => ClaseEstadoLogin();
}

class ClaseEstadoLogin extends State<ClaseLogin> {

  bool bMostrarContrasena = false;

  final TextEditingController oControlContrasena = TextEditingController();
  final TextEditingController oControlNombre     = TextEditingController();

  // Credenciales iniciales. Más adelante vendrán del ABM de Usuarios y de la BD.
  static const String sContrasenaInicial = '1234';
  static const String sNombreInicial     = 'admin';

  @override
  void initState() {
    super.initState();
    oControlContrasena.text = sContrasenaInicial;
    oControlNombre.text     = sNombreInicial;
  }

  @override
  void dispose() {
    oControlContrasena.dispose();
    oControlNombre.dispose();
    super.dispose();
  }

  // ── Acciones ────────────────────────────────────────────────────────────

  void cancelar() {
    SystemNavigator.pop();
  }

  Future<void> ingresar() async {

    final String sIdioma     = widget.oPreferencias.getIdioma();
    final String sNombre     = oControlNombre.text.trim();
    final String sContrasena = oControlContrasena.text;

    if (sNombre.isEmpty || sContrasena.isEmpty) {
      await funcMostrarMensaje(
        context,
        sIdioma,
        ClaseIdiomas.getTexto(sIdioma, 'aplicacion'),
        ClaseIdiomas.getTexto(sIdioma, 'campoObligatorio'),
        ClaseIdiomas.getTexto(sIdioma, 'aceptar'),
        ClaseGenLayout.iAnchoColumnasMensaje,
      );
      return;
    }
    if (sNombre != sNombreInicial || sContrasena != sContrasenaInicial) {
      await funcMostrarMensaje(
        context,
        sIdioma,
        ClaseIdiomas.getTexto(sIdioma, 'aplicacion'),
        ClaseIdiomas.getTexto(sIdioma, 'credencialesIncorrectas'),
        ClaseIdiomas.getTexto(sIdioma, 'aceptar'),
        ClaseGenLayout.iAnchoColumnasMensaje,
      );
      return;
    }
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (oContexto) => ClasePantallaPrincipal(
          funcAlCambiar : widget.funcAlCambiar,
          oPreferencias : widget.oPreferencias,
        ),
      ),
    );

  }

  // ── Construcción de la interfaz ─────────────────────────────────────────

  @override
  Widget build(BuildContext oContexto) {
    return Scaffold(
      backgroundColor : Theme.of(oContexto).colorScheme.surface,
      body: Stack(
        children: <Widget>[
          Center(
            child: SingleChildScrollView(
              padding : const EdgeInsets.all(ClaseGenEspacios.dEspacio24),
              child   : construirTarjeta(oContexto),
            ),
          ),
          Positioned(
            top   : ClaseGenEspacios.dEspacio16,
            right : ClaseGenEspacios.dEspacio16,
            child : ClaseControlesPreferencias(
              funcAlCambiar : widget.funcAlCambiar,
              oPreferencias : widget.oPreferencias,
            ),
          ),
        ],
      ),
    );
  }

  Widget construirTarjeta(BuildContext oContexto) {
    return SizedBox(
      width : ClaseGenLayout.dAnchoTarjetaLogin,
      child : Card(
        elevation : ClaseGenLayout.dElevacionTarjeta,
        shape     : RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ClaseGenRadios.dGrande),
        ),
        child: Padding(
          padding : const EdgeInsets.all(ClaseGenEspacios.dEspacio32),
          child   : Column(
            mainAxisSize        : MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                ClaseIdiomas.getTexto(widget.oPreferencias.getIdioma(), 'aplicacion'),
                style : ClaseGenEstilosTexto.tituloGrande(oContexto),
              ),
              Container(
                margin     : const EdgeInsets.only(
                  top    : ClaseGenEspacios.dEspacio08,
                  bottom : ClaseGenEspacios.dEspacio32,
                ),
                width      : ClaseGenEspacios.dEspacio64,
                height     : ClaseGenEspacios.dEspacio04,
                decoration : BoxDecoration(
                  color        : ClaseGenColores.colorAmarillo1,
                  borderRadius : BorderRadius.circular(ClaseGenRadios.dCompleto),
                ),
              ),
              construirCampoNombre(oContexto),
              const SizedBox(height: ClaseGenEspacios.dEspacio20),
              construirCampoContrasena(oContexto),
              const SizedBox(height: ClaseGenEspacios.dEspacio08),
              Align(
                alignment : Alignment.centerRight,
                child     : Text(
                  ClaseIdiomas.getTexto(widget.oPreferencias.getIdioma(), 'olvidasteContrasena'),
                  style : ClaseGenEstilosTexto.normalChico(oContexto),
                ),
              ),
              const SizedBox(height: ClaseGenEspacios.dEspacio32),
              construirBotones(oContexto),
            ],
          ),
        ),
      ),
    );
  }

  Widget construirCampoNombre(BuildContext oContexto) {
    final String sIdioma = widget.oPreferencias.getIdioma();
    return TextField(
      controller      : oControlNombre,
      style           : ClaseGenEstilosTexto.textoCampo(oContexto),
      textInputAction : TextInputAction.next,
      decoration      : InputDecoration(
        label : Row(
          mainAxisSize : MainAxisSize.min,
          children     : <Widget>[
            Text(ClaseIdiomas.getTexto(sIdioma, 'nombre'),
                 style: ClaseGenEstilosTexto.etiquetaCampo(oContexto)),
            Text(' *',
                 style: ClaseGenEstilosTexto.etiquetaCampo(oContexto)
                          .copyWith(color: ClaseGenColores.colorError)),
          ],
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ClaseGenRadios.dPequeno),
        ),
      ),
    );
  }

  Widget construirCampoContrasena(BuildContext oContexto) {
    final String sIdioma = widget.oPreferencias.getIdioma();
    return TextField(
      controller      : oControlContrasena,
      obscureText     : !bMostrarContrasena,
      style           : ClaseGenEstilosTexto.textoCampo(oContexto),
      textInputAction : TextInputAction.done,
      onSubmitted     : (sValor) => ingresar(),
      decoration      : InputDecoration(
        label : Row(
          mainAxisSize : MainAxisSize.min,
          children     : <Widget>[
            Text(ClaseIdiomas.getTexto(sIdioma, 'contrasena'),
                 style: ClaseGenEstilosTexto.etiquetaCampo(oContexto)),
            Text(' *',
                 style: ClaseGenEstilosTexto.etiquetaCampo(oContexto)
                          .copyWith(color: ClaseGenColores.colorError)),
          ],
        ),
        suffixIcon: IconButton(
          tooltip   : ClaseIdiomas.getTexto(sIdioma, 'verContrasena'),
          icon      : Icon(bMostrarContrasena ? Icons.visibility_off : Icons.visibility),
          onPressed : () => setState(() => bMostrarContrasena = !bMostrarContrasena),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ClaseGenRadios.dPequeno),
        ),
      ),
    );
  }

  Widget construirBotones(BuildContext oContexto) {
    final String sIdioma   = widget.oPreferencias.getIdioma();
    final String sCancelar = ClaseIdiomas.getTexto(sIdioma, 'cancelar');
    final String sIngresar = ClaseIdiomas.getTexto(sIdioma, 'ingresar');
    return Row(
      children: <Widget>[
        Expanded(
          child: FilledButton.icon(
            onPressed : ingresar,
            style     : FilledButton.styleFrom(
              minimumSize: const Size(0, ClaseGenLayout.dAltoBoton),
            ),
            icon      : const Icon(Icons.login),
            label     : Text(sIngresar,
                        style: ClaseGenEstilosTexto.botonGrande(oContexto)),
          ),
        ),
        const SizedBox(width: ClaseGenEspacios.dEspacio16),
        Expanded(
          child: OutlinedButton.icon(
            onPressed : cancelar,
            style     : OutlinedButton.styleFrom(
              minimumSize: const Size(0, ClaseGenLayout.dAltoBoton),
            ),
            icon      : const Icon(Icons.cancel_outlined),
            label     : Text(sCancelar,
                        style: ClaseGenEstilosTexto.botonGrande(oContexto)),
          ),
        ),
      ],
    );
  }

}
