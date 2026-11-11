/// Formatea un número según la máscara de entrada y el separador de miles del formato elegido ('latino' usa punto; 'frances' usa espacio).
///
/// Ejemplo: funcFormatearNumero('1234,5', '999.999,99', '.')  -> '1.234,50'
///          funcFormatearNumero('1234,5', '999.999,99', ' ')  -> '1 234,50'
String funcFormatearNumero(String sValor, String sMascara, String sSeparadorMiles) {
  
  final int  iPosComa    = sMascara.indexOf(',');
  final int  iDecimales  = (iPosComa < 0) ? 0 : sMascara.length - iPosComa - 1;
  final List<String> listPartes = sValor.split(',');
  String sEnteros    = listPartes[0].replaceAll(RegExp(r'[^0-9]'), '');
  String sDecimales  = (listPartes.length > 1) ? listPartes[1].replaceAll(RegExp(r'[^0-9]'), '') : '';

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