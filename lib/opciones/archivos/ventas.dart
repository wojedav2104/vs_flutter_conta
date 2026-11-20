import 'package:flutter/material.dart';

import '../../generales/idiomas/idiomas.dart';
import '../../generales/modelos/campo_abm.dart';
import '../../generales/modelos/documentos.dart';
import '../../generales/preferencias/preferencias.dart';
import '../../generales/utilitarios/formatos.dart';
import '../../generales/validaciones/cap_validar.dart';
import '../../generales/varios/listas.dart';
import '../../generales/widgets/formulario_cabecera_detalle.dart';

/// Pantalla de la tabla Libro Ventas (cabecera + grilla editable de detalles).
///
/// Cabecera con tres grupos (Generales, Detalles y Resolución 90/2021): la
/// grilla editable de detalles se muestra en la pestaña Detalles, debajo de
/// los importes de solo lectura, y las filas del asiento generado quedan en
/// la clave 'detalles'.
///
/// Validaciones cruzadas (validarRegistro):
///   · La Fecha de la venta debe estar dentro del Ejercicio contable.
///   · Cantidad de cuotas: solo se escribe en Factura Crédito (1 a 240); en
///     los demás tipos está deshabilitada y vale 0.
///   · Timbrado: obligatorio de 8 dígitos solo cuando el Tipo de documento
///     lleva la máscara 999-999-9999999; en blanco y deshabilitado en los
///     demás casos.
///   · Formato del N° de documento cuando el Tipo de documento lleva la
///     máscara (13 dígitos). Sin máscara el usuario escribe libremente.
///   · Formato de la identificación según el Tipo de identificación.
///   · La Fecha de fin de vigencia debe ser posterior al inicio.
///   · Total del comprobante = suma del Debe si se envía a Marangatú.
class ClaseVentas extends StatefulWidget {

  const ClaseVentas({
    super.key,
    required this.oPreferencias,
  });

  final ClasePreferencias oPreferencias;

  @override
  State<ClaseVentas> createState() => ClaseEstadoVentas();
}

class ClaseEstadoVentas extends State<ClaseVentas> {

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
      sGrupoConDetalles    : 'venDetalles',
      sTitulo              : ClaseIdiomas.getTexto('menuVentas', getIdioma()),
    );
  }

  String getIdioma() => widget.oPreferencias.getIdioma();

  // ── Auto-cálculos de la cabecera ────────────────────────────────────────

  /// Auto-cálculos según la spec de Ventas:
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
    if (ClaseTipoDocumentoVentas.esFacturaCredito(sTipoDocumento)) {
      final String sCuotas = (mapValores['cantidadCuotas'] ?? '').trim();
      if (sCuotas.isEmpty || sCuotas == '0') {
        mapActualizaciones['cantidadCuotas'] = '1';
      }
    } else {
      mapActualizaciones['cantidadCuotas'] = '0';
    }

    // Timbrado: en blanco cuando el Tipo de documento no lleva máscara.
    if (!ClaseTipoDocumentoVentas.esConMascara(sTipoDocumento)) {
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

    // Fecha de la venta dentro del Ejercicio contable.
    final String? sErrorFecha = ClaseCapValidar.validarFechaEnEjercicio(
      (oRegistro['fecha']     ?? '').toString(),
      (oRegistro['ejercicio'] ?? '').toString(),
      ClaseIdiomas.getTexto('venFecha', sIdioma),
      sIdioma,
    );
    if (sErrorFecha != null) return sErrorFecha;

    final String sTipoDoc = (oRegistro['tipoDocumento'] ?? '').toString();

    // Cantidad de cuotas: solo se escribe en Factura Crédito (1 a 240).
    // En los demás tipos el campo está deshabilitado y vale 0.
    final String sCuotas = (oRegistro['cantidadCuotas'] ?? '').toString().trim();
    if (ClaseTipoDocumentoVentas.esFacturaCredito(sTipoDoc)) {
      if (sCuotas.isEmpty) {
        return ClaseCapValidar.validarObligatorio(sCuotas,
            ClaseIdiomas.getTexto('venCantidadCuotas', sIdioma), sIdioma);
      }
      final String? sErrorCuotas = ClaseCapValidar.validarRangoEntero(sCuotas,
          ClaseIdiomas.getTexto('venCantidadCuotas', sIdioma), 1, 240, sIdioma);
      if (sErrorCuotas != null) return sErrorCuotas;
    }

    // Timbrado: obligatorio de 8 dígitos solo si el Tipo de documento lleva
    // la máscara 999-999-9999999; en blanco y deshabilitado en los demás casos.
    final String sTimbrado = (oRegistro['timbrado'] ?? '').toString();
    if (ClaseTipoDocumentoVentas.esConMascara(sTipoDoc)) {
      if (sTimbrado.trim().isEmpty) {
        return ClaseCapValidar.validarObligatorio(sTimbrado,
            ClaseIdiomas.getTexto('venTimbrado', sIdioma), sIdioma);
      }
      final String? sErrorTimbrado = ClaseCapValidar.validarDigitosExactos(sTimbrado,
          ClaseIdiomas.getTexto('venTimbrado', sIdioma), 8, sIdioma);
      if (sErrorTimbrado != null) return sErrorTimbrado;
    }

    // N° de documento: con máscara debe tener los 13 dígitos de
    // 999-999-9999999. Sin máscara el usuario escribe libremente
    // (mayúsculas, dígitos y caracteres especiales) y no se valida formato.
    if (ClaseTipoDocumentoVentas.esConMascara(sTipoDoc)) {
      final String? sErrorNumero = ClaseCapValidar.validarNumeroDocumento(
        (oRegistro['numero'] ?? '').toString(),
        ClaseIdiomas.getTexto('venNumero', sIdioma),
        sIdioma,
      );
      if (sErrorNumero != null) return sErrorNumero;
    }

    // Identificación según el Tipo de identificación.
    final String? sErrorIdent = ClaseCapValidar.validarIdentificacion(
      (oRegistro['identificacion']      ?? '').toString(),
      (oRegistro['tipoIdentificacion']  ?? '').toString(),
      ClaseIdiomas.getTexto('venIdentificacion', sIdioma),
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
        return ClaseIdiomas.getTexto('venErrorMarangatu', sIdioma);
      }
    }
    return null;
  }

  // ── Campos de la cabecera ──────────────────────────────────────────────
  //
  // Orden visual = orden de declaración (la fila se coloca donde aparece su
  // primer campo; dentro de la fila, los campos van en orden de declaración).

  List<ClaseCampoAbm> crearCamposCabecera() {

    final int    iAnchoEtiquetasPrimeraColumna = 29;

    final String sIdioma = getIdioma();

    return <ClaseCampoAbm>[

      // ── Generales ──────────────────────────────────────────────────────
      ClaseCampoAbm(
        bObligatorio     : true,
        funcValidarCampo : (sValor, sIdioma) => ClaseCapValidar.validarEjercicio(sValor, ClaseIdiomas.getTexto('venEjercicio', sIdioma), sIdioma),
        iAnchoCaracteres : 4,
        iAnchoEtiqueta   : iAnchoEtiquetasPrimeraColumna,
        iFila            : 1,
        oAlineacion      : EnumAlineacion.centro,
        oTipo            : EnumTipoCampoAbm.numero,
        sClave           : 'ejercicio',
        sEtiqueta        : ClaseIdiomas.getTexto('venEjercicio', sIdioma),
        sMascara         : '9.999',
        sGrupo           : 'venGenerales',
      ),
      ClaseCampoAbm(
        bObligatorio     : true,
        iAnchoCaracteres : 44,
        iAnchoEtiqueta   : 13,
        iFila            : 1,
        oTipo            : EnumTipoCampoAbm.texto,
        sClave           : 'sucursal',
        sEtiqueta        : ClaseIdiomas.getTexto('venSucursal', sIdioma),
        sGrupo           : 'venGenerales',
        sHint            : ClaseIdiomas.getTexto('venHintSucursal', sIdioma),
      ),
      ClaseCampoAbm(
        bEnGrilla             : false,
        bSiempreDeshabilitado : true,
        iAnchoCaracteres      : 6,
        iAnchoEtiqueta        : 18,
        iFila                 : 1,
        oTipo                 : EnumTipoCampoAbm.numero,
        sClave                : 'numeroAsiento',
        sEtiqueta             : ClaseIdiomas.getTexto('venNumeroAsiento', sIdioma),
        sGrupo                : 'venGenerales',
      ),
      ClaseCampoAbm(
        bObligatorio     : true,
        funcValidarCampo : (sValor, sIdioma) => ClaseCapValidar.validarFechaNoAnterior(sValor, ClaseIdiomas.getTexto('venFecha', sIdioma),
            DateTime(ClaseFechas.iAnoMinimo, 1, 1), sIdioma),
        iAnchoCaracteres : 10,
        iAnchoEtiqueta   : iAnchoEtiquetasPrimeraColumna,
        iFila            : 2,
        oAlineacion      : EnumAlineacion.centro,
        oTipo            : EnumTipoCampoAbm.fecha,
        sClave           : 'fecha',
        sEtiqueta        : ClaseIdiomas.getTexto('venFecha', sIdioma),
        sGrupo           : 'venGenerales',
      ),
      ClaseCampoAbm(
        bObligatorio     : true,
        funcValidarCampo : (sValor, sIdioma) => ClaseCapValidar.validarHoraValida(sValor, ClaseIdiomas.getTexto('venHora', sIdioma), sIdioma),
        iAnchoCaracteres : 5,
        iFila            : 2,
        oTipo            : EnumTipoCampoAbm.hora,
        sClave           : 'hora',
        sEtiqueta        : ClaseIdiomas.getTexto('venHora', sIdioma),
        sGrupo           : 'venGenerales',
      ),
      ClaseCampoAbm(
        bObligatorio     : true,
        iAnchoCaracteres : funcAnchoOpcion(ClaseTipoDocumentoVentas.getListOpciones(sIdioma)),
        iAnchoEtiqueta   : iAnchoEtiquetasPrimeraColumna,
        iFila            :  3,
        listOpciones     : ClaseTipoDocumentoVentas.getListOpciones(sIdioma),
        listValores      : ClaseTipoDocumentoVentas.listValores,
        oTipo            : EnumTipoCampoAbm.lista,
        sClave           : 'tipoDocumento',
        sEtiqueta        : ClaseIdiomas.getTexto('venTipoDocumento', sIdioma),
        sGrupo           : 'venGenerales',
        sValorDefecto    : '01',
      ),
      ClaseCampoAbm(
        bMayusculas       : true,
        bObligatorio      : true,
        funcMascara       : (mapValores) => ClaseTipoDocumentoVentas.esConMascara(mapValores['tipoDocumento'] ?? '') ? ClaseTipoDocumentoVentas.sMascaraNumero : null,
        iAnchoCaracteres  : 15,
        iFila             : 3,
        oTipo             : EnumTipoCampoAbm.texto,
        sClave            : 'numero',
        sEtiqueta         : ClaseIdiomas.getTexto('venNumero', sIdioma),
        sGrupo            : 'venGenerales',
      ),
      ClaseCampoAbm(
        funcActualizarEstado : (mapValores) => ClaseTipoDocumentoVentas.esFacturaCredito(mapValores['tipoDocumento'] ?? ''),
        funcValidarCampo     : (sValor, sIdioma) => ClaseCapValidar.validarSoloEntero(sValor, ClaseIdiomas.getTexto('venCantidadCuotas', sIdioma), sIdioma),
        iAnchoCaracteres     :  3,
        iAnchoEtiqueta       : iAnchoEtiquetasPrimeraColumna,
        oTipo                : EnumTipoCampoAbm.numero,
        sClave               : 'cantidadCuotas',
        sEtiqueta            : ClaseIdiomas.getTexto('venCantidadCuotas', sIdioma),
        sGrupo               : 'venGenerales',
        sValorDefecto        : '0',
      ),
      ClaseCampoAbm(
        bObligatorio     : true,
        iAnchoCaracteres : 48,
        iAnchoEtiqueta   : iAnchoEtiquetasPrimeraColumna,
        iFila            : 4,
        oTipo            : EnumTipoCampoAbm.texto,
        sClave           : 'cliente',
        sEtiqueta        : ClaseIdiomas.getTexto('venCliente', sIdioma),
        sGrupo           : 'venGenerales',
        sHint            : ClaseIdiomas.getTexto('venHintCliente', sIdioma),
      ),
      ClaseCampoAbm(
        iAnchoCaracteres : funcAnchoOpcion(ClaseTipoIdentificacion.getListOpciones(sIdioma)),
        iAnchoEtiqueta   : 13,
        iFila            : 4,
        listOpciones     : ClaseTipoIdentificacion.getListOpciones(sIdioma),
        listValores      : ClaseTipoIdentificacion.listValores,
        oTipo            : EnumTipoCampoAbm.lista,
        sClave           : 'tipoIdentificacion',
        sEtiqueta        : ClaseIdiomas.getTexto('venTipoIdentificacion', sIdioma),
        sGrupo           : 'venGenerales',
        sValorDefecto    : ClaseTipoIdentificacion.ruc,
      ),
      ClaseCampoAbm(
        bSiempreDeshabilitado : true,
        iAnchoCaracteres      : 15,
        iAnchoEtiqueta        :  6,
        iFila                 :  4,
        oTipo                 : EnumTipoCampoAbm.texto,
        sClave                : 'identificacion',
        sEtiqueta             : ClaseIdiomas.getTexto('venIdentificacion', sIdioma),
        sGrupo                : 'venGenerales',
      ),
      ClaseCampoAbm(
        funcActualizarEstado : (mapValores) => ClaseTipoDocumentoVentas.esConMascara(mapValores['tipoDocumento'] ?? ''),
        iAnchoCaracteres     :  8,
        iAnchoEtiqueta       : iAnchoEtiquetasPrimeraColumna,
        iFila                :  5,
        oTipo                : EnumTipoCampoAbm.texto,
        sClave               : 'timbrado',
        sEtiqueta            : ClaseIdiomas.getTexto('venTimbrado', sIdioma),
        sGrupo               : 'venGenerales',
      ),
      ClaseCampoAbm(
        bSiempreDeshabilitado : true,
        iAnchoCaracteres      : 10,
        iFila                 : 5,
        oTipo                 : EnumTipoCampoAbm.fecha,
        sClave                : 'vigenteDesde',
        sEtiqueta             : ClaseIdiomas.getTexto('venVigenteDesde', sIdioma),
        sGrupo                : 'venGenerales',
      ),
      ClaseCampoAbm(
        bSiempreDeshabilitado : true,
        iAnchoCaracteres      : 10,
        iFila                 : 5,
        oTipo                 : EnumTipoCampoAbm.fecha,
        sClave                : 'vigenteHasta',
        sEtiqueta             : ClaseIdiomas.getTexto('venVigenteHasta', sIdioma),
        sGrupo                : 'venGenerales',
      ),
      ClaseCampoAbm(
        funcValidarCampo : (sValor, sIdioma) => ClaseCapValidar.validarImporteNoNegativo(sValor, ClaseIdiomas.getTexto('venGravadas10', sIdioma), sIdioma),
        iAnchoCaracteres : 15,
        iAnchoEtiqueta   : iAnchoEtiquetasPrimeraColumna,
        iFila            :  6,
        oTipo            : EnumTipoCampoAbm.numero,
        sClave           : 'gravadas10',
        sEtiqueta        : ClaseIdiomas.getTexto('venGravadas10', sIdioma),
        sGrupo           : 'venGenerales',
        sMascara         : '999.999.999.999',
      ),
      ClaseCampoAbm(
        funcValidarCampo : (sValor, sIdioma) => ClaseCapValidar.validarImporteNoNegativo(sValor, ClaseIdiomas.getTexto('venIva10', sIdioma), sIdioma),
        iAnchoCaracteres : 15,
        iAnchoEtiqueta   : iAnchoEtiquetasPrimeraColumna,
        iFila            :  7,
        oTipo            : EnumTipoCampoAbm.numero,
        sClave           : 'iva10',
        sEtiqueta        : ClaseIdiomas.getTexto('venIva10', sIdioma),
        sGrupo           : 'venGenerales',
        sMascara         : '999.999.999.999',
      ),
      ClaseCampoAbm(
        funcValidarCampo : (sValor, sIdioma) => ClaseCapValidar.validarImporteNoNegativo(sValor, ClaseIdiomas.getTexto('venGravadas5', sIdioma), sIdioma),
        iAnchoCaracteres : 15,
        iAnchoEtiqueta   : iAnchoEtiquetasPrimeraColumna,
        iFila            :  8,
        oTipo            : EnumTipoCampoAbm.numero,
        sClave           : 'gravadas5',
        sEtiqueta        : ClaseIdiomas.getTexto('venGravadas5', sIdioma),
        sGrupo           : 'venGenerales',
        sMascara         : '999.999.999.999',
      ),
      ClaseCampoAbm(
        funcValidarCampo : (sValor, sIdioma) => ClaseCapValidar.validarImporteNoNegativo(sValor, ClaseIdiomas.getTexto('venIva5', sIdioma), sIdioma),
        iAnchoCaracteres : 15,
        iAnchoEtiqueta   : iAnchoEtiquetasPrimeraColumna,
        iFila            :  9,
        oTipo            : EnumTipoCampoAbm.numero,
        sClave           : 'iva5',
        sEtiqueta        : ClaseIdiomas.getTexto('venIva5', sIdioma),
        sGrupo           : 'venGenerales',
        sMascara         : '999.999.999.999',
      ),
      ClaseCampoAbm(
        funcValidarCampo : (sValor, sIdioma) => ClaseCapValidar.validarImporteNoNegativo(sValor, ClaseIdiomas.getTexto('venExentas', sIdioma), sIdioma),
        iAnchoCaracteres : 15,
        iAnchoEtiqueta   : iAnchoEtiquetasPrimeraColumna,
        iFila            : 10,
        oTipo            : EnumTipoCampoAbm.numero,
        sClave           : 'exentas',
        sEtiqueta        : ClaseIdiomas.getTexto('venExentas', sIdioma),
        sGrupo           : 'venGenerales',
        sMascara         : '999.999.999.999',
      ),
      ClaseCampoAbm(
        bEsTotal              : true,
        bSiempreDeshabilitado : true,
        iAnchoCaracteres      : 15,
        iAnchoEtiqueta        : iAnchoEtiquetasPrimeraColumna,
        iFila                 : 11,
        oTipo                 : EnumTipoCampoAbm.numero,
        sClave                : 'total',
        sEtiqueta             : ClaseIdiomas.getTexto('venTotal', sIdioma),
        sGrupo                : 'venGenerales',
        sMascara              : '999.999.999.999',
      ),
      ClaseCampoAbm(
        iAnchoCaracteres : funcAnchoOpcion(ClaseSiNo.getListOpciones(sIdioma)),
        iAnchoEtiqueta   : iAnchoEtiquetasPrimeraColumna,
        iFila            : 12,
        listOpciones     : ClaseSiNo.getListOpciones(sIdioma),
        listValores      : ClaseSiNo.listValores,
        oTipo            : EnumTipoCampoAbm.lista,
        sClave           : 'mostrarEnLibro',
        sEtiqueta        : ClaseIdiomas.getTexto('venMostrarEnLibro', sIdioma),
        sGrupo           : 'venGenerales',
        sValorDefecto    : ClaseSiNo.si,
      ),
      ClaseCampoAbm(
        iAnchoCaracteres : 60,
        iMaxComentario   : 500,
        oTipo            : EnumTipoCampoAbm.comentario,
        sClave           : 'comentarios',
        sEtiqueta        : ClaseIdiomas.getTexto('venComentarios', sIdioma),
        sGrupo           : 'venGenerales',
        sHint            : ClaseIdiomas.getTexto('venHintComentarios', sIdioma),
      ),

      // ── Detalles: los importes de las filas 6 a 11, solo de lectura ────
      // Mismas claves que en Generales (mismo valor); siempre deshabilitados y fuera de la grilla lateral.
      ClaseCampoAbm(
        bEnGrilla             : false,
        bSiempreDeshabilitado : true,
        iAnchoCaracteres      : 15,
        iFila                 : 6,
        oTipo                 : EnumTipoCampoAbm.numero,
        sClave                : 'gravadas10',
        sEtiqueta             : ClaseIdiomas.getTexto('venGravadas10', sIdioma),
        sGrupo                : 'venDetalles',
        sMascara              : '999.999.999.999',
      ),
      ClaseCampoAbm(
        bEnGrilla             : false,
        bSiempreDeshabilitado : true,
        iAnchoCaracteres      : 15,
        iFila                 : 7,
        oTipo                 : EnumTipoCampoAbm.numero,
        sClave                : 'iva10',
        sEtiqueta             : ClaseIdiomas.getTexto('venIva10', sIdioma),
        sGrupo                : 'venDetalles',
        sMascara              : '999.999.999.999',
      ),
      ClaseCampoAbm(
        bEnGrilla             : false,
        bSiempreDeshabilitado : true,
        iAnchoCaracteres      : 15,
        iFila                 : 8,
        oTipo                 : EnumTipoCampoAbm.numero,
        sClave                : 'gravadas5',
        sEtiqueta             : ClaseIdiomas.getTexto('venGravadas5', sIdioma),
        sGrupo                : 'venDetalles',
        sMascara              : '999.999.999.999',
      ),
      ClaseCampoAbm(
        bEnGrilla             : false,
        bSiempreDeshabilitado : true,
        iAnchoCaracteres      : 15,
        iFila                 : 9,
        oTipo                 : EnumTipoCampoAbm.numero,
        sClave                : 'iva5',
        sEtiqueta             : ClaseIdiomas.getTexto('venIva5', sIdioma),
        sGrupo                : 'venDetalles',
        sMascara              : '999.999.999.999',
      ),
      ClaseCampoAbm(
        bEnGrilla             : false,
        bSiempreDeshabilitado : true,
        iAnchoCaracteres      : 15,
        iFila                 : 10,
        oTipo                 : EnumTipoCampoAbm.numero,
        sClave                : 'exentas',
        sEtiqueta             : ClaseIdiomas.getTexto('venExentas', sIdioma),
        sGrupo                : 'venDetalles',
        sMascara              : '999.999.999.999',
      ),
      ClaseCampoAbm(
        bEnGrilla             : false,
        bEsTotal              : true,
        bSiempreDeshabilitado : true,
        iAnchoCaracteres      : 15,
        iFila                 : 11,
        oTipo                 : EnumTipoCampoAbm.numero,
        sClave                : 'total',
        sEtiqueta             : ClaseIdiomas.getTexto('venTotal', sIdioma),
        sGrupo                : 'venDetalles',
        sMascara              : '999.999.999.999',
      ),

      // ── Resolución 90/2021 ─────────────────────────────────────────────
      ClaseCampoAbm(
        iAnchoCaracteres : funcAnchoOpcion(ClaseSiNo.getListOpciones(sIdioma)),
        listOpciones     : ClaseSiNo.getListOpciones(sIdioma),
        listValores      : ClaseSiNo.listValores,
        oTipo            : EnumTipoCampoAbm.lista,
        sClave           : 'enviarMarangatu',
        sEtiqueta        : ClaseIdiomas.getTexto('venEnviarMarangatu', sIdioma),
        sGrupo           : 'venResolucion',
        sValorDefecto    : ClaseSiNo.si,
      ),
      ClaseCampoAbm(
        iAnchoCaracteres : 15,
        oTipo            : EnumTipoCampoAbm.numero,
        sClave           : 'importeGravado10',
        sEtiqueta        : ClaseIdiomas.getTexto('venImporteGravado10', sIdioma),
        sGrupo           : 'venResolucion',
        sMascara         : '999.999.999.999',
      ),
      ClaseCampoAbm(
        iAnchoCaracteres : 15,
        oTipo            : EnumTipoCampoAbm.numero,
        sClave           : 'importeGravado5',
        sEtiqueta        : ClaseIdiomas.getTexto('venImporteGravado5', sIdioma),
        sGrupo           : 'venResolucion',
        sMascara         : '999.999.999.999',
      ),
      ClaseCampoAbm(
        iAnchoCaracteres : 15,
        oTipo            : EnumTipoCampoAbm.numero,
        sClave           : 'importeExento',
        sEtiqueta        : ClaseIdiomas.getTexto('venImporteExento', sIdioma),
        sGrupo           : 'venResolucion',
        sMascara         : '999.999.999.999',
      ),
      ClaseCampoAbm(
        iAnchoCaracteres : 15,
        oTipo            : EnumTipoCampoAbm.numero,
        sClave           : 'importeIreSimple',
        sEtiqueta        : ClaseIdiomas.getTexto('venImporteIreSimple', sIdioma),
        sGrupo           : 'venResolucion',
        sMascara         : '999.999.999.999',
        sValorDefecto    : '0',
      ),
      ClaseCampoAbm(
        iAnchoCaracteres : 15,
        oTipo            : EnumTipoCampoAbm.numero,
        sClave           : 'importeIrpSimple',
        sEtiqueta        : ClaseIdiomas.getTexto('venImporteIrpSimple', sIdioma),
        sGrupo           : 'venResolucion',
        sMascara         : '999.999.999.999',
        sValorDefecto    : '0',
      ),
      ClaseCampoAbm(
        iAnchoCaracteres : 15,
        oTipo            : EnumTipoCampoAbm.numero,
        sClave           : 'importeNoImputable',
        sEtiqueta        : ClaseIdiomas.getTexto('venImporteNoImputable', sIdioma),
        sGrupo           : 'venResolucion',
        sMascara         : '999.999.999.999',
        sValorDefecto    : '0',
      ),
      ClaseCampoAbm(
        bEsTotal              : true,
        bSiempreDeshabilitado : true,
        iAnchoCaracteres      : 15,
        oTipo                 : EnumTipoCampoAbm.numero,
        sClave                : 'totalComprobante',
        sEtiqueta             : ClaseIdiomas.getTexto('venTotalComprobante', sIdioma),
        sGrupo                : 'venResolucion',
        sMascara              : '999.999.999.999',
      ),
    ];
  }

  // ── Columnas de la grilla de detalles ───────────────────────────────────

  List<ClaseCampoAbm> crearCamposDetalle() {

    final String sIdioma = getIdioma();

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

  // ── Datos de prueba (se reemplazarán por Firebird) ──────────────────────

  List<Map<String, dynamic>> crearRegistrosPrueba() {
    return <Map<String, dynamic>>[
      <String, dynamic>{
        'cantidadCuotas'      : '3',
        'cliente'             : 'Juan Pérez',
        'comentarios'         : 'Venta de servicios contables a crédito',
        'detalles'            : <Map<String, String>>[
          <String, String>{
            'concepto'     : 'Venta de servicios contables',
            'cuenta'       : '1.02.01',
            'debe'         : '2200000',
            'haber'        : '',
            'nombreCuenta' : 'Clientes',
            'subcuenta'    : '',
          },
          <String, String>{
            'concepto'     : 'Venta de servicios contables',
            'cuenta'       : '4.01.02',
            'debe'         : '',
            'haber'        : '2000000',
            'nombreCuenta' : 'Ventas Gravadas 10%',
            'subcuenta'    : '',
          },
          <String, String>{
            'concepto'     : 'Venta de servicios contables',
            'cuenta'       : '2.03.01',
            'debe'         : '',
            'haber'        : '200000',
            'nombreCuenta' : 'I.V.A Débito Fiscal 10%',
            'subcuenta'    : '',
          },
        ],
        'ejercicio'           : '2026',
        'enviarMarangatu'     : ClaseSiNo.si,
        'exentas'             : '0',
        'fecha'               : '15/02/2026',
        'gravadas10'          : '2000000',
        'gravadas5'           : '0',
        'hora'                : '11:00',
        'identificacion'      : '1234567-9',
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
        'numeroAsiento'       : '3',
        'sucursal'            : '0001 - Sucursal Central',
        'timbrado'            : '11223344',
        'tipoDocumento'       : '02',
        'tipoIdentificacion'  : ClaseTipoIdentificacion.ruc,
        'total'               : '2200000',
        'totalComprobante'    : '2200000',
        'vigenteDesde'        : '01/01/2026',
        'vigenteHasta'        : '31/12/2026',
      },
      <String, dynamic>{
        'cantidadCuotas'      : '0',
        'cliente'             : 'Pierre Dupont',
        'comentarios'         : '',
        'detalles'            : <Map<String, String>>[
          <String, String>{
            'concepto'     : 'Venta al contado',
            'cuenta'       : '1.01.01',
            'debe'         : '520000',
            'haber'        : '',
            'nombreCuenta' : 'Caja',
            'subcuenta'    : '',
          },
          <String, String>{
            'concepto'     : 'Venta al contado',
            'cuenta'       : '4.01.03',
            'debe'         : '',
            'haber'        : '400000',
            'nombreCuenta' : 'Ventas Gravadas 5%',
            'subcuenta'    : '',
          },
          <String, String>{
            'concepto'     : 'Venta al contado',
            'cuenta'       : '2.03.02',
            'debe'         : '',
            'haber'        : '20000',
            'nombreCuenta' : 'I.V.A Débito Fiscal 5%',
            'subcuenta'    : '',
          },
          <String, String>{
            'concepto'     : 'Venta al contado',
            'cuenta'       : '4.01.01',
            'debe'         : '',
            'haber'        : '100000',
            'nombreCuenta' : 'Ventas Exentas',
            'subcuenta'    : '',
          },
        ],
        'ejercicio'           : '2026',
        'enviarMarangatu'     : ClaseSiNo.no,
        'exentas'             : '100000',
        'fecha'               : '20/02/2026',
        'gravadas10'          : '0',
        'gravadas5'           : '400000',
        'hora'                : '10:30',
        'identificacion'      : 'AB123456',
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
        'numeroAsiento'       : '4',
        'sucursal'            : '0002 - Sucursal Luque',        
        'timbrado'            : '55667788',
        'tipoDocumento'       : '01',
        'tipoIdentificacion'  : ClaseTipoIdentificacion.pasaporte,
        'total'               : '520000',
        'totalComprobante'    : '520000',
        'vigenteDesde'        : '',
        'vigenteHasta'        : '',
      },
    ];
  }

}
