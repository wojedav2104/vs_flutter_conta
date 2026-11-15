import '../idiomas/idiomas.dart';


/// Listas de referencia para los campos de tipo lista de los formularios.
///
/// Cada clase ofrece las etiquetas traducidas (getListOpciones) y los valores internos que se guardan en la base (listValores).
/// Las validaciones de estos valores viven en ClaseCapValidar.
abstract final class ClaseSiNo {

  static const String si = 'S';
  static const String no = 'N';

  /// Valores internos que se guardan en la base.
  static const List<String> listValores = <String>[si, no];

  static List<String> getListOpciones(String sIdioma) {
    return <String>[
      ClaseIdiomas.getTexto('si', sIdioma),
      ClaseIdiomas.getTexto('no', sIdioma),
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
      ClaseIdiomas.getTexto('valorLocal', sIdioma),
      ClaseIdiomas.getTexto('valorExterior', sIdioma),
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
    return ClaseIdiomas.getTexto(_mapClaves[sValor] ?? sValor, sIdioma);
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
    return ClaseIdiomas.getTexto(_mapClaves[sValor] ?? sValor, sIdioma);
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
    return ClaseIdiomas.getTexto(_mapClaves[sValor] ?? sValor, sIdioma);
  }

  static List<String> getListOpciones(String sIdioma) {
    return listValores.map((String s) => getEtiqueta(s, sIdioma)).toList();
  }

}
