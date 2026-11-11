import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vs_conta/generales/widgets/controles_preferencias.dart';

import '../idiomas/idiomas.dart';
import '../preferencias/preferencias.dart';
import '../temas/colores.dart';
import '../temas/espacios.dart';
import '../temas/estilos_textos.dart';
import '../temas/layout.dart';
import '../temas/radios.dart';
import 'pantalla_principal.dart';

/// Pantalla de login de VS_CONTA.
class ClaseLogin extends StatefulWidget {
  const ClaseLogin({
    super.key,
    required this.oPreferencias,
    required this.funcAlCambiar,
  });

  final ClasePreferencias oPreferencias;
  final VoidCallback      funcAlCambiar;

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
  Future<void> actualizarIdioma(String? sValor) async {
    if (sValor == null) return;
    await widget.oPreferencias.setIdioma(sValor);
    if (!mounted) return;
    setState(() {});
    widget.funcAlCambiar();
  }

  Future<void> actualizarTema(String? sValor) async {
    if (sValor == null) return;
    await widget.oPreferencias.setTema(sValor);
    if (!mounted) return;
    setState(() {});
    widget.funcAlCambiar();
  }

  void cancelar() {
    SystemNavigator.pop();
  }

  Future<void> ingresar() async {

    final String sContrasena = oControlContrasena.text;
    final String sIdioma     = widget.oPreferencias.getIdioma();
    final String sNombre     = oControlNombre.text.trim();

    if (sNombre.isEmpty || sContrasena.isEmpty) {
      await mostrarMensaje(ClaseIdiomas.getTexto(sIdioma, 'campoObligatorio'));
      return;
    }
    if (sNombre != sNombreInicial || sContrasena != sContrasenaInicial) {
      await mostrarMensaje(ClaseIdiomas.getTexto(sIdioma, 'credencialesIncorrectas'));
      return;
    }
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (oContexto) => ClasePantallaPrincipal(
          oPreferencias : widget.oPreferencias,
          funcAlCambiar : widget.funcAlCambiar,
        ),
      ),
    );

  }


  Future<void> mostrarMensaje(String sMensaje) async {
    final String sAceptar    = ClaseIdiomas.getTexto(widget.oPreferencias.getIdioma(), 'aceptar');
    final String sAplicacion = ClaseIdiomas.getTexto(widget.oPreferencias.getIdioma(), 'aplicacion');
    await showDialog<void>(
      context            : context,
      barrierDismissible : false,
      builder            : (oContexto) {
        return AlertDialog(
          title: Row(
            children: <Widget>[
              const Icon(Icons.error_outline, color: ClaseGenColores.colorError),
              const SizedBox(width: ClaseGenEspacios.dEspacio08),
              Expanded(child: Text(sAplicacion, style: ClaseGenEstilosTexto.subtituloMediano(oContexto))),
              IconButton(
                icon      : const Icon(Icons.close),
                onPressed : () => Navigator.of(oContexto).pop(),
              ),
            ],
          ),
          content : Text(sMensaje, style: ClaseGenEstilosTexto.normalMediano(oContexto)),
          actions : <Widget>[
            FilledButton.icon(
              onPressed : () => Navigator.of(oContexto).pop(),
              icon      : const Icon(Icons.check),
              label     : Text(sAceptar, style: ClaseGenEstilosTexto.normalMediano(oContexto)),
            ),
          ],
        );
      },
    );
  }

  // ── Construcción de la interfaz ─────────────────────────────────────────
  @override
  Widget build(BuildContext oContexto) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          construirFondo(oContexto),
          Positioned(
            top   : ClaseGenEspacios.dEspacio16,
            right : ClaseGenEspacios.dEspacio16,
            child : ClaseControlesPreferencias(
              oPreferencias : widget.oPreferencias,
              funcAlCambiar : widget.funcAlCambiar,
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding : const EdgeInsets.all(ClaseGenEspacios.dEspacio24),
              child   : construirTarjeta(oContexto),
            ),
          ),
        ],
      ),
    );
  }

  Widget construirFondo(BuildContext oContexto) {
    final ThemeData oTema = Theme.of(oContexto);
    return Container(
      color : oTema.colorScheme.surface,
      child : Stack(
        children: <Widget>[
          Positioned(
            top   : -120,
            right : -80,
            child : Container(
              width       : 320,
              height      : 320,
              decoration  : BoxDecoration(
                color        : oTema.colorScheme.primaryContainer.withValues(alpha: 0.35),
                borderRadius : BorderRadius.circular(ClaseGenRadios.dCompleto),
              ),
            ),
          ),
          Positioned(
            bottom : -140,
            left   : -100,
            child  : Container(
              width       : 320,
              height      : 320,
              decoration  : BoxDecoration(
                color        : oTema.colorScheme.secondaryContainer.withValues(alpha: 0.35),
                borderRadius : BorderRadius.circular(ClaseGenRadios.dCompleto),
              ),
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
    final String sCancelar = ClaseIdiomas.getTexto(widget.oPreferencias.getIdioma(), 'cancelar');
    final String sIngresar = ClaseIdiomas.getTexto(widget.oPreferencias.getIdioma(), 'ingresar');
    return Row(
      children: <Widget>[
        Expanded(
          child: FilledButton.icon(
            onPressed : ingresar,
            style     : FilledButton.styleFrom(minimumSize: const Size(0, 52)),
            icon      : const Icon(Icons.login),
            label     : Text(sIngresar,
                        style: ClaseGenEstilosTexto.normalGrande(oContexto)
                                 .copyWith(fontWeight: FontWeight.w600)),
          ),
        ),
        const SizedBox(width: ClaseGenEspacios.dEspacio16),
        Expanded(
          child: OutlinedButton.icon(
            onPressed : cancelar,
            style     : OutlinedButton.styleFrom(minimumSize: const Size(0, 52)),
            icon      : const Icon(Icons.cancel_outlined),
            label     : Text(sCancelar,
                        style: ClaseGenEstilosTexto.normalGrande(oContexto)
                                 .copyWith(fontWeight: FontWeight.w600)),
          ),
        ),
      ],
    );
  }

}
