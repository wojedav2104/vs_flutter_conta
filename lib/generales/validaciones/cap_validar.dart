import '../idiomas/idiomas.dart';
import '../utilitarios/formatos.dart';
import '../modelos/documentos.dart';


/// Validaciones de los distintos tipos de datos, con mensajes en el idioma
/// del usuario. Todas devuelven null si el valor es válido, o un mensaje de
/// error traducido. Las cadenas de error admiten {0}, {1} (cuando el texto
/// traducido se construye por partes).
///
/// Los textos de error (valid*) se definen en idiomas_validaciones y se usan
/// con ClaseIdiomas.getTexto + replaceAll.
class ClaseCapValidar {

  // ── Texto ─────────────────────────────────────────────────────────────

  /// El valor no puede estar vacío.
  static String? validarObligatorio(String sValor, String sEtiqueta, String sIdioma) {
    if (sValor.trim().isEmpty) {
      return ClaseIdiomas.getTexto('validObligatorio', sIdioma)
          .replaceAll('{0}', sEtiqueta);
    }
    return null;
  }

  /// La longitud del valor no puede superar iMaximo caracteres.
  static String? validarLongitudMaxima(
      String sValor, String sEtiqueta, int iMaximo, String sIdioma) {
    if (sValor.length > iMaximo) {
      return ClaseIdiomas.getTexto('validLongMaxima', sIdioma)
          .replaceAll('{0}', sEtiqueta)
          .replaceAll('{1}', '$iMaximo');
    }
    return null;
  }

  /// La longitud del valor debe ser de al menos iMinimo caracteres.
  static String? validarLongitudMinima(
      String sValor, String sEtiqueta, int iMinimo, String sIdioma) {
    if (sValor.trim().length < iMinimo) {
      return ClaseIdiomas.getTexto('validLongMinima', sIdioma)
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
      return ClaseIdiomas.getTexto('validSoloEntero', sIdioma)
          .replaceAll('{0}', sEtiqueta);
    }
    if (iNumero < iMinimo || iNumero > iMaximo) {
      return ClaseIdiomas.getTexto('validRangoEntero', sIdioma)
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
      return ClaseIdiomas.getTexto('validSoloEntero', sIdioma)
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
      return ClaseIdiomas.getTexto('validDigitosExactos', sIdioma)
          .replaceAll('{0}', sEtiqueta)
          .replaceAll('{1}', '$iCantidad');
    }
    return null;
  }

  /// Moneda: máximo 12 dígitos enteros y 2 decimales. Con los puntos de
  /// separación de miles, el valor mostrado no supera los 15 caracteres
  /// (la máscara '999.999.999.999').
  static String? validarNumeroValor(
      String sValor, String sEtiqueta, String sIdioma) {
    final String sTexto = sValor.trim();
    if (sTexto.isEmpty) return null;
    if (!RegExp(r'^\d{1,12}([.,]\d{1,2})?$').hasMatch(sTexto)) {
      return ClaseIdiomas.getTexto('validNumeroValor', sIdioma)
          .replaceAll('{0}', sEtiqueta)
          .replaceAll('{1}', '12');
    }
    return null;
  }

  /// Valor según el Tipo de documento: el máximo es el mismo para todos los
  /// tipos (12 dígitos enteros y 2 decimales). Se conserva el parámetro del
  /// tipo por si en el futuro algún tipo admite otro ancho.
  static String? validarNumeroValorPorTipo(
      String sValor, String sTipoDocumento, String sEtiqueta, String sIdioma) {
    return validarNumeroValor(sValor, sEtiqueta, sIdioma);
  }

  // ── Documentos de compra/venta ────────────────────────────────────────

  /// El valor debe tener la forma de un número de documento (999-999-9999999).
  static String? validarNumeroDocumento(
      String sValor, String sEtiqueta, String sIdioma) {
    final String sDigitos = sValor.replaceAll(RegExp(r'[^0-9]'), '');
    if (sDigitos.length != 13) {
      return ClaseIdiomas.getTexto('validNumeroDocumento', sIdioma)
          .replaceAll('{0}', sEtiqueta);
    }
    return null;
  }

  /// Formato del N° de documento según el Tipo de documento.
  ///
  /// - Los comprobantes con timbrado (01, 02, 03, 04, 06, 09, 10) admiten
  ///   solo dígitos y deben tener 13 (con o sin los guiones).
  /// - Los tipos 05, 07, 08, 11 admiten de 5 a 13 dígitos.
  /// - Los tipos 12 a 18 (boletas, controles internos, entradas) requieren
  ///   exactamente 7 dígitos.
  static String? validarNumeroDocumentoPorTipo(
      String sValor, String sTipoDocumento, String sEtiqueta, String sIdioma) {
    final String sTexto = sValor.trim();
    if (sTexto.isEmpty) return null;
    if (ClaseTipoDocumento.esConMascara(sTipoDocumento)) {
      return validarNumeroDocumento(sTexto, sEtiqueta, sIdioma);
    }
    // Tipo 05 (Comprobante de Tributo Único) y similares: entre 5 y 13 dígitos.
    if (sTipoDocumento == '05' || sTipoDocumento == '07' ||
        sTipoDocumento == '08' || sTipoDocumento == '11') {
      final String sDigitos = sTexto.replaceAll(RegExp(r'[^0-9]'), '');
      if (!RegExp(r'^\d+$').hasMatch(sDigitos)
          || sDigitos.length < 5 || sDigitos.length > 13) {
        return ClaseIdiomas.getTexto('validNumeroDocumentoRango', sIdioma)
            .replaceAll('{0}', sEtiqueta);
      }
      return null;
    }
    // Tipos 12 a 18 (boletas, controles internos, entradas): 7 dígitos.
    final int? iCodigo = int.tryParse(sTipoDocumento);
    if (iCodigo != null && iCodigo >= 12 && iCodigo <= 18) {
      return validarDigitosExactos(sTexto, sEtiqueta, 7, sIdioma);
    }
    return null;
  }

  // ── Identificación ────────────────────────────────────────────────────

  /// Validación general de la identificación según el tipo:
  ///   · Cédula de Identidad: 5 a 8 dígitos (se permiten puntos).
  ///   · R.U.C.: 6 a 8 dígitos + dígito verificador.
  ///   · Pasaporte: letras mayúsculas, dígitos y guiones (hasta 20).
  ///   · Cédula Extranjera: 5 a 15 caracteres (letras, dígitos, puntos o guiones).
  ///   · Diplomático: 3 a 20 caracteres (letras, dígitos o guiones).
  ///   · Sin Nombre: siempre '0'.
  static String? validarIdentificacion(
      String sValor, String sTipoIdentificacion, String sEtiqueta, String sIdioma) {
    final String sTexto = sValor.trim();
    if (sTexto.isEmpty) return null;

    // Cédula de identidad: de 5 a 8 dígitos (se permiten puntos).
    if (sTipoIdentificacion == ClaseTipoIdentificacion.cedula) {
      final String sDigitos = sTexto.replaceAll('.', '');
      if (!RegExp(r'^\d{5,8}$').hasMatch(sDigitos)) {
        return ClaseIdiomas.getTexto('validIdentCedula', sIdioma)
            .replaceAll('{0}', sEtiqueta);
      }
      return null;
    }

    // RUC: con dígito verificador.
    if (sTipoIdentificacion == ClaseTipoIdentificacion.ruc) {
      return validarRuc(sTexto, sEtiqueta, sIdioma);
    }

    // Pasaporte: letras mayúsculas, dígitos y guiones, hasta 20 caracteres
    // (el campo se pone en mayúsculas al escribir).
    if (sTipoIdentificacion == ClaseTipoIdentificacion.pasaporte) {
      if (!RegExp(r'^[A-Z0-9-]{1,20}$').hasMatch(sTexto)) {
        return ClaseIdiomas.getTexto('validIdentPasaporte', sIdioma)
            .replaceAll('{0}', sEtiqueta);
      }
      return null;
    }

    // Cédula extranjera: de 5 a 15 caracteres (letras, dígitos, puntos o guiones).
    if (sTipoIdentificacion == ClaseTipoIdentificacion.cedulaExtranjera) {
      if (!RegExp(r'^[A-Za-z0-9.\-]{5,15}$').hasMatch(sTexto)) {
        return ClaseIdiomas.getTexto('validIdentOtros', sIdioma)
            .replaceAll('{0}', sEtiqueta);
      }
      return null;
    }

    // Diplomático: de 3 a 20 caracteres (letras, dígitos o guiones).
    if (sTipoIdentificacion == ClaseTipoIdentificacion.diplomatico) {
      if (!RegExp(r'^[A-Za-z0-9\-]{3,20}$').hasMatch(sTexto)) {
        return ClaseIdiomas.getTexto('validIdentDiplomatico', sIdioma)
            .replaceAll('{0}', sEtiqueta);
      }
      return null;
    }

    // Sin Nombre: siempre '0'.
    if (sTipoIdentificacion == ClaseTipoIdentificacion.sinNombre) {
      if (sTexto != '0') {
        return ClaseIdiomas.getTexto('validIdentSinNombre', sIdioma)
            .replaceAll('{0}', sEtiqueta);
      }
      return null;
    }

    // Otros tipos: de 5 a 15 caracteres.
    if (!RegExp(r'^[A-Za-z0-9.\-]{5,15}$').hasMatch(sTexto)) {
      return ClaseIdiomas.getTexto('validIdentOtros', sIdioma)
          .replaceAll('{0}', sEtiqueta);
    }
    return null;
  }

  /// RUC con dígito verificador (módulo 11).
  static String? validarRuc(String sValor, String sEtiqueta, String sIdioma) {
    final String sTexto = sValor.trim();
    if (sTexto.isEmpty) return null;
    if (!RegExp(r'^\d{6,8}-\d$').hasMatch(sTexto)) {
      return ClaseIdiomas.getTexto('validIdentRuc', sIdioma)
          .replaceAll('{0}', sEtiqueta);
    }
    final int iDv = funcDigitoVerificador(sTexto.split('-')[0]);
    if (iDv != int.parse(sTexto.split('-')[1])) {
      return ClaseIdiomas.getTexto('validIdentRucDv', sIdioma)
          .replaceAll('{0}', sEtiqueta);
    }
    return null;
  }

  /// Dígito verificador del R.U.C. (algoritmo Módulo 11 de la DNIT/SET).
  ///
  /// Los dígitos de la base se multiplican de derecha a izquierda por los
  /// factores 2, 3, 4, 5, 6, 7, 8, 9, 10 y 11 (el factor crece con la
  /// posición y NO se recicla). Se calcula el resto de la suma dividida por
  /// 11: si el resto es 0 o 1 el dígito verificador es 0; si no, es
  /// 11 menos el resto (equivalente a: si el resultado es 10 o 11, DV = 0).
  ///
  /// Recibe la base del RUC (por ejemplo '80101319') o el RUC completo
  /// (por ejemplo '80101319-4') y devuelve el dígito verificador calculado.
  /// Ejemplos verificados: 80101319 → 4, 1069218 → 5, 80031238 → 4,
  /// 80014477 → 5.
  static int funcDigitoVerificador(String sRuc) {
    final String sBase = sRuc.split('-').first.replaceAll(RegExp(r'[^0-9]'), '');
    int iSuma   = 0;
    int iFactor = 2;
    for (int i = sBase.length - 1; i >= 0; i--) {
      iSuma += int.parse(sBase[i]) * iFactor;
      iFactor++;
    }
    int iDv = 11 - (iSuma % 11);
    if (iDv >= 10) iDv = 0;
    return iDv;
  }

  /// Completa un RUC escrito solo con la base, agregando el guion y el
  /// dígito verificador ('1069218' → '1069218-5'). También completa
  /// '1069218-'. Devuelve null si no hay nada que completar (valor vacío,
  /// ya con dígito verificador o con formato no reconocido).
  /// Es la ayuda al usuario al salir del campo; la validación al grabar
  /// (validarRuc) sigue exigiendo el formato completo.
  static String? funcCompletarRuc(String sValor) {
    final String sTexto = sValor.trim();
    if (sTexto.isEmpty) return null;
    if (RegExp(r'^\d{6,8}-\d$').hasMatch(sTexto)) return null;
    if (!RegExp(r'^\d{6,8}-?$').hasMatch(sTexto)) return null;
    final String sBase = sTexto.replaceAll('-', '');
    return '$sBase-${funcDigitoVerificador(sBase)}';
  }

  // ── Fechas ────────────────────────────────────────────────────────────

  /// La fecha debe ser válida (dd/mm/aaaa y existir en el calendario).
  static String? validarFechaValida(String sValor, String sEtiqueta, String sIdioma) {
    final String sTexto = sValor.trim();
    if (sTexto.isEmpty) return null;
    if (funcParsearFecha(sTexto) == null) {
      return ClaseIdiomas.getTexto('validFechaInvalida', sIdioma)
          .replaceAll('{0}', sEtiqueta);
    }
    return null;
  }

  /// La fecha debe ser válida y estar entre fMinima y fMaxima (ambas
  /// incluidas). Vacío se acepta (la obligatoriedad la define el campo).
  /// Ej: fechas de movimientos → hasta el 31/12 del año actual;
  /// vigencia de los timbrados → hasta el 31/12 del año que viene.
  static String? validarFechaEnRango(
      String sValor, String sEtiqueta, DateTime fMinima, DateTime fMaxima,
      String sIdioma) {
    final String sTexto = sValor.trim();
    if (sTexto.isEmpty) return null;
    final DateTime? fValor = funcParsearFecha(sTexto);
    if (fValor == null) {
      return ClaseIdiomas.getTexto('validFechaInvalida', sIdioma)
          .replaceAll('{0}', sEtiqueta);
    }
    if (fValor.isBefore(fMinima) || fValor.isAfter(fMaxima)) {
      return ClaseIdiomas.getTexto('validFechaRango', sIdioma)
          .replaceAll('{0}', sEtiqueta)
          .replaceAll('{1}', funcFormatearFecha(fMinima))
          .replaceAll('{2}', funcFormatearFecha(fMaxima));
    }
    return null;
  }

  /// La fecha no puede ser anterior a la mínima (ej: no antes del 01/01/2020).
  /// Una fecha no vacía con formato inválido también es error.
  static String? validarFechaNoAnterior(
      String sValor, String sEtiqueta, DateTime fMinima, String sIdioma) {
    final String sTexto = sValor.trim();
    if (sTexto.isEmpty) return null;
    final DateTime? fValor = funcParsearFecha(sTexto);
    if (fValor == null) {
      return ClaseIdiomas.getTexto('validFechaInvalida', sIdioma)
          .replaceAll('{0}', sEtiqueta);
    }
    if (fValor.isBefore(fMinima)) {
      return ClaseIdiomas.getTexto('validFechaAnterior', sIdioma)
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
      return ClaseIdiomas.getTexto('validFechaFinPosterior', sIdioma);
    }
    return null;
  }

  /// La fecha debe estar entre el 1 de enero del ejercicio contable y
  /// a) la fecha de hoy si el ejercicio es el año actual, o b) el 31 de
  /// diciembre del ejercicio si es anterior al año actual.
  static String? validarFechaEnEjercicio(
      String sValor, String sEjercicio, String sEtiqueta, String sIdioma) {
    final int?      iEjercicio = int.tryParse(sEjercicio.trim());
    final DateTime? fFecha     = funcParsearFecha(sValor);
    if (iEjercicio == null || fFecha == null) return null;
    final DateTime fDesde = DateTime(iEjercicio, 1, 1);
    final DateTime fHasta = (iEjercicio == DateTime.now().year)
        ? DateTime.now()
        : DateTime(iEjercicio, 12, 31);
    if (fFecha.isBefore(fDesde) || fFecha.isAfter(fHasta)) {
      return ClaseIdiomas.getTexto('validFechaRango', sIdioma)
          .replaceAll('{0}', sEtiqueta)
          .replaceAll('{1}', funcFormatearFecha(fDesde))
          .replaceAll('{2}', funcFormatearFecha(fHasta));
    }
    return null;
  }

  /// El ejercicio debe ser un año dentro del rango admitido por la
  /// aplicación (ClaseFechas es la única fuente de esos límites).
  static String? validarEjercicio(String sValor, String sEtiqueta, String sIdioma) {
    final String sTexto = sValor.trim();
    if (sTexto.isEmpty) return null;
    final int? iAno = int.tryParse(sTexto);
    if (iAno == null
        || iAno < ClaseFechas.iAnoMinimo
        || iAno > ClaseFechas.getAnoMaximo()) {
      return ClaseIdiomas.getTexto('validEjercicioRango', sIdioma)
          .replaceAll('{0}', sEtiqueta)
          .replaceAll('{1}', '${ClaseFechas.iAnoMinimo}')
          .replaceAll('{2}', '${ClaseFechas.getAnoMaximo()}');
    }
    return null;
  }

  /// El día debe ser válido para el mes y año indicados (1..31, 1..30, etc.).
  /// Ej: validarRangoDiasMes('31', '04', '2025', …) → error (abril tiene 30).
  static String? validarRangoDiasMes(
      String sValor, String sMes, String sAnio, String sEtiqueta, String sIdioma) {
    final int? iDia  = int.tryParse(sValor.trim());
    final int? iMes  = int.tryParse(sMes.trim());
    final int? iAnio = int.tryParse(sAnio.trim());
    if (iDia == null || iMes == null || iAnio == null) {
      return ClaseIdiomas.getTexto('validFechaInvalida', sIdioma)
          .replaceAll('{0}', sEtiqueta);
    }
    final DateTime fInicioMes = DateTime(iAnio, iMes, 1);
    final DateTime fFinMes    = DateTime(iAnio, iMes + 1, 0);
    if (iDia < fInicioMes.day || iDia > fFinMes.day) {
      return ClaseIdiomas.getTexto('validDiaRango', sIdioma)
          .replaceAll('{0}', sEtiqueta)
          .replaceAll('{1}', '${fInicioMes.day}')
          .replaceAll('{2}', '${fFinMes.day}');
    }
    return null;
  }

  // ── Horas ─────────────────────────────────────────────────────────────

  /// La hora debe tener el formato hh:mm (24 horas) y ser válida.
  static String? validarHoraValida(String sValor, String sEtiqueta, String sIdioma) {
    final String sTexto = sValor.trim();
    if (sTexto.isEmpty) return null;
    if (!RegExp(r'^([01]\d|2[0-3]):[0-5]\d$').hasMatch(sTexto)) {
      return ClaseIdiomas.getTexto('validHoraInvalida', sIdioma)
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
      return ClaseIdiomas.getTexto('validHoraRango', sIdioma)
          .replaceAll('{0}', sEtiqueta)
          .replaceAll('{1}', sMinima)
          .replaceAll('{2}', sMaxima);
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
      return ClaseIdiomas.getTexto('validFormatoCuenta', sIdioma);
    }
    return null;
  }

  /// true si sValor tiene el formato de cuenta 99.99.99.99.99: el primer
  /// grupo tiene 1 o 2 dígitos y los demás exactamente 2 dígitos,
  /// separados por puntos, hasta 5 grupos.
  /// Ejemplos válidos: 1, 1.01, 2.03.01, 3.05.02.09, 10.02.05.03.04.
  static bool esFormatoCuenta(String sValor) =>
      RegExp(r'^\d{1,2}(\.\d{2}){0,4}$').hasMatch(sValor.trim());

  /// Cantidad de grupos de la cuenta (1.01.04 → 3).
  static int contarGruposCuenta(String sNumeroCuenta) =>
      sNumeroCuenta.trim().isEmpty ? 0 : sNumeroCuenta.trim().split('.').length;

  /// Cantidad de dígitos de la cuenta (ignora los puntos) (1.01.04 → 4).
  static int contarDigitosCuenta(String sNumeroCuenta) =>
      sNumeroCuenta.trim().replaceAll('.', '').length;

  /// Cuenta superior determinística: el grupo anterior.
  /// 1.03.02 → '1.03' ; 10.02 → '10' ; raíz (un solo grupo) → ''.
  static String funcCuentaSuperior(String sNumeroCuenta) {
    final String sCuenta = sNumeroCuenta.trim();
    if (contarGruposCuenta(sCuenta) <= 1) return '';
    return sCuenta.substring(0, sCuenta.lastIndexOf('.'));
  }

  /// La cuenta superior es obligatoria en las cuentas con más de un grupo
  /// (las raíces —"1", "10"— no tienen superior).
  static String? validarCuentaSuperior(
      String sNumeroCuenta, String sCuentaSuperior, String sIdioma) {
    if (contarGruposCuenta(sNumeroCuenta) > 1 && sCuentaSuperior.trim().isEmpty) {
      return ClaseIdiomas.getTexto('validCuentaSuperior', sIdioma);
    }
    return null;
  }

  /// El nivel de la cuenta debe estar entre 1 y 5.
  static String? validarNivelCuenta(String sValor, String sEtiqueta, String sIdioma) {
    final String? sError = validarSoloEntero(sValor, sEtiqueta, sIdioma);
    if (sError != null) return sError;
    final int iNivel = int.tryParse(sValor.trim()) ?? 0;
    if (iNivel < 1 || iNivel > 5) {
      return ClaseIdiomas.getTexto('validNivelCuenta', sIdioma)
          .replaceAll('{0}', sEtiqueta);
    }
    return null;
  }

  /// La subcuenta debe tener exactamente 5 dígitos, entre 00001 y 99999.
  /// El valor tecleado con menos dígitos se completa con ceros a la
  /// izquierda antes de validar (regla: 1 → 00001, 123 → 00123).
  static String? validarNumeroSubcuenta(
      String sValor, String sEtiqueta, String sIdioma) {
    final String sTexto = sValor.trim();
    if (sTexto.isEmpty) return null;
    if (!RegExp(r'^\d{5}$').hasMatch(sTexto) || int.parse(sTexto) < 1) {
      return ClaseIdiomas.getTexto('validSubcuentaRango', sIdioma)
          .replaceAll('{0}', sEtiqueta);
    }
    return null;
  }

  // ── Importes y detalle ────────────────────────────────────────────────

  /// El importe debe ser mayor o igual que cero (se acepta vacío).
  static String? validarImporteNoNegativo(
      String sValor, String sEtiqueta, String sIdioma) {
    final double? dValor = funcParsearNumero(sValor);
    if (dValor == null || dValor >= 0) return null;
    return ClaseIdiomas.getTexto('validNoNegativo', sIdioma)
        .replaceAll('{0}', sEtiqueta);
  }

  /// La suma del Debe debe ser igual a la suma del Haber.
  static String? validarSumaDebeHaber(double dDebe, double dHaber, String sIdioma) {
    if ((dDebe - dHaber).abs() > 0.005) {
      return ClaseIdiomas.getTexto('validSumaDebeHaber', sIdioma);
    }
    return null;
  }

  // ── Listas ────────────────────────────────────────────────────────────

  /// El valor debe estar entre las opciones permitidas (lista de códigos).
  static String? validarOpciones(
      String sValor, String sEtiqueta, List<String> listValoresPermitidos,
      String sIdioma) {
    if (sValor.trim().isEmpty) return null;
    if (!listValoresPermitidos.contains(sValor)) {
      return ClaseIdiomas.getTexto('validValorLista', sIdioma)
          .replaceAll('{0}', sEtiqueta);
    }
    return null;
  }

  /// Al menos una opción seleccionada.
  static String? validarAlMenosUnoSeleccionado(
      String sValor, String sEtiqueta, String sIdioma) {
    if (sValor.trim().isEmpty) {
      return ClaseIdiomas.getTexto('validAlMenosUno', sIdioma)
          .replaceAll('{0}', sEtiqueta);
    }
    return null;
  }

  // ── Credenciales y correo ─────────────────────────────────────────────

  /// Credenciales iniciales. Más adelante vendrán del ABM de Usuarios y de la BD.
  static const String sContrasenaInicial = '1234';
  static const String sNombreInicial     = 'admin';

  /// Valida las credenciales del login.
  static bool validarCredenciales(String sNombre, String sContrasena) {
    return sNombre == sNombreInicial && sContrasena == sContrasenaInicial;
  }

  /// Formato básico del e-mail.
  static bool esCorreoValido(String sCorreo) =>
      RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(sCorreo);

}