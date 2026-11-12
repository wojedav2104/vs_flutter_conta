// ============================================================================
//  ARCHIVO: lib/generales/validaciones/cap_validar.dart
//  TODAS las validaciones que NO requieren acceso a la Base de Datos
// ============================================================================

import '../idiomas/idiomas.dart';
import '../utilitarios/formatos.dart';

class ClaseCapValidar {

  // ── Auxiliares privados ─────────────────────────────────────────────────

  /// Devuelve el mensaje traducido con los parámetros {0}, {1}, etc.
  static String _traducir(String sIdioma, String sClave, List<String> listParametros) {
    String sMensaje = ClaseIdiomas.getTexto(sIdioma, sClave);
    for (int i = 0; i < listParametros.length; i++) {
      sMensaje = sMensaje.replaceAll('{$i}', listParametros[i]);
    }
    return sMensaje;
  }

  /// Formatea una fecha como dd/mm/aaaa.
  static String _formatearFecha(DateTime fFecha) {
    return '${fFecha.day.toString().padLeft(2, '0')}/'
           '${fFecha.month.toString().padLeft(2, '0')}/'
           '${fFecha.year}';
  }

  // ── Validaciones básicas ─────────────────────────────────────────────────

  static String? validarObligatorio(String sValor, String sEtiqueta, String sIdioma) {
    if (sValor.trim().isEmpty) return _traducir(sIdioma, 'validObligatorio', <String>[sEtiqueta]);
    return null;
  }

  static String? validarLongitudMaxima(String sValor, String sEtiqueta, int iMax, String sIdioma) {
    if (sValor.length > iMax) return _traducir(sIdioma, 'validLongMaxima', <String>[sEtiqueta, '$iMax']);
    return null;
  }

  static String? validarLongitudMinima(String sValor, String sEtiqueta, int iMin, String sIdioma) {
    final String sDato = sValor.trim();
    if (sDato.isEmpty) return null;
    if (sDato.length < iMin) return _traducir(sIdioma, 'validLongMinima', <String>[sEtiqueta, '$iMin']);
    return null;
  }

  static String? validarSoloEntero(String sValor, String sEtiqueta, String sIdioma) {
    final String sDato = sValor.trim();
    if (sDato.isEmpty) return null;
    if (int.tryParse(sDato) == null) return _traducir(sIdioma, 'validSoloEntero', <String>[sEtiqueta]);
    return null;
  }

  static String? validarEnteroDeLongitud(String sValor, String sEtiqueta, int iLong, String sIdioma) {
    final String sDato = sValor.trim();
    if (sDato.isEmpty) return null;
    if (int.tryParse(sDato) == null) return _traducir(sIdioma, 'validSoloEntero', <String>[sEtiqueta]);
    if (sDato.length != iLong)   return _traducir(sIdioma, 'validDigitosExactos', <String>[sEtiqueta, '$iLong']);
    return null;
  }

  // ── Validaciones de dígitos y rangos ─────────────────────────────────────

  static String? validarDigitosExactos(String sValor, String sEtiqueta, int iDigitos, String sIdioma) {
    final String sDato = sValor.trim();
    if (sDato.isEmpty) return null;
    if (!RegExp(r'^[0-9]+$').hasMatch(sDato) || sDato.length != iDigitos) {
      return _traducir(sIdioma, 'validDigitosExactos', <String>[sEtiqueta, '$iDigitos']);
    }
    return null;
  }

  static String? validarRangoEntero(String sValor, String sEtiqueta, int iMin, int iMax, String sIdioma) {
    final String sDato = sValor.trim();
    if (sDato.isEmpty) return null;
    final int? iValor = int.tryParse(sDato);
    if (iValor == null || iValor < iMin || iValor > iMax) {
      return _traducir(sIdioma, 'validRangoEntero', <String>[sEtiqueta, '$iMin', '$iMax']);
    }
    return null;
  }

  // ── Validaciones de fecha ────────────────────────────────────────────────

  static String? validarFechaValida(String sValor, String sEtiqueta, String sIdioma) {
    final String sDato = sValor.trim();
    if (sDato.isEmpty) return null;
    if (funcParsearFecha(sDato) == null) {
      return _traducir(sIdioma, 'validFechaInvalida', <String>[sEtiqueta]);
    }
    return null;
  }

  static String? validarFechaNoAnterior(String sValor, String sEtiqueta, DateTime fMin, String sIdioma) {
    final String sDato = sValor.trim();
    if (sDato.isEmpty) return null;
    final DateTime? fFecha = funcParsearFecha(sDato);
    if (fFecha == null) return _traducir(sIdioma, 'validFechaInvalida', <String>[sEtiqueta]);
    if (fFecha.isBefore(fMin)) {
      return _traducir(sIdioma, 'validFechaAnterior', <String>[sEtiqueta, _formatearFecha(fMin)]);
    }
    return null;
  }

  // ── Validaciones de cuenta contable ──────────────────────────────────────

  /// Valida formato de cuenta: hasta 5 grupos de 1-2 dígitos separados por puntos.
  /// Ejemplos válidos: 1, 1.01, 1.01.04, 2.03.05.17, 3.05.01.07.18
  static String? validarFormatoCuenta(String sValor, String sEtiqueta, String sIdioma) {
    final String sDato = sValor.trim();
    if (sDato.isEmpty) return null;
    if (!RegExp(r'^\d{1,2}(\.\d{1,2}){0,4}$').hasMatch(sDato)) {
      return ClaseIdiomas.getTexto(sIdioma, 'validFormatoCuenta');
    }
    return null;
  }

  /// Cuenta la cantidad de dígitos (sin puntos) de un número de cuenta.
  static int contarDigitosCuenta(String sCuenta) {
    return sCuenta.replaceAll('.', '').replaceAll(RegExp(r'[^0-9]'), '').length;
  }

  // ── Validaciones de ejercicio, nivel y subcuenta ─────────────────────────

  /// El año debe ser >= 2020 y <= año actual.
  static String? validarEjercicio(String sValor, String sEtiqueta, String sIdioma) {
    final String sDato = sValor.trim();
    if (sDato.isEmpty) return null;
    final int? iAnio = int.tryParse(sDato);
    final int iAnioActual = DateTime.now().year;
    if (iAnio == null || iAnio < 2020 || iAnio > iAnioActual) {
      return ClaseIdiomas.getTexto(sIdioma, 'validEjercicioRango');
    }
    return null;
  }

  /// Un dígito entre 1 y 9.
  static String? validarNivelCuenta(String sValor, String sEtiqueta, String sIdioma) {
    final String sDato = sValor.trim();
    if (sDato.isEmpty) return null;
    final int? iNivel = int.tryParse(sDato);
    if (iNivel == null || iNivel < 1 || iNivel > 9) {
      return ClaseIdiomas.getTexto(sIdioma, 'validNivelCuenta');
    }
    return null;
  }

  /// 5 dígitos entre 00001 y 99999.
  static String? validarNumeroSubcuenta(String sValor, String sEtiqueta, String sIdioma) {
    final String sDato = sValor.trim();
    if (sDato.isEmpty) return null;
    final int? iSub = int.tryParse(sDato);
    if (sDato.length != 5 || iSub == null || iSub < 1 || iSub > 99999) {
      return ClaseIdiomas.getTexto(sIdioma, 'validSubcuentaRango');
    }
    return null;
  }

  // ── Validaciones cruzadas (múltiples campos) ─────────────────────────────

  /// La fecha fin debe ser estrictamente posterior a la fecha inicio.
  static String? validarFechaFinPosterior(String sFechaInicio, String sFechaFin, String sIdioma) {
    if (sFechaFin.trim().isEmpty || sFechaInicio.trim().isEmpty) return null;
    final DateTime? fInicio = funcParsearFecha(sFechaInicio);
    final DateTime? fFin    = funcParsearFecha(sFechaFin);
    if (fInicio != null && fFin != null && !fFin.isAfter(fInicio)) {
      return ClaseIdiomas.getTexto(sIdioma, 'validFechaFinPosterior');
    }
    return null;
  }

  /// Al menos una opción seleccionada en un grupo de casillas.
  static String? validarAlMenosUnoSeleccionado(String sValor, String sEtiqueta, String sIdioma) {
    if (sValor.trim().isEmpty) {
      return _traducir(sIdioma, 'validAlMenosUno', <String>[sEtiqueta]);
    }
    return null;
  }

  /// La cuenta superior es obligatoria si la cuenta tiene más de 1 dígito.
  static String? validarCuentaSuperior(String sCuenta, String sCuentaSuperior, String sIdioma) {
    if (contarDigitosCuenta(sCuenta) > 1 && sCuentaSuperior.trim().isEmpty) {
      return ClaseIdiomas.getTexto(sIdioma, 'validCuentaSuperior');
    }
    return null;
  }

  /// La fecha del asiento debe estar entre el 1 de enero del ejercicio y
  /// a) la fecha de hoy si el ejercicio es el año actual, o
  /// b) el 31/12 del ejercicio si es un año anterior.
  static String? validarFechaAsiento(String sValor, String sEtiqueta, int iEjercicio, String sIdioma) {
    final String sDato = sValor.trim();
    if (sDato.isEmpty) return null;
    final DateTime? fFecha = funcParsearFecha(sDato);
    if (fFecha == null) return _traducir(sIdioma, 'validFechaInvalida', <String>[sEtiqueta]);
    final DateTime fInicio = DateTime(iEjercicio, 1, 1);
    final int iAnioActual   = DateTime.now().year;
    final DateTime fFin = (iEjercicio >= iAnioActual)
        ? DateTime.now()
        : DateTime(iEjercicio, 12, 31);
    if (fFecha.isBefore(fInicio) || fFecha.isAfter(fFin)) {
      return _traducir(sIdioma, 'validFechaAsientoRango',
          <String>[_formatearFecha(fInicio), _formatearFecha(fFin)]);
    }
    return null;
  }

  /// La suma del Debe debe ser exactamente igual a la suma del Haber.
  static String? validarSumaDebeHaber(int iSumaDebe, int iSumaHaber, String sIdioma) {
    if (iSumaDebe != iSumaHaber) {
      return ClaseIdiomas.getTexto(sIdioma, 'validSumaDebeHaber');
    }
    return null;
  }

}
