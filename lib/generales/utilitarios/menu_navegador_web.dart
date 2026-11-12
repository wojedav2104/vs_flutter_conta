import 'dart:js_interop';
import 'package:web/web.dart' as web;


/// Desactiva el menú contextual del navegador dentro de la aplicación (web).
void funcDesactivarMenuNavegador() {
  web.document.addEventListener('contextmenu', _onContextMenu.toJS);
}


void _onContextMenu(web.Event oEvento) {
  oEvento.preventDefault();
}

