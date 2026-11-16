import 'package:flutter/material.dart';

import '../../generales/idiomas/idiomas.dart';
import '../../generales/modelos/campo_abm.dart';
import '../../generales/preferencias/preferencias.dart';
import '../../generales/utilitarios/formatos.dart';
import '../../generales/validaciones/cap_validar.dart';
import '../../generales/varios/listas.dart';
import '../../generales/varios/paises.dart';
import '../../generales/widgets/formulario_abm.dart';

/// Pantalla de la tabla Empresa (primer ABM con pestañas).
///
/// Reglas propias de esta tabla:
///   · Debe tener un solo registro: Agregar se deshabilita si ya hay uno.
///   · El botón Encontrar debe estar siempre deshabilitado.
class ClaseEmpresa extends StatefulWidget {

  const ClaseEmpresa({
    super.key,
    required this.oPreferencias,
  });

  final ClasePreferencias oPreferencias;

  /// Valor del campo 'pais' en los datos de prueba (es también el valor por
  /// defecto del campo).
  static const String sPaisDefecto = 'PRY';

  /// País del registro único de la Empresa.
  /// Por ahora devuelve sPaisDefecto; cuando haya conexión con la Base de
  /// Datos devolverá el país grabado en la tabla Empresa.
  static String getPaisElegido() {
    return sPaisDefecto;                                  // ← CAMBIO limpieza sPaisDefecto
  }

  @override
  State<ClaseEmpresa> createState() => ClaseEstadoEmpresa();
}

class ClaseEstadoEmpresa extends State<ClaseEmpresa> {

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
      bPermitirEncontrar   : false,
      bTablaUnSoloRegistro : true,
      funcAlPerderFoco     : completarRuc,
      listCampos           : listCampos,
      listRegistros        : listRegistros,
      oPreferencias        : widget.oPreferencias,
      sTitulo              : ClaseIdiomas.getTexto('menuEmpresa', getIdioma()),
    );
  }

  String getIdioma() => widget.oPreferencias.getIdioma();

  // ── Auto-completado al salir del campo ──────────────────────────────────

  /// Completa el guion y el dígito verificador del RUC cuando el usuario
  /// escribe solo la base ('80012345' → '80012345-0'), al salir del campo.
  /// Es una ayuda para el usuario: la validación al grabar sigue exigiendo
  /// el formato completo.
  String? completarRuc(String sClave, String sValor, Map<String, String> mapValores) {
    if (sClave != 'ruc') return null;
    return ClaseCapValidar.funcCompletarRuc(sValor);
  }
  // ── Campos de los tres grupos ───────────────────────────────────────────

  List<ClaseCampoAbm> crearCampos() {

    final String sIdioma = getIdioma();

    // Códigos internos del tipo de IVA (solo se usan en esta pantalla).
    final List<String> listIvaOpciones = <String>[
      ClaseIdiomas.getTexto('empIvaGeneral', sIdioma),
      ClaseIdiomas.getTexto('empIvaSimplificado', sIdioma),
      ClaseIdiomas.getTexto('empNoPagaIva', sIdioma),
    ];
    const List<String> listIvaValores = <String>['GEN', 'SIM', 'NPG'];

    return <ClaseCampoAbm>[

      // ── Grupo 1: Generales ──────────────────────────────────────────────
      ClaseCampoAbm(
        bObligatorio     : true,
        iAnchoCaracteres : 50,
        oTipo            : EnumTipoCampoAbm.texto,
        sClave           : 'nombre',
        sEtiqueta        : ClaseIdiomas.getTexto('empNombre', sIdioma),
        sGrupo           : 'empGrupoGenerales',
        sHint            : ClaseIdiomas.getTexto('empHintNombre', sIdioma),
      ),
      ClaseCampoAbm(
        iAnchoCaracteres : 25,
        oTipo            : EnumTipoCampoAbm.texto,
        sClave           : 'apellidos',
        sEtiqueta        : ClaseIdiomas.getTexto('empApellidos', sIdioma),
        sGrupo           : 'empGrupoGenerales',
        sHint            : ClaseIdiomas.getTexto('empHintApellidos', sIdioma),
      ),
      ClaseCampoAbm(
        iAnchoCaracteres : 25,
        oTipo            : EnumTipoCampoAbm.texto,
        sClave           : 'nombres',
        sEtiqueta        : ClaseIdiomas.getTexto('empNombres', sIdioma),
        sGrupo           : 'empGrupoGenerales',
        sHint            : ClaseIdiomas.getTexto('empHintNombres', sIdioma),
      ),
      ClaseCampoAbm(
        iAnchoCaracteres : 60,
        oTipo            : EnumTipoCampoAbm.texto,
        sClave           : 'ramo',
        sEtiqueta        : ClaseIdiomas.getTexto('empRamo', sIdioma),
        sGrupo           : 'empGrupoGenerales',
        sHint            : ClaseIdiomas.getTexto('empHintRamo', sIdioma),
      ),
      ClaseCampoAbm(
        iAnchoCaracteres : 60,
        oTipo            : EnumTipoCampoAbm.texto,
        sClave           : 'direccion',
        sEtiqueta        : ClaseIdiomas.getTexto('empDireccion', sIdioma),
        sGrupo           : 'empGrupoGenerales',
        sHint            : ClaseIdiomas.getTexto('empHintDireccion', sIdioma),
      ),
      ClaseCampoAbm(
        iAnchoCaracteres : 15,
        oTipo            : EnumTipoCampoAbm.texto,
        sClave           : 'telefono',
        sEtiqueta        : ClaseIdiomas.getTexto('empTelefono', sIdioma),
        sGrupo           : 'empGrupoGenerales',
        sHint            : ClaseIdiomas.getTexto('empHintTelefono', sIdioma),
      ),
      ClaseCampoAbm(
        bObligatorio     : true,
        iAnchoCaracteres : funcAnchoOpcion(ClasePaises.getListOpciones(sIdioma)),
        listOpciones     : ClasePaises.getListOpciones(sIdioma),
        listValores      : ClasePaises.getListValores(),
        oTipo            : EnumTipoCampoAbm.lista,
        sClave           : 'pais',
        sEtiqueta        : ClaseIdiomas.getTexto('empPais', sIdioma),
        sGrupo           : 'empGrupoGenerales',
        sValorDefecto    : ClaseEmpresa.sPaisDefecto,     // ← CAMBIO limpieza sPaisDefecto
      ),
      ClaseCampoAbm(
        bObligatorio     : true,
        iAnchoCaracteres : 29,
        oTipo            : EnumTipoCampoAbm.texto,
        sClave           : 'departamento',
        sEtiqueta        : ClaseIdiomas.getTexto('empDepartamento', sIdioma),
        sGrupo           : 'empGrupoGenerales',
        sHint            : ClaseIdiomas.getTexto('empHintDepartamento', sIdioma),
      ),
      ClaseCampoAbm(
        bObligatorio     : true,
        iAnchoCaracteres : 40,
        oTipo            : EnumTipoCampoAbm.texto,
        sClave           : 'localidad',
        sEtiqueta        : ClaseIdiomas.getTexto('empLocalidad', sIdioma),
        sGrupo           : 'empGrupoGenerales',
        sHint            : ClaseIdiomas.getTexto('empHintLocalidad', sIdioma),
      ),
      ClaseCampoAbm(
        iAnchoCaracteres : 40,
        oTipo            : EnumTipoCampoAbm.texto,
        sClave           : 'email',
        sEtiqueta        : ClaseIdiomas.getTexto('empEmail', sIdioma),
        sGrupo           : 'empGrupoGenerales',
        sHint            : ClaseIdiomas.getTexto('empHintEmail', sIdioma),
      ),
      ClaseCampoAbm(
        bObligatorio     : true,
        funcValidarCampo : (sValor, sIdioma) => ClaseCapValidar.validarRuc(
            sValor, ClaseIdiomas.getTexto('empRuc', sIdioma), sIdioma),
        iAnchoCaracteres : 10,
        oTipo            : EnumTipoCampoAbm.texto,
        sClave           : 'ruc',
        sEtiqueta        : ClaseIdiomas.getTexto('empRuc', sIdioma),
        sGrupo           : 'empGrupoGenerales',
        sHint            : ClaseIdiomas.getTexto('empHintRuc', sIdioma),
      ),

      // ── Grupo 2: Varios ─────────────────────────────────────────────────
      ClaseCampoAbm(
        bObligatorio     : true,
        funcValidarCampo : (sValor, sIdioma) => ClaseCapValidar.validarEjercicio(
            sValor, ClaseIdiomas.getTexto('empEjercicio', sIdioma), sIdioma),
        iAnchoCaracteres : 4,
        oTipo            : EnumTipoCampoAbm.numero,
        sClave           : 'ejercicio',
        sEtiqueta        : ClaseIdiomas.getTexto('empEjercicio', sIdioma),
        sGrupo           : 'empGrupoVarios',
      ),

      // ── Grupo 3: Impuestos ──────────────────────────────────────────────
      ClaseCampoAbm(
        iAnchoCaracteres : funcAnchoOpcion(listIvaOpciones),
        listOpciones     : listIvaOpciones,
        listValores      : listIvaValores,
        oTipo            : EnumTipoCampoAbm.lista,
        sClave           : 'iva',
        sEtiqueta        : ClaseIdiomas.getTexto('empIva', sIdioma),
        sGrupo           : 'empGrupoImpuestos',
        sValorDefecto    : 'GEN',
      ),
      ClaseCampoAbm(
        iAnchoCaracteres : funcAnchoOpcion(ClaseSiNo.getListOpciones(sIdioma)),
        listOpciones     : ClaseSiNo.getListOpciones(sIdioma),
        listValores      : ClaseSiNo.listValores,
        oTipo            : EnumTipoCampoAbm.lista,
        sClave           : 'ireSimple',
        sEtiqueta        : ClaseIdiomas.getTexto('empIreSimple', sIdioma),
        sGrupo           : 'empGrupoImpuestos',
        sValorDefecto    : ClaseSiNo.no,
      ),
      ClaseCampoAbm(
        iAnchoCaracteres : funcAnchoOpcion(ClaseSiNo.getListOpciones(sIdioma)),
        listOpciones     : ClaseSiNo.getListOpciones(sIdioma),
        listValores      : ClaseSiNo.listValores,
        oTipo            : EnumTipoCampoAbm.lista,
        sClave           : 'irp',
        sEtiqueta        : ClaseIdiomas.getTexto('empIrp', sIdioma),
        sGrupo           : 'empGrupoImpuestos',
        sValorDefecto    : ClaseSiNo.no,
      ),
    ];
  }

  // ── Datos de prueba (se reemplazarán por Firebird) ──────────────────────
  // El RUC tiene dígito verificador válido según funcDigitoVerificador.

  List<Map<String, dynamic>> crearRegistrosPrueba() {
    return <Map<String, dynamic>>[
      <String, dynamic>{
        'apellidos'    : '',
        'departamento' : 'Central',
        'direccion'    : 'Av. España 1234',
        'ejercicio'    : '2026',
        'email'        : 'info@empresa.com.py',
        'ireSimple'    : ClaseSiNo.no,
        'irp'          : ClaseSiNo.si,
        'iva'          : 'GEN',
        'localidad'    : 'Luque',
        'nombre'       : 'Empresa de Prueba S.A.',
        'nombres'      : '',
        'pais'         : ClaseEmpresa.sPaisDefecto,       // ← CAMBIO limpieza sPaisDefecto
        'ramo'         : 'Servicios contables',
        'ruc'          : '80012345-0',
        'telefono'     : '021 500 400',
      },
    ];
  }

}

