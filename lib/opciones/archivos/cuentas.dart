import 'package:flutter/material.dart';

import '../../generales/idiomas/idiomas.dart';
import '../../generales/modelos/campo_abm.dart';
import '../../generales/preferencias/preferencias.dart';
import '../../generales/validaciones/cap_validar.dart';
import '../../generales/widgets/formulario_abm.dart';


/// Pantalla del Plan de Cuentas (ABM de múltiples registros con pestañas).
///
/// Dos grupos: "Principal" (Plan de Cuentas local) y "Alternativo" (Plan de
/// Cuentas de Francia). Datos comunes (Ejercicio, Sucursal) fuera de pestañas.
///
/// Correspondencia uno a uno entre cada cuenta local y la cuenta de Francia.
class ClaseCuentas extends StatefulWidget {

  const ClaseCuentas({
    super.key,
    required this.oPreferencias,
  });

  final ClasePreferencias oPreferencias;

  @override
  State<ClaseCuentas> createState() => ClaseEstadoCuentas();
}

class ClaseEstadoCuentas extends State<ClaseCuentas> {

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
      funcActualizarCampos : actualizarCampos,
      funcValidarRegistro  : validarRegistro,
      listCampos           : listCampos,
      listRegistros        : listRegistros,
      oPreferencias        : widget.oPreferencias,
      sTitulo              : ClaseIdiomas.getTexto(
                               widget.oPreferencias.getIdioma(), 'menuPlanCuentas'),
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

  // ── Habilitación dinámica ───────────────────────────────────────────────

  /// La cuenta superior se habilita solo si la cuenta tiene más de 1 dígito.
  bool habilitarCuentaSuperior(Map<String, String> mapValores, String sPrefijo) {
    return ClaseCapValidar.contarDigitosCuenta(
        mapValores['${sPrefijo}NumeroCuenta'] ?? '') > 1;
  }

  // ── Actualización automática de campos dependientes ─────────────────────

  /// Si la cuenta tiene 1 dígito, se vacía automáticamente la cuenta superior.
  Map<String, String>? actualizarCampos(Map<String, String> mapValores) {
    final Map<String, String> mapActualizaciones = <String, String>{};
    for (final String sPrefijo in <String>['pri', 'alt']) {
      final String sCuenta   = mapValores['${sPrefijo}NumeroCuenta'] ?? '';
      final String sSuperior = mapValores['${sPrefijo}CuentaSuperior'] ?? '';
      if (ClaseCapValidar.contarDigitosCuenta(sCuenta) <= 1 && sSuperior.isNotEmpty) {
        mapActualizaciones['${sPrefijo}CuentaSuperior'] = '';
      }
    }
    return mapActualizaciones.isNotEmpty ? mapActualizaciones : null;
  }

  // ── Validación del registro completo ────────────────────────────────────

  String? validarRegistro(Map<String, dynamic> oRegistro) {
    for (final String sPrefijo in <String>['pri', 'alt']) {
      final String? sError = ClaseCapValidar.validarCuentaSuperior(
        (oRegistro['${sPrefijo}NumeroCuenta'] ?? '').toString(),
        (oRegistro['${sPrefijo}CuentaSuperior'] ?? '').toString(),
        getIdioma(),
      );
      if (sError != null) return sError;
    }
    return null;
  }

  // ── Creación de campos ──────────────────────────────────────────────────

  /// Crea los 7 campos de un grupo (Principal o Alternativo).
  List<ClaseCampoAbm> crearCamposGrupo(String sPrefijo, String sGrupo) {
    final String sIdioma = getIdioma();

    final List<String> listSiNo = <String>[
      ClaseIdiomas.getTexto(sIdioma, 'si'),
      ClaseIdiomas.getTexto(sIdioma, 'no'),
    ];

    return <ClaseCampoAbm>[

      ClaseCampoAbm(
        bObligatorio     : true,
        funcValidarCampo : (sValor) => ClaseCapValidar.validarFormatoCuenta(
            sValor, ClaseIdiomas.getTexto(sIdioma, 'planNumeroCuenta'), sIdioma),
        iAnchoCaracteres : 16,
        oTipo            : EnumTipoCampoAbm.texto,
        sClave           : '${sPrefijo}NumeroCuenta',
        sEtiqueta        : ClaseIdiomas.getTexto(sIdioma, 'planNumeroCuenta'),
        sGrupo           : sGrupo,
        sHint            : ClaseIdiomas.getTexto(sIdioma, 'planHintCuenta'),
      ),

      ClaseCampoAbm(
        bObligatorio     : true,
        funcValidarCampo : (sValor) => ClaseCapValidar.validarLongitudMinima(
            sValor, ClaseIdiomas.getTexto(sIdioma, 'planNombreCuenta'), 3, sIdioma),
        iAnchoCaracteres : 40,
        oTipo            : EnumTipoCampoAbm.texto,
        sClave           : '${sPrefijo}NombreCuenta',
        sEtiqueta        : ClaseIdiomas.getTexto(sIdioma, 'planNombreCuenta'),
        sGrupo           : sGrupo,
        sHint            : ClaseIdiomas.getTexto(sIdioma, 'planHintNombreCuenta'),
      ),

      ClaseCampoAbm(
        funcValidarCampo : (sValor) => ClaseCapValidar.validarNumeroSubcuenta(
            sValor, ClaseIdiomas.getTexto(sIdioma, 'planNumeroSubcuenta'), sIdioma),
        iAnchoCaracteres : 5,
        oTipo            : EnumTipoCampoAbm.texto,
        sClave           : '${sPrefijo}NumeroSubcuenta',
        sEtiqueta        : ClaseIdiomas.getTexto(sIdioma, 'planNumeroSubcuenta'),
        sGrupo           : sGrupo,
      ),

      ClaseCampoAbm(
        iAnchoCaracteres : 40,
        oTipo            : EnumTipoCampoAbm.texto,
        sClave           : '${sPrefijo}NombreSubcuenta',
        sEtiqueta        : ClaseIdiomas.getTexto(sIdioma, 'planNombreSubcuenta'),
        sGrupo           : sGrupo,
        sHint            : ClaseIdiomas.getTexto(sIdioma, 'planHintNombreSubcuenta'),
      ),

      ClaseCampoAbm(
        bObligatorio         : true,
        funcActualizarEstado : (mapValores) => habilitarCuentaSuperior(mapValores, sPrefijo),
        iAnchoCaracteres     : 58,
        oTipo                : EnumTipoCampoAbm.texto,
        sClave               : '${sPrefijo}CuentaSuperior',
        sEtiqueta            : ClaseIdiomas.getTexto(sIdioma, 'planCuentaSuperior'),
        sGrupo               : sGrupo,
        sHint                : ClaseIdiomas.getTexto(sIdioma, 'planHintCuentaSuperior'),
      ),

      ClaseCampoAbm(
        bObligatorio     : true,
        funcValidarCampo : (sValor) => ClaseCapValidar.validarNivelCuenta(
            sValor, ClaseIdiomas.getTexto(sIdioma, 'planNivel'), sIdioma),
        iAnchoCaracteres : 1,
        oTipo            : EnumTipoCampoAbm.numero,
        sClave           : '${sPrefijo}Nivel',
        sEtiqueta        : ClaseIdiomas.getTexto(sIdioma, 'planNivel'),
        sGrupo           : sGrupo,
      ),

      ClaseCampoAbm(
        iAnchoCaracteres : calcularAncho(listSiNo),
        listOpciones     : listSiNo,
        oTipo            : EnumTipoCampoAbm.lista,
        sClave           : '${sPrefijo}Asentable',
        sEtiqueta        : ClaseIdiomas.getTexto(sIdioma, 'planAsentable'),
        sGrupo           : sGrupo,
      ),
    ];
  }

  List<ClaseCampoAbm> crearCampos() {
    final String sIdioma = getIdioma();

    return <ClaseCampoAbm>[

      // ── Datos comunes (sin grupo, siempre visibles) ──────────────────────────────────
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
        sEtiqueta        : ClaseIdiomas.getTexto(sIdioma, 'planSucursal'),
        sHint            : ClaseIdiomas.getTexto(sIdioma, 'planHintSucursal'),
      ),

      // ── Grupo Principal (Plan de Cuentas local) ──────────────────────────────────────
      ...crearCamposGrupo('pri', 'planPrincipal'),

      // ── Grupo Alternativo (Plan de Cuentas Francia) ──────────────────────────────────
      ...crearCamposGrupo('alt', 'planAlternativo'),
    ];
  }

  // ── Datos de prueba (se reemplazarán por Firebird) ──────────────────────

  List<Map<String, dynamic>> crearRegistrosPrueba() {
    final String sIdioma = getIdioma();
    return <Map<String, dynamic>>[
      <String, dynamic>{
        'altAsentable'         : ClaseIdiomas.getTexto(sIdioma, 'si'),
        'altCuentaSuperior'    : '1',
        'altNivel'             : '2',
        'altNombreCuenta'      : 'Fonds commercial',
        'altNombreSubcuenta'   : '',
        'altNumeroCuenta'      : '2.01',
        'altNumeroSubcuenta'   : '',
        'ejercicio'            : '2026',
        'priAsentable'         : ClaseIdiomas.getTexto(sIdioma, 'si'),
        'priCuentaSuperior'    : '1',
        'priNivel'             : '2',
        'priNombreCuenta'      : 'Caja y Bancos',
        'priNombreSubcuenta'   : 'Banco Nacional',
        'priNumeroCuenta'      : '1.01',
        'priNumeroSubcuenta'   : '00001',
        'sucursal'             : '0001 - Sucursal Central',
      },
      <String, dynamic>{
        'altAsentable'         : ClaseIdiomas.getTexto(sIdioma, 'no'),
        'altCuentaSuperior'    : '',
        'altNivel'             : '1',
        'altNombreCuenta'      : 'Actif',
        'altNombreSubcuenta'   : '',
        'altNumeroCuenta'      : '1',
        'altNumeroSubcuenta'   : '',
        'ejercicio'            : '2026',
        'priAsentable'         : ClaseIdiomas.getTexto(sIdioma, 'no'),
        'priCuentaSuperior'    : '',
        'priNivel'             : '1',
        'priNombreCuenta'      : 'Activo',
        'priNombreSubcuenta'   : '',
        'priNumeroCuenta'      : '1',
        'priNumeroSubcuenta'   : '',
        'sucursal'             : '0001 - Sucursal Central',
      },
    ];
  }

}
