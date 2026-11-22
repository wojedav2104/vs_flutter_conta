import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Estado global de la sesion (empresa activa, pais, idioma y ejercicio contable).
class ClaseSesionEstado {

  const ClaseSesionEstado({
    this.sEmpresaActiva = '',
    this.sPais          = 'PRY',
    this.sIdioma        = 'es',
    this.iEjercicio     = 2026,
  });

  final String sEmpresaActiva;
  final String sPais;
  final String sIdioma;
  final int    iEjercicio;

  ClaseSesionEstado funcCopiarCon({
    String? sEmpresaActiva,
    String? sPais,
    String? sIdioma,
    int?    iEjercicio,
  }) {
    return ClaseSesionEstado(
      sEmpresaActiva : sEmpresaActiva ?? this.sEmpresaActiva,
      sPais          : sPais          ?? this.sPais,
      sIdioma        : sIdioma        ?? this.sIdioma,
      iEjercicio     : iEjercicio     ?? this.iEjercicio,
    );
  }
}

/// Notifier de Riverpod para gestionar el estado global de la sesion.
class ClaseSesionNotifier extends Notifier<ClaseSesionEstado> {

  @override
  ClaseSesionEstado build() {
    return const ClaseSesionEstado();
  }

  void funcActualizarEmpresa(String sValor) {
    state = state.funcCopiarCon(sEmpresaActiva: sValor);
  }

  void funcActualizarPais(String sValor) {
    state = state.funcCopiarCon(sPais: sValor);
  }

  void funcActualizarIdioma(String sValor) {
    state = state.funcCopiarCon(sIdioma: sValor);
  }

  void funcActualizarEjercicio(int iValor) {
    state = state.funcCopiarCon(iEjercicio: iValor);
  }
}

/// Proveedor global de Riverpod para el estado de la sesion.
final NotifierProvider<ClaseSesionNotifier, ClaseSesionEstado> oProveedorSesion =
    NotifierProvider<ClaseSesionNotifier, ClaseSesionEstado>(ClaseSesionNotifier.new);
