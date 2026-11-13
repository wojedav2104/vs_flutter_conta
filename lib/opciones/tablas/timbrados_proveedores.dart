import 'package:flutter/material.dart';

import '../../generales/idiomas/idiomas.dart';
import '../../generales/modelos/campo_abm.dart';
import '../../generales/preferencias/preferencias.dart';
import '../../generales/varios/listas.dart';
import '../../generales/widgets/formulario_abm.dart';
import '../../generales/varios/timbrados_comun.dart';

/// Pantalla de la tabla Timbrados de Proveedores (ABM de múltiples registros).
///
/// Validaciones centralizadas en ClaseCapValidar.
class ClaseTimbradosProveedores extends StatefulWidget {

  const ClaseTimbradosProveedores({
    super.key,
    required this.oPreferencias,
  });

  final ClasePreferencias oPreferencias;

  @override
  State<ClaseTimbradosProveedores> createState() => ClaseEstadoTimbradosProveedores();
}

class ClaseEstadoTimbradosProveedores extends State<ClaseTimbradosProveedores> {

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
      sTitulo             : ClaseIdiomas.getTexto(getIdioma(), 'menuTimbradosProveedores'),
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
      ClaseCampoAbm(
        bObligatorio     : true,
        iAnchoCaracteres : 48,
        oTipo            : EnumTipoCampoAbm.texto,
        sClave           : 'nombreProveedor',
        sEtiqueta        : ClaseIdiomas.getTexto(sIdioma, 'timPrvNombre'),
        sHint            : ClaseIdiomas.getTexto(sIdioma, 'timPrvHintNombre'),
      ),

      // Los 5 campos comunes: timbrado, vigencia, afectaA, medioGeneracion.
      ...ClaseTimbradosComun.crearCampos(sIdioma),
    ];
  }

  // ── Datos de prueba (se reemplazarán por Firebird) ──────────────────────

  List<Map<String, dynamic>> crearRegistrosPrueba() {
    return <Map<String, dynamic>>[
      <String, dynamic>{
        'afectaA'         : '${ClaseAfectaA.factura},${ClaseAfectaA.notaDebito}',
        'fechaFin'        : '31/12/2026',
        'fechaInicio'     : '01/01/2025',
        'medioGeneracion' : ClaseMedioGeneracion.preImpresos,
        'nombreProveedor' : 'Distribuidora del Sur S.A.',
        'timbradoNumero'  : '11223344',
      },
      <String, dynamic>{
        'afectaA'         : '${ClaseAfectaA.factura},${ClaseAfectaA.notaCredito},${ClaseAfectaA.notaRemision}',
        'fechaFin'        : '',
        'fechaInicio'     : '01/06/2026',
        'medioGeneracion' : ClaseMedioGeneracion.documentosElectronicos,
        'nombreProveedor' : 'Importadora Brasil Ltda.',
        'timbradoNumero'  : '55667788',
      },
    ];
  }

}
