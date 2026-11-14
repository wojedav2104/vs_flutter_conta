import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../idiomas/idiomas.dart';
import '../preferencias/preferencias.dart';
import '../temas/espacios.dart';
import '../temas/estilos_textos.dart';
import '../temas/layout.dart';
import '../temas/radios.dart';
import '../temas/temas.dart';
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

  /// Sale de la aplicación, previa confirmación para evitar salidas
  /// accidentales.
  Future<void> cancelar() async {
    final String sIdioma = widget.oPreferencias.getIdioma();
    if (!mounted) return;
    final EnumRespuestaConfirmacion oRespuesta = await funcMostrarConfirmacion(
      context,
      sIdioma,
      ClaseIdiomas.getTexto(sIdioma, 'aplicacion'),
      ClaseIdiomas.getTexto(sIdioma, 'confirmarSalir'),
      bMostrarCancelar : false,
    );
    if (oRespuesta == EnumRespuestaConfirmacion.si && mounted) {
      SystemNavigator.pop();
    }
  }

  Future<void> ingresar() async {

    final String sIdioma     = widget.oPreferencias.getIdioma();
    final String sNombre     = oControlNombre.text.trim();
    final String sContrasena = oControlContrasena.text;

    if (sNombre.isEmpty || sContrasena.isEmpty) {
      if (!mounted) return;
      await funcMostrarError(
        context,
        sIdioma,
        ClaseIdiomas.getTexto(sIdioma, 'aplicacion'),
        ClaseIdiomas.getTexto(sIdioma, 'campoObligatorio'),
      );
      return;
    }
    if (sNombre != sNombreInicial || sContrasena != sContrasenaInicial) {
      if (!mounted) return;
      await funcMostrarError(
        context,
        sIdioma,
        ClaseIdiomas.getTexto(sIdioma, 'aplicacion'),
        ClaseIdiomas.getTexto(sIdioma, 'credencialesIncorrectas'),
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

  /// Recuperación de contraseña: pide el e-mail y muestra el aviso estándar.
  /// TODO: cuando exista conexión con la BD, verificar que el e-mail esté
  /// registrado y enviar el mensaje para crear la nueva contraseña.
  Future<void> recuperarContrasena() async {
    final String sIdioma = widget.oPreferencias.getIdioma();
    if (!mounted) return;
    final String? sCorreo = await funcMostrarPedirTexto(
      context,
      sIdioma,
      ClaseIdiomas.getTexto(sIdioma, 'olvidasteContrasena'),
      ClaseIdiomas.getTexto(sIdioma, 'olvidasteMensaje'),
      ClaseIdiomas.getTexto(sIdioma, 'correoElectronico'),
    );
    if (sCorreo == null || !mounted) return;
    if (!funcEsCorreoValido(sCorreo)) {
      await funcMostrarError(
        context,
        sIdioma,
        ClaseIdiomas.getTexto(sIdioma, 'aplicacion'),
        ClaseIdiomas.getTexto(sIdioma, 'correoInvalido'),
      );
      return;
    }
    await funcMostrarInformacion(
      context,
      sIdioma,
      ClaseIdiomas.getTexto(sIdioma, 'aplicacion'),
      ClaseIdiomas.getTexto(sIdioma, 'olvidasteConfirmacion'),
    );
  }

  /// Formato básico del e-mail.
  /// TODO: mover a lib/generales/validaciones/cap_validar.dart (regla de
  /// que todas las validaciones viven ahí) si no existe ya un validador.
  bool funcEsCorreoValido(String sCorreo) =>
      RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(sCorreo);

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
                  color        : ClaseGenTemas.colorAcento(oContexto),
                  borderRadius : BorderRadius.circular(ClaseGenRadios.dCompleto),
                ),
              ),
              construirCampoNombre(oContexto),
              const SizedBox(height: ClaseGenEspacios.dEspacio20),
              construirCampoContrasena(oContexto),
              const SizedBox(height: ClaseGenEspacios.dEspacio08),
              Align(
                alignment : Alignment.centerRight,
                child     : TextButton(
                  onPressed : recuperarContrasena,
                  child     : Text(
                    ClaseIdiomas.getTexto(widget.oPreferencias.getIdioma(), 'olvidasteContrasena'),
                    style : ClaseGenEstilosTexto.normalChico(oContexto),
                  ),
                ),
              ),
              const SizedBox(height: ClaseGenEspacios.dEspacio16),
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
      autofocus       : true,                       // ← foco inicial (decisión 3)
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
                          .copyWith(color: Theme.of(oContexto).colorScheme.error)),
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
      controller        : oControlContrasena,
      obscureText       : !bMostrarContrasena,
      autocorrect       : false,
      enableSuggestions : false,
      style             : ClaseGenEstilosTexto.textoCampo(oContexto),
      textInputAction   : TextInputAction.done,
      onSubmitted       : (sValor) => ingresar(),
      decoration        : InputDecoration(
        label : Row(
          mainAxisSize : MainAxisSize.min,
          children     : <Widget>[
            Text(ClaseIdiomas.getTexto(sIdioma, 'contrasena'),
                 style: ClaseGenEstilosTexto.etiquetaCampo(oContexto)),
            Text(' *',
                 style: ClaseGenEstilosTexto.etiquetaCampo(oContexto)
                          .copyWith(color: Theme.of(oContexto).colorScheme.error)),
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
