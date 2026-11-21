import '../../generales/idiomas/idiomas.dart';
import '../../generales/modelos/documentos.dart';
import '../../generales/utilitarios/formatos.dart';
import '../../generales/validaciones/cap_validar.dart';
import '../../generales/varios/listas.dart';
import '../../generales/widgets/formulario_cabecera_detalle.dart';

/// Auto-cálculos y validaciones cruzadas del Libro Compras (spec 02_03).
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
abstract final class ClaseComprasLogica {

  // ── Auto-cálculos de la cabecera ────────────────────────────────────────

  /// Auto-cálculos según la spec 02_03:
  ///   · Total (Grupo 1) = gravadas 10% + IVA 10% + gravadas 5% + IVA 5%
  ///     + exentas.
  ///   · Importe gravado 10%/5% y exento (Grupo 3): se sugieren solo si
  ///     están vacíos. I.R.E. Simple, I.R.P. Simple y no imputable son
  ///     manuales (inicialmente 0).
  ///   · Total del comprobante = suma de los 6 importes del Grupo 3.
  ///   · Cantidad de cuotas según el Tipo de documento: en Factura Crédito,
  ///     si está vacía o en 0 se coloca 1 (cualquier otro valor se respeta);
  ///     en los demás tipos vale 0.
  ///   · Timbrado en blanco cuando el Tipo de documento no lleva máscara.
  static Map<String, String>? actualizarCampos(Map<String, String> mapValores) {

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

    // Total del comprobante = suma de los 6 importes del Grupo 3
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

  static String? validarRegistro(Map<String, dynamic> oRegistro, String sIdioma) {

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

}
