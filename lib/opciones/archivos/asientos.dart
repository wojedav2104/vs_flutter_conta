import 'package:flutter/material.dart';

import '../../generales/idiomas/idiomas.dart';
import '../../generales/modelos/campo_abm.dart';
import '../../generales/preferencias/preferencias.dart';
import '../../generales/utilitarios/formatos.dart';
import '../../generales/validaciones/cap_validar.dart';
import '../../generales/widgets/formulario_cabecera_detalle.dart';

/// Pantalla de la tabla Asientos (cabecera + grilla editable de detalles).
///
/// Cada registro lleva la cabecera (número, fecha y comentarios) y las filas
/// del movimiento contable en la clave 'detalles': cuenta, nombre de la
/// cuenta, subcuenta, concepto, debe y haber.
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
      listCamposCabecera : listCamposCabecera,
      listCamposDetalle  : listCamposDetalle,
      listRegistros      : listRegistros,
      oPreferencias      : widget.oPreferencias,
      sTitulo            : ClaseIdiomas.getTexto(getIdioma(), 'menuAsientos'),
    );
  }

  String getIdioma() => widget.oPreferencias.getIdioma();

  // ── Campos de la cabecera ──────────────────────────────────────────────

  List<ClaseCampoAbm> crearCamposCabecera() {

    final String sIdioma = getIdioma();

    return <ClaseCampoAbm>[
      ClaseCampoAbm(
        bObligatorio     : true,
        funcValidarCampo : (sValor, sIdioma) => ClaseCapValidar.validarSoloEntero(
            sValor, ClaseIdiomas.getTexto(sIdioma, 'asiNumero'), sIdioma),
        iAnchoCaracteres : 5,
        oTipo            : EnumTipoCampoAbm.numero,
        sClave           : 'numero',
        sEtiqueta        : ClaseIdiomas.getTexto(sIdioma, 'asiNumero'),
      ),
      ClaseCampoAbm(
        bObligatorio     : true,
        funcValidarCampo : (sValor, sIdioma) => ClaseCapValidar.validarFechaNoAnterior(
            sValor, ClaseIdiomas.getTexto(sIdioma, 'asiFecha'),
            DateTime(ClaseFechas.iAnioMinimo, 1, 1), sIdioma),
        iAnchoCaracteres : 10,
        oTipo            : EnumTipoCampoAbm.fecha,
        sClave           : 'fecha',
        sEtiqueta        : ClaseIdiomas.getTexto(sIdioma, 'asiFecha'),
      ),
      ClaseCampoAbm(
        iAnchoCaracteres : 60,
        iMaxComentario   : 500,
        oTipo            : EnumTipoCampoAbm.comentario,
        sClave           : 'comentarios',
        sEtiqueta        : ClaseIdiomas.getTexto(sIdioma, 'asiComentarios'),
        sHint            : ClaseIdiomas.getTexto(sIdioma, 'asiHintComentarios'),
      ),
    ];
  }

  // ── Columnas de la grilla de detalles ───────────────────────────────────

  List<ClaseCampoAbm> crearCamposDetalle() {

    final String sIdioma = getIdioma();

    return <ClaseCampoAbm>[
      ClaseCampoAbm(
        bObligatorio     : true,
        iAnchoCaracteres : 16,
        oTipo            : EnumTipoCampoAbm.texto,
        sClave           : 'cuenta',
        sEtiqueta        : ClaseIdiomas.getTexto(sIdioma, 'detCuenta'),
        sHint            : ClaseIdiomas.getTexto(sIdioma, 'detHintCuenta'),
      ),
      ClaseCampoAbm(
        iAnchoCaracteres : 40,
        oTipo            : EnumTipoCampoAbm.texto,
        sClave           : 'nombreCuenta',
        sEtiqueta        : ClaseIdiomas.getTexto(sIdioma, 'detNombreCuenta'),
        sHint            : ClaseIdiomas.getTexto(sIdioma, 'detHintNombreCuenta'),
      ),
      ClaseCampoAbm(
        funcValidarCampo : (sValor, sIdioma) => ClaseCapValidar.validarNumeroSubcuenta(
            sValor, ClaseIdiomas.getTexto(sIdioma, 'detSubcuenta'), sIdioma),
        iAnchoCaracteres : 5,
        oTipo            : EnumTipoCampoAbm.texto,
        sClave           : 'subcuenta',
        sEtiqueta        : ClaseIdiomas.getTexto(sIdioma, 'detSubcuenta'),
      ),
      ClaseCampoAbm(
        iAnchoCaracteres : 30,
        oTipo            : EnumTipoCampoAbm.texto,
        sClave           : 'concepto',
        sEtiqueta        : ClaseIdiomas.getTexto(sIdioma, 'detConcepto'),
        sHint            : ClaseIdiomas.getTexto(sIdioma, 'detHintConcepto'),
      ),
      ClaseCampoAbm(
        bTieneDecimales  : true,
        iAnchoCaracteres : 12,
        oTipo            : EnumTipoCampoAbm.numero,
        sClave           : 'debe',
        sEtiqueta        : ClaseIdiomas.getTexto(sIdioma, 'detDebe'),
      ),
      ClaseCampoAbm(
        bTieneDecimales  : true,
        iAnchoCaracteres : 12,
        oTipo            : EnumTipoCampoAbm.numero,
        sClave           : 'haber',
        sEtiqueta        : ClaseIdiomas.getTexto(sIdioma, 'detHaber'),
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
        'fecha'       : '05/01/2026',
        'numero'      : '1',
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
        'fecha'       : '10/01/2026',
        'numero'      : '2',
      },
    ];
  }

}
