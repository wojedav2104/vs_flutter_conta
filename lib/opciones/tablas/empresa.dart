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
      listCampos           : listCampos,
      listRegistros        : listRegistros,
      oPreferencias        : widget.oPreferencias,
      sTitulo              : ClaseIdiomas.getTexto(getIdioma(), 'menuEmpresa'),
    );
  }

  String getIdioma() => widget.oPreferencias.getIdioma();

  // ── Campos de los tres grupos ───────────────────────────────────────────

  List<ClaseCampoAbm> crearCampos() {

    final String sIdioma = getIdioma();

    // Códigos internos del tipo de IVA (solo se usan en esta pantalla).
    final List<String> listIvaOpciones = <String>[
      ClaseIdiomas.getTexto(sIdioma, 'empIvaGeneral'),
      ClaseIdiomas.getTexto(sIdioma, 'empIvaSimplificado'),
      ClaseIdiomas.getTexto(sIdioma, 'empNoPagaIva'),
    ];
    const List<String> listIvaValores = <String>['GEN', 'SIM', 'NPG'];

    return <ClaseCampoAbm>[

      // ── Grupo 1: Generales ──────────────────────────────────────────────
      ClaseCampoAbm(
        bObligatorio     : true,
        iAnchoCaracteres : 50,
        oTipo            : EnumTipoCampoAbm.texto,
        sClave           : 'nombre',
        sEtiqueta        : ClaseIdiomas.getTexto(sIdioma, 'empNombre'),
        sGrupo           : 'empGrupoGenerales',
        sHint            : ClaseIdiomas.getTexto(sIdioma, 'empHintNombre'),
      ),
      ClaseCampoAbm(
        iAnchoCaracteres : 25,
        oTipo            : EnumTipoCampoAbm.texto,
        sClave           : 'apellidos',
        sEtiqueta        : ClaseIdiomas.getTexto(sIdioma, 'empApellidos'),
        sGrupo           : 'empGrupoGenerales',
        sHint            : ClaseIdiomas.getTexto(sIdioma, 'empHintApellidos'),
      ),
      ClaseCampoAbm(
        iAnchoCaracteres : 25,
        oTipo            : EnumTipoCampoAbm.texto,
        sClave           : 'nombres',
        sEtiqueta        : ClaseIdiomas.getTexto(sIdioma, 'empNombres'),
        sGrupo           : 'empGrupoGenerales',
        sHint            : ClaseIdiomas.getTexto(sIdioma, 'empHintNombres'),
      ),
      ClaseCampoAbm(
        iAnchoCaracteres : 60,
        oTipo            : EnumTipoCampoAbm.texto,
        sClave           : 'ramo',
        sEtiqueta        : ClaseIdiomas.getTexto(sIdioma, 'empRamo'),
        sGrupo           : 'empGrupoGenerales',
        sHint            : ClaseIdiomas.getTexto(sIdioma, 'empHintRamo'),
      ),
      ClaseCampoAbm(
        iAnchoCaracteres : 60,
        oTipo            : EnumTipoCampoAbm.texto,
        sClave           : 'direccion',
        sEtiqueta        : ClaseIdiomas.getTexto(sIdioma, 'empDireccion'),
        sGrupo           : 'empGrupoGenerales',
        sHint            : ClaseIdiomas.getTexto(sIdioma, 'empHintDireccion'),
      ),
      ClaseCampoAbm(
        iAnchoCaracteres : 15,
        oTipo            : EnumTipoCampoAbm.texto,
        sClave           : 'telefono',
        sEtiqueta        : ClaseIdiomas.getTexto(sIdioma, 'empTelefono'),
        sGrupo           : 'empGrupoGenerales',
        sHint            : ClaseIdiomas.getTexto(sIdioma, 'empHintTelefono'),
      ),
      ClaseCampoAbm(
        bObligatorio     : true,
        iAnchoCaracteres : funcAnchoOpcion(ClasePaises.getListOpciones(sIdioma)),
        listOpciones     : ClasePaises.getListOpciones(sIdioma),
        listValores      : ClasePaises.getListValores(),
        oTipo            : EnumTipoCampoAbm.lista,
        sClave           : 'pais',
        sEtiqueta        : ClaseIdiomas.getTexto(sIdioma, 'empPais'),
        sGrupo           : 'empGrupoGenerales',
        sValorDefecto    : 'PRY',
      ),
      ClaseCampoAbm(
        bObligatorio     : true,
        iAnchoCaracteres : 29,
        oTipo            : EnumTipoCampoAbm.texto,
        sClave           : 'departamento',
        sEtiqueta        : ClaseIdiomas.getTexto(sIdioma, 'empDepartamento'),
        sGrupo           : 'empGrupoGenerales',
        sHint            : ClaseIdiomas.getTexto(sIdioma, 'empHintDepartamento'),
      ),
      ClaseCampoAbm(
        bObligatorio     : true,
        iAnchoCaracteres : 40,
        oTipo            : EnumTipoCampoAbm.texto,
        sClave           : 'localidad',
        sEtiqueta        : ClaseIdiomas.getTexto(sIdioma, 'empLocalidad'),
        sGrupo           : 'empGrupoGenerales',
        sHint            : ClaseIdiomas.getTexto(sIdioma, 'empHintLocalidad'),
      ),
      ClaseCampoAbm(
        iAnchoCaracteres : 40,
        oTipo            : EnumTipoCampoAbm.texto,
        sClave           : 'email',
        sEtiqueta        : ClaseIdiomas.getTexto(sIdioma, 'empEmail'),
        sGrupo           : 'empGrupoGenerales',
        sHint            : ClaseIdiomas.getTexto(sIdioma, 'empHintEmail'),
      ),
      ClaseCampoAbm(
        bObligatorio     : true,
        funcValidarCampo : (sValor, sIdioma) => ClaseCapValidar.validarRuc(
            sValor, ClaseIdiomas.getTexto(sIdioma, 'empRuc'), sIdioma),
        iAnchoCaracteres : 10,
        oTipo            : EnumTipoCampoAbm.texto,
        sClave           : 'ruc',
        sEtiqueta        : ClaseIdiomas.getTexto(sIdioma, 'empRuc'),
        sGrupo           : 'empGrupoGenerales',
        sHint            : ClaseIdiomas.getTexto(sIdioma, 'empHintRuc'),
      ),

      // ── Grupo 2: Varios ─────────────────────────────────────────────────
      ClaseCampoAbm(
        bObligatorio     : true,
        funcValidarCampo : (sValor, sIdioma) => ClaseCapValidar.validarEjercicio(
            sValor, ClaseIdiomas.getTexto(sIdioma, 'empEjercicio'), sIdioma),
        iAnchoCaracteres : 4,
        oTipo            : EnumTipoCampoAbm.numero,
        sClave           : 'ejercicio',
        sEtiqueta        : ClaseIdiomas.getTexto(sIdioma, 'empEjercicio'),
        sGrupo           : 'empGrupoVarios',
      ),

      // ── Grupo 3: Impuestos ──────────────────────────────────────────────
      ClaseCampoAbm(
        iAnchoCaracteres : funcAnchoOpcion(listIvaOpciones),
        listOpciones     : listIvaOpciones,
        listValores      : listIvaValores,
        oTipo            : EnumTipoCampoAbm.lista,
        sClave           : 'iva',
        sEtiqueta        : ClaseIdiomas.getTexto(sIdioma, 'empIva'),
        sGrupo           : 'empGrupoImpuestos',
        sValorDefecto    : 'GEN',
      ),
      ClaseCampoAbm(
        iAnchoCaracteres : funcAnchoOpcion(ClaseSiNo.getListOpciones(sIdioma)),
        listOpciones     : ClaseSiNo.getListOpciones(sIdioma),
        listValores      : ClaseSiNo.listValores,
        oTipo            : EnumTipoCampoAbm.lista,
        sClave           : 'ireSimple',
        sEtiqueta        : ClaseIdiomas.getTexto(sIdioma, 'empIreSimple'),
        sGrupo           : 'empGrupoImpuestos',
        sValorDefecto    : ClaseSiNo.no,
      ),
      ClaseCampoAbm(
        iAnchoCaracteres : funcAnchoOpcion(ClaseSiNo.getListOpciones(sIdioma)),
        listOpciones     : ClaseSiNo.getListOpciones(sIdioma),
        listValores      : ClaseSiNo.listValores,
        oTipo            : EnumTipoCampoAbm.lista,
        sClave           : 'irp',
        sEtiqueta        : ClaseIdiomas.getTexto(sIdioma, 'empIrp'),
        sGrupo           : 'empGrupoImpuestos',
        sValorDefecto    : ClaseSiNo.no,
      ),
    ];
  }

  // ── Datos de prueba (se reemplazarán por Firebird) ──────────────────────

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
        'pais'         : 'PRY',
        'ramo'         : 'Servicios contables',
        'ruc'          : '80012345-0',
        'telefono'     : '021 500 400',
      },
    ];
  }

}
