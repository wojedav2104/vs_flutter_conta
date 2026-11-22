import '../../generales/idiomas/idiomas.dart';
import '../../generales/utilitarios/formatos.dart';
import '../../generales/validaciones/cap_validar.dart';

/// Auto-cálculos y validaciones cruzadas de Retenciones a Proveedores
/// (specs 02_04_01 y 02_04_02).
///
/// Validaciones cruzadas (validarRegistro):
///   · Formato de la identificación según el Tipo de identificación.
///   · La fecha de fin de vigencia debe ser posterior al inicio.
abstract final class ClaseRetencionesProveedoresLogica {

  // ── Auto-cálculos del Grupo 2 ────────────────────────────────────────────

  /// Auto-cálculos según la spec de Retenciones a Proveedores (02_04_02):
  ///   · Valor total de la transacción = valor sin I.V.A. + I.V.A. incluido.
  ///   · Importe retenido del I.V.A. = I.V.A. incluido * Retención I.V.A. % / 100.
  ///   · Importe retenido de renta = valor sin I.V.A. * Retención Renta % / 100.
  ///   · Importe total de la retención = importe retenido del I.V.A. +
  ///     importe retenido de renta.
  static Map<String, String>? actualizarCampos(Map<String, String> mapValores) {

    final double dSinIva   = funcParsearNumero(mapValores['valorTransaccionSinIva']  ?? '') ?? 0;
    final double dIva      = funcParsearNumero(mapValores['ivaIncluido']             ?? '') ?? 0;
    final double dPorcIva  = funcParsearNumero(mapValores['retencionIvaPorcentaje']  ?? '') ?? 30;
    final double dPorcRenta= funcParsearNumero(mapValores['retencionRentaPorcentaje'] ?? '') ?? 0;

    final double dRetIva   = dIva * dPorcIva / 100;
    final double dRetRenta = dSinIva * dPorcRenta / 100;

    return <String, String>{
      'valorTotalTransaccion' : funcFormatearNumeroPlano(dSinIva + dIva),
      'importeRetenidoIva'    : funcFormatearNumeroPlano(dRetIva),
      'importeRetenidoRenta'  : funcFormatearNumeroPlano(dRetRenta),
      'importeTotalRetencion' : funcFormatearNumeroPlano(dRetIva + dRetRenta),
    };
  }

  // ── Validación cruzada del registro completo ────────────────────────────

  static String? validarRegistro(Map<String, dynamic> oRegistro, String sIdioma) {

    // Identificación según el Tipo de identificación.
    final String? sErrorIdent = ClaseCapValidar.validarIdentificacion(
      (oRegistro['identificacion']     ?? '').toString(),
      (oRegistro['tipoIdentificacion'] ?? '').toString(),
      ClaseIdiomas.getTexto('retIdentificacion', sIdioma),
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

    return null;
  }

}
