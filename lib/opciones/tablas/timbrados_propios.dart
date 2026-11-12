import 'package:flutter/material.dart';

import '../../generales/idiomas/idiomas.dart';
import '../../generales/modelos/campo_abm.dart';
import '../../generales/preferencias/preferencias.dart';
import '../../generales/validaciones/cap_validar.dart';
import '../../generales/widgets/formulario_abm.dart';


/// Pantalla de la tabla Timbrados Propios (ABM de múltiples registros).
///
/// Validaciones centralizadas en ClaseCapValidar.
class ClaseTimbradosPropios extends StatefulWidget {

  const ClaseTimbradosPropios({
    super.key,
    required this.oPreferencias,
  });

  final ClasePreferencias oPreferencias;

  @override
  State<ClaseTimbradosPropios> createState() => ClaseEstadoTimbradosPropios();
}

class ClaseEstadoTimbradosPropios extends State<ClaseTimbradosPropios> {

  late final List<ClaseCampoAbm>        listCampos;
  late final List<Map<String, dynamic>> listRegistros;

  @override
  void initState() {
    super.initState();
    listCampos    = crearCampos();
    listRegistros = crearRegistrosPrueba();
  }

  @override
  Widget build(BuildContext oContexto) {
    return ClaseFormularioAbm(
      funcValidarRegistro : validarRegistro,
      listCampos          : listCampos,
      listRegistros       : listRegistros,
      oPreferencias       : widget.oPreferencias,
      sTitulo             : ClaseIdiomas.getTexto(
                              widget.oPreferencias.getIdioma(), 'menuTimbradosPropios'),
    );
  }

  // ── Utilidades ──────────────────────────────────────────────────────────

  String getIdioma() => widget.oPreferencias.getIdioma();

  /// Ancho mínimo del campo: caracteres de la opción más larga.
  int calcularAncho(List<String> listOpciones) {
    int iAncho = 0;
    for (final String sOpcion in listOpciones) {
      if (sOpcion.length > iAncho) iAncho = sOpcion.length;
    }
    return iAncho;
  }

  // ── Validación del registro completo (campos cruzados) ──────────────────

  String? validarRegistro(Map<String, dynamic> oRegistro) {
    return ClaseCapValidar.validarFechaFinPosterior(
      (oRegistro['fechaInicio'] ?? '').toString(),
      (oRegistro['fechaFin'] ?? '').toString(),
      getIdioma(),
    );
  }

  // ── Campos ──────────────────────────────────────────────────────────────

  List<ClaseCampoAbm> crearCampos() {

    final String sIdioma = getIdioma();

    final List<String> listAfectaA = <String>[
      ClaseIdiomas.getTexto(sIdioma, 'timFactura'),
      ClaseIdiomas.getTexto(sIdioma, 'timNotaCredito'),
      ClaseIdiomas.getTexto(sIdioma, 'timNotaDebito'),
      ClaseIdiomas.getTexto(sIdioma, 'timNotaRemision'),
    ];
    final List<String> listMedioGeneracion = <String>[
      ClaseIdiomas.getTexto(sIdioma, 'timAutoImpresores'),
      ClaseIdiomas.getTexto(sIdioma, 'timPreImpresos'),
      ClaseIdiomas.getTexto(sIdioma, 'timComprobantesVirtuales'),
      ClaseIdiomas.getTexto(sIdioma, 'timDocumentosElectronicos'),
    ];

    return <ClaseCampoAbm>[

      ClaseCampoAbm(
        bObligatorio     : true,
        funcValidarCampo : (sValor) => ClaseCapValidar.validarDigitosExactos(
            sValor, ClaseIdiomas.getTexto(sIdioma, 'timTimbrado'), 8, sIdioma),
        iAnchoCaracteres : 8,
        oTipo            : EnumTipoCampoAbm.texto,
        sClave           : 'timbradoNumero',
        sEtiqueta        : ClaseIdiomas.getTexto(sIdioma, 'timTimbrado'),
      ),

      ClaseCampoAbm(
        bObligatorio     : true,
        funcValidarCampo : (sValor) => ClaseCapValidar.validarFechaNoAnterior(
            sValor, ClaseIdiomas.getTexto(sIdioma, 'timFechaInicio'),
            DateTime(2020, 1, 1), sIdioma),
        iAnchoCaracteres : 10,
        oTipo            : EnumTipoCampoAbm.fecha,
        sClave           : 'fechaInicio',
        sEtiqueta        : ClaseIdiomas.getTexto(sIdioma, 'timFechaInicio'),
      ),

      ClaseCampoAbm(
        funcValidarCampo : (sValor) => ClaseCapValidar.validarFechaValida(
            sValor, ClaseIdiomas.getTexto(sIdioma, 'timFechaFin'), sIdioma),
        iAnchoCaracteres : 10,
        oTipo            : EnumTipoCampoAbm.fecha,
        sClave           : 'fechaFin',
        sEtiqueta        : ClaseIdiomas.getTexto(sIdioma, 'timFechaFin'),
      ),

      ClaseCampoAbm(
        bEnGrilla        : false,
        bObligatorio     : true,
        funcValidarCampo : (sValor) => ClaseCapValidar.validarAlMenosUnoSeleccionado(
            sValor, ClaseIdiomas.getTexto(sIdioma, 'timAfectaA'), sIdioma),
        iAnchoCaracteres : calcularAncho(listAfectaA),
        listOpciones     : listAfectaA,
        oTipo            : EnumTipoCampoAbm.casillas,
        sClave           : 'afectaA',
        sEtiqueta        : ClaseIdiomas.getTexto(sIdioma, 'timAfectaA'),
      ),

      ClaseCampoAbm(
        iAnchoCaracteres : calcularAncho(listMedioGeneracion),
        listOpciones     : listMedioGeneracion,
        oTipo            : EnumTipoCampoAbm.lista,
        sClave           : 'medioGeneracion',
        sEtiqueta        : ClaseIdiomas.getTexto(sIdioma, 'timMedioGeneracion'),
      ),

      ClaseCampoAbm(
        bObligatorio     : true,
        funcValidarCampo : (sValor) => ClaseCapValidar.validarDigitosExactos(
            sValor, ClaseIdiomas.getTexto(sIdioma, 'timUltimoDocumento'), 13, sIdioma),
        iAnchoCaracteres : 15,
        oTipo            : EnumTipoCampoAbm.texto,
        sClave           : 'numeroUltimoDocumento',
        sEtiqueta        : ClaseIdiomas.getTexto(sIdioma, 'timUltimoDocumento'),
        sMascara         : '999-999-9999999',
      ),
    ];
  }

  // ── Datos de prueba (se reemplazarán por Firebird) ──────────────────────

  List<Map<String, dynamic>> crearRegistrosPrueba() {
    final String sIdioma = getIdioma();
    return <Map<String, dynamic>>[
      <String, dynamic>{
        'afectaA'              : '${ClaseIdiomas.getTexto(sIdioma, 'timFactura')},${ClaseIdiomas.getTexto(sIdioma, 'timNotaCredito')}',
        'fechaFin'             : '31/12/2026',
        'fechaInicio'          : '01/01/2025',
        'medioGeneracion'      : ClaseIdiomas.getTexto(sIdioma, 'timAutoImpresores'),
        'numeroUltimoDocumento': '123-456-7890123',
        'timbradoNumero'       : '12345678',
      },
      <String, dynamic>{
        'afectaA'              : ClaseIdiomas.getTexto(sIdioma, 'timFactura'),
        'fechaFin'             : '',
        'fechaInicio'          : '01/06/2026',
        'medioGeneracion'      : ClaseIdiomas.getTexto(sIdioma, 'timDocumentosElectronicos'),
        'numeroUltimoDocumento': '987-654-3210987',
        'timbradoNumero'       : '87654321',
      },
    ];
  }

}
