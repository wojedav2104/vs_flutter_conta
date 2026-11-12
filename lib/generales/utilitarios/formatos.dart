import 'package:flutter/services.dart';

/// Formatea un número según la máscara de entrada y el separador de miles
/// del formato elegido ('latino' usa punto; 'frances' usa espacio).
String funcFormatearNumero(String sValor, String sMascara, String sSeparadorMiles) {

  final int  iPosComa   = sMascara.indexOf(',');
  final int  iDecimales = (iPosComa < 0) ? 0 : sMascara.length - iPosComa - 1;
  final List<String> listPartes = sValor.split(',');
  String sEnteros   = listPartes[0].replaceAll(RegExp(r'[^0-9]'), '');
  String sDecimales = (listPartes.length > 1) ? listPartes[1].replaceAll(RegExp(r'[^0-9]'), '') : '';

  if (sEnteros.isEmpty && sDecimales.isEmpty) return '';

  sDecimales = sDecimales.padRight(iDecimales, '0');
  if (sDecimales.length > iDecimales) sDecimales = sDecimales.substring(0, iDecimales);

  final StringBuffer oBuffer = StringBuffer();
  if (sEnteros.isEmpty) {
    oBuffer.write('0');
  } else {
    for (int i = 0; i < sEnteros.length; i++) {
      if (i > 0 && (sEnteros.length - i) % 3 == 0) oBuffer.write(sSeparadorMiles);
      oBuffer.write(sEnteros[i]);
    }
  }
  String sResultado = oBuffer.toString();
  if (iDecimales > 0) sResultado = '$sResultado,$sDecimales';
  return sResultado;

}

/// Convierte una cadena dd/mm/aaaa a DateTime. Devuelve null si no es válida.
DateTime? funcParsearFecha(String sValor) {
  final List<String> listPartes = sValor.trim().split('/');
  if (listPartes.length != 3) return null;
  final int? iDia  = int.tryParse(listPartes[0]);
  final int? iMes  = int.tryParse(listPartes[1]);
  final int? iAnio = int.tryParse(listPartes[2]);
  if (iDia == null || iMes == null || iAnio == null) return null;
  return DateTime(iAnio, iMes, iDia);
}

/// Convierte "1.234.567" a 1234567 (elimina separadores de miles).
int funcParsearEnteroMiles(String sValor) {
  return int.tryParse(sValor.replaceAll('.', '').replaceAll(' ', '')) ?? 0;
}

/// Convierte 1234567 a "1.234.567" (agrega separadores de miles con punto).
String funcFormatearEnteroMiles(int iValor) {
  final String sDato = iValor.abs().toString();
  final StringBuffer oBuffer = StringBuffer();
  if (iValor < 0) oBuffer.write('-');
  for (int i = 0; i < sDato.length; i++) {
    if (i > 0 && (sDato.length - i) % 3 == 0) oBuffer.write('.');
    oBuffer.write(sDato[i]);
  }
  return oBuffer.toString();
}

/// Formateador para números enteros con separador de miles (punto).
/// Ejemplo: el usuario escribe 1234567 y se visualiza 1.234.567
class ClaseFormatoMiles extends TextInputFormatter {

  ClaseFormatoMiles({
    this.iMaxDigitos = 12,
  });

  final int iMaxDigitos;

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
      if (i > 0 && (sDigitos.length - i) % 3 == 0) oBuffer.write('.');
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
