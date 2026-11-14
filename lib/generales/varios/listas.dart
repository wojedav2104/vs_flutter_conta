import '../idiomas/idiomas.dart';

/// Listas de referencia para los campos de tipo lista de los formularios.
///
/// Cada clase ofrece las etiquetas traducidas (getListOpciones) y los
/// valores internos que se guardan en la base (listValores).
/// Las validaciones de estos valores viven en ClaseCapValidar.
abstract final class ClaseTipoDocumento {

  /// Máscara del N° de documento para los tipos que la usan.
  static const String sMascaraNumero = '999-999-9999999';

  /// Valores internos (etiquetas comTipoDoc01..comTipoDoc18).
  static const List<String> listValores = <String>[
    '01', '02', '03', '04', '05', '06', '07', '08', '09', '10',
    '11', '12', '13', '14', '15', '16', '17', '18',
  ];

  /// Tipos cuyo N° de documento usa la máscara.
  static const List<String> _listConMascara = <String>[
    '01', '02', '03', '04', '06', '09', '10',
  ];

  static bool esConMascara(String sValor) {
    return _listConMascara.contains(sValor);
  }

  static bool esFacturaCredito(String sValor) {
    return (sValor == '02');
  }

  static String getEtiqueta(String sValor, String sIdioma) {
    return ClaseIdiomas.getTexto(sIdioma, 'comTipoDoc$sValor');
  }

  static List<String> getListOpciones(String sIdioma) {
    return listValores.map((String s) => getEtiqueta(s, sIdioma)).toList();
  }

}


/// Tipos de documento de identidad (Clientes, Proveedores y Compras).
abstract final class ClaseTipoIdentificacion {

  static const String cedula           = 'CI';
  static const String cedulaExtranjera = 'CEX';
  static const String diplomatico      = 'DIP';
  static const String pasaporte        = 'PAS';
  static const String ruc              = 'RUC';
  static const String sinNombre        = 'SD';

  /// Valores internos, en el orden en que se muestran.
  static const List<String> listValores = <String>[
    ruc, cedula, pasaporte, cedulaExtranjera, sinNombre, diplomatico,
  ];

  static const Map<String, String> _mapClaves = <String, String>{
    ruc              : 'docRuc',
    cedula           : 'docCedulaIdentidad',
    pasaporte        : 'docPasaporte',
    cedulaExtranjera : 'docCedulaExtranjera',
    sinNombre        : 'docSinNombre',
    diplomatico      : 'docDiplomatico',
  };

  static String getEtiqueta(String sValor, String sIdioma) {
    return ClaseIdiomas.getTexto(sIdioma, _mapClaves[sValor] ?? sValor);
  }

  static List<String> getListOpciones(String sIdioma) {
    return listValores.map((String s) => getEtiqueta(s, sIdioma)).toList();
  }

}


/// Lista Sí/No.
abstract final class ClaseSiNo {

  static const String si = 'S';
  static const String no = 'N';

  /// Valores internos que se guardan en la base.
  static const List<String> listValores = <String>[si, no];

  static List<String> getListOpciones(String sIdioma) {
    return <String>[
      ClaseIdiomas.getTexto(sIdioma, 'si'),
      ClaseIdiomas.getTexto(sIdioma, 'no'),
    ];
  }

}


/// Ámbito del tercero: Local o Exterior (Clientes y Proveedores).
abstract final class ClaseLocalExterior {

  static const String local    = 'LOC';
  static const String exterior = 'EXT';

  /// Valores internos que se guardan en la base.
  static const List<String> listValores = <String>[local, exterior];

  static List<String> getListOpciones(String sIdioma) {
    return <String>[
      ClaseIdiomas.getTexto(sIdioma, 'valorLocal'),
      ClaseIdiomas.getTexto(sIdioma, 'valorExterior'),
    ];
  }

}


/// Documentos que afecta un timbrado (Timbrados Propios y de Proveedores).
abstract final class ClaseAfectaA {

  static const String factura      = 'FAC';
  static const String notaCredito  = 'NCR';
  static const String notaDebito   = 'NDE';
  static const String notaRemision = 'NRE';

  /// Valores internos, en el orden en que se muestran.
  static const List<String> listValores = <String>[
    factura, notaCredito, notaDebito, notaRemision,
  ];

  static const Map<String, String> _mapClaves = <String, String>{
    factura      : 'timFactura',
    notaCredito  : 'timNotaCredito',
    notaDebito   : 'timNotaDebito',
    notaRemision : 'timNotaRemision',
  };

  static String getEtiqueta(String sValor, String sIdioma) {
    return ClaseIdiomas.getTexto(sIdioma, _mapClaves[sValor] ?? sValor);
  }

  static List<String> getListOpciones(String sIdioma) {
    return listValores.map((String s) => getEtiqueta(s, sIdioma)).toList();
  }

}


/// Medio de generación del timbrado.
abstract final class ClaseMedioGeneracion {

  static const String autoImpresores         = 'AUTO';
  static const String preImpresos            = 'PREI';
  static const String comprobantesVirtuales  = 'CVIR';
  static const String documentosElectronicos = 'DELE';

  /// Valores internos, en el orden en que se muestran.
  static const List<String> listValores = <String>[
    autoImpresores, preImpresos, comprobantesVirtuales, documentosElectronicos,
  ];

  static const Map<String, String> _mapClaves = <String, String>{
    autoImpresores         : 'timAutoImpresores',
    preImpresos            : 'timPreImpresos',
    comprobantesVirtuales  : 'timComprobantesVirtuales',
    documentosElectronicos : 'timDocumentosElectronicos',
  };

  static String getEtiqueta(String sValor, String sIdioma) {
    return ClaseIdiomas.getTexto(sIdioma, _mapClaves[sValor] ?? sValor);
  }

  static List<String> getListOpciones(String sIdioma) {
    return listValores.map((String s) => getEtiqueta(s, sIdioma)).toList();
  }


}

/// Tipo de afectación del comprobante (Libro Compras).
abstract final class ClaseTipoAfectacion {

  static const String directo     = 'DIR';
  static const String indistinto  = 'IND';
  static const String exportacion = 'EXP';
  static const String importacion = 'IMP';

  /// Valores internos, en el orden en que se muestran.
  static const List<String> listValores = <String>[
    directo, indistinto, exportacion, importacion,
  ];

  static const Map<String, String> _mapClaves = <String, String>{
    directo     : 'comAfectDirecto',
    indistinto  : 'comAfectIndistinto',
    exportacion : 'comAfectExportacion',
    importacion : 'comAfectImportacion',
  };

  static String getEtiqueta(String sValor, String sIdioma) {
    return ClaseIdiomas.getTexto(sIdioma, _mapClaves[sValor] ?? sValor);
  }

  static List<String> getListOpciones(String sIdioma) {
    return listValores.map((String s) => getEtiqueta(s, sIdioma)).toList();
  }

}
