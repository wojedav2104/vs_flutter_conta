/// Textos del idioma: Retenciones a Clientes (specs 02_05_01 y 02_05_02).
abstract final class ClaseIdiomasRetenciones {

  static const Map<String, String> mapEs = <String, String>{
    // ── Grupos ────────────────────────────────────────────────────────────
    'retGenerales'                : 'Generales',
    'retDetalles'                 : 'Detalles',
    // ── Cabecera (pestaña Generales) ──────────────────────────────────────
    'retEjercicio'                : 'Ejercicio contable',
    'retSucursal'                 : 'Sucursal',
    'retNumeroAsiento'            : 'Número del asiento',
    'retFecha'                    : 'Fecha de la retención',
    'retCliente'                  : 'Cliente',
    'retProveedor'                : 'Proveedor',
    'retTipoIdentificacion'       : 'Tipo de identificación',
    'retIdentificacion'           : 'Identificación N°',
    'retComprobanteRetencion'     : 'Comprobante de Retención N°',
    'retTimbrado'                 : 'Timbrado N°',
    'retVigenteDesde'             : 'Vigente desde el día',
    'retVigenteHasta'             : 'Vigente hasta el día',
    'retFactura'                  : 'Factura N°',
    'retFechaFactura'             : 'Fecha Factura',
    'retExentas'                  : 'Exentas',
    'retGravadas'                 : 'Gravadas',
    'retIva'                      : 'I.V.A.',
    'retImponibleRenta'           : 'Imponible Renta',
    'retTotal'                    : 'Total',
    'retComentarios'              : 'Comentarios',
    // ── Detalles (pestaña Detalles) ───────────────────────────────────────
    'retValorTransaccionSinIva'   : 'Valor de la transacción sin I.V.A.',
    'retIvaIncluido'              : 'I.V.A. incluido en la transacción',
    'retValorTotalTransaccion'    : 'Valor total de la transacción',
    'retRetencionIva'             : 'Retención I.V.A. %',
    'retImporteRetenidoIva'       : 'Importe retenido del I.V.A.',
    'retRetencionRenta'           : 'Retención Renta %',
    'retImporteRetenidoRenta'     : 'Importe retenido de renta',
    'retImporteTotalRetencion'    : 'Importe total de la retención',
    // ── Hints ─────────────────────────────────────────────────────────────
    'retHintSucursal'             : 'Código y Nombre de la sucursal',
    'retHintCliente'              : 'Código y Nombre del cliente',
    'retHintProveedor'            : 'Código y Nombre del proveedor',
    'retHintComentarios'          : 'Comentarios sobre esta retención',
  };

  static const Map<String, String> mapFr = <String, String>{
    // ── Grupos ────────────────────────────────────────────────────────────
    'retGenerales'                : 'Généraux',
    'retDetalles'                 : 'Détails',
    // ── Cabecera (pestaña Generales) ──────────────────────────────────────
    'retEjercicio'                : 'Exercice comptable',
    'retSucursal'                 : 'Succursale',
    'retNumeroAsiento'            : 'Numéro de l\'écriture',
    'retFecha'                    : 'Date de la retenue',
    'retCliente'                  : 'Client',
    'retTipoIdentificacion'       : 'Identification',
    'retIdentificacion'           : 'Identification N°',
    'retComprobanteRetencion'     : 'N° du justificatif de retenue',
    'retTimbrado'                 : 'Timbrado N°',
    'retVigenteDesde'             : 'Valide à partir du',
    'retVigenteHasta'             : 'Valide jusqu\'au',
    'retFactura'                  : 'Facture N°',
    'retFechaFactura'             : 'Date de la facture',
    'retExentas'                  : 'Exonérées',
    'retGravadas'                 : 'Taxables',
    'retIva'                      : 'T.V.A.',
    'retImponibleRenta'           : 'Imponible revenu',
    'retTotal'                    : 'Total',
    'retComentarios'              : 'Commentaires',
    // ── Detalles (pestaña Detalles) ───────────────────────────────────────
    'retValorTransaccionSinIva'   : 'Valeur de la transaction hors T.V.A.',
    'retIvaIncluido'              : 'T.V.A. incluse dans la transaction',
    'retValorTotalTransaccion'    : 'Valeur totale de la transaction',
    'retRetencionIva'             : 'Retenue T.V.A. %',
    'retImporteRetenidoIva'       : 'Montant retenu de la T.V.A.',
    'retRetencionRenta'           : 'Retenue revenu %',
    'retImporteRetenidoRenta'     : 'Montant retenu sur le revenu',
    'retImporteTotalRetencion'    : 'Montant total de la retenue',
    // ── Hints ─────────────────────────────────────────────────────────────
    'retHintSucursal'             : 'Code et nom de la succursale',
    'retHintCliente'              : 'Code et nom du client',
    'retHintComentarios'          : 'Commentaires sur cette retenue',
  };

}
