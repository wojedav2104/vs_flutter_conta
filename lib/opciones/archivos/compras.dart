import 'package:flutter/material.dart';

import '../../generales/idiomas/idiomas.dart';
import '../../generales/modelos/campo_abm.dart';
import '../../generales/modelos/documentos.dart';
import '../../generales/preferencias/preferencias.dart';
import '../../generales/utilitarios/formatos.dart';
import '../../generales/validaciones/cap_validar.dart';
import '../../generales/varios/listas.dart';
import '../../generales/widgets/formulario_cabecera_detalle.dart';

/// Pantalla de la tabla Libro Compras (cabecera + grilla editable de detalles).
///
/// Cabecera con tres grupos (Generales, Detalles y Resolución 90/2021): la
/// grilla editable de detalles se muestra en la pestaña Detalles, debajo de
/// los importes de solo lectura, y las filas del asiento generado quedan en
/// la clave 'detalles'.
///
/// Validaciones cruzadas (validarRegistro):
///   · La Fecha de la compra debe estar dentro del Ejercicio contable.
///   · Cantidad de cuotas: solo se escribe en Factura Crédito (1 a 240); en
///     los demás tipos está deshabilitada y vale 0.
///   · Timbrado: obligatorio de 8 dígitos solo cuando el Tipo de documento
///     lleva la máscara 999-999-9999999; en blanco y deshabilitado en los
///     demás casos.
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
      sClaveCampoAlPie     : 'comentarios',
      sGrupoConDetalles    : 'comDetalles',
      sTitulo              : ClaseIdiomas.getTexto('menuLibroCompras', getIdioma()),
    );
  }

  String getIdioma() => widget.oPreferencias.getIdioma();

  // ── Auto-cálculos de la cabecera ────────────────────────────────────────

  /// Auto-cálculos según la spec 02_03:
  ///   · Total (Grupo 1) = gravadas 10% + IVA 10% + gravadas 5% + IVA 5%
  ///     + exentas.
  ///   · Importe gravado 10%/5% y exento (Grupo 2): se sugieren solo si
  ///     están vacíos. I.R.E. Simple, I.R.P. Simple y no imputable son
  ///     manuales (inicialmente 0).
  ///   · Total del comprobante = suma de los 6 importes del Grupo 2.
  ///   · Cantidad de cuotas según el Tipo de documento: en Factura Crédito,
  ///     si está vacía o en 0 se coloca 1 (cualquier otro valor se respeta);
  ///     en los demás tipos vale 0.
  ///   · Timbrado en blanco cuando el Tipo de documento no lleva máscara.
  Map<String, String>? actualizarCampos(Map<String, String> mapValores) {

    final String sTipoDocumento = mapValores['tipoDocumento'] ?? '';

    final Map<String, String> mapActualizaciones = <String, String>{};

    // Cantidad de cuotas según el Tipo de documento.
    if (ClaseTipoDocumento.esFacturaCredito(sTipoDocumento)) {
      final String sCuotas = (mapValores['cantidadCuotas'] ?? '').trim();
      if (sCuotas.isEmpty || sCuotas == '0') {
        mapActualizaciones['cantidadCuotas'] = '1';
      }
    } else {
      mapActualizaciones['cantidadCuotas'] = '0';
    }

    // Timbrado: en blanco cuando el Tipo de documento no lleva máscara.
    if (!ClaseTipoDocumento.esConMascara(sTipoDocumento)) {
      mapActualizaciones['timbrado'] = '';
    }

    // Total del Grupo 1.
    final double dGravadas10 = funcParsearNumero(mapValores['gravadas10'] ?? '') ?? 0;
    final double dIva10      = funcParsearNumero(mapValores['iva10']      ?? '') ?? 0;
    final double dGravadas5  = funcParsearNumero(mapValores['gravadas5']  ?? '') ?? 0;
    final double dIva5       = funcParsearNumero(mapValores['iva5']       ?? '') ?? 0;
    final double dExentas    = funcParsearNumero(mapValores['exentas']    ?? '') ?? 0;
    final double dTotal      = dGravadas10 + dIva10 + dGravadas5 + dIva5 + dExentas;
    mapActualizaciones['total'] = funcFormatearNumeroPlano(dTotal);

    // Importes de la Resolución 90/2021: se sugieren solo si están vacíos.
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

    // Total del comprobante = suma de los 6 importes del Grupo 2
    // (con las sugerencias de arriba ya aplicadas).
    final String sGravado10 = mapActualizaciones['importeGravado10'] ?? (mapValores['importeGravado10'] ?? '');
    final String sGravado5  = mapActualizaciones['importeGravado5']  ?? (mapValores['importeGravado5']  ?? '');
    final String sExento    = mapActualizaciones['importeExento']    ?? (mapValores['importeExento']    ?? '');
    final double dComprobante =
        (funcParsearNumero(sGravado10)                      ?? 0) +
        (funcParsearNumero(sGravado5)                       ?? 0) +
        (funcParsearNumero(sExento)                         ?? 0) +
        (funcParsearNumero(mapValores['importeIreSimple']   ?? '') ?? 0) +
        (funcParsearNumero(mapValores['importeIrpSimple']   ?? '') ?? 0) +
        (funcParsearNumero(mapValores['importeNoImputable'] ?? '') ?? 0);
    mapActualizaciones['totalComprobante'] = funcFormatearNumeroPlano(dComprobante);

    return mapActualizaciones;
  }

  // ── Validación cruzada del registro completo ────────────────────────────

  String? validarRegistro(Map<String, dynamic> oRegistro) {

    final String sIdioma = getIdioma();

    // Fecha de la compra dentro del Ejercicio contable.
    final String? sErrorFecha = ClaseCapValidar.validarFechaEnEjercicio(
      (oRegistro['fecha']     ?? '').toString(),
      (oRegistro['ejercicio'] ?? '').toString(),
      ClaseIdiomas.getTexto('comFecha', sIdioma),
      sIdioma,
    );
    if (sErrorFecha != null) return sErrorFecha;

    final String sTipoDoc = (oRegistro['tipoDocumento'] ?? '').toString();

    // Cantidad de cuotas: solo se escribe en Factura Crédito (1 a 240).
    // En los demás tipos el campo está deshabilitado y vale 0.
    final String sCuotas = (oRegistro['cantidadCuotas'] ?? '').toString().trim();
    if (ClaseTipoDocumento.esFacturaCredito(sTipoDoc)) {
      if (sCuotas.isEmpty) {
        return ClaseCapValidar.validarObligatorio(sCuotas,
            ClaseIdiomas.getTexto('comCantidadCuotas', sIdioma), sIdioma);
      }
      final String? sErrorCuotas = ClaseCapValidar.validarRangoEntero(sCuotas,
          ClaseIdiomas.getTexto('comCantidadCuotas', sIdioma), 1, 240, sIdioma);
      if (sErrorCuotas != null) return sErrorCuotas;
    }

    // Timbrado: obligatorio de 8 dígitos solo si el Tipo de documento lleva
    // la máscara 999-999-9999999; en blanco y deshabilitado en los demás casos.
    final String sTimbrado = (oRegistro['timbrado'] ?? '').toString();
    if (ClaseTipoDocumento.esConMascara(sTipoDoc)) {
      if (sTimbrado.trim().isEmpty) {
        return ClaseCapValidar.validarObligatorio(sTimbrado,
            ClaseIdiomas.getTexto('comTimbrado', sIdioma), sIdioma);
      }
      final String? sErrorTimbrado = ClaseCapValidar.validarDigitosExactos(sTimbrado,
          ClaseIdiomas.getTexto('comTimbrado', sIdioma), 8, sIdioma);
      if (sErrorTimbrado != null) return sErrorTimbrado;
    }

    // N° de documento según el Tipo de documento.
    final String? sErrorNumero = ClaseCapValidar.validarNumeroDocumentoPorTipo(
      (oRegistro['numero'] ?? '').toString(),
      sTipoDoc,
      ClaseIdiomas.getTexto('comNumero', sIdioma),
      sIdioma,
    );
    if (sErrorNumero != null) return sErrorNumero;

    // Identificación según el Tipo de identificación.
    final String? sErrorIdent = ClaseCapValidar.validarIdentificacion(
      (oRegistro['identificacion']      ?? '').toString(),
      (oRegistro['tipoIdentificacion']  ?? '').toString(),
      ClaseIdiomas.getTexto('comIdentificacion', sIdioma),
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
        return ClaseIdiomas.getTexto('comErrorMarangatu', sIdioma);
      }
    }
    return null;
  }

  // ── Campos de la cabecera ──────────────────────────────────────────────
  //
  // Orden visual = orden de declaración (la fila se coloca donde aparece su
  // primer campo; dentro de la fila, los campos van en orden de declaración).

  List<ClaseCampoAbm> crearCamposCabecera() {

    final String sIdioma = getIdioma();

    return <ClaseCampoAbm>[

      // ── Generales ──────────────────────────────────────────────────────
      ClaseCampoAbm(
        bObligatorio     : true,
        funcValidarCampo : (sValor, sIdioma) => ClaseCapValidar.validarEjercicio(
            sValor, ClaseIdiomas.getTexto('comEjercicio', sIdioma), sIdioma),
        iAnchoCaracteres : 4,
        iFila            : 1,
        oTipo            : EnumTipoCampoAbm.numero,
        sClave           : 'ejercicio',
        sEtiqueta        : ClaseIdiomas.getTexto('comEjercicio', sIdioma),
        sGrupo           : 'comGenerales',
      ),
      ClaseCampoAbm(
        bObligatorio     : true,
        iAnchoCaracteres : 44,
        iFila            : 1,
        oTipo            : EnumTipoCampoAbm.texto,
        sClave           : 'sucursal',
        sEtiqueta        : ClaseIdiomas.getTexto('comSucursal', sIdioma),
        sGrupo           : 'comGenerales',
        sHint            : ClaseIdiomas.getTexto('comHintSucursal', sIdioma),
      ),
      ClaseCampoAbm(
        bEnGrilla             : false,
        bSiempreDeshabilitado : true,
        iAnchoCaracteres      : 6,
        iFila                 : 1,
        oTipo                 : EnumTipoCampoAbm.numero,
        sClave                : 'numeroAsiento',
        sEtiqueta             : ClaseIdiomas.getTexto('comNumeroAsiento', sIdioma),
        sGrupo                : 'comGenerales',
      ),
      ClaseCampoAbm(
        bObligatorio     : true,
        funcValidarCampo : (sValor, sIdioma) => ClaseCapValidar.validarFechaNoAnterior(
            sValor, ClaseIdiomas.getTexto('comFecha', sIdioma),
            DateTime(ClaseFechas.iAnoMinimo, 1, 1), sIdioma),
        iAnchoCaracteres : 10,
        iFila            : 2,
        oTipo            : EnumTipoCampoAbm.fecha,
        sClave           : 'fecha',
        sEtiqueta        : ClaseIdiomas.getTexto('comFecha', sIdioma),
        sGrupo           : 'comGenerales',
      ),
      ClaseCampoAbm(
        bObligatorio     : true,
        funcValidarCampo : (sValor, sIdioma) => ClaseCapValidar.validarHoraValida(
            sValor, ClaseIdiomas.getTexto('comHora', sIdioma), sIdioma),
        iAnchoCaracteres : 5,
        iFila            : 2,
        oTipo            : EnumTipoCampoAbm.hora,
        sClave           : 'hora',
        sEtiqueta        : ClaseIdiomas.getTexto('comHora', sIdioma),
        sGrupo           : 'comGenerales',
      ),
      ClaseCampoAbm(
        bObligatorio     : true,
        iAnchoCaracteres : funcAnchoOpcion(ClaseTipoDocumento.getListOpciones(sIdioma)),
        iFila            : 3,
        listOpciones     : ClaseTipoDocumento.getListOpciones(sIdioma),
        listValores      : ClaseTipoDocumento.listValores,
        oTipo            : EnumTipoCampoAbm.lista,
        sClave           : 'tipoDocumento',
        sEtiqueta        : ClaseIdiomas.getTexto('comTipoDocumento', sIdioma),
        sGrupo           : 'comGenerales',
        sValorDefecto    : '01',
      ),
      ClaseCampoAbm(
        bMayusculas       : true,
        bObligatorio      : true,
        funcMascara       : (mapValores) => ClaseTipoDocumento.esConMascara(
            mapValores['tipoDocumento'] ?? '') ? ClaseTipoDocumento.sMascaraNumero : null,
        iAnchoCaracteres  : 16,
        iFila             : 3,
        oTipo             : EnumTipoCampoAbm.texto,
        sClave            : 'numero',
        sEtiqueta         : ClaseIdiomas.getTexto('comNumero', sIdioma),
        sGrupo            : 'comGenerales',
      ),
      ClaseCampoAbm(
        funcActualizarEstado : (mapValores) => ClaseTipoDocumento.esFacturaCredito(
            mapValores['tipoDocumento'] ?? ''),
        funcValidarCampo     : (sValor, sIdioma) => ClaseCapValidar.validarSoloEntero(
            sValor, ClaseIdiomas.getTexto('comCantidadCuotas', sIdioma), sIdioma),
        iAnchoCaracteres     : 3,
        oTipo                : EnumTipoCampoAbm.numero,
        sClave               : 'cantidadCuotas',
        sEtiqueta            : ClaseIdiomas.getTexto('comCantidadCuotas', sIdioma),
        sGrupo               : 'comGenerales',
        sValorDefecto        : '0',
      ),
      ClaseCampoAbm(
        bObligatorio     : true,
        iAnchoCaracteres : 48,
        iFila            : 4,
        oTipo            : EnumTipoCampoAbm.texto,
        sClave           : 'proveedor',
        sEtiqueta        : ClaseIdiomas.getTexto('comProveedor', sIdioma),
        sGrupo           : 'comGenerales',
        sHint            : ClaseIdiomas.getTexto('comHintProveedor', sIdioma),
      ),
      ClaseCampoAbm(
        iAnchoCaracteres : funcAnchoOpcion(ClaseTipoIdentificacion.getListOpciones(sIdioma)),
        iFila            : 4,
        listOpciones     : ClaseTipoIdentificacion.getListOpciones(sIdioma),
        listValores      : ClaseTipoIdentificacion.listValores,
        oTipo            : EnumTipoCampoAbm.lista,
        sClave           : 'tipoIdentificacion',
        sEtiqueta        : ClaseIdiomas.getTexto('comTipoIdentificacion', sIdioma),
        sGrupo           : 'comGenerales',
        sValorDefecto    : ClaseTipoIdentificacion.ruc,
      ),
      ClaseCampoAbm(
        bSiempreDeshabilitado : true,
        iAnchoCaracteres      : 15,
        iFila                 : 4,
        oTipo                 : EnumTipoCampoAbm.texto,
        sClave                : 'identificacion',
        sEtiqueta             : ClaseIdiomas.getTexto('comIdentificacion', sIdioma),
        sGrupo                : 'comGenerales',
      ),
      ClaseCampoAbm(
        funcActualizarEstado : (mapValores) => ClaseTipoDocumento.esConMascara(
            mapValores['tipoDocumento'] ?? ''),
        iAnchoCaracteres     : 8,
        iFila                : 5,
        oTipo                : EnumTipoCampoAbm.texto,
        sClave               : 'timbrado',
        sEtiqueta            : ClaseIdiomas.getTexto('comTimbrado', sIdioma),
        sGrupo               : 'comGenerales',
      ),
      ClaseCampoAbm(
        bSiempreDeshabilitado : true,
        iAnchoCaracteres      : 10,
        iFila                 : 5,
        oTipo                 : EnumTipoCampoAbm.fecha,
        sClave                : 'vigenteDesde',
        sEtiqueta             : ClaseIdiomas.getTexto('comVigenteDesde', sIdioma),
        sGrupo                : 'comGenerales',
      ),
      ClaseCampoAbm(
        bSiempreDeshabilitado : true,
        iAnchoCaracteres      : 10,
        iFila                 : 5,
        oTipo                 : EnumTipoCampoAbm.fecha,
        sClave                : 'vigenteHasta',
        sEtiqueta             : ClaseIdiomas.getTexto('comVigenteHasta', sIdioma),
        sGrupo                : 'comGenerales',
      ),
      ClaseCampoAbm(
        iAnchoCaracteres : funcAnchoOpcion(ClaseSiNo.getListOpciones(sIdioma)),
        iFila            : 6,
        listOpciones     : ClaseSiNo.getListOpciones(sIdioma),
        listValores      : ClaseSiNo.listValores,
        oTipo            : EnumTipoCampoAbm.lista,
        sClave           : 'esFacturaElectronica',
        sEtiqueta        : ClaseIdiomas.getTexto('comEsFacturaElectronica', sIdioma),
        sGrupo           : 'comGenerales',
        sValorDefecto    : ClaseSiNo.si,
      ),
      ClaseCampoAbm(
        bObligatorio     : true,
        iAnchoCaracteres : funcAnchoOpcion(ClaseTipoAfectacion.getListOpciones(sIdioma)),
        iFila            : 6,
        listOpciones     : ClaseTipoAfectacion.getListOpciones(sIdioma),
        listValores      : ClaseTipoAfectacion.listValores,
        oTipo            : EnumTipoCampoAbm.lista,
        sClave           : 'tipoAfectacion',
        sEtiqueta        : ClaseIdiomas.getTexto('comTipoAfectacion', sIdioma),
        sGrupo           : 'comGenerales',
        sValorDefecto    : ClaseTipoAfectacion.directo,
      ),
      ClaseCampoAbm(
        iAnchoCaracteres : funcAnchoOpcion(ClaseSiNo.getListOpciones(sIdioma)),
        iFila            : 6,
        listOpciones     : ClaseSiNo.getListOpciones(sIdioma),
        listValores      : ClaseSiNo.listValores,
        oTipo            : EnumTipoCampoAbm.lista,
        sClave           : 'mostrarEnLibro',
        sEtiqueta        : ClaseIdiomas.getTexto('comMostrarEnLibro', sIdioma),
        sGrupo           : 'comGenerales',
        sValorDefecto    : ClaseSiNo.si,
      ),
      ClaseCampoAbm(
        funcValidarCampo : (sValor, sIdioma) => ClaseCapValidar.validarImporteNoNegativo(
            sValor, ClaseIdiomas.getTexto('comExentas', sIdioma), sIdioma),
        iAnchoCaracteres : 15,
        iFila            : 7,
        oTipo            : EnumTipoCampoAbm.numero,
        sClave           : 'exentas',
        sEtiqueta        : ClaseIdiomas.getTexto('comExentas', sIdioma),
        sGrupo           : 'comGenerales',
        sMascara         : '999.999.999.999',
      ),
      ClaseCampoAbm(
        funcValidarCampo : (sValor, sIdioma) => ClaseCapValidar.validarImporteNoNegativo(
            sValor, ClaseIdiomas.getTexto('comGravadas10', sIdioma), sIdioma),
        iAnchoCaracteres : 15,
        iFila            : 8,
        oTipo            : EnumTipoCampoAbm.numero,
        sClave           : 'gravadas10',
        sEtiqueta        : ClaseIdiomas.getTexto('comGravadas10', sIdioma),
        sGrupo           : 'comGenerales',
        sMascara         : '999.999.999.999',
      ),
      ClaseCampoAbm(
        funcValidarCampo : (sValor, sIdioma) => ClaseCapValidar.validarImporteNoNegativo(
            sValor, ClaseIdiomas.getTexto('comIva10', sIdioma), sIdioma),
        iAnchoCaracteres : 15,
        iFila            : 9,
        oTipo            : EnumTipoCampoAbm.numero,
        sClave           : 'iva10',
        sEtiqueta        : ClaseIdiomas.getTexto('comIva10', sIdioma),
        sGrupo           : 'comGenerales',
        sMascara         : '999.999.999.999',
      ),
      ClaseCampoAbm(
        funcValidarCampo : (sValor, sIdioma) => ClaseCapValidar.validarImporteNoNegativo(
            sValor, ClaseIdiomas.getTexto('comGravadas5', sIdioma), sIdioma),
        iAnchoCaracteres : 15,
        iFila            : 10,
        oTipo            : EnumTipoCampoAbm.numero,
        sClave           : 'gravadas5',
        sEtiqueta        : ClaseIdiomas.getTexto('comGravadas5', sIdioma),
        sGrupo           : 'comGenerales',
        sMascara         : '999.999.999.999',
      ),
      ClaseCampoAbm(
        funcValidarCampo : (sValor, sIdioma) => ClaseCapValidar.validarImporteNoNegativo(
            sValor, ClaseIdiomas.getTexto('comIva5', sIdioma), sIdioma),
        iAnchoCaracteres : 15,
        iFila            : 11,
        oTipo            : EnumTipoCampoAbm.numero,
        sClave           : 'iva5',
        sEtiqueta        : ClaseIdiomas.getTexto('comIva5', sIdioma),
        sGrupo           : 'comGenerales',
        sMascara         : '999.999.999.999',
      ),
      ClaseCampoAbm(
        bSiempreDeshabilitado : true,
        iAnchoCaracteres      : 15,
        iFila                 : 12,
        oTipo                 : EnumTipoCampoAbm.numero,
        sClave                : 'total',
        sEtiqueta             : ClaseIdiomas.getTexto('comTotal', sIdioma),
        sGrupo                : 'comGenerales',
        sMascara              : '999.999.999.999',
      ),
      ClaseCampoAbm(
        iAnchoCaracteres : 60,
        iMaxComentario   : 500,
        oTipo            : EnumTipoCampoAbm.comentario,
        sClave           : 'comentarios',
        sEtiqueta        : ClaseIdiomas.getTexto('comComentarios', sIdioma),
        sGrupo           : 'comGenerales',
        sHint            : ClaseIdiomas.getTexto('comHintComentarios', sIdioma),
      ),

      // ── Detalles: los importes de las filas 7 a 12, solo de lectura ────
      // Mismas claves que en Generales (mismo valor); siempre deshabilitados
      // y fuera de la grilla lateral.
      ClaseCampoAbm(
        bEnGrilla             : false,
        bSiempreDeshabilitado : true,
        iAnchoCaracteres      : 15,
        iFila                 : 7,
        oTipo                 : EnumTipoCampoAbm.numero,
        sClave                : 'exentas',
        sEtiqueta             : ClaseIdiomas.getTexto('comExentas', sIdioma),
        sGrupo                : 'comDetalles',
        sMascara              : '999.999.999.999',
      ),
      ClaseCampoAbm(
        bEnGrilla             : false,
        bSiempreDeshabilitado : true,
        iAnchoCaracteres      : 15,
        iFila                 : 8,
        oTipo                 : EnumTipoCampoAbm.numero,
        sClave                : 'gravadas10',
        sEtiqueta             : ClaseIdiomas.getTexto('comGravadas10', sIdioma),
        sGrupo                : 'comDetalles',
        sMascara              : '999.999.999.999',
      ),
      ClaseCampoAbm(
        bEnGrilla             : false,
        bSiempreDeshabilitado : true,
        iAnchoCaracteres      : 15,
        iFila                 : 9,
        oTipo                 : EnumTipoCampoAbm.numero,
        sClave                : 'iva10',
        sEtiqueta             : ClaseIdiomas.getTexto('comIva10', sIdioma),
        sGrupo                : 'comDetalles',
        sMascara              : '999.999.999.999',
      ),
      ClaseCampoAbm(
        bEnGrilla             : false,
        bSiempreDeshabilitado : true,
        iAnchoCaracteres      : 15,
        iFila                 : 10,
        oTipo                 : EnumTipoCampoAbm.numero,
        sClave                : 'gravadas5',
        sEtiqueta             : ClaseIdiomas.getTexto('comGravadas5', sIdioma),
        sGrupo                : 'comDetalles',
        sMascara              : '999.999.999.999',
      ),
      ClaseCampoAbm(
        bEnGrilla             : false,
        bSiempreDeshabilitado : true,
        iAnchoCaracteres      : 15,
        iFila                 : 11,
        oTipo                 : EnumTipoCampoAbm.numero,
        sClave                : 'iva5',
        sEtiqueta             : ClaseIdiomas.getTexto('comIva5', sIdioma),
        sGrupo                : 'comDetalles',
        sMascara              : '999.999.999.999',
      ),
      ClaseCampoAbm(
        bEnGrilla             : false,
        bSiempreDeshabilitado : true,
        iAnchoCaracteres      : 15,
        iFila                 : 12,
        oTipo                 : EnumTipoCampoAbm.numero,
        sClave                : 'total',
        sEtiqueta             : ClaseIdiomas.getTexto('comTotal', sIdioma),
        sGrupo                : 'comDetalles',
        sMascara              : '999.999.999.999',
      ),

      // ── Resolución 90/2021 (sin cambios) ───────────────────────────────
      ClaseCampoAbm(
        iAnchoCaracteres : funcAnchoOpcion(ClaseSiNo.getListOpciones(sIdioma)),
        listOpciones     : ClaseSiNo.getListOpciones(sIdioma),
        listValores      : ClaseSiNo.listValores,
        oTipo            : EnumTipoCampoAbm.lista,
        sClave           : 'enviarMarangatu',
        sEtiqueta        : ClaseIdiomas.getTexto('comEnviarMarangatu', sIdioma),
        sGrupo           : 'comResolucion',
        sValorDefecto    : ClaseSiNo.si,
      ),
      ClaseCampoAbm(
        iAnchoCaracteres : 15,
        oTipo            : EnumTipoCampoAbm.numero,
        sClave           : 'importeGravado10',
        sEtiqueta        : ClaseIdiomas.getTexto('comImporteGravado10', sIdioma),
        sGrupo           : 'comResolucion',
        sMascara         : '999.999.999.999',
      ),
      ClaseCampoAbm(
        iAnchoCaracteres : 15,
        oTipo            : EnumTipoCampoAbm.numero,
        sClave           : 'importeGravado5',
        sEtiqueta        : ClaseIdiomas.getTexto('comImporteGravado5', sIdioma),
        sGrupo           : 'comResolucion',
        sMascara         : '999.999.999.999',
      ),
      ClaseCampoAbm(
        iAnchoCaracteres : 15,
        oTipo            : EnumTipoCampoAbm.numero,
        sClave           : 'importeExento',
        sEtiqueta        : ClaseIdiomas.getTexto('comImporteExento', sIdioma),
        sGrupo           : 'comResolucion',
        sMascara         : '999.999.999.999',
      ),
      ClaseCampoAbm(
        iAnchoCaracteres : 15,
        oTipo            : EnumTipoCampoAbm.numero,
        sClave           : 'importeIreSimple',
        sEtiqueta        : ClaseIdiomas.getTexto('comImporteIreSimple', sIdioma),
        sGrupo           : 'comResolucion',
        sMascara         : '999.999.999.999',
        sValorDefecto    : '0',
      ),
      ClaseCampoAbm(
        iAnchoCaracteres : 15,
        oTipo            : EnumTipoCampoAbm.numero,
        sClave           : 'importeIrpSimple',
        sEtiqueta        : ClaseIdiomas.getTexto('comImporteIrpSimple', sIdioma),
        sGrupo           : 'comResolucion',
        sMascara         : '999.999.999.999',
        sValorDefecto    : '0',
      ),
      ClaseCampoAbm(
        iAnchoCaracteres : 15,
        oTipo            : EnumTipoCampoAbm.numero,
        sClave           : 'importeNoImputable',
        sEtiqueta        : ClaseIdiomas.getTexto('comImporteNoImputable', sIdioma),
        sGrupo           : 'comResolucion',
        sMascara         : '999.999.999.999',
        sValorDefecto    : '0',
      ),
      ClaseCampoAbm(
        bSiempreDeshabilitado : true,
        iAnchoCaracteres      : 15,
        oTipo                 : EnumTipoCampoAbm.numero,
        sClave                : 'totalComprobante',
        sEtiqueta             : ClaseIdiomas.getTexto('comTotalComprobante', sIdioma),
        sGrupo                : 'comResolucion',
        sMascara              : '999.999.999.999',
      ),
    ];
  }

  // ── Columnas de la grilla de detalles ───────────────────────────────────

  List<ClaseCampoAbm> crearCamposDetalle() {

    final String sIdioma = getIdioma();

    return <ClaseCampoAbm>[
      ClaseCampoAbm(
        funcValidarCampo : (sValor, sIdioma) => ClaseCapValidar.validarFormatoCuenta(
            sValor, ClaseIdiomas.getTexto('detCuenta', sIdioma), sIdioma),
        iAnchoCaracteres : 16,
        oTipo            : EnumTipoCampoAbm.texto,
        sClave           : 'cuenta',
        sEtiqueta        : ClaseIdiomas.getTexto('detCuenta', sIdioma),
        sHint            : ClaseIdiomas.getTexto('comHintCuenta', sIdioma),
      ),
      ClaseCampoAbm(
        bCompletarCeros  : true,
        funcValidarCampo : (sValor, sIdioma) => ClaseCapValidar.validarNumeroSubcuenta(
            sValor, ClaseIdiomas.getTexto('detSubcuenta', sIdioma), sIdioma),
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
        sHint                 : ClaseIdiomas.getTexto('comHintNombreCuenta', sIdioma),
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
        iAnchoCaracteres : 60,
        iAnchoVisible    : 15,
        oTipo            : EnumTipoCampoAbm.texto,
        sClave           : 'concepto',
        sEtiqueta        : ClaseIdiomas.getTexto('detConcepto', sIdioma),
        sHint            : ClaseIdiomas.getTexto('detHintConcepto', sIdioma),
      ),
    ];
  }

  // ── Datos de prueba (se reemplazarán por Firebird) ──────────────────────

  List<Map<String, dynamic>> crearRegistrosPrueba() {
    return <Map<String, dynamic>>[
      <String, dynamic>{
        'cantidadCuotas'      : '3',
        'comentarios'         : 'Compra de mercadería para reventa',
        'detalles'            : <Map<String, String>>[
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
        'ejercicio'           : '2026',
        'enviarMarangatu'     : ClaseSiNo.si,
        'esFacturaElectronica': ClaseSiNo.si,
        'exentas'             : '0',
        'fecha'               : '10/02/2026',
        'gravadas10'          : '2000000',
        'gravadas5'           : '0',
        'hora'                : '10:30',
        'identificacion'      : '80098765-9',
        'importeExento'       : '0',
        'importeGravado10'    : '2200000',
        'importeGravado5'     : '0',
        'importeIreSimple'    : '0',
        'importeIrpSimple'    : '0',
        'importeNoImputable'  : '0',
        'iva10'               : '200000',
        'iva5'                : '0',
        'mostrarEnLibro'      : ClaseSiNo.si,
        'numero'              : '001-002-0000123',
        'numeroAsiento'       : '2',
        'proveedor'           : 'Distribuidora del Sur S.A.',
        'sucursal'            : '0001 - Sucursal Central',
        'timbrado'            : '11223344',
        'tipoAfectacion'      : ClaseTipoAfectacion.directo,
        'tipoDocumento'       : '02',
        'tipoIdentificacion'  : ClaseTipoIdentificacion.ruc,
        'total'               : '2200000',
        'totalComprobante'    : '2200000',
        'vigenteDesde'        : '01/01/2026',
        'vigenteHasta'        : '31/12/2026',
      },
      <String, dynamic>{
        'cantidadCuotas'      : '0',
        'comentarios'         : '',
        'detalles'            : <Map<String, String>>[
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
        'ejercicio'           : '2026',
        'enviarMarangatu'     : ClaseSiNo.no,
        'esFacturaElectronica': ClaseSiNo.no,
        'exentas'             : '100000',
        'fecha'               : '20/02/2026',
        'gravadas10'          : '0',
        'gravadas5'           : '400000',
        'hora'                : '10:30',
        'identificacion'      : 'EX789012',
        'importeExento'       : '100000',
        'importeGravado10'    : '0',
        'importeGravado5'     : '420000',
        'importeIreSimple'    : '0',
        'importeIrpSimple'    : '0',
        'importeNoImputable'  : '0',
        'iva10'               : '0',
        'iva5'                : '20000',
        'mostrarEnLibro'      : ClaseSiNo.si,
        'numero'              : '001-001-0000456',
        'numeroAsiento'       : '5',
        'proveedor'           : 'Importadora Brasil Ltda.',
        'sucursal'            : '0001 - Sucursal Central',
        'timbrado'            : '55667788',
        'tipoAfectacion'      : ClaseTipoAfectacion.indistinto,
        'tipoDocumento'       : '01',
        'tipoIdentificacion'  : ClaseTipoIdentificacion.cedulaExtranjera,
        'total'               : '520000',
        'totalComprobante'    : '520000',
        'vigenteDesde'        : '',
        'vigenteHasta'        : '',
      },
    ];
  }

}
