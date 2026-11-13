import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../idiomas/idiomas.dart';

/// Países admitidos, cargados desde assets/datos/paises.json.
///
/// El JSON define la lista (código + clave de idioma); los nombres visibles
/// se traducen con ClaseIdiomas. Los registros guardan solo el código.
abstract final class ClasePaises {

  static List<Map<String, String>> _listPaises = <Map<String, String>>[];

  /// Carga el JSON. Se llama una sola vez en main(), antes de runApp().
  static Future<void> cargar() async {
    final String sJson = await rootBundle.loadString('assets/datos/paises.json');
    final List<dynamic> listDatos = jsonDecode(sJson) as List<dynamic>;
    _listPaises = listDatos
        .map((dynamic o) => Map<String, String>.from(o as Map))
        .toList();
  }

  /// Códigos en el orden del JSON (lo que se guarda en los registros).
  static List<String> getListValores() {
    return _listPaises.map((Map<String, String> o) => o['codigo']!).toList();
  }

  /// Etiquetas 'CÓDIGO - Nombre' traducidas (lo que se muestra en pantalla).
  static List<String> getListOpciones(String sIdioma) {
    return _listPaises
        .map((Map<String, String> o) => getEtiqueta(o['codigo']!, sIdioma))
        .toList();
  }

  /// Etiqueta 'CÓDIGO - Nombre' de un país guardado en un registro.
  static String getEtiqueta(String sCodigo, String sIdioma) {
    return '$sCodigo - ${getNombre(sCodigo, sIdioma)}';
  }

  /// Nombre traducido del país. Si el código no existe, devuelve el código.
  static String getNombre(String sCodigo, String sIdioma) {
    for (final Map<String, String> o in _listPaises) {
      if (o['codigo'] == sCodigo) {
        return ClaseIdiomas.getTexto(sIdioma, o['clave']!);
      }
    }
    return sCodigo;
  }

}
