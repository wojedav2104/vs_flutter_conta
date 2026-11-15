import '../idiomas/idiomas.dart';
import 'formatos.dart';

/// Validaciones de los distintos tipos de datos, con mensajes en el idioma
/// del usuario. Todas devuelven null si el valor es válido, o un mensaje de
/// error traducido. Las cadenas de error admiten {0}, {1} (cuando el texto
/// traducido se construye por partes).
///
/// Los textos de error (valid*) se definen en idiomas_general y se usan
/// con ClaseIdiomas.getTexto + replaceAll.
class ClaseCapValidar {

  // ── Texto ─────────────────────────────────────────────────────────────

  /// El valor no puede estar vacío.
  static String? validarObligatorio(String sValor, String sEtiqueta, String sIdioma) {
    if (sValor.trim().isEmpty) {
      return ClaseIdiomas.getTexto(sIdioma, 'validObligatorio')
          .replaceAll('{0}', sEtiqueta);
    }
    return null;
  }

  /// La longitud del valor no puede superar iMaximo caracteres.
  static String? validarLongitudMaxima(
      String sValor, String sEtiqueta, int iMaximo, String sIdioma) {
    if (sValor.length > iMaximo) {
      return ClaseIdiomas.getTexto(sIdioma, 'validCantidadCaracteresMaxima')
          .replaceAll('{0}', sEtiqueta)
          .replaceAll('{1}', '$iMaximo');
    }
    return null;
  }

  /// La longitud del valor debe ser de al menos iMinimo caracteres.
  static String? validarLongitudMinima(
      String sValor, String sEtiqueta, int iMinimo, String sIdioma) {
    if (sValor.trim().length < iMinimo) {
      return ClaseIdiomas.getTexto(sIdioma, 'validCantidadCaracteresMinima')
          .replaceAll('{0}', sEtiqueta)
          .replaceAll('{1}', '$iMinimo');
    }
    return null;
  }

  // ── Números ───────────────────────────────────────────────────────────

  /// El valor debe ser un número entero dentro del rango [iMinimo, iMaximo].
  static String? validarRangoEntero(
      String sValor, String sEtiqueta, int iMinimo, int iMaximo, String sIdioma) {
    final int? iNumero = int.tryParse(sValor.trim());
    if (iNumero == null) {
      return ClaseIdiomas.getTexto(sIdioma, 'validNumeroEntero')
          .replaceAll('{0}', sEtiqueta);
    }
    if (iNumero < iMinimo || iNumero > iMaximo) {
      return ClaseIdiomas.getTexto(sIdioma, 'validRangoEntero')
          .replaceAll('{0}', sEtiqueta)
          .replaceAll('{1}', '$iMinimo')
          .replaceAll('{2}', '$iMaximo');
    }
    return null;
  }

  /// El valor debe ser un número entero (con signo opcional).
  static String? validarSoloEntero(String sValor, String sEtiqueta, String sIdioma) {
    final String sTexto = sValor.trim();
    if (sTexto.isEmpty) return null;
    if (!RegExp(r'^[+-]?\d+$').hasMatch(sTexto)) {
      return ClaseIdiomas.getTexto(sIdioma, 'validNumeroEntero')
          .replaceAll('{0}', sEtiqueta);
    }
    return null;
  }

  /// El valor debe tener exactamente iCantidad dígitos (se ignoran los
  /// espacios en blanco).
  static String? validarDigitosExactos(
      String sValor, String sEtiqueta, int iCantidad, String sIdioma) {
    final String sDigitos = sValor.replaceAll(' ', '');
    if (sDigitos.length != iCantidad || !RegExp(r'^\d+$').hasMatch(sDigitos)) {
      return ClaseIdiomas.getTexto(sIdioma, 'validDigitosExactos')
          .replaceAll('{0}', sEtiqueta)
          .replaceAll('{1}', '$iCantidad');
    }
    return null;
  }

  /// El valor debe tener la forma de un número de documento (999-999-9999999).
  static String? validarNumeroDocumento(
      String sValor, String sEtiqueta, String sIdioma) {
    final String sDigitos = sValor.replaceAll(RegExp(r'[^0-9]'), '');
    if (sDigitos.length != 13) {
      return ClaseIdiomas.getTexto(sIdioma, 'validNumeroDocumento')
          .replaceAll('{0}', sEtiqueta);
    }
    return null;
  }

  /// Formato del N° de documento según el Tipo de documento.
  ///
  /// - Los tipos con máscara (01, 02, 03, 04, 06, 09, 10) admiten solo
  ///   dígitos y deben tener 13 (con o sin los guiones).
  /// - Los tipos 05, 07, 08, 11 admiten de 5 a 13 dígitos.
  /// - Los tipos 12 a 18 (importación) requieren 7 dígitos.
  static String? validarNumeroDocumentoPorTipo(
      String sValor, String sTipoDocumento, String sEtiqueta, String sIdioma) {
    final String sTexto = sValor.trim();
    if (sTexto.isEmpty) return null;
    if (ClaseTipoDocumento.esConMascara(sTipoDocumento)) {
      return validarNumeroDocumento(sTexto, sEtiqueta, sIdioma);
    }
    // Tipo 05 (remisión) y similares: entre 5 y 13 dígitos.
    if (sTipoDocumento == '05' || sTipoDocumento == '07' ||
        sTipoDocumento == '08' || sTipoDocumento == '11') {
      final String sDigitos = sTexto.replaceAll(RegExp(r'[^0-9]'), '');
      if (!RegExp(r'^\d+$').hasMatch(sDigitos)
          || sDigitos.length < 5 || sDigitos.length > 13) {
        return ClaseIdiomas.getTexto(sIdioma, 'validNumeroDocumentoTipo')
            .replaceAll('{0}', sEtiqueta)
            .replaceAll('{1}', sTipoDocumento);
      }
      return null;
    }
    // Importación (12 a 18): exactamente 7 dígitos.
    final int? iCodigo = int.tryParse(sTipoDocumento);
    if (iCodigo != null && iCodigo >= 12 && iCodigo <= 18) {
      return validarDigitosExactos(sTexto, sEtiqueta, 7, sIdioma);
    }
    return null;
  }

  /// La hora debe tener el formato hh:mm (24 horas) y ser válida.
  static String? validarHoraValida(String sValor, String sEtiqueta, String sIdioma) {
    final String sTexto = sValor.trim();
    if (sTexto.isEmpty) return null;
    if (!RegExp(r'^([01]\d|2[0-3]):[0-5]\d$').hasMatch(sTexto)) {
      return ClaseIdiomas.getTexto(sIdioma, 'validHora')
          .replaceAll('{0}', sEtiqueta);
    }
    return null;
  }

  /// El ejercicio debe ser un año entre 2020 y 2100.
  static String? validarEjercicio(String sValor, String sEtiqueta, String sIdioma) {
    final String sTexto = sValor.trim();
    if (sTexto.isEmpty) return null;
    final int? iAno = int.tryParse(sTexto);
    if (iAno == null || iAno < 2020 || iAno > 2100) {
      return ClaseIdiomas.getTexto(sIdioma, 'validRangoAnios')
          .replaceAll('{0}', sEtiqueta)
          .replaceAll('{1}', '2020')
          .replaceAll('{2}', '2100');
    }
    return null;
  }

  /// RUC con dígito verificador (módulo 11).
  static String? validarRuc(String sValor, String sEtiqueta, String sIdioma) {
    final String sTexto = sValor.trim();
    if (sTexto.isEmpty) return null;
    if (!RegExp(r'^\d{6,8}-\d$').hasMatch(sTexto)) {
      return ClaseIdiomas.getTexto(sIdioma, 'validRuc')
          .replaceAll('{0}', sEtiqueta);
    }
    final int iDv = funcDigitoVerificador(sTexto.split('-')[0]);
    if (iDv != int.parse(sTexto.split('-')[1])) {
      return ClaseIdiomas.getTexto(sIdioma, 'validRuc')
          .replaceAll('{0}', sEtiqueta);
    }
    return null;
  }

  /// Validación general de la identificación según el tipo.
  static String? validarIdentificacion(
      String sValor, String sTipoIdentificacion, String sEtiqueta, String sIdioma) {
    final String sTexto = sValor.trim();
    if (sTexto.isEmpty) return null;

    // Pasaporte: letras y dígitos, hasta 20 caracteres.
    if (sTipoIdentificacion == ClaseTipoIdentificacion.pasaporte) {
      if (!RegExp(r'^[A-Za-z0-9]{1,20}$').hasMatch(sTexto)) {
        return ClaseIdiomas.getTexto(sIdioma, 'validPasaporte')
            .replaceAll('{0}', sEtiqueta);
      }
      return null;
    }

    // RUC: con dígito verificador.
    if (sTipoIdentificacion == ClaseTipoIdentificacion.ruc) {
      return validarRuc(sTexto, sEtiqueta, sIdioma);
    }

    // Cédula de identidad: de 5 a 8 dígitos (se permiten puntos).
    if (sTipoIdentificacion == ClaseTipoIdentificacion.cedula) {
      final String sDigitos = sTexto.replaceAll('.', '');
      if (!RegExp(r'^\d{5,8}$').hasMatch(sDigitos)) {
        return ClaseIdiomas.getTexto(sIdioma, 'validCedula')
            .replaceAll('{0}', sEtiqueta);
      }
      return null;
    }

    // Cédula extranjera y otros: de 5 a 15 caracteres.
    if (!RegExp(r'^[A-Za-z0-9.\-]{5,15}$').hasMatch(sTexto)) {
      return ClaseIdiomas.getTexto(sIdioma, 'validIdentificacion')
          .replaceAll('{0}', sEtiqueta);
    }
    return null;
  }

  // ── Cuentas contables ─────────────────────────────────────────────────

  /// Formato de cuenta 99.99.99.99.99: hasta 5 grupos de números
  /// separados por puntos (el primero de 1 o 2 dígitos y los demás de
  /// exactamente 2 dígitos).
  static String? validarFormatoCuenta(String sValor, String sEtiqueta, String sIdioma) {
    final String sTexto = sValor.trim();
    if (sTexto.isEmpty) return null;
    if (!esFormatoCuenta(sTexto)) {
      return ClaseIdiomas.getTexto(sIdioma, 'validFormatoCuenta')
          .replaceAll('{0}', sEtiqueta);
    }
    return null;
  }

  /// true si sValor tiene el formato de cuenta 99.99.99.99.99: el primer
  /// grupo tiene 1 o 2 dígitos y los demás exactamente 2 dígitos,
  /// separados por puntos, hasta 5 grupos.                        ← LOTE 1
  /// Ejemplos válidos: 1, 1.01, 2.03.01, 3.05.02.09, 10.02.05.03.04.
  static bool esFormatoCuenta(String sValor) =>
      RegExp(r'^\d{1,2}(\.\d{2}){0,4}$').hasMatch(sValor.trim());

  /// Cantidad de grupos de la cuenta (1.01.04 → 3).
  static int contarGruposCuenta(String sNumeroCuenta) =>
      sNumeroCuenta.trim().isEmpty ? 0 : sNumeroCuenta.trim().split('.').length;

  /// Cantidad de dígitos de la cuenta (ignora los puntos) (1.01.04 → 4).
  static int contarDigitosCuenta(String sNumeroCuenta) =>
      sNumeroCuenta.trim().replaceAll('.', '').length;

  /// Cuenta superior determinística: el grupo anterior.           ← LOTE 1
  /// 1.03.02 → '1.03' ; 10.02 → '10' ; raíz (un solo grupo) → ''.
  static String funcCuentaSuperior(String sNumeroCuenta) {
    final String sCuenta = sNumeroCuenta.trim();
    if (contarGruposCuenta(sCuenta) <= 1) return '';
    return sCuenta.substring(0, sCuenta.lastIndexOf('.'));
  }

  /// La cuenta superior es obligatoria en las cuentas con más de un grupo
  /// (las raíces —"1", "10"— no tienen superior).                ← LOTE 1
  static String? validarCuentaSuperior(
      String sNumeroCuenta, String sCuentaSuperior, String sIdioma) {
    if (contarGruposCuenta(sNumeroCuenta) > 1 && sCuentaSuperior.trim().isEmpty) {
      return ClaseIdiomas.getTexto(sIdioma, 'validCuentaSuperiorObligatoria')
          .replaceAll('{0}',
              ClaseIdiomas.getTexto(sIdioma, 'planCuentaSuperior'));
    }
    return null;
  }

  /// El nivel de la cuenta debe estar entre 1 y 5.                ← LOTE 1
  static String? validarNivelCuenta(String sValor, String sEtiqueta, String sIdioma) {
    final String? sError = validarSoloEntero(sValor, sEtiqueta, sIdioma);
    if (sError != null) return sError;
    final int iNivel = int.tryParse(sValor.trim()) ?? 0;
    if (iNivel < 1 || iNivel > 5) {
      return ClaseIdiomas.getTexto(sIdioma, 'validNivelCuenta')
          .replaceAll('{0}', sEtiqueta);
    }
    return null;
  }

  /// La suma del Debe debe ser igual a la suma del Haber.
  static String? validarSumaDebeHaber(double dDebe, double dHaber, String sIdioma) {
    if ((dDebe - dHaber).abs() > 0.005) {
      return ClaseIdiomas.getTexto(sIdioma, 'validDebeIgualHaber');
    }
    return null;
  }

  /// El valor debe estar entre las opciones permitidas (lista de códigos).
  static String? validarOpciones(
      String sValor, String sEtiqueta, List<String> listValoresPermitidos,
      String sIdioma) {
    if (sValor.trim().isEmpty) return null;
    if (!listValoresPermitidos.contains(sValor)) {
      return ClaseIdiomas.getTexto(sIdioma, 'validValorLista')
          .replaceAll('{0}', sEtiqueta);
    }
    return null;
  }

  /// Al menos una opción seleccionada.
  static String? validarAlMenosUnoSeleccionado(
      String sValor, String sEtiqueta, String sIdioma) {
    if (sValor.trim().isEmpty) {
      return ClaseIdiomas.getTexto(sIdioma, 'validObligatorio')
          .replaceAll('{0}', sEtiqueta);
    }
    return null;
  }

  /// El día debe ser válido para el mes y año indicados (1..31, 1..30, etc.).
  /// Ej: validarRangoDiasMes('31', '04', '2025', …) → error (abril tiene 30).
  static String? validarRangoDiasMes(
      String sValor, String sMes, String sAnio, String sEtiqueta, String sIdioma) {
    final int? iDia   = int.tryParse(sValor.trim());
    final int? iMes   = int.tryParse(sMes.trim());
    final int? iAnio  = int.tryParse(sAnio.trim());
    if (iDia == null || iMes == null || iAnio == null) {
      return ClaseIdiomas.getTexto(sIdioma, 'validFecha')
          .replaceAll('{0}', sEtiqueta);
    }
    final DateTime fInicioMes = DateTime(iAnio, iMes, 1);
    final DateTime fFinMes    = DateTime(iAnio, iMes + 1, 0);
    if (iDia < fInicioMes.day || iDia > fFinMes.day) {
      return ClaseIdiomas.getTexto(sIdioma, 'validDiaRango')
          .replaceAll('{0}', sEtiqueta)
          .replaceAll('{1}', '${fInicioMes.day}')
          .replaceAll('{2}', '${fFinMes.day}');
    }
    return null;
  }

  /// La fecha no puede ser anterior a la mínima (ej: no antes del 01/01/2020).
  static String? validarFechaNoAnterior(
      String sValor, String sEtiqueta, DateTime fMinima, String sIdioma) {
    final DateTime? fValor = funcParsearFecha(sValor);
    if (fValor == null) return null;
    if (fValor.isBefore(fMinima)) {
      return ClaseIdiomas.getTexto(sIdioma, 'validFechaMinima')
          .replaceAll('{0}', sEtiqueta)
          .replaceAll('{1}', funcFormatearFecha(fMinima));
    }
    return null;
  }

  /// La fecha de fin no puede ser anterior a la fecha de inicio.
  static String? validarFechaFinPosterior(
      String sValorInicio, String sValorFin, String sIdioma) {
    final DateTime? fInicio = funcParsearFecha(sValorInicio);
    final DateTime? fFin    = funcParsearFecha(sValorFin);
    if (fInicio == null || fFin == null) return null;
    if (fFin.isBefore(fInicio)) {
      return ClaseIdiomas.getTexto(sIdioma, 'validFechaFinAnterior');
    }
    return null;
  }

  /// La fecha debe ser válida (dd/mm/aaaa y existir en el calendario).
  static String? validarFechaValida(String sValor, String sEtiqueta, String sIdioma) {
    final String sTexto = sValor.trim();
    if (sTexto.isEmpty) return null;
    if (funcParsearFecha(sTexto) == null) {
      return ClaseIdiomas.getTexto(sIdioma, 'validFecha')
          .replaceAll('{0}', sEtiqueta);
    }
    return null;
  }

  /// La subcuenta debe ser un número de hasta 5 dígitos.
  static String? validarNumeroSubcuenta(
      String sValor, String sEtiqueta, String sIdioma) {
    final String sTexto = sValor.trim();
    if (sTexto.isEmpty) return null;
    if (!RegExp(r'^\d{1,5}$').hasMatch(sTexto)) {
      return ClaseIdiomas.getTexto(sIdioma, 'validSubcuenta')
          .replaceAll('{0}', sEtiqueta);
    }
    return null;
  }

  /// Moneda: máximo 15 dígitos enteros y 2 decimales.
  static String? validarNumeroValor(
      String sValor, String sEtiqueta, String sIdioma) {
    final String sTexto = sValor.trim();
    if (sTexto.isEmpty) return null;
    if (!RegExp(r'^\d{1,15}([.,]\d{1,2})?$').hasMatch(sTexto)) {
      return ClaseIdiomas.getTexto(sIdioma, 'validNumeroValor')
          .replaceAll('{0}', sEtiqueta);
    }
    return null;
  }

  /// Valor según el Tipo de documento:
  /// - 01 (Factura), 03 (Nota de crédito) y 04 (Nota de débito):
  ///   hasta 15 dígitos enteros y 2 decimales.
  /// - 02 (Factura de importación): hasta 20 dígitos enteros y 2 decimales.
  static String? validarNumeroValorPorTipo(
      String sValor, String sTipoDocumento, String sEtiqueta, String sIdioma) {
    final String sTexto = sValor.trim();
    if (sTexto.isEmpty) return null;
    final int iMaximo = (sTipoDocumento == '02') ? 20 : 15;
    if (!RegExp(r'^\d{1,$iMaximo}([.,]\d{1,2})?$').hasMatch(sTexto)) {
      return ClaseIdiomas.getTexto(sIdioma, 'validNumeroValor')
          .replaceAll('{0}', sEtiqueta);
    }
    return null;
  }

  /// La hora debe estar dentro del rango permitido (ej: 07:00 a 19:00).
  /// Ej: validarHoraRango('08:30', '07:00', '19:00', …) → null.
  static String? validarHoraRango(
      String sValor, String sMinima, String sMaxima, String sEtiqueta, String sIdioma) {
    final String sTexto = sValor.trim();
    if (sTexto.isEmpty) return null;
    final String? sError = validarHoraValida(sTexto, sEtiqueta, sIdioma);
    if (sError != null) return sError;
    final int iMinima = funcParsearHora(sMinima) ?? 0;
    final int iMaxima = funcParsearHora(sMaxima) ?? 24 * 60 - 1;
    final int? iValor = funcParsearHora(sTexto);
    if (iValor == null || iValor < iMinima || iValor > iMaxima) {
      return ClaseIdiomas.getTexto(sIdioma, 'validHoraRango')
          .replaceAll('{0}', sEtiqueta)
          .replaceAll('{1}', sMinima)
          .replaceAll('{2}', sMaxima);
    }
    return null;
  }

}
