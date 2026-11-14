import 'package:flutter/services.dart';

/// Límites de años admitidos en toda la aplicación.
/// Única fuente de estas constantes (validaciones y selectores de fecha).
abstract final class ClaseFechas {

  static const int iAnioMaximo = 2100;
  static const int iAnioMinimo = 2020;

}


// ── Fechas y horas ──────────────────────────────────────────────────────────

/// Formatea una fecha como dd/mm/aaaa.
String funcFormatearFecha(DateTime fFecha) {
  return '${fFecha.day.toString().padLeft(2, '0')}/'
         '${fFecha.month.toString().padLeft(2, '0')}/'
         '${fFecha.year}';
}

/// Formatea una hora como hh:mm.
String funcFormatearHora(int iHora, int iMinuto) {
  return '${iHora.toString().padLeft(2, '0')}:'
         '${iMinuto.toString().padLeft(2, '0')}';
}

/// Convierte una cadena dd/mm/aaaa a DateTime.
/// Devuelve null si el formato no es válido, si la fecha no existe
/// (31/02/2026, 30/02/2026, 29/02 fuera de año bisiesto) o si el año está
/// fuera del rango admitido por ClaseFechas.
DateTime? funcParsearFecha(String sValor) {
  final RegExpMatch? oMatch =
      RegExp(r'^(\d{1,2})/(\d{1,2})/(\d{4})$').firstMatch(sValor.trim());
  if (oMatch == null) return null;
  final int? iDia  = int.tryParse(oMatch.group(1)!);
  final int? iMes  = int.tryParse(oMatch.group(2)!);
  final int? iAnio = int.tryParse(oMatch.group(3)!);
  if (iDia == null || iMes == null || iAnio == null) return null;
  if (iAnio < ClaseFechas.iAnioMinimo || iAnio > ClaseFechas.iAnioMaximo) return null;
  final DateTime fFecha = DateTime(iAnio, iMes, iDia);
  // DateTime normaliza las fechas imposibles (31/02/2026 → 03/03/2026):
  // si los componentes cambiaron, la fecha original no existía.
  if (fFecha.day != iDia || fFecha.month != iMes || fFecha.year != iAnio) return null;
  return fFecha;
}

/// Convierte una cadena hh:mm a los minutos contados desde las 00:00.
/// Devuelve null si el formato no es válido o si la hora está fuera
/// del rango 00:00–23:59.
int? funcParsearHora(String sValor) {
  final RegExpMatch? oMatch =
      RegExp(r'^(\d{1,2}):(\d{2})$').firstMatch(sValor.trim());
  if (oMatch == null) return null;
  final int? iHora   = int.tryParse(oMatch.group(1)!);
  final int? iMinuto = int.tryParse(oMatch.group(2)!);
  if (iHora == null || iMinuto == null) return null;
  if (iHora > 23 || iMinuto > 59) return null;
  return iHora * 60 + iMinuto;
}


// ── Números ─────────────────────────────────────────────────────────────────

/// Convierte "1.234.567" a 1234567 (elimina separadores de miles).
/// Devuelve 0 si el texto no representa un número entero.
int funcParsearEnteroMiles(String sValor) {
  return funcParsearEnteroMilesEstricto(sValor) ?? 0;
}

/// Igual que funcParsearEnteroMiles pero devuelve null cuando el texto no
/// representa un número entero válido. Pensada para validaciones estrictas.
int? funcParsearEnteroMilesEstricto(String sValor) {
  final String sLimpio = sValor.trim().replaceAll('.', '').replaceAll(' ', '');
  if (sLimpio.isEmpty) return null;
  return int.tryParse(sLimpio);
}

/// Convierte 1234567 a "1.234.567" (o "1 234 567"), usando el separador de
/// miles del formato elegido ('latino' usa punto; 'frances' usa espacio).
String funcFormatearEnteroMiles(int iValor, String sSeparadorMiles) {
  final String sDato = iValor.abs().toString();
  final StringBuffer oBuffer = StringBuffer();
  if (iValor < 0) oBuffer.write('-');
  for (int i = 0; i < sDato.length; i++) {
    if (i > 0 && (sDato.length - i) % 3 == 0) oBuffer.write(sSeparadorMiles);
    oBuffer.write(sDato[i]);
  }
  return oBuffer.toString();
}

/// Formatea un número según la máscara de entrada y el separador de miles
/// del formato elegido.
///
/// · Limita la cantidad de dígitos enteros a la que admite la máscara.
/// · Si se ingresaron más decimales de los que admite la máscara, el valor
///   se redondea HACIA ARRIBA (regla Paraguay: 1000,7 se convierte en 1001).
String funcFormatearNumero(String sValor, String sMascara, String sSeparadorMiles) {

  final int iPosComa   = sMascara.indexOf(',');
  final int iDecimales = (iPosComa < 0) ? 0 : sMascara.length - iPosComa - 1;
  final int iMaxEnteros = (iPosComa < 0)
      ? sMascara.split('').where((s) => s == '9').length
      : sMascara.substring(0, iPosComa).split('').where((s) => s == '9').length;

  final List<String> listPartes = sValor.split(',');
  String sEnteros   = listPartes[0].replaceAll(RegExp(r'[^0-9]'), '');
  String sDecimales = (listPartes.length > 1)
      ? listPartes[1].replaceAll(RegExp(r'[^0-9]'), '')
      : '';

  if (sEnteros.isEmpty && sDecimales.isEmpty) return '';
  if (sEnteros.length > iMaxEnteros) sEnteros = sEnteros.substring(0, iMaxEnteros);

  // Valor escalado a iDecimales decimales, redondeando hacia arriba cuando
  // el usuario ingresó decimales de más.
  int iValor;
  if (sDecimales.length <= iDecimales) {
    iValor = int.parse(
        (sEnteros.isEmpty ? '0' : sEnteros) + sDecimales.padRight(iDecimales, '0'));
  } else {
    iValor = int.parse(
        (sEnteros.isEmpty ? '0' : sEnteros) + sDecimales.substring(0, iDecimales));
    if (sDecimales.substring(iDecimales).contains(RegExp(r'[1-9]'))) iValor += 1;
  }

  final String sEscalar      = iValor.toString().padLeft(iDecimales + 1, '0');
  final String sParteEntera  = sEscalar.substring(0, sEscalar.length - iDecimales);
  final String sParteDecimal = sEscalar.substring(sEscalar.length - iDecimales);

  final StringBuffer oBuffer = StringBuffer();
  for (int i = 0; i < sParteEntera.length; i++) {
    if (i > 0 && (sParteEntera.length - i) % 3 == 0) oBuffer.write(sSeparadorMiles);
    oBuffer.write(sParteEntera[i]);
  }
  String sResultado = oBuffer.toString();
  if (iDecimales > 0) sResultado = '$sResultado,$sParteDecimal';
  return sResultado;

}


// ── Formateadores de entrada ────────────────────────────────────────────────

/// Formateador para números enteros con separador de miles.
/// Ejemplo: el usuario escribe 1234567 y se visualiza 1.234.567
class ClaseFormatoMiles extends TextInputFormatter {

  ClaseFormatoMiles({
    this.iMaxDigitos     = 12,
    this.sSeparadorMiles = '.',
  });

  final int    iMaxDigitos;
  final String sSeparadorMiles;

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oValorAnterior, TextEditingValue oValorNuevo) {
    String sDigitos = oValorNuevo.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (sDigitos.length > iMaxDigitos) sDigitos = sDigitos.substring(0, iMaxDigitos);
    if (sDigitos.isEmpty) {
      return const TextEditingValue(text: '', selection: TextSelection.collapsed(offset: 0));
    }
    sDigitos = sDigitos.replaceFirst(RegExp(r'^0+(?=\d)'), '');
    final StringBuffer oBuffer = StringBuffer();
    for (int i = 0; i < sDigitos.length; i++) {
      if (i > 0 && (sDigitos.length - i) % 3 == 0) oBuffer.write(sSeparadorMiles);
      oBuffer.write(sDigitos[i]);
    }
    final String sResultado = oBuffer.toString();
    return TextEditingValue(
      text      : sResultado,
      selection : TextSelection.collapsed(offset: sResultado.length),
    );
  }

}

/// Formateador de entrada para máscaras fijas como 999-999-9999999.
/// Los caracteres '9' representan un dígito (0-9); los demás son fijos.
class ClaseFormatoMascara extends TextInputFormatter {

  ClaseFormatoMascara({
    required this.sMascara,
  });

  final String sMascara;

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oValorAnterior, TextEditingValue oValorNuevo) {
    String sDigitos = oValorNuevo.text.replaceAll(RegExp(r'[^0-9]'), '');
    final int iMaxDigitos = sMascara.split('').where((s) => s == '9').length;
    if (sDigitos.length > iMaxDigitos) {
      sDigitos = sDigitos.substring(0, iMaxDigitos);
    }
    String sResultado = '';
    int    iDigito    = 0;
    for (int i = 0; i < sMascara.length && iDigito < sDigitos.length; i++) {
      if (sMascara[i] == '9') {
        sResultado += sDigitos[iDigito];
        iDigito++;
      } else {
        sResultado += sMascara[i];
      }
    }
    return TextEditingValue(
      text      : sResultado,
      selection : TextSelection.collapsed(offset: sResultado.length),
    );
  }

}


// ── Ordenamiento de grillas ─────────────────────────────────────────────────

/// Interpreta un valor de grilla como número para ordenarlo.
/// Ej: "1.234.567" → 1234567 ; "12,5" → 12.5
num? funcNumeroOrden(String sValor) {
  final String sLimpio = sValor.trim()
      .replaceAll(' ', '')
      .replaceAll('.', '')
      .replaceAll(',', '.');
  return num.tryParse(sLimpio);
}

/// Interpreta un valor de grilla como fecha para ordenarlo.
DateTime? funcFechaOrden(String sValor) {
  return funcParsearFecha(sValor) ?? DateTime.tryParse(sValor);
}

// Para ordenar por hora se usa directamente funcParsearHora (devuelve los
// minutos desde las 00:00, comparables como enteros).


// ── Utilidades ──────────────────────────────────────────────────────────────

/// Ancho mínimo de un campo de lista: caracteres de la opción más larga.
int funcAnchoOpcion(List<String> listOpciones) {
  int iAncho = 0;
  for (final String sOpcion in listOpciones) {
    if (sOpcion.length > iAncho) iAncho = sOpcion.length;
  }
  return iAncho;
}

/// Completa con ceros a la izquierda hasta iLong caracteres.
/// Ej: funcCompletarCeros('123', 6) → '000123'. Un valor vacío se mantiene.
String funcCompletarCeros(String sValor, int iLong) {
  final String sDato = sValor.trim();
  if (sDato.isEmpty) return '';
  return sDato.padLeft(iLong, '0');
}

/// Aplica una máscara de entrada (ej: '999-999-9999999') sobre una cadena de
/// dígitos: cada '9' se reemplaza por un dígito disponible y los demás
/// caracteres se insertan tal cual. Los dígitos sobrantes se ignoran.
String funcAplicarMascara(String sDigitos, String sMascara) {
  final StringBuffer oSalida = StringBuffer();
  int i = 0;
  for (int j = 0; j < sMascara.length; j++) {
    if (sMascara[j] == '9') {
      if (i >= sDigitos.length) break;
      oSalida.write(sDigitos[i++]);
    } else {
      oSalida.write(sMascara[j]);
    }
  }
  return oSalida.toString();
}

/// Convierte un importe tecleado a double ('1234.56' o '1234,56').
/// Devuelve null si el texto no es un importe válido.
double? funcParsearNumero(String sValor) {
  final String sDato = sValor.trim().replaceAll(' ', '');
  if (sDato.isEmpty) return null;
  final String sNormalizado = sDato.replaceAll(',', '.');
  if (!RegExp(r'^\d+(\.\d+)?$').hasMatch(sNormalizado)) return null;
  return double.tryParse(sNormalizado);
}

/// Formatea un importe para mostrarlo:
/// '1.234.567,00' en formato latino o '1 234 567,00' en formato francés.
/// Los decimales solo se muestran si son distintos de cero.
String funcFormatearNumero(double dValor, String sFormato) {
  final bool   bLatino           = (sFormato != 'frances');
  final String sSeparadorMiles   = bLatino ? '.' : ' ';
  final String sSeparadorDecimal = bLatino ? ',' : '.';
  final String sBase    = dValor.abs().toStringAsFixed(2);
  final List<String> listPartes = sBase.split('.');
  final String sEnteros = listPartes[0];
  final StringBuffer oSalida = StringBuffer();
  for (int i = 0; i < sEnteros.length; i++) {
    if (i > 0 && (sEnteros.length - i) % 3 == 0) oSalida.write(sSeparadorMiles);
    oSalida.write(sEnteros[i]);
  }
  if (listPartes[1] != '00') {
    oSalida..write(sSeparadorDecimal)..write(listPartes[1]);
  }
  return '${dValor < 0 ? '-' : ''}$oSalida';
}

