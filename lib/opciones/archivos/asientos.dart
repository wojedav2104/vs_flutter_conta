import 'package:flutter/material.dart';

import '../../generales/idiomas/idiomas.dart';
import '../../generales/modelos/campo_abm.dart';
import '../../generales/preferencias/preferencias.dart';
import '../../generales/validaciones/cap_validar.dart';
import '../../generales/widgets/formulario_cabecera_detalle.dart';


/// Pantalla de Asientos contables (ABM cabecera/detalle).
class ClaseAsientos extends StatefulWidget {

  const ClaseAsientos({
    super.key,
    required this.oPreferencias,
  });

  final ClasePreferencias oPreferencias;

  @override
  State<ClaseAsientos> createState() => ClaseEstadoAsientos();
}

class ClaseEstadoAsientos extends State<ClaseAsientos> {

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
      funcValidarRegistro  : validarRegistro,
      listCamposCabecera   : listCamposCabecera,
      listCamposDetalle    : listCamposDetalle,
      listCamposPie        : listCamposPie,
      listRegistros        : listRegistros,
      oPreferencias        : widget.oPreferencias,
      sTitulo              : ClaseIdiomas.getTexto(
                               widget.oPreferencias.getIdioma(), 'menuAsientos'),
    );
  }

  String getIdioma() => widget.oPreferencias.getIdioma();

  // ── Validación cruzada ──────────────────────────────────────────────────

  String? validarRegistro(Map<String, dynamic> oRegistro) {
    // Validar ejercicio primero para obtener el año
    final String sEjercicio = (oRegistro['ejercicio'] ?? '').toString().trim();
    final String sFecha     = (oRegistro['fechaAsiento'] ?? '').toString().trim();
    final int? iEjercicio   = int.tryParse(sEjercicio);
    if (iEjercicio != null && sFecha.isNotEmpty) {
      return ClaseCapValidar.validarFechaAsiento(
          sFecha, ClaseIdiomas.getTexto(getIdioma(), 'asiFecha'), iEjercicio, getIdioma());
    }
    return null;
  }

  // ── Campos de cabecera ──────────────────────────────────────────────────

  List<ClaseCampoAbm> crearCamposCabecera() {
    final String sIdioma = getIdioma();
    return <ClaseCampoAbm>[
      ClaseCampoAbm(
        bObligatorio     : true,
        funcValidarCampo : (sValor) => ClaseCapValidar.validarEjercicio(
            sValor, ClaseIdiomas.getTexto(sIdioma, 'planEjercicio'), sIdioma),
        iAnchoCaracteres : 4,
        oTipo            : EnumTipoCampoAbm.numero,
        sClave           : 'ejercicio',
        sEtiqueta        : ClaseIdiomas.getTexto(sIdioma, 'planEjercicio'),
      ),
      ClaseCampoAbm(
        bObligatorio     : true,
        iAnchoCaracteres : 44,
        oTipo            : EnumTipoCampoAbm.texto,
        sClave           : 'sucursal',
        sEtiqueta        : ClaseIdiomas.getTexto(sIdioma, 'ctaSucursal'),
        sHint            : ClaseIdiomas.getTexto(sIdioma, 'ctaHintSucursal'),
      ),
      ClaseCampoAbm(
        bObligatorio     : true,
        iAnchoCaracteres : 10,
        oTipo            : EnumTipoCampoAbm.fecha,
        sClave           : 'fechaAsiento',
        sEtiqueta        : ClaseIdiomas.getTexto(sIdioma, 'asiFecha'),
      ),
      ClaseCampoAbm(
        bSiempreDeshabilitado : true,
        iAnchoCaracteres      : 6,
        oTipo                 : EnumTipoCampoAbm.numero,
        sClave                : 'numeroAsiento',
        sEtiqueta             : ClaseIdiomas.getTexto(sIdioma, 'asiNumero'),
      ),
    ];
  }

  // ── Campos de detalle (grilla editable) ─────────────────────────────────

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
        sHint            : ClaseIdiomas.getTexto(sIdioma, 'asiHintCuenta'),
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
        iAnchoCaracteres : 40,
        oTipo            : EnumTipoCampoAbm.texto,
        sClave           : 'nombreCuenta',
        sEtiqueta        : ClaseIdiomas.getTexto(sIdioma, 'asiNombreCuenta'),
        sHint            : ClaseIdiomas.getTexto(sIdioma, 'asiHintNombreCuenta'),
      ),
      ClaseCampoAbm(
        iAnchoCaracteres : 15,
        oTipo            : EnumTipoCampoAbm.numero,
        sClave           : 'debe',
        sEtiqueta        : ClaseIdiomas.getTexto(sIdioma, 'asiDebe'),
        sMascara         : '999.999.999.999',
      ),
      ClaseCampoAbm(
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
        sEtiqueta        : ClaseIdiomas.getTexto(sIdioma, 'asiComentarios'),
        sHint            : ClaseIdiomas.getTexto(sIdioma, 'asiHintComentarios'),
      ),
    ];
  }

  // ── Datos de prueba ─────────────────────────────────────────────────────

  List<Map<String, dynamic>> crearRegistrosPrueba() {
    return <Map<String, dynamic>>[
      <String, dynamic>{
        'comentarios'    : 'Asiento de apertura del ejercicio',
        'ejercicio'      : '2026',
        'fechaAsiento'   : '02/01/2026',
        'numeroAsiento'  : '000001',
        'sucursal'       : '0001 - Sucursal Central',
        'detalles'       : <Map<String, dynamic>>[
          <String, dynamic>{
            'cuentaNumero' : '1.01',
            'subcuenta'    : '00001',
            'nombreCuenta' : 'Banco Nacional',
            'debe'         : '5.000.000',
            'haber'        : '',
            'concepto'     : 'Aporte inicial en efectivo',
          },
          <String, dynamic>{
            'cuentaNumero' : '3.01',
            'subcuenta'    : '',
            'nombreCuenta' : 'Capital Social',
            'debe'         : '',
            'haber'        : '5.000.000',
            'concepto'     : 'Aporte inicial socios',
          },
        ],
      },
      <String, dynamic>{
        'comentarios'    : 'Compra de mercaderías',
        'ejercicio'      : '2026',
        'fechaAsiento'   : '15/03/2026',
        'numeroAsiento'  : '000002',
        'sucursal'       : '0001 - Sucursal Central',
        'detalles'       : <Map<String, dynamic>>[
          <String, dynamic>{
            'cuentaNumero' : '1.04',
            'subcuenta'    : '',
            'nombreCuenta' : 'Mercaderías',
            'debe'         : '1.500.000',
            'haber'        : '',
            'concepto'     : 'Compra mercaderías marzo',
          },
          <String, dynamic>{
            'cuentaNumero' : '1.03',
            'subcuenta'    : '',
            'nombreCuenta' : 'IVA Crédito Fiscal',
            'debe'         : '150.000',
            'haber'        : '',
            'concepto'     : 'IVA 10% compra',
          },
          <String, dynamic>{
            'cuentaNumero' : '2.01',
            'subcuenta'    : '',
            'nombreCuenta' : 'Proveedores',
            'debe'         : '',
            'haber'        : '1.650.000',
            'concepto'     : 'Compra a crédito',
          },
        ],
      },
    ];
  }

}