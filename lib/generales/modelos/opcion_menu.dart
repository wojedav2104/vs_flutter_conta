import 'package:flutter/material.dart';


/// Opción del menú lateral (drawer).
class ClaseOpcionMenu {

  ClaseOpcionMenu({
    required this.oIcono,
    required this.sClave,
    required this.sRuta,
    this.listPaises,
  });

  final IconData      oIcono;

  /// Países en los que se muestra la opción (códigos de paises.json).
  /// null = se muestra en todos los países.
  final List<String>? listPaises;

  final String        sClave;
  final String        sRuta;

  /// Devuelve true si la opción se muestra en el país indicado.
  /// Cuando listPaises es null la opción se muestra en todos los países.
  bool puedeMostrar(String sPais) => listPaises == null || listPaises!.contains(sPais);

}
