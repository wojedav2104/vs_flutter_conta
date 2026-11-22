import '../../generales/idiomas/idiomas.dart';
import '../../generales/modelos/campo_abm.dart';
import '../../generales/modelos/documentos.dart';
import '../../generales/utilitarios/formatos.dart';
import '../../generales/validaciones/cap_validar.dart';

/// Campos de Retenciones a Proveedores (specs 02_04_01 y 02_04_02): cabecera
/// con dos grupos (Generales y Detalles) y columnas de la grilla de detalles.
///
/// Disposición: la pestaña Generales lleva los datos de la cabecera y al
/// final, después de la grilla de la pestaña Detalles, el campo Comentarios.
/// Los importes de la factura (Fecha Factura, Exentas, Gravadas, I.V.A.,
/// Imponible Renta y Total) se escriben a mano hasta que la búsqueda de
/// Facturas los coloque automáticamente; los porcentajes y los importes
/// retenidos de la retención son manuales (solo los dos totales son suma).
abstract final class ClaseRetencionesProveedoresCampos {

  // ── Campos de la cabecera ──────────────────────────────────────────
  //
  // Orden visual = orden de declaración (la fila se coloca donde aparece su
  // primer campo; dentro de la fila, los campos van en orden de declaración).

  static List<ClaseCampoAbm> crearCamposCabecera(String sIdioma) {

    final int iAnchoEtiquetasPrimeraColumna = 29;

    return <ClaseCampoAbm>[

      // ── Generales ──────────────────────────────────────────────────
      ClaseCampoAbm(
        bObligatorio     : true,
        funcValidarCampo : (sValor, sIdioma) => ClaseCapValidar.validarEjercicio(sValor, ClaseIdiomas.getTexto('retEjercicio', sIdioma), sIdioma),
        iAnchoCaracteres : 4,
        iAnchoEtiqueta   : iAnchoEtiquetasPrimeraColumna,
        iFila            : 1,
        oAlineacion      : EnumAlineacion.centro,
        oTipo            : EnumTipoCampoAbm.numero,
        sClave           : 'ejercicio',
        sEtiqueta        : ClaseIdiomas.getTexto('retEjercicio', sIdioma),
        sMascara         : '9.999',
        sGrupo           : 'retGenerales',
      ),
      ClaseCampoAbm(
        bObligatorio     : true,
        iAnchoCaracteres : 44,
        iAnchoEtiqueta   : 13,
        iFila            : 1,
        oTipo            : EnumTipoCampoAbm.texto,
        sClave           : 'sucursal',
        sEtiqueta        : ClaseIdiomas.getTexto('retSucursal', sIdioma),
        sGrupo           : 'retGenerales',
        sHint            : ClaseIdiomas.getTexto('retHintSucursal', sIdioma),
      ),
      ClaseCampoAbm(
        bEnGrilla             : false,
        bSiempreDeshabilitado : true,
        iAnchoCaracteres      : 6,
        iAnchoEtiqueta        : 18,
        iFila                 : 1,
        oTipo                 : EnumTipoCampoAbm.numero,
        sClave                : 'numeroAsiento',
        sEtiqueta             : ClaseIdiomas.getTexto('retNumeroAsiento', sIdioma),
        sGrupo                : 'retGenerales',
      ),
      ClaseCampoAbm(
        bObligatorio     : true,
        funcValidarCampo : (sValor, sIdioma) => ClaseCapValidar.validarFechaAnoActualOAnterior(sValor, ClaseIdiomas.getTexto('retFecha', sIdioma), sIdioma),
        iAnchoCaracteres : 10,
        iAnchoEtiqueta   : iAnchoEtiquetasPrimeraColumna,
        iFila            : 2,
        oAlineacion      : EnumAlineacion.centro,
        oTipo            : EnumTipoCampoAbm.fecha,
        sClave           : 'fecha',
        sEtiqueta        : ClaseIdiomas.getTexto('retFecha', sIdioma),
        sGrupo           : 'retGenerales',
      ),
      ClaseCampoAbm(
        bObligatorio     : true,
        iAnchoCaracteres : 48,
        iAnchoEtiqueta   : iAnchoEtiquetasPrimeraColumna,
        iFila            : 3,
        oTipo            : EnumTipoCampoAbm.texto,
        sClave           : 'proveedor',
        sEtiqueta        : ClaseIdiomas.getTexto('retProveedor', sIdioma),
        sGrupo           : 'retGenerales',
        sHint            : ClaseIdiomas.getTexto('retHintProveedor', sIdioma),
      ),
      ClaseCampoAbm(
        iAnchoCaracteres : funcAnchoOpcion(ClaseTipoIdentificacion.getListOpciones(sIdioma)),
        iAnchoEtiqueta   : 21,
        iFila            : 3,
        listOpciones     : ClaseTipoIdentificacion.getListOpciones(sIdioma),
        listValores      : ClaseTipoIdentificacion.listValores,
        oTipo            : EnumTipoCampoAbm.lista,
        sClave           : 'tipoIdentificacion',
        sEtiqueta        : ClaseIdiomas.getTexto('retTipoIdentificacion', sIdioma),
        sGrupo           : 'retGenerales',
        sValorDefecto    : ClaseTipoIdentificacion.ruc,
      ),
      ClaseCampoAbm(
        bSiempreDeshabilitado : true,
        iAnchoCaracteres      : 15,
        iAnchoEtiqueta        : 17,
        iFila                 : 3,
        oTipo                 : EnumTipoCampoAbm.texto,
        sClave                : 'identificacion',
        sEtiqueta             : ClaseIdiomas.getTexto('retIdentificacion', sIdioma),
        sGrupo                : 'retGenerales',
      ),
      ClaseCampoAbm(
        bObligatorio     : true,
        funcValidarCampo : (sValor, sIdioma) => ClaseCapValidar.validarNumeroDocumento(sValor, ClaseIdiomas.getTexto('retComprobanteRetencion', sIdioma), sIdioma),
        iAnchoCaracteres : 15,
        iAnchoEtiqueta   : iAnchoEtiquetasPrimeraColumna,
        iFila            : 4,
        oTipo            : EnumTipoCampoAbm.texto,
        sClave           : 'comprobanteRetencion',
        sEtiqueta        : ClaseIdiomas.getTexto('retComprobanteRetencion', sIdioma),
        sGrupo           : 'retGenerales',
        sMascara         : '999-999-9999999',
      ),
      ClaseCampoAbm(
        funcValidarCampo : (sValor, sIdioma) => sValor.trim().isEmpty ? null : ClaseCapValidar.validarDigitosExactos(sValor, ClaseIdiomas.getTexto('retTimbrado', sIdioma), 8, sIdioma),
        iAnchoCaracteres : 8,
        iAnchoEtiqueta   : 12,
        iFila            : 4,
        oTipo            : EnumTipoCampoAbm.texto,
        sClave           : 'timbrado',
        sEtiqueta        : ClaseIdiomas.getTexto('retTimbrado', sIdioma),
        sGrupo           : 'retGenerales',
        sMascara         : '99999999',
      ),
      ClaseCampoAbm(
        bSiempreDeshabilitado : true,
        iAnchoCaracteres      : 10,
        iAnchoEtiqueta        : 20,
        iFila                 : 4,
        oTipo                 : EnumTipoCampoAbm.fecha,
        sClave                : 'vigenteDesde',
        sEtiqueta             : ClaseIdiomas.getTexto('retVigenteDesde', sIdioma),
        sGrupo                : 'retGenerales',
      ),
      ClaseCampoAbm(
        bSiempreDeshabilitado : true,
        iAnchoCaracteres      : 10,
        iAnchoEtiqueta        : 20,
        iFila                 : 4,
        oTipo                 : EnumTipoCampoAbm.fecha,
        sClave                : 'vigenteHasta',
        sEtiqueta             : ClaseIdiomas.getTexto('retVigenteHasta', sIdioma),
        sGrupo                : 'retGenerales',
      ),
      ClaseCampoAbm(
        bObligatorio     : true,
        funcValidarCampo : (sValor, sIdioma) => ClaseCapValidar.validarNumeroDocumento(sValor, ClaseIdiomas.getTexto('retFactura', sIdioma), sIdioma),
        iAnchoCaracteres : 15,
        iAnchoEtiqueta   : iAnchoEtiquetasPrimeraColumna,
        iFila            : 5,
        oTipo            : EnumTipoCampoAbm.texto,
        sClave           : 'factura',
        sEtiqueta        : ClaseIdiomas.getTexto('retFactura', sIdioma),
        sGrupo           : 'retGenerales',
        sMascara         : '999-999-9999999',
      ),
      ClaseCampoAbm(
        iAnchoCaracteres : 10,
        iAnchoEtiqueta   : 13,
        iFila            : 5,
        oTipo            : EnumTipoCampoAbm.fecha,
        sClave           : 'fechaFactura',
        sEtiqueta        : ClaseIdiomas.getTexto('retFechaFactura', sIdioma),
        sGrupo           : 'retGenerales',
      ),

      // Importes de la factura
      ClaseCampoAbm(
        iAnchoCaracteres : 15,
        iAnchoEtiqueta   : iAnchoEtiquetasPrimeraColumna,
        iFila            : 6,
        oTipo            : EnumTipoCampoAbm.numero,
        sClave           : 'exentas',
        sEtiqueta        : ClaseIdiomas.getTexto('retExentas', sIdioma),
        sGrupo           : 'retGenerales',
        sMascara         : '999.999.999.999',
      ),
      ClaseCampoAbm(
        iAnchoCaracteres : 15,
        iAnchoEtiqueta   : iAnchoEtiquetasPrimeraColumna,
        iFila            : 7,
        oTipo            : EnumTipoCampoAbm.numero,
        sClave           : 'gravadas',
        sEtiqueta        : ClaseIdiomas.getTexto('retGravadas', sIdioma),
        sGrupo           : 'retGenerales',
        sMascara         : '999.999.999.999',
      ),
      ClaseCampoAbm(
        iAnchoCaracteres : 15,
        iAnchoEtiqueta   : iAnchoEtiquetasPrimeraColumna,
        iFila            : 8,
        oTipo            : EnumTipoCampoAbm.numero,
        sClave           : 'iva',
        sEtiqueta        : ClaseIdiomas.getTexto('retIva', sIdioma),
        sGrupo           : 'retGenerales',
        sMascara         : '999.999.999.999',
      ),
      ClaseCampoAbm(
        iAnchoCaracteres : 15,
        iAnchoEtiqueta   : iAnchoEtiquetasPrimeraColumna,
        iFila            : 9,
        oTipo            : EnumTipoCampoAbm.numero,
        sClave           : 'imponibleRenta',
        sEtiqueta        : ClaseIdiomas.getTexto('retImponibleRenta', sIdioma),
        sGrupo           : 'retGenerales',
        sMascara         : '999.999.999.999',
      ),
      ClaseCampoAbm(
        bEsTotal         : true,
        iAnchoCaracteres : 15,
        iAnchoEtiqueta   : iAnchoEtiquetasPrimeraColumna,
        iFila            : 10,
        oTipo            : EnumTipoCampoAbm.numero,
        sClave           : 'total',
        sEtiqueta        : ClaseIdiomas.getTexto('retTotal', sIdioma),
        sGrupo           : 'retGenerales',
        sMascara         : '999.999.999.999',
      ),
      ClaseCampoAbm(
        iAnchoCaracteres : 60,
        iMaxComentario   : 500,
        oTipo            : EnumTipoCampoAbm.comentario,
        sClave           : 'comentarios',
        sEtiqueta        : ClaseIdiomas.getTexto('retComentarios', sIdioma),
        sGrupo           : 'retGenerales',
        sHint            : ClaseIdiomas.getTexto('retHintComentarios', sIdioma),
      ),

      // ── Detalles: los 8 campos (filas 1 a 8) y, debajo, la grilla ────
      ClaseCampoAbm(
        funcValidarCampo : (sValor, sIdioma) => ClaseCapValidar.validarImporteNoNegativo(sValor, ClaseIdiomas.getTexto('retValorTransaccionSinIva', sIdioma), sIdioma),
        iAnchoCaracteres : 15,
        iAnchoEtiqueta   : iAnchoEtiquetasPrimeraColumna,
        iFila            : 1,
        oTipo            : EnumTipoCampoAbm.numero,
        sClave           : 'valorTransaccionSinIva',
        sEtiqueta        : ClaseIdiomas.getTexto('retValorTransaccionSinIva', sIdioma),
        sGrupo           : 'retDetalles',
        sMascara         : '999.999.999.999',
      ),
      ClaseCampoAbm(
        funcValidarCampo : (sValor, sIdioma) => ClaseCapValidar.validarImporteNoNegativo(sValor, ClaseIdiomas.getTexto('retIvaIncluido', sIdioma), sIdioma),
        iAnchoCaracteres : 15,
        iAnchoEtiqueta   : iAnchoEtiquetasPrimeraColumna,
        iFila            : 2,
        oTipo            : EnumTipoCampoAbm.numero,
        sClave           : 'ivaIncluido',
        sEtiqueta        : ClaseIdiomas.getTexto('retIvaIncluido', sIdioma),
        sGrupo           : 'retDetalles',
        sMascara         : '999.999.999.999',
      ),
      ClaseCampoAbm(
        bEsTotal              : true,
        bSiempreDeshabilitado : true,
        iAnchoCaracteres      : 15,
        iAnchoEtiqueta        : iAnchoEtiquetasPrimeraColumna,
        iFila                 : 3,
        oTipo                 : EnumTipoCampoAbm.numero,
        sClave                : 'valorTotalTransaccion',
        sEtiqueta             : ClaseIdiomas.getTexto('retValorTotalTransaccion', sIdioma),
        sGrupo                : 'retDetalles',
        sMascara              : '999.999.999.999',
      ),
      ClaseCampoAbm(
        iAnchoCaracteres : 2,
        iAnchoEtiqueta   : iAnchoEtiquetasPrimeraColumna,
        iFila            : 4,
        oTipo            : EnumTipoCampoAbm.numero,
        sClave           : 'retencionIvaPorcentaje',
        sEtiqueta        : ClaseIdiomas.getTexto('retRetencionIva', sIdioma),
        sGrupo           : 'retDetalles',
        sMascara         : '99',
        sValorDefecto    : '30',
      ),
      ClaseCampoAbm(
        funcValidarCampo : (sValor, sIdioma) => ClaseCapValidar.validarImporteNoNegativo(sValor, ClaseIdiomas.getTexto('retImporteRetenidoIva', sIdioma), sIdioma),
        iAnchoCaracteres : 15,
        iAnchoEtiqueta   : iAnchoEtiquetasPrimeraColumna,
        iFila            : 5,
        oTipo            : EnumTipoCampoAbm.numero,
        sClave           : 'importeRetenidoIva',
        sEtiqueta        : ClaseIdiomas.getTexto('retImporteRetenidoIva', sIdioma),
        sGrupo           : 'retDetalles',
        sMascara         : '999.999.999.999',
      ),
      ClaseCampoAbm(
        iAnchoCaracteres : 2,
        iAnchoEtiqueta   : iAnchoEtiquetasPrimeraColumna,
        iFila            : 6,
        oTipo            : EnumTipoCampoAbm.numero,
        sClave           : 'retencionRentaPorcentaje',
        sEtiqueta        : ClaseIdiomas.getTexto('retRetencionRenta', sIdioma),
        sGrupo           : 'retDetalles',
        sMascara         : '99',
      ),
      ClaseCampoAbm(
        funcValidarCampo : (sValor, sIdioma) => ClaseCapValidar.validarImporteNoNegativo(sValor, ClaseIdiomas.getTexto('retImporteRetenidoRenta', sIdioma), sIdioma),
        iAnchoCaracteres : 15,
        iAnchoEtiqueta   : iAnchoEtiquetasPrimeraColumna,
        iFila            : 7,
        oTipo            : EnumTipoCampoAbm.numero,
        sClave           : 'importeRetenidoRenta',
        sEtiqueta        : ClaseIdiomas.getTexto('retImporteRetenidoRenta', sIdioma),
        sGrupo           : 'retDetalles',
        sMascara         : '999.999.999.999',
      ),
      ClaseCampoAbm(
        bEsTotal              : true,
        bSiempreDeshabilitado : true,
        iAnchoCaracteres      : 15,
        iAnchoEtiqueta        : iAnchoEtiquetasPrimeraColumna,
        iFila                 : 8,
        oTipo                 : EnumTipoCampoAbm.numero,
        sClave                : 'importeTotalRetencion',
        sEtiqueta             : ClaseIdiomas.getTexto('retImporteTotalRetencion', sIdioma),
        sGrupo                : 'retDetalles',
        sMascara              : '999.999.999.999',
      ),
    ];
  }

  // ── Columnas de la grilla de detalles ───────────────────────────────────

  static List<ClaseCampoAbm> crearCamposDetalle(String sIdioma) {

    return <ClaseCampoAbm>[
      ClaseCampoAbm(
        funcValidarCampo : (sValor, sIdioma) => ClaseCapValidar.validarFormatoCuenta(sValor, ClaseIdiomas.getTexto('detCuenta', sIdioma), sIdioma),
        iAnchoCaracteres : 16,
        oTipo            : EnumTipoCampoAbm.texto,
        sClave           : 'cuenta',
        sEtiqueta        : ClaseIdiomas.getTexto('detCuenta', sIdioma),
        sHint            : ClaseIdiomas.getTexto('detHintCuenta', sIdioma),
      ),
      ClaseCampoAbm(
        bCompletarCeros  : true,
        funcValidarCampo : (sValor, sIdioma) => ClaseCapValidar.validarNumeroSubcuenta(sValor, ClaseIdiomas.getTexto('detSubcuenta', sIdioma), sIdioma),
        iAnchoCaracteres : 5,
        oTipo            : EnumTipoCampoAbm.texto,
        sClave           : 'subcuenta',
        sEtiqueta        : ClaseIdiomas.getTexto('detSubcuenta', sIdioma),
      ),
      ClaseCampoAbm(
        bSiempreDeshabilitado : true,
        iAnchoCaracteres      : 40,
        oTipo                 : EnumTipoCampoAbm.texto,
        sClave                : 'nombreCuenta',
        sEtiqueta             : ClaseIdiomas.getTexto('detNombreCuenta', sIdioma),
        sHint                 : ClaseIdiomas.getTexto('detHintNombreCuenta', sIdioma),
      ),
      ClaseCampoAbm(
        iAnchoCaracteres : 15,
        oTipo            : EnumTipoCampoAbm.numero,
        sClave           : 'debe',
        sEtiqueta        : ClaseIdiomas.getTexto('detDebe', sIdioma),
        sMascara         : '999.999.999.999',
      ),
      ClaseCampoAbm(
        iAnchoCaracteres : 15,
        oTipo            : EnumTipoCampoAbm.numero,
        sClave           : 'haber',
        sEtiqueta        : ClaseIdiomas.getTexto('detHaber', sIdioma),
        sMascara         : '999.999.999.999',
      ),
      ClaseCampoAbm(
        bColumnaExpansible: true,
        iAnchoCaracteres  : 60,
        iAnchoVisible     : 15,
        oTipo             : EnumTipoCampoAbm.texto,
        sClave            : 'concepto',
        sEtiqueta         : ClaseIdiomas.getTexto('detConcepto', sIdioma),
        sHint             : ClaseIdiomas.getTexto('detHintConcepto', sIdioma),
      ),
    ];
  }

}
