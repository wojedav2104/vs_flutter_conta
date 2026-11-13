import 'package:flutter/material.dart';

import '../../generales/idiomas/idiomas.dart';
import '../../generales/modelos/campo_abm.dart';
import '../../generales/preferencias/preferencias.dart';
import '../../generales/validaciones/cap_validar.dart';
import '../../generales/widgets/formulario_abm.dart';

/// Pantalla de la tabla Cuentas asignadas (ABM de múltiples registros).
///
/// Estas cuentas se utilizarán cuando la aplicación necesite realizar
/// procesos sin intervención del usuario (asientos de compra/venta,
/// cierre del ejercicio, etc.). Cada registro corresponde a un
/// ejercicio contable y a una sucursal.
///
/// Todos los campos de cuentas son opcionales y deben contener números
/// con el formato 9.99.99.99 (ejemplos: 1, 1.01, 1.01.04, 2.03.05.17).
/// Al conectar la Base de Datos serán búsquedas desde el Plan de Cuentas.
class ClaseCuentasAsignadas extends StatefulWidget {

  const ClaseCuentasAsignadas({
    super.key,
    required this.oPreferencias,
  });

  final ClasePreferencias oPreferencias;

  @override
  State<ClaseCuentasAsignadas> createState() => ClaseEstadoCuentasAsignadas();
}

class ClaseEstadoCuentasAsignadas extends State<ClaseCuentasAsignadas> {

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
      listCampos    : listCampos,
      listRegistros : listRegistros,
      oPreferencias : widget.oPreferencias,
      sTitulo       : ClaseIdiomas.getTexto(getIdioma(), 'menuCuentasAsignadas'),
    );
  }

  String getIdioma() => widget.oPreferencias.getIdioma();

  // ── Utilidades ──────────────────────────────────────────────────────────

  /// Crea un campo de cuenta con validación de formato y hint específico.
  ClaseCampoAbm crearCampoCuenta(String sClave, String sClaveEtiqueta, String sClaveHint) {
    return ClaseCampoAbm(
      iAnchoCaracteres : 58,
      oTipo            : EnumTipoCampoAbm.texto,
      sClave           : sClave,
      sEtiqueta        : ClaseIdiomas.getTexto(getIdioma(), sClaveEtiqueta),
      sHint            : ClaseIdiomas.getTexto(getIdioma(), sClaveHint),
      funcValidarCampo : (sValor, sIdioma) => ClaseCapValidar.validarFormatoCuenta(
          sValor, ClaseIdiomas.getTexto(sIdioma, sClaveEtiqueta), sIdioma),
    );
  }

  // ── Campos ──────────────────────────────────────────────────────────────

  List<ClaseCampoAbm> crearCampos() {

    final String sIdioma = getIdioma();

    return <ClaseCampoAbm>[

      // ── Identificación del registro ──────────────────────────────────────
      ClaseCampoAbm(
        bObligatorio     : true,
        funcValidarCampo : (sValor, sIdioma) => ClaseCapValidar.validarEjercicio(
            sValor, ClaseIdiomas.getTexto(sIdioma, 'ctaEjercicio'), sIdioma),
        iAnchoCaracteres : 4,
        oTipo            : EnumTipoCampoAbm.numero,
        sClave           : 'ejercicio',
        sEtiqueta        : ClaseIdiomas.getTexto(sIdioma, 'ctaEjercicio'),
        sValorDefecto    : DateTime.now().year.toString(),
      ),

      ClaseCampoAbm(
        bObligatorio     : true,
        iAnchoCaracteres : 44,
        oTipo            : EnumTipoCampoAbm.texto,
        sClave           : 'sucursal',
        sEtiqueta        : ClaseIdiomas.getTexto(sIdioma, 'ctaSucursal'),
        sHint            : ClaseIdiomas.getTexto(sIdioma, 'ctaHintSucursal'),
      ),

      // ── Cuentas ──────────────────────────────────────────────────────────
      crearCampoCuenta('caja',                  'ctaCaja',                  'ctaHintCaja'),
      crearCampoCuenta('ivaCredito10',          'ctaIvaCredito10',          'ctaHintIvaCredito10'),
      crearCampoCuenta('ivaCredito5',           'ctaIvaCredito5',           'ctaHintIvaCredito5'),
      crearCampoCuenta('ivaDebito10',           'ctaIvaDebito10',           'ctaHintIvaDebito10'),
      crearCampoCuenta('ivaDebito5',            'ctaIvaDebito5',            'ctaHintIvaDebito5'),
      crearCampoCuenta('mercaderiasExentas',    'ctaMercaderiasExentas',    'ctaHintMercExentas'),
      crearCampoCuenta('mercaderiasGravadas10', 'ctaMercaderiasGravadas10', 'ctaHintMercGravadas10'),
      crearCampoCuenta('mercaderiasGravadas5',  'ctaMercaderiasGravadas5',  'ctaHintMercGravadas5'),
      crearCampoCuenta('ventasExentas',         'ctaVentasExentas',         'ctaHintVentasExentas'),
      crearCampoCuenta('ventasGravadas10',      'ctaVentasGravadas10',      'ctaHintVentasGravadas10'),
      crearCampoCuenta('ventasGravadas5',       'ctaVentasGravadas5',       'ctaHintVentasGravadas5'),
      crearCampoCuenta('debeVentaContado',      'ctaDebeVentaContado',      'ctaHintDebeVentaContado'),
      crearCampoCuenta('debeVentaCredito',      'ctaDebeVentaCredito',      'ctaHintDebeVentaCredito'),
      crearCampoCuenta('haberCompraContado',    'ctaHaberCompraContado',    'ctaHintHaberCompraContado'),
      crearCampoCuenta('haberCompraCredito',    'ctaHaberCompraCredito',    'ctaHintHaberCompraCredito'),
      crearCampoCuenta('resultadosEjercicio',   'ctaResultadosEjercicio',   'ctaHintResultados'),
    ];
  }

  // ── Datos de prueba (se reemplazarán por Firebird) ──────────────────────

  List<Map<String, dynamic>> crearRegistrosPrueba() {
    return <Map<String, dynamic>>[
      <String, dynamic>{
        'caja'                  : '1.01.01',
        'debeVentaContado'      : '1.02.01',
        'debeVentaCredito'      : '1.02.02',
        'ejercicio'             : '2026',
        'haberCompraContado'    : '2.01.01',
        'haberCompraCredito'    : '2.01.02',
        'ivaCredito10'          : '1.03.01',
        'ivaCredito5'           : '1.03.02',
        'ivaDebito10'           : '2.03.01',
        'ivaDebito5'            : '2.03.02',
        'mercaderiasExentas'    : '1.04.01',
        'mercaderiasGravadas10' : '1.04.02',
        'mercaderiasGravadas5'  : '1.04.03',
        'resultadosEjercicio'   : '3.01.01',
        'sucursal'              : '0001 - Sucursal Central',
        'ventasExentas'         : '4.01.01',
        'ventasGravadas10'      : '4.01.02',
        'ventasGravadas5'       : '4.01.03',
      },
      <String, dynamic>{
        'caja'                  : '1.01.01',
        'debeVentaContado'      : '1.02.01',
        'debeVentaCredito'      : '1.02.02',
        'ejercicio'             : '2025',
        'haberCompraContado'    : '2.01.01',
        'haberCompraCredito'    : '2.01.02',
        'ivaCredito10'          : '1.03.01',
        'ivaCredito5'           : '1.03.02',
        'ivaDebito10'           : '2.03.01',
        'ivaDebito5'            : '2.03.02',
        'mercaderiasExentas'    : '1.04.01',
        'mercaderiasGravadas10' : '1.04.02',
        'mercaderiasGravadas5'  : '1.04.03',
        'resultadosEjercicio'   : '3.01.01',
        'sucursal'              : '0002 - Sucursal Luque',
        'ventasExentas'         : '4.01.01',
        'ventasGravadas10'      : '4.01.02',
        'ventasGravadas5'       : '4.01.03',
      },
    ];
  }

}
