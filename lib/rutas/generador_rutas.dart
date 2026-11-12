import 'package:flutter/material.dart';

import '../generales/preferencias/preferencias.dart';
import '../generales/varios/pantalla_proximamente.dart';

import '../opciones/archivos/asientos.dart';
import '../opciones/archivos/cuentas.dart';

import '../opciones/tablas/clientes.dart';
import '../opciones/tablas/configuracion.dart';
import '../opciones/tablas/cuentas_asignadas.dart';
import '../opciones/tablas/empresa.dart';
import '../opciones/tablas/proveedores.dart';
import '../opciones/tablas/sucursales.dart';
import '../opciones/tablas/timbrados_propios.dart';
import '../opciones/tablas/timbrados_proveedores.dart';

import 'rutas.dart';


/// Observador de rutas: permite a las pantallas saber cuándo el usuario
/// regresa a ellas desde otra pantalla.
final RouteObserver<PageRoute<dynamic>> oObservadorRutas = RouteObserver<PageRoute<dynamic>>();


/// Genera la pantalla correspondiente a cada ruta.
///
/// Recibe las preferencias del usuario para pasarlas a cada pantalla.
/// A medida que se implemente cada módulo se agrega su caso aquí.
Route<dynamic> funcGenerarRuta(
  RouteSettings     oConfiguracion,
  ClasePreferencias oPreferencias,
) {
  final String sTitulo = (oConfiguracion.arguments as String?) ?? '';

  if (oConfiguracion.name == ClaseRutas.rutaEmpresa) {
    return MaterialPageRoute<dynamic>(
      settings : oConfiguracion,
      builder  : (oContexto) => ClaseEmpresa(oPreferencias: oPreferencias),
    );
  }

  if (oConfiguracion.name == ClaseRutas.rutaConfiguracion) {
    return MaterialPageRoute<dynamic>(
      settings : oConfiguracion,
      builder  : (oContexto) => ClaseConfiguracion(oPreferencias: oPreferencias),
    );
  }

  if (oConfiguracion.name == ClaseRutas.rutaSucursales) {
    return MaterialPageRoute<dynamic>(
      settings : oConfiguracion,
      builder  : (oContexto) => ClaseSucursales(oPreferencias: oPreferencias),
    );
  }

  if (oConfiguracion.name == ClaseRutas.rutaClientes) {
    return MaterialPageRoute<dynamic>(
      settings : oConfiguracion,
      builder  : (oContexto) => ClaseClientes(oPreferencias: oPreferencias),
    );
  }

  if (oConfiguracion.name == ClaseRutas.rutaProveedores) {
    return MaterialPageRoute<dynamic>(
      settings : oConfiguracion,
      builder  : (oContexto) => ClaseProveedores(oPreferencias: oPreferencias),
    );
  }

  if (oConfiguracion.name == ClaseRutas.rutaTimbradosPropios) {
    return MaterialPageRoute<dynamic>(
      settings : oConfiguracion,
      builder  : (oContexto) => ClaseTimbradosPropios(oPreferencias: oPreferencias),
    );
  }

  if (oConfiguracion.name == ClaseRutas.rutaTimbradosProveedores) {
    return MaterialPageRoute<dynamic>(
      settings : oConfiguracion,
      builder  : (oContexto) => ClaseTimbradosProveedores(oPreferencias: oPreferencias),
    );
  }

  if (oConfiguracion.name == ClaseRutas.rutaCuentasAsignadas) {
    return MaterialPageRoute<dynamic>(
      settings : oConfiguracion,
      builder  : (oContexto) => ClaseCuentasAsignadas(oPreferencias: oPreferencias),
    );
  }

  if (oConfiguracion.name == ClaseRutas.rutaCuentas) {
    return MaterialPageRoute<dynamic>(
      settings : oConfiguracion,
      builder  : (oContexto) => ClaseCuentas(oPreferencias: oPreferencias),
    );
  }

  if (oConfiguracion.name == ClaseRutas.rutaAsientos) {
    return MaterialPageRoute<dynamic>(
      settings : oConfiguracion,
      builder  : (oContexto) => ClaseAsientos(oPreferencias: oPreferencias),
    );
  }

  





  // Resto de las opciones: pantalla provisoria
  return MaterialPageRoute<dynamic>(
    settings : oConfiguracion,
    builder  : (oContexto) => ClasePantallaProximamente(sTitulo: sTitulo),
  );

}
