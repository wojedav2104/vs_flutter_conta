import 'package:flutter/material.dart';

import '../../generales/idiomas/idiomas.dart';
import '../../generales/modelos/campo_abm.dart';
import '../../generales/preferencias/preferencias.dart';
import '../../generales/utilitarios/formatos.dart';
import '../../generales/validaciones/cap_validar.dart';
import '../../generales/widgets/formulario_cabecera_detalle.dart';


/// Pantalla de Libro Compras (ABM cabecera/detalle).
///
/// Grupo 1 "Generales": campos de cabecera + grilla de detalles + comentarios.
/// Grupo 2 "Resolución 90/2021": importes para Marangatú.
/// Punto 21: grilla lateral solo muestra los 6 campos más importantes.
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
  late final List<ClaseCampoAbm>        listCamposPie;
  late final List<Map<String, dynamic>> listRegistros;

  @override
  void initState() {
    super.initState();
    listCamposCabecera = crearCamposCabecera();
    listCamposDetalle  = crearCamposDetalle();
    listCamposPie      = crearCamposPie();
    listRegistros      = crearRegistrosPrueba();
  }

  @override
  Widget build(BuildContext oContexto) {
    return ClaseFormularioCabeceraDetalle(
      funcActualizarCampos : actualizarCampos,
      funcValidarRegistro  : validarRegistro,
      listCamposCabecera   : listCamposCabecera,
      listCamposDetalle    : listCamposDetalle,
      listCamposPie        : listCamposPie,
      listRegistros        : listRegistros,
      oPreferencias        : widget.oPreferencias,
      sTitulo              : ClaseIdiomas.getTexto(
                               widget.oPreferencias.getIdioma(), 'menuLibroCompras'),
    );
  }

  String getIdioma() => widget.oPreferencias.getIdioma();

  // ── Auto-cálculo ────────────────────────────────────────────────────────

  Map<String, String>? actualizarCampos(Map<String, String> mapValores) {
    final Map<String, String> mapCambio = <String, String>{};

    final int iGravadas10 = funcParsearEnteroMiles(mapValores['gravadas10'] ?? '');
    final int iIva10      = funcParsearEnteroMiles(mapValores['iva10']      ?? '');
    final int iGravadas5  = funcParsearEnteroMiles(mapValores['gravadas5']  ?? '');
    final int iIva5       = funcParsearEnteroMiles(mapValores['iva5']       ?? '');
    final int iExentas    = funcParsearEnteroMiles(mapValores['exentas']    ?? '');

    // Total del Grupo 1
    final int iTotal = iGravadas10 + iIva10 + iGravadas5 + iIva5 + iExentas;
    mapCambio['total'] = (iTotal == 0) ? '' : funcFormatearEnteroMiles(iTotal);

    // Importes iniciales del Grupo 2
    final int iEsperadoGravado10 = iGravadas10 + iIva10;
    final int iEsperadoGravado5  = iGravadas5  + iIva5;
    final int iEsperadoExento    = iExentas;

    final int iActualGravado10 = funcParsearEnteroMiles(mapValores['importeGravado10'] ?? '');
    final int iActualGravado5  = funcParsearEnteroMiles(mapValores['importeGravado5']  ?? '');
    final int iActualExento    = funcParsearEnteroMiles(mapValores['importeExento']    ?? '');

    if (iActualGravado10 == 0 || iActualGravado10 == iEsperadoGravado10) {
      mapCambio['importeGravado10'] =
          (iEsperadoGravado10 == 0) ? '' : funcFormatearEnteroMiles(iEsperadoGravado10);
    }
    if (iActualGravado5 == 0 || iActualGravado5 == iEsperadoGravado5) {
      mapCambio['importeGravado5'] =
          (iEsperadoGravado5 == 0) ? '' : funcFormatearEnteroMiles(iEsperadoGravado5);
    }
    if (iActualExento == 0 || iActualExento == iEsperadoExento) {
      mapCambio['importeExento'] =
          (iEsperadoExento == 0) ? '' : funcFormatearEnteroMiles(iEsperadoExento);
    }

    // Total del comprobante
    final int iImpGravado10 = funcParsearEnteroMiles(
        mapCambio['importeGravado10'] ?? mapValores['importeGravado10'] ?? '');
    final int iImpGravado5 = funcParsearEnteroMiles(
        mapCambio['importeGravado5'] ?? mapValores['importeGravado5'] ?? '');
    final int iImpExento = funcParsearEnteroMiles(
        mapCambio['importeExento'] ?? mapValores['importeExento'] ?? '');
    final int iImpIre   = funcParsearEnteroMiles(mapValores['importeIreSimple']   ?? '');
    final int iImpIrp   = funcParsearEnteroMiles(mapValores['importeIrpSimple']   ?? '');
    final int iImpNoImp = funcParsearEnteroMiles(mapValores['importeNoImputable'] ?? '');

    final int iTotalComprobante =
        iImpGravado10 + iImpGravado5 + iImpExento + iImpIre + iImpIrp + iImpNoImp;
    mapCambio['totalComprobante'] =
        (iTotalComprobante == 0) ? '' : funcFormatearEnteroMiles(iTotalComprobante);

    // Cantidad de cuotas: 0 si no es Factura Crédito
    final String sTipoDoc = mapValores['tipoDocumento'] ?? '';
    if (sTipoDoc != ClaseIdiomas.getTexto(getIdioma(), 'comTipoDoc02')) {
      mapCambio['cantidadCuotas'] = '0';
    }

    return mapCambio.isEmpty ? null : mapCambio;
  }

  // ── Validación cruzada ──────────────────────────────────────────────────

  String? validarRegistro(Map<String, dynamic> oRegistro) {
    final String sIdioma = getIdioma();

    final String sEjercicio = (oRegistro['ejercicio'] ?? '').toString().trim();
    final String sFecha     = (oRegistro['fechaCompra'] ?? '').toString().trim();
    final int?   iEjercicio = int.tryParse(sEjercicio);
    if (iEjercicio != null && sFecha.isNotEmpty) {
      final String? sErrorFecha = ClaseCapValidar.validarFechaCompra(
          sFecha, ClaseIdiomas.getTexto(sIdioma, 'comFecha'), iEjercicio, sIdioma);
      if (sErrorFecha != null) return sErrorFecha;
    }

    final String sTipoDoc = (oRegistro['tipoDocumento'] ?? '').toString().trim();
    final String sNumero  = (oRegistro['numeroDocumento'] ?? '').toString().trim();
    final bool bConMascara = esTipoDocumentoConMascara(sTipoDoc);
    if (sNumero.isNotEmpty) {
      if (bConMascara) {
        if (!RegExp(r'^\d{3}-\d{3}-\d{7}$').hasMatch(sNumero)) {
          return ClaseIdiomas.getTexto(sIdioma, 'comErrorNumeroFormato');
        }
      } else {
        if (!RegExp(r'^[A-Z0-9]+$').hasMatch(sNumero)) {
          return ClaseIdiomas.getTexto(sIdioma, 'comErrorNumeroFormato');
        }
      }
    }

    final String sTimbrado = (oRegistro['timbradoNumero'] ?? '').toString().trim();
    if (bConMascara) {
      if (sTimbrado.isEmpty) {
        return ClaseIdiomas.getTexto(sIdioma, 'comErrorTimbrado');
      }
      if (!RegExp(r'^\d{8}$').hasMatch(sTimbrado)) {
        return ClaseIdiomas.getTexto(sIdioma, 'comErrorTimbrado');
      }
    }

    final String sMarangatu = (oRegistro['enviarMarangatu'] ?? '').toString().trim();
    if (sMarangatu != ClaseIdiomas.getTexto(sIdioma, 'comNo')) {
      final int iTotalComprobante =
          funcParsearEnteroMiles((oRegistro['totalComprobante'] ?? '').toString());
      final int iSumaDebe =
          int.tryParse((oRegistro['_sumaDebe'] ?? '0').toString()) ?? 0;
      if (iTotalComprobante != iSumaDebe) {
        return ClaseIdiomas.getTexto(sIdioma, 'comErrorMarangatu');
      }
    }

    return null;
  }

  bool esTipoDocumentoConMascara(String sTipoDoc) {
    if (sTipoDoc.isEmpty) return false;
    final String sIdioma = getIdioma();
    return sTipoDoc == ClaseIdiomas.getTexto(sIdioma, 'comTipoDoc01') ||
           sTipoDoc == ClaseIdiomas.getTexto(sIdioma, 'comTipoDoc02') ||
           sTipoDoc == ClaseIdiomas.getTexto(sIdioma, 'comTipoDoc03') ||
           sTipoDoc == ClaseIdiomas.getTexto(sIdioma, 'comTipoDoc04') ||
           sTipoDoc == ClaseIdiomas.getTexto(sIdioma, 'comTipoDoc06') ||
           sTipoDoc == ClaseIdiomas.getTexto(sIdioma, 'comTipoDoc09') ||
           sTipoDoc == ClaseIdiomas.getTexto(sIdioma, 'comTipoDoc10');
  }

  bool esFacturaCredito(String sTipoDoc) {
    return sTipoDoc == ClaseIdiomas.getTexto(getIdioma(), 'comTipoDoc02');
  }

  // ── Campos de cabecera ──────────────────────────────────────────────────
  // Punto 21: solo 6 campos visibles en la grilla lateral (bEnGrilla = true):
  //   ejercicio, fechaCompra, tipoDocumento, numeroDocumento, proveedor, total
  // Los demás 25 campos tienen bEnGrilla : false.

  List<ClaseCampoAbm> crearCamposCabecera() {
    final String sIdioma = getIdioma();
    return <ClaseCampoAbm>[
      // ════════════════════════════════════════════════════════════════════
      // Grupo 1: Generales
      // ════════════════════════════════════════════════════════════════════
      ClaseCampoAbm(
        bObligatorio     : true,
        funcValidarCampo : (sValor) => ClaseCapValidar.validarEjercicio(
            sValor, ClaseIdiomas.getTexto(sIdioma, 'planEjercicio'), sIdioma),
        iAnchoCaracteres : 4,
        oTipo            : EnumTipoCampoAbm.numero,
        sClave           : 'ejercicio',
        sEtiqueta        : ClaseIdiomas.getTexto(sIdioma, 'planEjercicio'),
        sGrupo           : 'comGenerales',
      ),
      ClaseCampoAbm(
        bEnGrilla        : false,
        bObligatorio     : true,
        iAnchoCaracteres : 44,
        oTipo            : EnumTipoCampoAbm.texto,
        sClave           : 'sucursal',
        sEtiqueta        : ClaseIdiomas.getTexto(sIdioma, 'ctaSucursal'),
        sGrupo           : 'comGenerales',
      ),
      ClaseCampoAbm(
        bObligatorio     : true,
        iAnchoCaracteres : 10,
        oTipo            : EnumTipoCampoAbm.fecha,
        sClave           : 'fechaCompra',
        sEtiqueta        : ClaseIdiomas.getTexto(sIdioma, 'comFecha'),
        sGrupo           : 'comGenerales',
      ),
      ClaseCampoAbm(
        bEnGrilla        : false,
        bObligatorio     : true,
        iAnchoCaracteres : 5,
        oTipo            : EnumTipoCampoAbm.hora,
        sClave           : 'hora',
        sEtiqueta        : ClaseIdiomas.getTexto(sIdioma, 'comHora'),
        sGrupo           : 'comGenerales',
      ),
      ClaseCampoAbm(
        bEnGrilla             : false,
        bSiempreDeshabilitado : true,
        iAnchoCaracteres      : 6,
        oTipo                 : EnumTipoCampoAbm.numero,
        sClave                : 'numeroAsiento',
        sEtiqueta             : ClaseIdiomas.getTexto(sIdioma, 'comNumeroAsiento'),
        sGrupo                : 'comGenerales',
      ),
      ClaseCampoAbm(
        bObligatorio     : true,
        iAnchoCaracteres : 35,
        listOpciones     : <String>[
          ClaseIdiomas.getTexto(sIdioma, 'comTipoDoc01'),
          ClaseIdiomas.getTexto(sIdioma, 'comTipoDoc02'),
          ClaseIdiomas.getTexto(sIdioma, 'comTipoDoc03'),
          ClaseIdiomas.getTexto(sIdioma, 'comTipoDoc04'),
          ClaseIdiomas.getTexto(sIdioma, 'comTipoDoc05'),
          ClaseIdiomas.getTexto(sIdioma, 'comTipoDoc06'),
          ClaseIdiomas.getTexto(sIdioma, 'comTipoDoc07'),
          ClaseIdiomas.getTexto(sIdioma, 'comTipoDoc08'),
          ClaseIdiomas.getTexto(sIdioma, 'comTipoDoc09'),
          ClaseIdiomas.getTexto(sIdioma, 'comTipoDoc10'),
          ClaseIdiomas.getTexto(sIdioma, 'comTipoDoc11'),
          ClaseIdiomas.getTexto(sIdioma, 'comTipoDoc12'),
          ClaseIdiomas.getTexto(sIdioma, 'comTipoDoc13'),
          ClaseIdiomas.getTexto(sIdioma, 'comTipoDoc14'),
          ClaseIdiomas.getTexto(sIdioma, 'comTipoDoc15'),
          ClaseIdiomas.getTexto(sIdioma, 'comTipoDoc16'),
          ClaseIdiomas.getTexto(sIdioma, 'comTipoDoc17'),
          ClaseIdiomas.getTexto(sIdioma, 'comTipoDoc18'),
        ],
        oTipo            : EnumTipoCampoAbm.lista,
        sClave           : 'tipoDocumento',
        sEtiqueta        : ClaseIdiomas.getTexto(sIdioma, 'comTipoDocumento'),
        sGrupo           : 'comGenerales',
      ),
      ClaseCampoAbm(
        bObligatorio     : true,
        iAnchoCaracteres : 16,
        oTipo            : EnumTipoCampoAbm.texto,
        sClave           : 'numeroDocumento',
        sEtiqueta        : ClaseIdiomas.getTexto(sIdioma, 'comNumero'),
        sGrupo           : 'comGenerales',
      ),
      ClaseCampoAbm(
        bEnGrilla        : false,
        bObligatorio     : true,
        funcActualizarEstado : (mapValores) =>
            esFacturaCredito(mapValores['tipoDocumento'] ?? ''),
        funcValidarCampo : (sValor) =>
            ClaseCapValidar.validarNoNegativo(
                sValor, ClaseIdiomas.getTexto(getIdioma(), 'comCantidadCuotas'), getIdioma()),
        iAnchoCaracteres : 3,
        oTipo            : EnumTipoCampoAbm.numero,
        sClave           : 'cantidadCuotas',
        sEtiqueta        : ClaseIdiomas.getTexto(sIdioma, 'comCantidadCuotas'),
        sGrupo           : 'comGenerales',
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
        bEnGrilla             : false,
        bSiempreDeshabilitado : true,
        iAnchoCaracteres      : 20,
        listOpciones          : <String>[
          ClaseIdiomas.getTexto(sIdioma, 'comIdentRuc'),
          ClaseIdiomas.getTexto(sIdioma, 'comIdentCedula'),
          ClaseIdiomas.getTexto(sIdioma, 'comIdentPasaporte'),
          ClaseIdiomas.getTexto(sIdioma, 'comIdentCedulaExt'),
          ClaseIdiomas.getTexto(sIdioma, 'comIdentSinNombre'),
          ClaseIdiomas.getTexto(sIdioma, 'comIdentDiplomatico'),
        ],
        oTipo                 : EnumTipoCampoAbm.lista,
        sClave                : 'tipoIdentificacion',
        sEtiqueta             : ClaseIdiomas.getTexto(sIdioma, 'comTipoIdentificacion'),
        sGrupo                : 'comGenerales',
      ),
      ClaseCampoAbm(
        bEnGrilla             : false,
        bSiempreDeshabilitado : true,
        iAnchoCaracteres      : 10,
        oTipo                 : EnumTipoCampoAbm.texto,
        sClave                : 'rucCedula',
        sEtiqueta             : ClaseIdiomas.getTexto(sIdioma, 'comRucCedula'),
        sGrupo                : 'comGenerales',
      ),
      ClaseCampoAbm(
        bEnGrilla          : false,
        funcActualizarEstado : (mapValores) =>
            esTipoDocumentoConMascara(mapValores['tipoDocumento'] ?? ''),
        funcValidarCampo : (sValor) {
          if (sValor.isEmpty) return null;
          if (!RegExp(r'^\d{8}$').hasMatch(sValor)) {
            return ClaseIdiomas.getTexto(getIdioma(), 'comErrorTimbrado');
          }
          return null;
        },
        iAnchoCaracteres : 8,
        oTipo            : EnumTipoCampoAbm.texto,
        sClave           : 'timbradoNumero',
        sEtiqueta        : ClaseIdiomas.getTexto(sIdioma, 'comTimbrado'),
        sGrupo           : 'comGenerales',
      ),
      ClaseCampoAbm(
        bEnGrilla             : false,
        bSiempreDeshabilitado : true,
        iAnchoCaracteres      : 10,
        oTipo                 : EnumTipoCampoAbm.fecha,
        sClave                : 'vigenteDesde',
        sEtiqueta             : ClaseIdiomas.getTexto(sIdioma, 'comVigenteDesde'),
        sGrupo                : 'comGenerales',
      ),
      ClaseCampoAbm(
        bEnGrilla             : false,
        bSiempreDeshabilitado : true,
        iAnchoCaracteres      : 10,
        oTipo                 : EnumTipoCampoAbm.fecha,
        sClave                : 'vigenteHasta',
        sEtiqueta             : ClaseIdiomas.getTexto(sIdioma, 'comVigenteHasta'),
        sGrupo                : 'comGenerales',
      ),
      ClaseCampoAbm(
        bEnGrilla        : false,
        iAnchoCaracteres : 5,
        listOpciones     : <String>[
          ClaseIdiomas.getTexto(sIdioma, 'comSi'),
          ClaseIdiomas.getTexto(sIdioma, 'comNo'),
        ],
        oTipo            : EnumTipoCampoAbm.lista,
        sClave           : 'esFacturaElectronica',
        sEtiqueta        : ClaseIdiomas.getTexto(sIdioma, 'comEsFacturaElectronica'),
        sGrupo           : 'comGenerales',
      ),
      ClaseCampoAbm(
        bEnGrilla        : false,
        funcValidarCampo : (sValor) => ClaseCapValidar.validarNoNegativo(
            sValor, ClaseIdiomas.getTexto(getIdioma(), 'comGravadas10'), getIdioma()),
        iAnchoCaracteres : 15,
        oTipo            : EnumTipoCampoAbm.numero,
        sClave           : 'gravadas10',
        sEtiqueta        : ClaseIdiomas.getTexto(sIdioma, 'comGravadas10'),
        sGrupo           : 'comGenerales',
        sMascara         : '999.999.999.999',
      ),
      ClaseCampoAbm(
        bEnGrilla        : false,
        funcValidarCampo : (sValor) => ClaseCapValidar.validarNoNegativo(
            sValor, ClaseIdiomas.getTexto(getIdioma(), 'comIva10'), getIdioma()),
        iAnchoCaracteres : 15,
        oTipo            : EnumTipoCampoAbm.numero,
        sClave           : 'iva10',
        sEtiqueta        : ClaseIdiomas.getTexto(sIdioma, 'comIva10'),
        sGrupo           : 'comGenerales',
        sMascara         : '999.999.999.999',
      ),
      ClaseCampoAbm(
        bEnGrilla        : false,
        funcValidarCampo : (sValor) => ClaseCapValidar.validarNoNegativo(
            sValor, ClaseIdiomas.getTexto(getIdioma(), 'comGravadas5'), getIdioma()),
        iAnchoCaracteres : 15,
        oTipo            : EnumTipoCampoAbm.numero,
        sClave           : 'gravadas5',
        sEtiqueta        : ClaseIdiomas.getTexto(sIdioma, 'comGravadas5'),
        sGrupo           : 'comGenerales',
        sMascara         : '999.999.999.999',
      ),
      ClaseCampoAbm(
        bEnGrilla        : false,
        funcValidarCampo : (sValor) => ClaseCapValidar.validarNoNegativo(
            sValor, ClaseIdiomas.getTexto(getIdioma(), 'comIva5'), getIdioma()),
        iAnchoCaracteres : 15,
        oTipo            : EnumTipoCampoAbm.numero,
        sClave           : 'iva5',
        sEtiqueta        : ClaseIdiomas.getTexto(sIdioma, 'comIva5'),
        sGrupo           : 'comGenerales',
        sMascara         : '999.999.999.999',
      ),
      ClaseCampoAbm(
        bEnGrilla        : false,
        funcValidarCampo : (sValor) => ClaseCapValidar.validarNoNegativo(
            sValor, ClaseIdiomas.getTexto(getIdioma(), 'comExentas'), getIdioma()),
        iAnchoCaracteres : 15,
        oTipo            : EnumTipoCampoAbm.numero,
        sClave           : 'exentas',
        sEtiqueta        : ClaseIdiomas.getTexto(sIdioma, 'comExentas'),
        sGrupo           : 'comGenerales',
        sMascara         : '999.999.999.999',
      ),
      ClaseCampoAbm(
        bSiempreDeshabilitado : true,
        iAnchoCaracteres      : 15,
        oTipo                 : EnumTipoCampoAbm.numero,
        sClave                : 'total',
        sEtiqueta             : ClaseIdiomas.getTexto(sIdioma, 'comTotal'),
        sGrupo                : 'comGenerales',
        sMascara              : '999.999.999.999',
      ),
      ClaseCampoAbm(
        bEnGrilla        : false,
        iAnchoCaracteres : 25,
        listOpciones     : <String>[
          ClaseIdiomas.getTexto(sIdioma, 'comAfectDirecto'),
          ClaseIdiomas.getTexto(sIdioma, 'comAfectIndistinto'),
          ClaseIdiomas.getTexto(sIdioma, 'comAfectExportacion'),
          ClaseIdiomas.getTexto(sIdioma, 'comAfectImportacion'),
        ],
        oTipo            : EnumTipoCampoAbm.lista,
        sClave           : 'tipoAfectacion',
        sEtiqueta        : ClaseIdiomas.getTexto(sIdioma, 'comTipoAfectacion'),
        sGrupo           : 'comGenerales',
      ),
      ClaseCampoAbm(
        bEnGrilla        : false,
        iAnchoCaracteres : 5,
        listOpciones     : <String>[
          ClaseIdiomas.getTexto(sIdioma, 'comSi'),
          ClaseIdiomas.getTexto(sIdioma, 'comNo'),
        ],
        oTipo            : EnumTipoCampoAbm.lista,
        sClave           : 'mostrarEnLibro',
        sEtiqueta        : ClaseIdiomas.getTexto(sIdioma, 'comMostrarEnLibro'),
        sGrupo           : 'comGenerales',
      ),

      // ════════════════════════════════════════════════════════════════════
      // Grupo 2: Resolución 90/2021
      // ════════════════════════════════════════════════════════════════════
      ClaseCampoAbm(
        bEnGrilla        : false,
        iAnchoCaracteres : 5,
        listOpciones     : <String>[
          ClaseIdiomas.getTexto(sIdioma, 'comSi'),
          ClaseIdiomas.getTexto(sIdioma, 'comNo'),
        ],
        oTipo            : EnumTipoCampoAbm.lista,
        sClave           : 'enviarMarangatu',
        sEtiqueta        : ClaseIdiomas.getTexto(sIdioma, 'comEnviarMarangatu'),
        sGrupo           : 'comResolucion',
      ),
      ClaseCampoAbm(
        bEnGrilla        : false,
        iAnchoCaracteres : 15,
        oTipo            : EnumTipoCampoAbm.numero,
        sClave           : 'importeGravado10',
        sEtiqueta        : ClaseIdiomas.getTexto(sIdioma, 'comImporteGravado10'),
        sGrupo           : 'comResolucion',
        sMascara         : '999.999.999.999',
      ),
      ClaseCampoAbm(
        bEnGrilla        : false,
        iAnchoCaracteres : 15,
        oTipo            : EnumTipoCampoAbm.numero,
        sClave           : 'importeGravado5',
        sEtiqueta        : ClaseIdiomas.getTexto(sIdioma, 'comImporteGravado5'),
        sGrupo           : 'comResolucion',
        sMascara         : '999.999.999.999',
      ),
      ClaseCampoAbm(
        bEnGrilla        : false,
        iAnchoCaracteres : 15,
        oTipo            : EnumTipoCampoAbm.numero,
        sClave           : 'importeExento',
        sEtiqueta        : ClaseIdiomas.getTexto(sIdioma, 'comImporteExento'),
        sGrupo           : 'comResolucion',
        sMascara         : '999.999.999.999',
      ),
      ClaseCampoAbm(
        bEnGrilla        : false,
        funcValidarCampo : (sValor) => ClaseCapValidar.validarNoNegativo(
            sValor, ClaseIdiomas.getTexto(getIdioma(), 'comImporteIreSimple'), getIdioma()),
        iAnchoCaracteres : 15,
        oTipo            : EnumTipoCampoAbm.numero,
        sClave           : 'importeIreSimple',
        sEtiqueta        : ClaseIdiomas.getTexto(sIdioma, 'comImporteIreSimple'),
        sGrupo           : 'comResolucion',
        sMascara         : '999.999.999.999',
      ),
      ClaseCampoAbm(
        bEnGrilla        : false,
        funcValidarCampo : (sValor) => ClaseCapValidar.validarNoNegativo(
            sValor, ClaseIdiomas.getTexto(getIdioma(), 'comImporteIrpSimple'), getIdioma()),
        iAnchoCaracteres : 15,
        oTipo            : EnumTipoCampoAbm.numero,
        sClave           : 'importeIrpSimple',
        sEtiqueta        : ClaseIdiomas.getTexto(sIdioma, 'comImporteIrpSimple'),
        sGrupo           : 'comResolucion',
        sMascara         : '999.999.999.999',
      ),
      ClaseCampoAbm(
        bEnGrilla        : false,
        funcValidarCampo : (sValor) => ClaseCapValidar.validarNoNegativo(
            sValor, ClaseIdiomas.getTexto(getIdioma(), 'comImporteNoImputable'), getIdioma()),
        iAnchoCaracteres : 15,
        oTipo            : EnumTipoCampoAbm.numero,
        sClave           : 'importeNoImputable',
        sEtiqueta        : ClaseIdiomas.getTexto(sIdioma, 'comImporteNoImputable'),
        sGrupo           : 'comResolucion',
        sMascara         : '999.999.999.999',
      ),
      ClaseCampoAbm(
        bEnGrilla             : false,
        bSiempreDeshabilitado : true,
        iAnchoCaracteres      : 15,
        oTipo                 : EnumTipoCampoAbm.numero,
        sClave                : 'totalComprobante',
        sEtiqueta             : ClaseIdiomas.getTexto(sIdioma, 'comTotalComprobante'),
        sGrupo                : 'comResolucion',
        sMascara              : '999.999.999.999',
      ),
    ];
  }

  // ── Campos de detalle ───────────────────────────────────────────────────

  List<ClaseCampoAbm> crearCamposDetalle() {
    final String sIdioma = getIdioma();
    return <ClaseCampoAbm>[
      ClaseCampoAbm(
        funcValidarCampo : (sValor) => ClaseCapValidar.validarFormatoCuenta(
            sValor, ClaseIdiomas.getTexto(sIdioma, 'asiCuenta'), sIdioma),
        iAnchoCaracteres : 16,
        oTipo            : EnumTipoCampoAbm.texto,
        sClave           : 'cuentaNumero',
        sEtiqueta        : ClaseIdiomas.getTexto(sIdioma, 'asiCuenta'),
        sHint            : ClaseIdiomas.getTexto(sIdioma, 'comHintCuenta'),
      ),
      ClaseCampoAbm(
        funcValidarCampo : (sValor) => ClaseCapValidar.validarNumeroSubcuenta(
            sValor, ClaseIdiomas.getTexto(sIdioma, 'asiSubcuenta'), sIdioma),
        iAnchoCaracteres : 5,
        oTipo            : EnumTipoCampoAbm.texto,
        sClave           : 'subcuenta',
        sEtiqueta        : ClaseIdiomas.getTexto(sIdioma, 'asiSubcuenta'),
        sHint            : ClaseIdiomas.getTexto(sIdioma, 'asiHintSubcuenta'),
      ),
      ClaseCampoAbm(
        bObligatorio     : true,
        funcValidarCampo : (sValor) => ClaseCapValidar.validarObligatorio(
            sValor, ClaseIdiomas.getTexto(sIdioma, 'asiNombreCuenta'), sIdioma),
        iAnchoCaracteres : 40,
        oTipo            : EnumTipoCampoAbm.texto,
        sClave           : 'nombreCuenta',
        sEtiqueta        : ClaseIdiomas.getTexto(sIdioma, 'asiNombreCuenta'),
        sHint            : ClaseIdiomas.getTexto(sIdioma, 'comHintNombreCuenta'),
      ),
      ClaseCampoAbm(
        bObligatorio     : true,
        funcValidarCampo : (sValor) => ClaseCapValidar.validarObligatorio(
            sValor, ClaseIdiomas.getTexto(sIdioma, 'asiDebe'), sIdioma),
        iAnchoCaracteres : 15,
        oTipo            : EnumTipoCampoAbm.numero,
        sClave           : 'debe',
        sEtiqueta        : ClaseIdiomas.getTexto(sIdioma, 'asiDebe'),
        sMascara         : '999.999.999.999',
      ),
      ClaseCampoAbm(
        bObligatorio     : true,
        funcValidarCampo : (sValor) => ClaseCapValidar.validarObligatorio(
            sValor, ClaseIdiomas.getTexto(sIdioma, 'asiHaber'), sIdioma),
        iAnchoCaracteres : 15,
        oTipo            : EnumTipoCampoAbm.numero,
        sClave           : 'haber',
        sEtiqueta        : ClaseIdiomas.getTexto(sIdioma, 'asiHaber'),
        sMascara         : '999.999.999.999',
      ),
      ClaseCampoAbm(
        iAnchoCaracteres : 60,
        oTipo            : EnumTipoCampoAbm.texto,
        sClave           : 'concepto',
        sEtiqueta        : ClaseIdiomas.getTexto(sIdioma, 'asiConcepto'),
        sHint            : ClaseIdiomas.getTexto(sIdioma, 'asiHintConcepto'),
      ),
    ];
  }

  // ── Campos de pie ───────────────────────────────────────────────────────

  List<ClaseCampoAbm> crearCamposPie() {
    final String sIdioma = getIdioma();
    return <ClaseCampoAbm>[
      ClaseCampoAbm(
        iAnchoCaracteres : 500,
        iMaxComentario   : 500,
        oTipo            : EnumTipoCampoAbm.comentario,
        sClave           : 'comentarios',
        sEtiqueta        : ClaseIdiomas.getTexto(sIdioma, 'comComentarios'),
        sHint            : ClaseIdiomas.getTexto(sIdioma, 'comHintComentarios'),
      ),
    ];
  }

  // ── Datos de prueba ─────────────────────────────────────────────────────

  List<Map<String, dynamic>> crearRegistrosPrueba() {
    return <Map<String, dynamic>>[
      <String, dynamic>{
        'cantidadCuotas'       : '0',
        'comentarios'          : 'Compra de mercaderías para reventa',
        'ejercicio'            : '2026',
        'esFacturaElectronica' : 'Sí',
        'enviarMarangatu'      : 'Sí',
        'exentas'              : '0',
        'fechaCompra'          : '15/03/2026',
        'gravadas10'           : '1.500.000',
        'gravadas5'            : '0',
        'hora'                 : '10:30',
        'importeExento'        : '0',
        'importeGravado10'     : '1.650.000',
        'importeGravado5'      : '0',
        'importeIreSimple'     : '0',
        'importeIrpSimple'     : '0',
        'importeNoImputable'   : '0',
        'iva10'                : '150.000',
        'iva5'                 : '0',
        'mostrarEnLibro'       : 'Sí',
        'numeroAsiento'        : '000001',
        'numeroDocumento'      : '001-002-0003456',
        'proveedor'            : 'Distribuidora ABC S.A.',
        'rucCedula'            : '80012345-6',
        'sucursal'             : '0001 - Sucursal Central',
        'timbradoNumero'       : '12345678',
        'tipoAfectacion'       : 'Directo',
        'tipoDocumento'        : 'Factura Contado',
        'tipoIdentificacion'   : 'R.U.C.',
        'total'                : '1.650.000',
        'totalComprobante'     : '1.650.000',
        'vigenteDesde'         : '01/01/2026',
        'vigenteHasta'         : '31/12/2026',
        'detalles'             : <Map<String, dynamic>>[
          <String, dynamic>{
            'cuentaNumero' : '1.04',
            'subcuenta'    : '',
            'nombreCuenta' : 'Mercaderías',
            'debe'         : '1.500.000',
            'haber'        : '0',
            'concepto'     : 'Compra mercaderías marzo',
          },
          <String, dynamic>{
            'cuentaNumero' : '1.03',
            'subcuenta'    : '',
            'nombreCuenta' : 'IVA Crédito Fiscal',
            'debe'         : '150.000',
            'haber'        : '0',
            'concepto'     : 'IVA 10% compra',
          },
          <String, dynamic>{
            'cuentaNumero' : '2.01',
            'subcuenta'    : '',
            'nombreCuenta' : 'Proveedores',
            'debe'         : '0',
            'haber'        : '1.650.000',
            'concepto'     : 'Compra a crédito',
          },
        ],
      },
      <String, dynamic>{
        'cantidadCuotas'       : '0',
        'comentarios'          : 'Compra de servicios',
        'ejercicio'            : '2026',
        'esFacturaElectronica' : 'Sí',
        'enviarMarangatu'      : 'No',
        'exentas'              : '200.000',
        'fechaCompra'          : '20/04/2026',
        'gravadas10'           : '0',
        'gravadas5'            : '0',
        'hora'                 : '14:15',
        'importeExento'        : '200.000',
        'importeGravado10'     : '0',
        'importeGravado5'      : '0',
        'importeIreSimple'     : '0',
        'importeIrpSimple'     : '0',
        'importeNoImputable'   : '0',
        'iva10'                : '0',
        'iva5'                 : '0',
        'mostrarEnLibro'       : 'Sí',
        'numeroAsiento'        : '000002',
        'numeroDocumento'      : 'SVC-2026-0042',
        'proveedor'            : 'Servicios XYZ',
        'rucCedula'            : '1234567',
        'sucursal'             : '0001 - Sucursal Central',
        'timbradoNumero'       : '',
        'tipoAfectacion'       : 'Indistinto',
        'tipoDocumento'        : 'Control Interno',
        'tipoIdentificacion'   : 'Cédula de Identidad',
        'total'                : '200.000',
        'totalComprobante'     : '200.000',
        'vigenteDesde'         : '',
        'vigenteHasta'         : '',
        'detalles'             : <Map<String, dynamic>>[
          <String, dynamic>{
            'cuentaNumero' : '5.01',
            'subcuenta'    : '',
            'nombreCuenta' : 'Servicios',
            'debe'         : '200.000',
            'haber'        : '0',
            'concepto'     : 'Servicios de limpieza',
          },
          <String, dynamic>{
            'cuentaNumero' : '1.01',
            'subcuenta'    : '',
            'nombreCuenta' : 'Banco Nacional',
            'debe'         : '0',
            'haber'        : '200.000',
            'concepto'     : 'Pago servicios',
          },
        ],
      },
    ];
  }

}
