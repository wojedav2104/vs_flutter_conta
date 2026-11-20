import 'package:flutter/material.dart';

import '../../generales/idiomas/idiomas.dart';
import '../../generales/modelos/campo_abm.dart';
import '../../generales/preferencias/preferencias.dart';
import '../../generales/utilitarios/formatos.dart';
import '../../generales/validaciones/cap_validar.dart';
import '../../generales/varios/listas.dart';
import '../../generales/varios/paises.dart';
import '../../generales/widgets/formulario_abm.dart';

import '../../opciones/tablas/empresa.dart';

/// Pantalla del Plan de Cuentas (ABM de múltiples registros con pestañas).
///
/// Dos grupos: "Principal" (Plan de Cuentas local) y "Alternativo" (Plan de
/// Cuentas de Francia). Datos comunes (Ejercicio, Sucursal) fuera de pestañas.
///
/// Correspondencia uno a uno entre cada cuenta local y la cuenta de Francia.
/// Al conectar la Base de Datos, Cuenta Superior será búsqueda desde el
/// propio Plan de Cuentas.
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
      funcEtiquetaGrupo    : (String sClave) => (sClave == 'planPrincipal')
          ? '${ClaseIdiomas.getTexto('planPrincipal', getIdioma())} '
            '(${ClasePaises.getNombre(ClaseEmpresa.getPaisElegido(), getIdioma())})'
          : ClaseIdiomas.getTexto(sClave, getIdioma()),
      funcValidarRegistro  : validarRegistro,
      listCampos           : listCampos,
      listRegistros        : listRegistros,
      oPreferencias        : widget.oPreferencias,
      sTitulo              : ClaseIdiomas.getTexto('menuPlanCuentas', getIdioma()),
    );
  }

  String getIdioma() => widget.oPreferencias.getIdioma();

  // ── Habilitación dinámica ───────────────────────────────────────────────

  /// La cuenta superior se habilita solo si la cuenta tiene más de un grupo.
  bool habilitarCuentaSuperior(Map<String, String> mapValores, String sPrefijo) {
    return ClaseCapValidar.contarGruposCuenta(
        mapValores['${sPrefijo}NumeroCuenta'] ?? '') > 1;
  }

  // ── Actualización automática de campos dependientes ─────────────────────

  /// Por cada grupo (pri y alt):
  ///   · Nivel: se deriva de la cantidad de grupos de la cuenta (1.01.04 → 3).
  ///   · Cuenta superior: sugerida quitando el último grupo (1.01.04 → 1.01),
  ///     solo si está vacía (la jerarquía puede no seguir la numeración).
  ///     Se vacía sola si la cuenta es raíz (un solo grupo: "1", "10").
  Map<String, String>? actualizarCampos(Map<String, String> mapValores) {
    final Map<String, String> mapActualizaciones = <String, String>{};
    for (final String sPrefijo in <String>['pri', 'alt']) {
      final String sCuenta = (mapValores['${sPrefijo}NumeroCuenta'] ?? '').trim();
      if (ClaseCapValidar.esFormatoCuenta(sCuenta)) {
        mapActualizaciones['${sPrefijo}Nivel'] =
            '${ClaseCapValidar.contarGruposCuenta(sCuenta)}';
        // Solo se sugiere si está vacía (la jerarquía puede no seguir la
        // numeración); las raíces quedan sin superior.
        final String sSuperior = (mapValores['${sPrefijo}CuentaSuperior'] ?? '').trim();
        mapActualizaciones['${sPrefijo}CuentaSuperior'] =
            (ClaseCapValidar.contarGruposCuenta(sCuenta) <= 1)
                ? ''
                : (sSuperior.isEmpty
                    ? ClaseCapValidar.funcCuentaSuperior(sCuenta)
                    : sSuperior);
      }
    }
    return mapActualizaciones.isEmpty ? null : mapActualizaciones;
  }

  // ── Validación del registro completo ────────────────────────────────────

  /// La cuenta superior es obligatoria solo en las cuentas con más de un
  /// grupo (regla de ClaseCapValidar.validarCuentaSuperior): por eso el
  /// campo no lleva bObligatorio, que exigiría el dato también en las raíces.
  String? validarRegistro(Map<String, dynamic> oRegistro) {
    for (final String sPrefijo in <String>['pri', 'alt']) {
      final String? sError = ClaseCapValidar.validarCuentaSuperior(
        (oRegistro['${sPrefijo}NumeroCuenta']    ?? '').toString(),
        (oRegistro['${sPrefijo}CuentaSuperior']  ?? '').toString(),
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

    return <ClaseCampoAbm>[

      ClaseCampoAbm(
        bObligatorio     : true,
        funcValidarCampo : (sValor, sIdioma) => ClaseCapValidar.validarFormatoCuenta(sValor, ClaseIdiomas.getTexto('planNumeroCuenta', sIdioma), sIdioma),
        iAnchoCaracteres : 16,
        oTipo            : EnumTipoCampoAbm.texto,
        sClave           : '${sPrefijo}NumeroCuenta',
        sEtiqueta        : ClaseIdiomas.getTexto('planNumeroCuenta', sIdioma),
        sGrupo           : sGrupo,
        sHint            : ClaseIdiomas.getTexto('planHintCuenta', sIdioma),
      ),

      ClaseCampoAbm(
        bObligatorio     : true,
        funcValidarCampo : (sValor, sIdioma) => ClaseCapValidar.validarLongitudMinima(sValor, ClaseIdiomas.getTexto('planNombreCuenta', sIdioma), 3, sIdioma),
        iAnchoCaracteres : 40,
        oTipo            : EnumTipoCampoAbm.texto,
        sClave           : '${sPrefijo}NombreCuenta',
        sEtiqueta        : ClaseIdiomas.getTexto('planNombreCuenta', sIdioma),
        sGrupo           : sGrupo,
        sHint            : ClaseIdiomas.getTexto('planHintNombreCuenta', sIdioma),
      ),
      ClaseCampoAbm(
        bCompletarCeros  : true,
        funcValidarCampo : (sValor, sIdioma) => ClaseCapValidar.validarNumeroSubcuenta(sValor, ClaseIdiomas.getTexto('planNumeroSubcuenta', sIdioma), sIdioma),
        iAnchoCaracteres : 5,
        oTipo            : EnumTipoCampoAbm.texto,
        sClave           : '${sPrefijo}NumeroSubcuenta',
        sEtiqueta        : ClaseIdiomas.getTexto('planNumeroSubcuenta', sIdioma),
        sGrupo           : sGrupo,
      ),
      ClaseCampoAbm(
        iAnchoCaracteres : 40,
        oTipo            : EnumTipoCampoAbm.texto,
        sClave           : '${sPrefijo}NombreSubcuenta',
        sEtiqueta        : ClaseIdiomas.getTexto('planNombreSubcuenta', sIdioma),
        sGrupo           : sGrupo,
        sHint            : ClaseIdiomas.getTexto('planHintNombreSubcuenta', sIdioma),
      ),

      // Sin bObligatorio: la obligatoriedad condicional (>1 grupo) la
      // valida ClaseCapValidar.validarCuentaSuperior en validarRegistro.
      ClaseCampoAbm(
        funcActualizarEstado : (mapValores) => habilitarCuentaSuperior(mapValores, sPrefijo),
        iAnchoCaracteres     : 58,
        oTipo                : EnumTipoCampoAbm.texto,
        sClave               : '${sPrefijo}CuentaSuperior',
        sEtiqueta            : ClaseIdiomas.getTexto('planCuentaSuperior', sIdioma),
        sGrupo               : sGrupo,
        sHint                : ClaseIdiomas.getTexto('planHintCuentaSuperior', sIdioma),
      ),

      ClaseCampoAbm(
        bObligatorio     : true,
        funcValidarCampo : (sValor, sIdioma) => ClaseCapValidar.validarNivelCuenta(sValor, ClaseIdiomas.getTexto('planNivel', sIdioma), sIdioma),
        iAnchoCaracteres : 1,
        oTipo            : EnumTipoCampoAbm.numero,
        sClave           : '${sPrefijo}Nivel',
        sEtiqueta        : ClaseIdiomas.getTexto('planNivel', sIdioma),
        sGrupo           : sGrupo,
      ),

      ClaseCampoAbm(
        iAnchoCaracteres : funcAnchoOpcion(ClaseSiNo.getListOpciones(sIdioma)),
        listOpciones     : ClaseSiNo.getListOpciones(sIdioma),
        listValores      : ClaseSiNo.listValores,
        oTipo            : EnumTipoCampoAbm.lista,
        sClave           : '${sPrefijo}Asentable',
        sEtiqueta        : ClaseIdiomas.getTexto('planAsentable', sIdioma),
        sGrupo           : sGrupo,
      ),
    ];
  }

  List<ClaseCampoAbm> crearCampos() {

    final String sIdioma = getIdioma();

    return <ClaseCampoAbm>[

      // ── Datos comunes (sin grupo, siempre visibles) ──────────────────────
      ClaseCampoAbm(
        bObligatorio     : true,
        funcValidarCampo : (sValor, sIdioma) => ClaseCapValidar.validarEjercicio(sValor, ClaseIdiomas.getTexto('planEjercicio', sIdioma), sIdioma),
        iAnchoCaracteres : 4,
        oAlineacion      : EnumAlineacion.centro,
        oTipo            : EnumTipoCampoAbm.numero,
        sClave           : 'ejercicio',
        sEtiqueta        : ClaseIdiomas.getTexto('planEjercicio', sIdioma),
        sMascara         : '9.999',
        sValorDefecto    : DateTime.now().year.toString(),
      ),

      ClaseCampoAbm(
        bObligatorio     : true,
        iAnchoCaracteres : 44,
        oTipo            : EnumTipoCampoAbm.texto,
        sClave           : 'sucursal',
        sEtiqueta        : ClaseIdiomas.getTexto('planSucursal', sIdioma),
        sHint            : ClaseIdiomas.getTexto('planHintSucursal', sIdioma),
      ),

      // ── Grupo Principal (Plan de Cuentas local) ──────────────────────────
      ...crearCamposGrupo('pri', 'planPrincipal'),

      // ── Grupo Alternativo (Plan de Cuentas Francia) ──────────────────────
      ...crearCamposGrupo('alt', 'planAlternativo'),
    ];
  }

  // ── Datos de prueba (se reemplazarán por Firebird) ──────────────────────
  // La jerarquía no sigue la numeración: 2.01 depende de 1 (no de 2).

  List<Map<String, dynamic>> crearRegistrosPrueba() {
    return <Map<String, dynamic>>[
      <String, dynamic>{
        'altAsentable'         : ClaseSiNo.si,
        'altCuentaSuperior'    : '1',
        'altNivel'             : '2',
        'altNombreCuenta'      : 'Fonds commercial',
        'altNombreSubcuenta'   : '',
        'altNumeroCuenta'      : '2.01',
        'altNumeroSubcuenta'   : '',
        'ejercicio'            : '2026',
        'priAsentable'         : ClaseSiNo.si,
        'priCuentaSuperior'    : '1',
        'priNivel'             : '2',
        'priNombreCuenta'      : 'Caja y Bancos',
        'priNombreSubcuenta'   : 'Banco Nacional',
        'priNumeroCuenta'      : '1.01',
        'priNumeroSubcuenta'   : '00001',
        'sucursal'             : '0001 - Sucursal Central',
      },
      <String, dynamic>{
        'altAsentable'         : ClaseSiNo.no,
        'altCuentaSuperior'    : '',
        'altNivel'             : '1',
        'altNombreCuenta'      : 'Actif',
        'altNombreSubcuenta'   : '',
        'altNumeroCuenta'      : '1',
        'altNumeroSubcuenta'   : '',
        'ejercicio'            : '2026',
        'priAsentable'         : ClaseSiNo.no,
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
