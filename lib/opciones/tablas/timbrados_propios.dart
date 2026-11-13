import 'package:flutter/material.dart';

import '../../generales/idiomas/idiomas.dart';
import '../../generales/modelos/campo_abm.dart';
import '../../generales/preferencias/preferencias.dart';
import '../../generales/validaciones/cap_validar.dart';
import '../../generales/varios/listas.dart';
import '../../generales/widgets/formulario_abm.dart';
import '../../generales/varios/timbrados_comun.dart';

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
      sTitulo             : ClaseIdiomas.getTexto(getIdioma(), 'menuTimbradosPropios'),
    );
  }

  String getIdioma() => widget.oPreferencias.getIdioma();

  // ── Validación del registro completo (campos cruzados) ──────────────────

  String? validarRegistro(Map<String, dynamic> oRegistro) {
    return ClaseTimbradosComun.validarVigencia(oRegistro, getIdioma());
  }

  // ── Campos ──────────────────────────────────────────────────────────────

  List<ClaseCampoAbm> crearCampos() {

    final String sIdioma = getIdioma();

    return <ClaseCampoAbm>[
      // Los 5 campos comunes: timbrado, vigencia, afectaA, medioGeneracion.
      ...ClaseTimbradosComun.crearCampos(sIdioma),

      ClaseCampoAbm(
        bObligatorio     : true,
        funcValidarCampo : (sValor, sIdioma) => ClaseCapValidar.validarNumeroDocumento(
            sValor, ClaseIdiomas.getTexto(sIdioma, 'timUltimoDocumento'), sIdioma),
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
    return <Map<String, dynamic>>[
      <String, dynamic>{
        'afectaA'               : '${ClaseAfectaA.factura},${ClaseAfectaA.notaCredito}',
        'fechaFin'              : '31/12/2026',
        'fechaInicio'           : '01/01/2025',
        'medioGeneracion'       : ClaseMedioGeneracion.autoImpresores,
        'numeroUltimoDocumento' : '123-456-7890123',
        'timbradoNumero'        : '12345678',
      },
      <String, dynamic>{
        'afectaA'               : ClaseAfectaA.factura,
        'fechaFin'              : '',
        'fechaInicio'           : '01/06/2026',
        'medioGeneracion'       : ClaseMedioGeneracion.documentosElectronicos,
        'numeroUltimoDocumento' : '987-654-3210987',
        'timbradoNumero'        : '87654321',
      },
    ];
  }

}
