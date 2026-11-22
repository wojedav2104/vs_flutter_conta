import '../../generales/modelos/documentos.dart';

/// Datos de prueba de Retenciones a Proveedores (se reemplazarán por Firebird).
abstract final class ClaseRetencionesProveedoresDatos {

  static List<Map<String, dynamic>> crearRegistrosPrueba() {
    return <Map<String, dynamic>>[
      <String, dynamic>{
        'proveedor'               : 'Comercial ABC S.A.',
        'comentarios'             : 'Retencion de IVA y renta a proveedor Comercial ABC S.A.',
        'comprobanteRetencion'    : '001-001-0000001',
        'detalles'                : <Map<String, String>>[
          <String, String>{
            'concepto'     : 'Retencion a Comercial ABC S.A.',
            'cuenta'       : '2.01.01',
            'debe'         : '',
            'haber'        : '160000',
            'nombreCuenta' : 'Proveedores locales',
            'subcuenta'    : '',
          },
          <String, String>{
            'concepto'     : 'Retencion IVA',
            'cuenta'       : '1.01.03',
            'debe'         : '60000',
            'haber'        : '',
            'nombreCuenta' : 'Credito fiscal IVA',
            'subcuenta'    : '',
          },
          <String, String>{
            'concepto'     : 'Retencion Renta',
            'cuenta'       : '1.01.04',
            'debe'         : '100000',
            'haber'        : '',
            'nombreCuenta' : 'Retencion renta pagada',
            'subcuenta'    : '',
          },
        ],
        'ejercicio'               : '2026',
        'exentas'                 : '0',
        'factura'                 : '001-001-0000100',
        'fecha'                   : '15/03/2026',
        'fechaFactura'            : '14/03/2026',
        'gravadas'                : '2000000',
        'identificacion'          : '80012345-6',
        'imponibleRenta'          : '2000000',
        'importeRetenidoIva'      : '60000',
        'importeRetenidoRenta'    : '100000',
        'importeTotalRetencion'   : '160000',
        'iva'                     : '200000',
        'ivaIncluido'             : '200000',
        'numeroAsiento'           : '12',
        'retencionIvaPorcentaje'  : '30',
        'retencionRentaPorcentaje': '5',
        'sucursal'                : '0001 - Sucursal Central',
        'timbrado'                : '11223344',
        'tipoIdentificacion'      : ClaseTipoIdentificacion.ruc,
        'total'                   : '2200000',
        'valorTotalTransaccion'   : '2200000',
        'valorTransaccionSinIva'  : '2000000',
        'vigenteDesde'            : '01/01/2026',
        'vigenteHasta'            : '31/12/2026',
      },
    ];
  }

}
