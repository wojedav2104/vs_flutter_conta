import '../idiomas/idiomas.dart';

/// Tipos de documento de compra/venta (Libro Compras y Libro Ventas).
///
/// Los códigos '01'..'18' son los valores que se guardan en la base; las
/// etiquetas se traducen con las claves comTipoDocNN de ClaseIdiomas.
/// Las validaciones de estos documentos viven en ClaseCapValidar.
abstract final class ClaseTipoDocumento {

  /// Máscara del N° de documento para los tipos que la usan.
  static const String sMascaraNumero = '999-999-9999999';

  /// Códigos en orden (comTipoDoc01..comTipoDoc18).
  static const List<String> listCodigos = <String>[
    '01', '02', '03', '04', '05', '06', '07', '08', '09', '10',
    '11', '12', '13', '14', '15', '16', '17', '18',
  ];

  /// Tipos cuyo N° de documento usa la máscara.
  static const List<String> _listConMascara = <String>[
    '01', '02', '03', '04', '06', '09', '10',
  ];

  static bool esConMascara(String sCodigo) {
    return _listConMascara.contains(sCodigo);
  }

  static bool esFacturaCredito(String sCodigo) {
    return (sCodigo == '02');
  }

  static String getEtiqueta(String sCodigo, String sIdioma) {
    return ClaseIdiomas.getTexto(sIdioma, 'comTipoDoc$sCodigo');
  }

  static List<String> getListOpciones(String sIdioma) {
    return listCodigos.map((String s) => getEtiqueta(s, sIdioma)).toList();
  }

}


/// Tipos de documento de identidad (Clientes, Proveedores y Compras).
///
/// Los códigos son los valores que se guardan en la base; las etiquetas se
/// traducen con las claves doc* de ClaseIdiomas.
abstract final class ClaseTipoIdentificacion {

  /// Códigos en el orden en que se muestran.
  static const List<String> listValores = <String>[
    'RUC', 'CI', 'PAS', 'CEX', 'SD', 'DIP',
  ];

  static const Map<String, String> _mapClaves = <String, String>{
    'RUC' : 'docRuc',
    'CI'  : 'docCedulaIdentidad',
    'PAS' : 'docPasaporte',
    'CEX' : 'docCedulaExtranjera',
    'SD'  : 'docSinNombre',
    'DIP' : 'docDiplomatico',
  };

  static String getEtiqueta(String sValor, String sIdioma) {
    return ClaseIdiomas.getTexto(sIdioma, _mapClaves[sValor] ?? sValor);
  }

  static List<String> getListOpciones(String sIdioma) {
    return listValores.map((String s) => getEtiqueta(s, sIdioma)).toList();
  }

}
