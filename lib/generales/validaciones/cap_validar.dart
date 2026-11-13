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

  // ── Validaciones de números enteros ──────────────────────────────────────

  /// Solo dígitos, sin signo. Si algún día se necesitan números negativos,
  /// se creará un método aparte.
  static String? validarSoloEntero(String sValor, String sEtiqueta, String sIdioma) {
    final String sDato = sValor.trim();
    if (sDato.isEmpty) return null;
    if (!RegExp(r'^[0-9]+$').hasMatch(sDato)) {
      return _traducir(sIdioma, 'validSoloEntero', <String>[sEtiqueta]);
    }
    return null;
  }

  static String? validarEnteroDeLongitud(String sValor, String sEtiqueta, int iLong, String sIdioma) {
    final String sDato = sValor.trim();
    if (sDato.isEmpty) return null;
    if (!RegExp(r'^[0-9]+$').hasMatch(sDato)) {
      return _traducir(sIdioma, 'validSoloEntero', <String>[sEtiqueta]);
    }
    if (sDato.length != iLong) {
      return _traducir(sIdioma, 'validDigitosExactos', <String>[sEtiqueta, '$iLong']);
    }
    return null;
  }

  static String? validarDigitosExactos(String sValor, String sEtiqueta, int iDigitos, String sIdioma) {
    final String sDato = sValor.trim();
    if (sDato.isEmpty) return null;
    if (!RegExp(r'^[0-9]+$').hasMatch(sDato) || sDato.length != iDigitos) {
      return _traducir(sIdioma, 'validDigitosExactos', <String>[sEtiqueta, '$iDigitos']);
    }
    return null;
  }

  /// Valida un número de documento con la máscara 999-999-9999999
  /// (13 dígitos agrupados 3-3-7). Es el formato del N° de documento.
  static String? validarNumeroDocumento(String sValor, String sEtiqueta, String sIdioma) {
    final String sDato = sValor.trim();
    if (sDato.isEmpty) return null;
    if (!RegExp(r'^\d{3}-\d{3}-\d{7}$').hasMatch(sDato)) {
      return _traducir(sIdioma, 'validNumeroDocumento', <String>[sEtiqueta]);
    }
    return null;
  }
  
  static String? validarRangoEntero(String sValor, String sEtiqueta, int iMin, int iMax, String sIdioma) {
    final String sDato = sValor.trim();
    if (sDato.isEmpty) return null;
    if (!RegExp(r'^[0-9]+$').hasMatch(sDato)) {
      return _traducir(sIdioma, 'validSoloEntero', <String>[sEtiqueta]);
    }
    final int iValor = int.parse(sDato);
    if (iValor < iMin || iValor > iMax) {
      return _traducir(sIdioma, 'validRangoEntero', <String>[sEtiqueta, '$iMin', '$iMax']);
    }
    return null;
  }

  // ── Validaciones de fecha y hora ─────────────────────────────────────────

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
      return _traducir(sIdioma, 'validFechaAnterior', <String>[sEtiqueta, funcFormatearFecha(fMin)]);
    }
    return null;
  }

  /// La hora debe tener formato hh:mm y estar entre 00:00 y 23:59.
  static String? validarHoraValida(String sValor, String sEtiqueta, String sIdioma) {
    final String sDato = sValor.trim();
    if (sDato.isEmpty) return null;
    if (funcParsearHora(sDato) == null) {
      return _traducir(sIdioma, 'validHoraInvalida', <String>[sEtiqueta]);
    }
    return null;
  }

  // ── Validaciones de cuenta contable ──────────────────────────────────────

  /// Indica si un texto tiene el formato de cuenta válido: hasta 5 grupos
  /// de 1-2 dígitos separados por puntos (1, 1.01, 1.01.04, 2.03.05.17).
  static bool esFormatoCuenta(String sValor) {
    return RegExp(r'^\d{1,2}(\.\d{1,2}){0,4}$').hasMatch(sValor.trim());
  }

  /// Cuenta la cantidad de dígitos (sin puntos) de un número de cuenta.
  static int contarDigitosCuenta(String sCuenta) {
    return sCuenta.replaceAll('.', '').replaceAll(RegExp(r'[^0-9]'), '').length;
  }

  /// Cuenta la cantidad de grupos de un número de cuenta (1.01.04 → 3).
  static int contarGruposCuenta(String sCuenta) {
    final String sDato = sCuenta.trim();
    return sDato.isEmpty ? 0 : sDato.split('.').length;
  }

  static String? validarFormatoCuenta(String sValor, String sEtiqueta, String sIdioma) {
    final String sDato = sValor.trim();
    if (sDato.isEmpty) return null;
    if (!esFormatoCuenta(sDato)) {
      return ClaseIdiomas.getTexto(sIdioma, 'validFormatoCuenta');
    }
    return null;
  }

  /// Cuenta la cantidad de dígitos (sin puntos) de un número de cuenta.
  static int contarDigitosCuenta(String sCuenta) {
    return sCuenta.replaceAll('.', '').replaceAll(RegExp(r'[^0-9]'), '').length;
  }

  // ── Validaciones de ejercicio, nivel y subcuenta ─────────────────────────

  /// El año debe ser >= ClaseFechas.iAnioMinimo y <= año actual.
  static String? validarEjercicio(String sValor, String sEtiqueta, String sIdioma) {
    final String sDato = sValor.trim();
    if (sDato.isEmpty) return null;
    if (!RegExp(r'^[0-9]+$').hasMatch(sDato)) {
      return _traducir(sIdioma, 'validSoloEntero', <String>[sEtiqueta]);
    }
    final int iAnio       = int.parse(sDato);
    final int iAnioActual = DateTime.now().year;
    if (iAnio < ClaseFechas.iAnioMinimo || iAnio > iAnioActual) {
      return _traducir(sIdioma, 'validEjercicioRango', <String>[sEtiqueta]);
    }
    return null;
  }

  /// Un dígito entre 1 y 9.
  static String? validarNivelCuenta(String sValor, String sEtiqueta, String sIdioma) {
    final String sDato = sValor.trim();
    if (sDato.isEmpty) return null;
    if (!RegExp(r'^[1-9]$').hasMatch(sDato)) {
      return _traducir(sIdioma, 'validNivelCuenta', <String>[sEtiqueta]);
    }
    return null;
  }

  /// 5 dígitos entre 00001 y 99999.
  static String? validarNumeroSubcuenta(String sValor, String sEtiqueta, String sIdioma) {
    final String sDato = sValor.trim();
    if (sDato.isEmpty) return null;
    if (!RegExp(r'^[0-9]{5}$').hasMatch(sDato)) {
      return _traducir(sIdioma, 'validSubcuentaRango', <String>[sEtiqueta]);
    }
    final int iSub = int.parse(sDato);
    if (iSub < 1 || iSub > 99999) {
      return _traducir(sIdioma, 'validSubcuentaRango', <String>[sEtiqueta]);
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

  /// La fecha debe estar entre el 01/01 del ejercicio y
  /// a) la fecha de hoy si el ejercicio es el año actual, o
  /// b) el 31/12 del ejercicio si es un año anterior.
  /// Se usa tanto para la fecha del asiento como para la fecha de la compra.
  static String? validarFechaEnEjercicio(
    String sValor,
    String sEtiqueta,
    int    iEjercicio,
    String sIdioma,
  ) {
    final String sDato = sValor.trim();
    if (sDato.isEmpty) return null;
    final DateTime? fFecha = funcParsearFecha(sDato);
    if (fFecha == null) return _traducir(sIdioma, 'validFechaInvalida', <String>[sEtiqueta]);
    final DateTime fInicio = DateTime(iEjercicio, 1, 1);
    final DateTime fAhora  = DateTime.now();
    final DateTime fFin    = (iEjercicio >= fAhora.year) ? fAhora : DateTime(iEjercicio, 12, 31);
    if (fFecha.isBefore(fInicio) || fFecha.isAfter(fFin)) {
      return _traducir(sIdioma, 'validFechaRango',
          <String>[sEtiqueta, funcFormatearFecha(fInicio), funcFormatearFecha(fFin)]);
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

  /// Valida que un valor numérico (con o sin separador de miles) sea mayor o
  /// igual que cero. Rechaza cualquier texto que no sea un número entero.
  static String? validarNoNegativo(String sValor, String sEtiqueta, String sIdioma) {
    final String sDato = sValor.trim();
    if (sDato.isEmpty) return null;
    final int? iValor = funcParsearEnteroMilesEstricto(sDato);
    if (iValor == null) return _traducir(sIdioma, 'validSoloEntero', <String>[sEtiqueta]);
    if (iValor < 0)     return _traducir(sIdioma, 'validNoNegativo', <String>[sEtiqueta]);
    return null;
  }

  // ── Validación de identificación (RUC, cédula, pasaporte) ───────────────

  /// Calcula el dígito verificador del RUC según el módulo 11 (DNIT/SET).
  /// Los multiplicadores van de 2 a 11, ciclando de derecha a izquierda
  /// sobre los dígitos de la base (sin el guión ni el DV).
  /// Ejemplo de la SET: base 3535123 → DV 3.
  static int calcularDigitoVerificadorRuc(String sBase) {
    int iTotal = 0;
    int iK     = 2;
    for (int i = sBase.length - 1; i >= 0; i--) {
      iTotal += int.parse(sBase[i]) * iK;
      iK = (iK == 11) ? 2 : iK + 1;
    }
    final int iResto = iTotal % 11;
    return (iResto > 1) ? (11 - iResto) : 0;
  }

  /// Valida la identificación según el tipo (código de ClaseTipoIdentificacion):
  ///   RUC : de 6 a 8 dígitos + guión + dígito verificador (módulo 11).
  ///         Persona física: base de 6-7 dígitos (total 8-9).
  ///         Persona jurídica: base de 8 dígitos (total 10).
  ///   CI  : de 5 a 8 dígitos, con puntos opcionales como separadores.
  ///   PAS / CEX : letras mayúsculas, dígitos y guiones.
  ///   SD / DIP : sin validación de formato.
  static String? validarIdentificacion(
    String sValor,
    String sTipoIdentificacion,
    String sEtiqueta,
    String sIdioma,
  ) {
    final String sDato = sValor.trim();
    if (sDato.isEmpty) return null;
    switch (sTipoIdentificacion) {
      case ClaseTipoIdentificacion.ruc:
        final RegExpMatch? oMatch =
            RegExp(r'^(\d{6,8})-(\d)$').firstMatch(sDato);
        if (oMatch == null) {
          return _traducir(sIdioma, 'validIdentRuc', <String>[sEtiqueta]);
        }
        final int iDv = int.parse(oMatch.group(2)!);
        if (calcularDigitoVerificadorRuc(oMatch.group(1)!) != iDv) {
          return _traducir(sIdioma, 'validIdentRucDv', <String>[sEtiqueta]);
        }
        return null;
      case ClaseTipoIdentificacion.cedula:
        final String sDigitos = sDato.replaceAll('.', '');
        if (!RegExp(r'^\d{5,8}$').hasMatch(sDigitos)) {
          return _traducir(sIdioma, 'validIdentCedula', <String>[sEtiqueta]);
        }
        return null;
      case ClaseTipoIdentificacion.pasaporte:
      case ClaseTipoIdentificacion.cedulaExtranjera:
        if (!RegExp(r'^[A-Z0-9\-]+$').hasMatch(sDato)) {
          return _traducir(sIdioma, 'validIdentPasaporte', <String>[sEtiqueta]);
        }
        return null;
      default:
        return null;
    }
  }

  /// Valida un número de RUC (formato y dígito verificador módulo 11).
  static String? validarRuc(String sValor, String sEtiqueta, String sIdioma) {
    return validarIdentificacion(
        sValor, ClaseTipoIdentificacion.ruc, sEtiqueta, sIdioma);
  }

}
