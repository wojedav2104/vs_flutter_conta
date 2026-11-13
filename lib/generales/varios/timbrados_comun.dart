import '../idiomas/idiomas.dart';
import '../modelos/campo_abm.dart';
import '../utilitarios/formatos.dart';
import '../validaciones/cap_validar.dart';
import 'listas.dart';

/// Campos, validaciones y auto-cálculos compartidos por Timbrados Propios y
/// Timbrados de Proveedores (los 5 campos comunes de la spec).
abstract final class ClaseTimbradosComun {

  /// Los 5 campos comunes, en el orden de la spec: N° de timbrado,
  /// Fecha de inicio, Fecha de fin, Afecta a, Medio de generación.
  static List<ClaseCampoAbm> crearCampos(String sIdioma) {
    return <ClaseCampoAbm>[
      ClaseCampoAbm(
        bCompletarCeros  : true,
        bObligatorio     : true,
        funcValidarCampo : (sValor, sIdioma) => ClaseCapValidar.validarDigitosExactos(
            sValor, ClaseIdiomas.getTexto(sIdioma, 'timTimbrado'), 8, sIdioma),
        iAnchoCaracteres : 8,
        oTipo            : EnumTipoCampoAbm.texto,
        sClave           : 'timbradoNumero',
        sEtiqueta        : ClaseIdiomas.getTexto(sIdioma, 'timTimbrado'),
      ),
      ClaseCampoAbm(
        bObligatorio     : true,
        funcValidarCampo : (sValor, sIdioma) => ClaseCapValidar.validarFechaNoAnterior(
            sValor, ClaseIdiomas.getTexto(sIdioma, 'timFechaInicio'),
            DateTime(ClaseFechas.iAnioMinimo, 1, 1), sIdioma),
        iAnchoCaracteres : 10,
        oTipo            : EnumTipoCampoAbm.fecha,
        sClave           : 'fechaInicio',
        sEtiqueta        : ClaseIdiomas.getTexto(sIdioma, 'timFechaInicio'),
      ),
      ClaseCampoAbm(
        funcValidarCampo : (sValor, sIdioma) => ClaseCapValidar.validarFechaValida(
            sValor, ClaseIdiomas.getTexto(sIdioma, 'timFechaFin'), sIdioma),
        iAnchoCaracteres : 10,
        oTipo            : EnumTipoCampoAbm.fecha,
        sClave           : 'fechaFin',
        sEtiqueta        : ClaseIdiomas.getTexto(sIdioma, 'timFechaFin'),
      ),
      ClaseCampoAbm(
        bEnGrilla        : false,
        bObligatorio     : true,
        funcValidarCampo : (sValor, sIdioma) => ClaseCapValidar.validarAlMenosUnoSeleccionado(
            sValor, ClaseIdiomas.getTexto(sIdioma, 'timAfectaA'), sIdioma),
        iAnchoCaracteres : funcAnchoOpcion(ClaseAfectaA.getListOpciones(sIdioma)),
        listOpciones     : ClaseAfectaA.getListOpciones(sIdioma),
        listValores      : ClaseAfectaA.listValores,
        oTipo            : EnumTipoCampoAbm.casillas,
        sClave           : 'afectaA',
        sEtiqueta        : ClaseIdiomas.getTexto(sIdioma, 'timAfectaA'),
        sValorDefecto    : ClaseAfectaA.factura,
      ),
      ClaseCampoAbm(
        iAnchoCaracteres : funcAnchoOpcion(ClaseMedioGeneracion.getListOpciones(sIdioma)),
        listOpciones     : ClaseMedioGeneracion.getListOpciones(sIdioma),
        listValores      : ClaseMedioGeneracion.listValores,
        oTipo            : EnumTipoCampoAbm.lista,
        sClave           : 'medioGeneracion',
        sEtiqueta        : ClaseIdiomas.getTexto(sIdioma, 'timMedioGeneracion'),
        sValorDefecto    : ClaseMedioGeneracion.preImpresos,
      ),
    ];
  }

  /// La fecha de fin de vigencia debe ser estrictamente posterior a la
  /// fecha de inicio (si la de fin está vacía, no se valida).
  static String? validarVigencia(Map<String, dynamic> oRegistro, String sIdioma) {
    return ClaseCapValidar.validarFechaFinPosterior(
      (oRegistro['fechaInicio'] ?? '').toString(),
      (oRegistro['fechaFin']   ?? '').toString(),
      sIdioma,
    );
  }

  /// Sugiere la Fecha de fin cuando está vacía y el Medio de generación es
  /// PreImpresos: el último día del mismo mes del año siguiente al de la
  /// Fecha de inicio (lo más común para esos talonarios).
  /// Ejemplo de la SET: inicio 13/11/2025 → fin 30/11/2026.
  /// El valor sugerido es editable y nunca pisa uno ya cargado.
  static Map<String, String>? actualizarCampos(Map<String, String> mapValores) {
    final String sInicio = mapValores['fechaInicio']     ?? '';
    final String sFin    = mapValores['fechaFin']        ?? '';
    final String sMedio  = mapValores['medioGeneracion'] ?? '';
    if (sFin.trim().isNotEmpty)                     return null;
    if (sMedio != ClaseMedioGeneracion.preImpresos) return null;
    final DateTime? fInicio = funcParsearFecha(sInicio);
    if (fInicio == null) return null;
    final DateTime fFin = DateTime(fInicio.year + 1, fInicio.month + 1, 0);
    return <String, String>{'fechaFin': funcFormatearFecha(fFin)};
  }

}
