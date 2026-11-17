import 'package:flutter/material.dart';

import '../../generales/idiomas/idiomas.dart';
import '../../generales/modelos/campo_abm.dart';
import '../../generales/preferencias/preferencias.dart';
import '../../generales/utilitarios/formatos.dart';
import '../../generales/validaciones/cap_validar.dart';
import '../../generales/widgets/formulario_cabecera_detalle.dart';

/// Pantalla de la tabla Asientos (cabecera + grilla editable de detalles).
///
/// Cada registro lleva la cabecera (ejercicio, sucursal, fecha, número y
/// comentarios) y las filas del movimiento contable en la clave 'detalles':
/// cuenta, subcuenta, nombre de la cuenta, debe, haber y concepto.
///
/// Las validaciones de las filas (al menos una fila, uno solo del Debe o del
/// Haber por fila y suma del Debe = suma del Haber) viven en
/// ClaseFormularioCabeceraDetalle. Al conectar la Base de Datos, el nombre
/// de la cuenta se completará desde el Plan de Cuentas.
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
      funcValidarRegistro  : validarRegistro,
      listCamposCabecera   : listCamposCabecera,
      listCamposDetalle    : listCamposDetalle,
      listRegistros        : listRegistros,
      oPreferencias        : widget.oPreferencias,
      sClaveCampoAlPie     : 'comentarios',
      sTitulo              : ClaseIdiomas.getTexto('menuAsientos', getIdioma()),
    );
  }

  String getIdioma() => widget.oPreferencias.getIdioma();

  // ── Validación del registro completo (campos cruzados) ──────────────────

  /// La Fecha del asiento debe estar entre el 1 de enero del Ejercicio
  /// contable y a) la fecha de hoy si el ejercicio es el año actual, o
  /// b) el 31 de diciembre del ejercicio si es anterior al año actual.
  String? validarRegistro(Map<String, dynamic> oRegistro) {
    return ClaseCapValidar.validarFechaEnEjercicio(
      (oRegistro['fecha']     ?? '').toString(),
      (oRegistro['ejercicio'] ?? '').toString(),
      ClaseIdiomas.getTexto('asiFecha', getIdioma()),
      getIdioma(),
    );
  }

  // ── Campos de la cabecera ──────────────────────────────────────────────

  List<ClaseCampoAbm> crearCamposCabecera() {

    final String sIdioma = getIdioma();

    return <ClaseCampoAbm>[
      ClaseCampoAbm(
        bObligatorio     : true,
        funcValidarCampo : (sValor, sIdioma) => ClaseCapValidar.validarEjercicio(
            sValor, ClaseIdiomas.getTexto('asiEjercicio', sIdioma), sIdioma),
        iAnchoCaracteres : 4,
        oTipo            : EnumTipoCampoAbm.numero,
        sClave           : 'ejercicio',
        sEtiqueta        : ClaseIdiomas.getTexto('asiEjercicio', sIdioma),
        sValorDefecto    : ClaseFechas.getAnoMaximo().toString(),
      ),
      ClaseCampoAbm(
        bObligatorio     : true,
        iAnchoCaracteres : 44,
        oTipo            : EnumTipoCampoAbm.texto,
        sClave           : 'sucursal',
        sEtiqueta        : ClaseIdiomas.getTexto('asiSucursal', sIdioma),
        sHint            : ClaseIdiomas.getTexto('asiHintSucursal', sIdioma),
      ),
      ClaseCampoAbm(
        bObligatorio     : true,
        funcValidarCampo : (sValor, sIdioma) => ClaseCapValidar.validarFechaNoAnterior(
            sValor, ClaseIdiomas.getTexto('asiFecha', sIdioma),
            DateTime(ClaseFechas.iAnoMinimo, 1, 1), sIdioma),
        iAnchoCaracteres : 10,
        oTipo            : EnumTipoCampoAbm.fecha,
        sClave           : 'fecha',
        sEtiqueta        : ClaseIdiomas.getTexto('asiFecha', sIdioma),
      ),
      ClaseCampoAbm(
        bSiempreDeshabilitado : true,
        iAnchoCaracteres      : 6,
        oTipo                 : EnumTipoCampoAbm.numero,
        sClave                : 'numero',
        sEtiqueta             : ClaseIdiomas.getTexto('asiNumero', sIdioma),
      ),
      ClaseCampoAbm(
        iAnchoCaracteres : 60,
        iMaxComentario   : 500,
        oTipo            : EnumTipoCampoAbm.comentario,
        sClave           : 'comentarios',
        sEtiqueta        : ClaseIdiomas.getTexto('asiComentarios', sIdioma),
        sHint            : ClaseIdiomas.getTexto('asiHintComentarios', sIdioma),
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
        sHint            : ClaseIdiomas.getTexto('detHintCuenta', sIdioma),
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
        'comentarios' : 'Aporte de capital inicial',
        'detalles'    : <Map<String, String>>[
          <String, String>{
            'concepto'     : 'Aporte de capital',
            'cuenta'       : '1.01.01',
            'debe'         : '5000000',
            'haber'        : '',
            'nombreCuenta' : 'Caja',
            'subcuenta'    : '',
          },
          <String, String>{
            'concepto'     : 'Aporte de capital',
            'cuenta'       : '3.01.01',
            'debe'         : '',
            'haber'        : '5000000',
            'nombreCuenta' : 'Capital Social',
            'subcuenta'    : '',
          },
        ],
        'ejercicio'   : '2026',
        'fecha'       : '05/01/2026',
        'numero'      : '1',
        'sucursal'    : '0001 - Sucursal Central',
      },
      <String, dynamic>{
        'comentarios' : 'Compra de mercadería para reventa',
        'detalles'    : <Map<String, String>>[
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
        'ejercicio'   : '2026',
        'fecha'       : '10/01/2026',
        'numero'      : '2',
        'sucursal'    : '0001 - Sucursal Central',
      },
    ];
  }

}