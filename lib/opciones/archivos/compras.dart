import 'package:flutter/material.dart';

import '../../generales/idiomas/idiomas.dart';
import '../../generales/modelos/campo_abm.dart';
import '../../generales/preferencias/preferencias.dart';
import '../../generales/utilitarios/formatos.dart';
import '../../generales/validaciones/cap_validar.dart';
import '../../generales/varios/listas.dart';
import '../../generales/widgets/formulario_cabecera_detalle.dart';

/// Pantalla de la tabla Libro Compras (cabecera + grilla editable de detalles).
///
/// Cabecera con dos pestañas (Generales y Resolución 90/2021) y las filas
/// del asiento generado en la clave 'detalles'.
///
/// Validaciones cruzadas (validarRegistro):
///   · Cantidad de cuotas obligatoria (1 a 240) en Factura Crédito; en los
///     demás tipos puede estar vacía o ser 0.
///   · Formato del N° de documento según el Tipo de documento.
///   · Formato de la identificación según el Tipo de identificación.
///   · La Fecha de fin de vigencia debe ser posterior al inicio.
///   · Total del comprobante = suma del Debe si se envía a Marangatú.
class ClaseCompras extends StatefulWidget {

  const ClaseCompras({
    super.key,
    required this.oPreferencias,
  });

  final ClasePreferencias oPreferencias;

  @override
  State<ClaseCompras> createState() => ClaseEstadoCompras();
}

class ClaseEstadoCompras extends State<ClaseCompras> {

  late final List<ClaseCampoAbm>        listCamposCabecera;
  late final List<ClaseCampoAbm>        listCamposDetalle;
  late final List<Map<String, dynamic>> listRegistros;

  @override
  void initState() {
    super.initState();
    listCamposCabecera = crearCamposCabecera();
    listCamposDetalle  = crearCamposDetalle();
    listRegistros      = crearRegistrosPrueba();
  }

  @override
  Widget build(BuildContext oContexto) {
    return ClaseFormularioCabeceraDetalle(
      funcActualizarCampos : actualizarCampos,
      funcValidarRegistro  : validarRegistro,
      listCamposCabecera   : listCamposCabecera,
      listCamposDetalle    : listCamposDetalle,
      listRegistros        : listRegistros,
      oPreferencias        : widget.oPreferencias,
      sTitulo              : ClaseIdiomas.getTexto(getIdioma(), 'menuLibroCompras'),
    );
  }

  String getIdioma() => widget.oPreferencias.getIdioma();

  // ── Auto-cálculos de la cabecera ────────────────────────────────────────

  /// Total = gravadas 10% + IVA 10% + gravadas 5% + IVA 5% + exentas.
  /// Total del comprobante = Total. Los importes de la Resolución 90/2021
  /// se sugieren solo si están vacíos; IRE simple, IRP simple y no imputable
  /// son manuales.
  Map<String, String>? actualizarCampos(Map<String, String> mapValores) {

    final double dGravadas10 = funcParsearNumero(mapValores['gravadas10'] ?? '') ?? 0;
    final double dIva10      = funcParsearNumero(mapValores['iva10']      ?? '') ?? 0;
    final double dGravadas5  = funcParsearNumero(mapValores['gravadas5']  ?? '') ?? 0;
    final double dIva5       = funcParsearNumero(mapValores['iva5']       ?? '') ?? 0;
    final double dExentas    = funcParsearNumero(mapValores['exentas']    ?? '') ?? 0;
    final double dTotal      = dGravadas10 + dIva10 + dGravadas5 + dIva5 + dExentas;

    final Map<String, String> mapActualizaciones = <String, String>{
      'total'            : funcFormatearNumeroPlano(dTotal),
      'totalComprobante' : funcFormatearNumeroPlano(dTotal),
    };

    if ((mapValores['importeGravado10'] ?? '').trim().isEmpty) {
      mapActualizaciones['importeGravado10'] =
          funcFormatearNumeroPlano(dGravadas10 + dIva10);
    }
    if ((mapValores['importeGravado5'] ?? '').trim().isEmpty) {
      mapActualizaciones['importeGravado5'] =
          funcFormatearNumeroPlano(dGravadas5 + dIva5);
    }
    if ((mapValores['importeExento'] ?? '').trim().isEmpty) {
      mapActualizaciones['importeExento'] = funcFormatearNumeroPlano(dExentas);
    }
    return mapActualizaciones;
  }

  // ── Validación cruzada del registro completo ────────────────────────────

  String? validarRegistro(Map<String, dynamic> oRegistro) {

    final String sIdioma = getIdioma();
    final String sTipoDoc = (oRegistro['tipoDocumento'] ?? '').toString();
    final String sCuotas  = (oRegistro['cantidadCuotas'] ?? '').toString().trim();

    // Cantidad de cuotas: obligatoria (1 a 240) en Factura Crédito;
    // en los demás tipos puede estar vacía o ser 0.
    if (ClaseTipoDocumento.esFacturaCredito(sTipoDoc)) {
      if (sCuotas.isEmpty || sCuotas == '0') {
        return ClaseCapValidar.validarObligatorio(sCuotas,
            ClaseIdiomas.getTexto(sIdioma, 'comCantidadCuotas'), sIdioma);
      }
    }
    if (sCuotas.isNotEmpty && sCuotas != '0') {
      final String? sError = ClaseCapValidar.validarRangoEntero(sCuotas,
          ClaseIdiomas.getTexto(sIdioma, 'comCantidadCuotas'), 1, 240, sIdioma);
      if (sError != null) return sError;
    }

    // N° de documento según el Tipo de documento.
    final String? sErrorNumero = ClaseCapValidar.validarNumeroDocumentoPorTipo(
      (oRegistro['numero'] ?? '').toString(),
      sTipoDoc,
      ClaseIdiomas.getTexto(sIdioma, 'comNumero'),
      sIdioma,
    );
    if (sErrorNumero != null) return sErrorNumero;

    // Identificación según el Tipo de identificación.
    final String? sErrorIdent = ClaseCapValidar.validarIdentificacion(
      (oRegistro['rucCedula'] ?? '').toString(),
      (oRegistro['tipoIdentificacion'] ?? '').toString(),
      ClaseIdiomas.getTexto(sIdioma, 'comRucCedula'),
      sIdioma,
    );
    if (sErrorIdent != null) return sErrorIdent;

    // Vigencia del timbrado: el fin debe ser posterior al inicio.
    final String? sErrorVigencia = ClaseCapValidar.validarFechaFinPosterior(
      (oRegistro['vigenteDesde'] ?? '').toString(),
      (oRegistro['vigenteHasta'] ?? '').toString(),
      sIdioma,
    );
    if (sErrorVigencia != null) return sErrorVigencia;

    // Marangatú: el Total del comprobante debe ser igual a la suma del Debe.
    if ((oRegistro['enviarMarangatu'] ?? '') == ClaseSiNo.si) {
      double dDebe = 0;
      final dynamic oDetalles =
          oRegistro[ClaseFormularioCabeceraDetalle.sClaveDetalles];
      if (oDetalles is List) {
        for (final dynamic oFila in oDetalles) {
          dDebe += funcParsearNumero(((oFila as Map)['debe'] ?? '').toString()) ?? 0;
        }
      }
      final double dTotal = funcParsearNumero(
          (oRegistro['totalComprobante'] ?? '').toString()) ?? 0;
      if ((dTotal - dDebe).abs() > 0.005) {
        return ClaseIdiomas.getTexto(sIdioma, 'comErrorMarangatu');
      }
    }
    return null;
  }

  // ── Campos de la cabecera ──────────────────────────────────────────────

  List<ClaseCampoAbm> crearCamposCabecera() {

    final String sIdioma = getIdioma();

    return <ClaseCampoAbm>[

      // ── Generales ────────────────────────────────────────────────────────
      ClaseCampoAbm(
        bObligatorio     : true,
        funcValidarCampo : (sValor, sIdioma) => ClaseCapValidar.validarFechaNoAnterior(
            sValor, ClaseIdiomas.getTexto(sIdioma, 'comFecha'),
            DateTime(ClaseFechas.iAnioMinimo, 1, 1), sIdioma),
        iAnchoCaracteres : 10,
        oTipo            : EnumTipoCampoAbm.fecha,
        sClave           : 'fecha',
        sEtiqueta        : ClaseIdiomas.getTexto(sIdioma, 'comFecha'),
        sGrupo           : 'comGenerales',
      ),
      ClaseCampoAbm(
        funcValidarCampo : (sValor, sIdioma) => ClaseCapValidar.validarHoraValida(
            sValor, ClaseIdiomas.getTexto(sIdioma, 'comHora'), sIdioma),
        iAnchoCaracteres : 5,
        oTipo            : EnumTipoCampoAbm.hora,
        sClave           : 'hora',
        sEtiqueta        : ClaseIdiomas.getTexto(sIdioma, 'comHora'),
        sGrupo           : 'comGenerales',
      ),
      ClaseCampoAbm(
        bObligatorio     : true,
        funcValidarCampo : (sValor, sIdioma) => ClaseCapValidar.validarSoloEntero(
            sValor, ClaseIdiomas.getTexto(sIdioma, 'comNumeroAsiento'), sIdioma),
        iAnchoCaracteres : 5,
        oTipo            : EnumTipoCampoAbm.numero,
        sClave           : 'numeroAsiento',
        sEtiqueta        : ClaseIdiomas.getTexto(sIdioma, 'comNumeroAsiento'),
        sGrupo           : 'comGenerales',
      ),
      ClaseCampoAbm(
        bObligatorio     : true,
        iAnchoCaracteres : funcAnchoOpcion(ClaseTipoDocumento.getListOpciones(sIdioma)),
        listOpciones     : ClaseTipoDocumento.getListOpciones(sIdioma),
        listValores      : ClaseTipoDocumento.listValores,
        oTipo            : EnumTipoCampoAbm.lista,
        sClave           : 'tipoDocumento',
        sEtiqueta        : ClaseIdiomas.getTexto(sIdioma, 'comTipoDocumento'),
        sGrupo           : 'comGenerales',
        sValorDefecto    : '01',
      ),
      ClaseCampoAbm(
        bObligatorio     : true,
        funcMascara      : (mapValores) => ClaseTipoDocumento.esConMascara(
            mapValores['tipoDocumento'] ?? '') ? ClaseTipoDocumento.sMascaraNumero : null,
        iAnchoCaracteres : 15,
        oTipo            : EnumTipoCampoAbm.texto,
        sClave           : 'numero',
        sEtiqueta        : ClaseIdiomas.getTexto(sIdioma, 'comNumero'),
        sGrupo           : 'comGenerales',
      ),
      ClaseCampoAbm(
        funcValidarCampo : (sValor, sIdioma) => ClaseCapValidar.validarSoloEntero(
            sValor, ClaseIdiomas.getTexto(sIdioma, 'comCantidadCuotas'), sIdioma),
        iAnchoCaracteres : 3,
        oTipo            : EnumTipoCampoAbm.numero,
        sClave           : 'cantidadCuotas',
        sEtiqueta        : ClaseIdiomas.getTexto(sIdioma, 'comCantidadCuotas'),
        sGrupo           : 'comGenerales',
        sValorDefecto    : '1',
      ),
      ClaseCampoAbm(
        bObligatorio     : true,
        iAnchoCaracteres : 48,
        oTipo            : EnumTipoCampoAbm.texto,
        sClave           : 'proveedor',
        sEtiqueta        : ClaseIdiomas.getTexto(sIdioma, 'comProveedor'),
        sGrupo           : 'comGenerales',
        sHint            : ClaseIdiomas.getTexto(sIdioma, 'comHintProveedor'),
      ),
      ClaseCampoAbm(
        iAnchoCaracteres : funcAnchoOpcion(ClaseTipoIdentificacion.getListOpciones(sIdioma)),
        listOpciones     : ClaseTipoIdentificacion.getListOpciones(sIdioma),
        listValores      : ClaseTipoIdentificacion.listValores,
        oTipo            : EnumTipoCampoAbm.lista,
        sClave           : 'tipoIdentificacion',
        sEtiqueta        : ClaseIdiomas.getTexto(sIdioma, 'comTipoIdentificacion'),
        sGrupo           : 'comGenerales',
        sValorDefecto    : ClaseTipoIdentificacion.ruc,
      ),
      ClaseCampoAbm(
        iAnchoCaracteres : 15,
        oTipo            : EnumTipoCampoAbm.texto,
        sClave           : 'rucCedula',
        sEtiqueta        : ClaseIdiomas.getTexto(sIdioma, 'comRucCedula'),
        sGrupo           : 'comGenerales',
      ),
      ClaseCampoAbm(
        bCompletarCeros  : true,
        funcValidarCampo : (sValor, sIdioma) => ClaseCapValidar.validarDigitosExactos(
            sValor, ClaseIdiomas.getTexto(sIdioma, 'comTimbrado'), 8, sIdioma),
        iAnchoCaracteres : 8,
        oTipo            : EnumTipoCampoAbm.texto,
        sClave           : 'timbrado',
        sEtiqueta        : ClaseIdiomas.getTexto(sIdioma, 'comTimbrado'),
        sGrupo           : 'comGenerales',
      ),
      ClaseCampoAbm(
        funcValidarCampo : (sValor, sIdioma) => ClaseCapValidar.validarFechaValida(
            sValor, ClaseIdiomas.getTexto(sIdioma, 'comVigenteDesde'), sIdioma),
        iAnchoCaracteres : 10,
        oTipo            : EnumTipoCampoAbm.fecha,
        sClave           : 'vigenteDesde',
        sEtiqueta        : ClaseIdiomas.getTexto(sIdioma, 'comVigenteDesde'),
        sGrupo           : 'comGenerales',
      ),
      ClaseCampoAbm(
        funcValidarCampo : (sValor, sIdioma) => ClaseCapValidar.validarFechaValida(
            sValor, ClaseIdiomas.getTexto(sIdioma, 'comVigenteHasta'), sIdioma),
        iAnchoCaracteres : 10,
        oTipo            : EnumTipoCampoAbm.fecha,
        sClave           : 'vigenteHasta',
        sEtiqueta        : ClaseIdiomas.getTexto(sIdioma, 'comVigenteHasta'),
        sGrupo           : 'comGenerales',
      ),
      ClaseCampoAbm(
        iAnchoCaracteres : funcAnchoOpcion(ClaseSiNo.getListOpciones(sIdioma)),
        listOpciones     : ClaseSiNo.getListOpciones(sIdioma),
        listValores      : ClaseSiNo.listValores,
        oTipo            : EnumTipoCampoAbm.lista,
        sClave           : 'esFacturaElectronica',
        sEtiqueta        : ClaseIdiomas.getTexto(sIdioma, 'comEsFacturaElectronica'),
        sGrupo           : 'comGenerales',
        sValorDefecto    : ClaseSiNo.si,
      ),
      ClaseCampoAbm(
        bDecimales       : true,
        iAnchoCaracteres : 12,
        oTipo            : EnumTipoCampoAbm.numero,
        sClave           : 'gravadas10',
        sEtiqueta        : ClaseIdiomas.getTexto(sIdioma, 'comGravadas10'),
        sGrupo           : 'comGenerales',
      ),
      ClaseCampoAbm(
        bDecimales       : true,
        iAnchoCaracteres : 12,
        oTipo            : EnumTipoCampoAbm.numero,
        sClave           : 'iva10',
        sEtiqueta        : ClaseIdiomas.getTexto(sIdioma, 'comIva10'),
        sGrupo           : 'comGenerales',
      ),
      ClaseCampoAbm(
        bDecimales       : true,
        iAnchoCaracteres : 12,
        oTipo            : EnumTipoCampoAbm.numero,
        sClave           : 'gravadas5',
        sEtiqueta        : ClaseIdiomas.getTexto(sIdioma, 'comGravadas5'),
        sGrupo           : 'comGenerales',
      ),
      ClaseCampoAbm(
        bDecimales       : true,
        iAnchoCaracteres : 12,
        oTipo            : EnumTipoCampoAbm.numero,
        sClave           : 'iva5',
        sEtiqueta        : ClaseIdiomas.getTexto(sIdioma, 'comIva5'),
        sGrupo           : 'comGenerales',
      ),
      ClaseCampoAbm(
        bDecimales       : true,
        iAnchoCaracteres : 12,
        oTipo            : EnumTipoCampoAbm.numero,
        sClave           : 'exentas',
        sEtiqueta        : ClaseIdiomas.getTexto(sIdioma, 'comExentas'),
        sGrupo           : 'comGenerales',
      ),
      ClaseCampoAbm(
        bDecimales       : true,
        iAnchoCaracteres : 12,
        oTipo            : EnumTipoCampoAbm.numero,
        sClave           : 'total',
        sEtiqueta        : ClaseIdiomas.getTexto(sIdioma, 'comTotal'),
        sGrupo           : 'comGenerales',
      ),
      ClaseCampoAbm(
        bObligatorio     : true,
        iAnchoCaracteres : funcAnchoOpcion(ClaseTipoAfectacion.getListOpciones(sIdioma)),
        listOpciones     : ClaseTipoAfectacion.getListOpciones(sIdioma),
        listValores      : ClaseTipoAfectacion.listValores,
        oTipo            : EnumTipoCampoAbm.lista,
        sClave           : 'tipoAfectacion',
        sEtiqueta        : ClaseIdiomas.getTexto(sIdioma, 'comTipoAfectacion'),
        sGrupo           : 'comGenerales',
        sValorDefecto    : ClaseTipoAfectacion.directo,
      ),
      ClaseCampoAbm(
        iAnchoCaracteres : funcAnchoOpcion(ClaseSiNo.getListOpciones(sIdioma)),
        listOpciones     : ClaseSiNo.getListOpciones(sIdioma),
        listValores      : ClaseSiNo.listValores,
        oTipo            : EnumTipoCampoAbm.lista,
        sClave           : 'mostrarEnLibro',
        sEtiqueta        : ClaseIdiomas.getTexto(sIdioma, 'comMostrarEnLibro'),
        sGrupo           : 'comGenerales',
        sValorDefecto    : ClaseSiNo.si,
      ),
      ClaseCampoAbm(
        iAnchoCaracteres : 60,
        iMaxComentario   : 500,
        oTipo            : EnumTipoCampoAbm.comentario,
        sClave           : 'comentarios',
        sEtiqueta        : ClaseIdiomas.getTexto(sIdioma, 'comComentarios'),
        sGrupo           : 'comGenerales',
        sHint            : ClaseIdiomas.getTexto(sIdioma, 'comHintComentarios'),
      ),

      // ── Resolución 90/2021 ───────────────────────────────────────────────
      ClaseCampoAbm(
        iAnchoCaracteres : funcAnchoOpcion(ClaseSiNo.getListOpciones(sIdioma)),
        listOpciones     : ClaseSiNo.getListOpciones(sIdioma),
        listValores      : ClaseSiNo.listValores,
        oTipo            : EnumTipoCampoAbm.lista,
        sClave           : 'enviarMarangatu',
        sEtiqueta        : ClaseIdiomas.getTexto(sIdioma, 'comEnviarMarangatu'),
        sGrupo           : 'comResolucion',
        sValorDefecto    : ClaseSiNo.si,
      ),
      ClaseCampoAbm(
        bDecimales       : true,
        iAnchoCaracteres : 12,
        oTipo            : EnumTipoCampoAbm.numero,
        sClave           : 'importeGravado10',
        sEtiqueta        : ClaseIdiomas.getTexto(sIdioma, 'comImporteGravado10'),
        sGrupo           : 'comResolucion',
      ),
      ClaseCampoAbm(
        bDecimales       : true,
        iAnchoCaracteres : 12,
        oTipo            : EnumTipoCampoAbm.numero,
        sClave           : 'importeGravado5',
        sEtiqueta        : ClaseIdiomas.getTexto(sIdioma, 'comImporteGravado5'),
        sGrupo           : 'comResolucion',
      ),
      ClaseCampoAbm(
        bDecimales       : true,
        iAnchoCaracteres : 12,
        oTipo            : EnumTipoCampoAbm.numero,
        sClave           : 'importeExento',
        sEtiqueta        : ClaseIdiomas.getTexto(sIdioma, 'comImporteExento'),
        sGrupo           : 'comResolucion',
      ),
      ClaseCampoAbm(
        bDecimales       : true,
        iAnchoCaracteres : 12,
        oTipo            : EnumTipoCampoAbm.numero,
        sClave           : 'importeIreSimple',
        sEtiqueta        : ClaseIdiomas.getTexto(sIdioma, 'comImporteIreSimple'),
        sGrupo           : 'comResolucion',
      ),
      ClaseCampoAbm(
        bDecimales       : true,
        iAnchoCaracteres : 12,
        oTipo            : EnumTipoCampoAbm.numero,
        sClave           : 'importeIrpSimple',
        sEtiqueta        : ClaseIdiomas.getTexto(sIdioma, 'comImporteIrpSimple'),
        sGrupo           : 'comResolucion',
      ),
      ClaseCampoAbm(
        bDecimales       : true,
        iAnchoCaracteres : 12,
        oTipo            : EnumTipoCampoAbm.numero,
        sClave           : 'importeNoImputable',
        sEtiqueta        : ClaseIdiomas.getTexto(sIdioma, 'comImporteNoImputable'),
        sGrupo           : 'comResolucion',
      ),
      ClaseCampoAbm(
        bDecimales       : true,
        iAnchoCaracteres : 12,
        oTipo            : EnumTipoCampoAbm.numero,
        sClave           : 'totalComprobante',
        sEtiqueta        : ClaseIdiomas.getTexto(sIdioma, 'comTotalComprobante'),
        sGrupo           : 'comResolucion',
      ),
    ];
  }

  // ── Columnas de la grilla de detalles ───────────────────────────────────

  List<ClaseCampoAbm> crearCamposDetalle() {

    final String sIdioma = getIdioma();

    return <ClaseCampoAbm>[
      ClaseCampoAbm(
        bObligatorio     : true,
        iAnchoCaracteres : 16,
        oTipo            : EnumTipoCampoAbm.texto,
        sClave           : 'cuenta',
        sEtiqueta        : ClaseIdiomas.getTexto(sIdioma, 'detCuenta'),
        sHint            : ClaseIdiomas.getTexto(sIdioma, 'comHintCuenta'),
      ),
      ClaseCampoAbm(
        iAnchoCaracteres : 40,
        oTipo            : EnumTipoCampoAbm.texto,
        sClave           : 'nombreCuenta',
        sEtiqueta        : ClaseIdiomas.getTexto(sIdioma, 'detNombreCuenta'),
        sHint            : ClaseIdiomas.getTexto(sIdioma, 'comHintNombreCuenta'),
      ),
      ClaseCampoAbm(
        funcValidarCampo : (sValor, sIdioma) => ClaseCapValidar.validarNumeroSubcuenta(
            sValor, ClaseIdiomas.getTexto(sIdioma, 'detSubcuenta'), sIdioma),
        iAnchoCaracteres : 5,
        oTipo            : EnumTipoCampoAbm.texto,
        sClave           : 'subcuenta',
        sEtiqueta        : ClaseIdiomas.getTexto(sIdioma, 'detSubcuenta'),
      ),
      ClaseCampoAbm(
        iAnchoCaracteres : 30,
        oTipo            : EnumTipoCampoAbm.texto,
        sClave           : 'concepto',
        sEtiqueta        : ClaseIdiomas.getTexto(sIdioma, 'detConcepto'),
        sHint            : ClaseIdiomas.getTexto(sIdioma, 'detHintConcepto'),
      ),
      ClaseCampoAbm(
        bDecimales       : true,
        iAnchoCaracteres : 12,
        oTipo            : EnumTipoCampoAbm.numero,
        sClave           : 'debe',
        sEtiqueta        : ClaseIdiomas.getTexto(sIdioma, 'detDebe'),
      ),
      ClaseCampoAbm(
        bDecimales       : true,
        iAnchoCaracteres : 12,
        oTipo            : EnumTipoCampoAbm.numero,
        sClave           : 'haber',
        sEtiqueta        : ClaseIdiomas.getTexto(sIdioma, 'detHaber'),
      ),
    ];
  }

  // ── Datos de prueba (se reemplazarán por Firebird) ──────────────────────

  List<Map<String, dynamic>> crearRegistrosPrueba() {
    return <Map<String, dynamic>>[
      <String, dynamic>{
        'cantidadCuotas'     : '3',
        'comentarios'        : 'Compra de mercadería para reventa',
        'detalles'           : <Map<String, String>>[
          <String, String>{
            'concepto'     : 'Compra de mercadería',
            'cuenta'       : '1.04.02',
            'debe'         : '2000000',
            'haber'        : '',
            'nombreCuenta' : 'Mercaderías Gravadas 10%',
            'subcuenta'    : '',
          },
          <String, String>{
            'concepto'     : 'Compra de mercadería',
            'cuenta'       : '1.03.01',
            'debe'         : '200000',
            'haber'        : '',
            'nombreCuenta' : 'I.V.A Crédito Fiscal 10%',
            'subcuenta'    : '',
          },
          <String, String>{
            'concepto'     : 'Compra de mercadería',
            'cuenta'       : '2.01.01',
            'debe'         : '',
            'haber'        : '2200000',
            'nombreCuenta' : 'Proveedores',
            'subcuenta'    : '',
          },
        ],
        'enviarMarangatu'    : ClaseSiNo.si,
        'esFacturaElectronica': ClaseSiNo.si,
        'exentas'            : '0',
        'fecha'              : '10/02/2026',
        'gravadas10'         : '2000000',
        'gravadas5'          : '0',
        'hora'               : '10:30',
        'importeExento'      : '0',
        'importeGravado10'   : '2200000',
        'importeGravado5'    : '0',
        'importeIreSimple'   : '0',
        'importeIrpSimple'   : '0',
        'importeNoImputable' : '0',
        'iva10'              : '200000',
        'iva5'               : '0',
        'mostrarEnLibro'     : ClaseSiNo.si,
        'numero'             : '001-002-0000123',
        'numeroAsiento'      : '2',
        'proveedor'          : 'Distribuidora del Sur S.A.',
        'rucCedula'          : '80098765-9',
        'timbrado'           : '11223344',
        'tipoAfectacion'     : ClaseTipoAfectacion.directo,
        'tipoDocumento'      : '02',
        'tipoIdentificacion' : ClaseTipoIdentificacion.ruc,
        'total'              : '2200000',
        'totalComprobante'   : '2200000',
        'vigenteDesde'       : '01/01/2026',
        'vigenteHasta'       : '31/12/2026',
      },
      <String, dynamic>{
        'cantidadCuotas'     : '',
        'comentarios'        : '',
        'detalles'           : <Map<String, String>>[
          <String, String>{
            'concepto'     : 'Compra de mercadería',
            'cuenta'       : '1.04.03',
            'debe'         : '400000',
            'haber'        : '',
            'nombreCuenta' : 'Mercaderías Gravadas 5%',
            'subcuenta'    : '',
          },
          <String, String>{
            'concepto'     : 'Compra de mercadería',
            'cuenta'       : '1.03.02',
            'debe'         : '20000',
            'haber'        : '',
            'nombreCuenta' : 'I.V.A Crédito Fiscal 5%',
            'subcuenta'    : '',
          },
          <String, String>{
            'concepto'     : 'Compra de mercadería',
            'cuenta'       : '1.04.01',
            'debe'         : '100000',
            'haber'        : '',
            'nombreCuenta' : 'Mercaderías Exentas',
            'subcuenta'    : '',
          },
          <String, String>{
            'concepto'     : 'Compra de mercadería',
            'cuenta'       : '1.01.01',
            'debe'         : '',
            'haber'        : '520000',
            'nombreCuenta' : 'Caja',
            'subcuenta'    : '',
          },
        ],
        'enviarMarangatu'    : ClaseSiNo.no,
        'esFacturaElectronica': ClaseSiNo.no,
        'exentas'            : '100000',
        'fecha'              : '20/02/2026',
        'gravadas10'         : '0',
        'gravadas5'          : '400000',
        'hora'               : '',
        'importeExento'      : '100000',
        'importeGravado10'   : '0',
        'importeGravado5'    : '420000',
        'importeIreSimple'   : '0',
        'importeIrpSimple'   : '0',
        'importeNoImputable' : '0',
        'iva10'              : '0',
        'iva5'               : '20000',
        'mostrarEnLibro'     : ClaseSiNo.si,
        'numero'             : '001-001-0000456',
        'numeroAsiento'      : '5',
        'proveedor'          : 'Importadora Brasil Ltda.',
        'rucCedula'          : 'EX789012',
        'timbrado'           : '55667788',
        'tipoAfectacion'     : ClaseTipoAfectacion.indistinto,
        'tipoDocumento'      : '01',
        'tipoIdentificacion' : ClaseTipoIdentificacion.cedulaExtranjera,
        'total'              : '520000',
        'totalComprobante'   : '520000',
        'vigenteDesde'       : '',
        'vigenteHasta'       : '',
      },
    ];
  }

}
