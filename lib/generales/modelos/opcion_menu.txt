import 'package:flutter/material.dart';


/// Opción del menú lateral (drawer).
class ClaseOpcionMenu {

  ClaseOpcionMenu({
    required this.oIcono,
    required this.sClave,
    required this.sRuta,
    this.listPaises,
  });

  IconData      oIcono;
  List<String>? listPaises;
  String        sClave;
  String        sRuta;

  /// Devuelve true si la opción se muestra en el país indicado.
  /// Cuando listPaises es null la opción se muestra en todos los países.
  bool puedeMostrar(String sPais) => listPaises == null || listPaises!.contains(sPais);

}