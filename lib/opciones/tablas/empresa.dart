import 'package:flutter/material.dart';

import '../../generales/idiomas/idiomas.dart';
import '../../generales/modelos/campo_abm.dart';
import '../../generales/preferencias/preferencias.dart';
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
      sTitulo              : ClaseIdiomas.getTexto(
                               widget.oPreferencias.getIdioma(), 'menuEmpresa'),
    );
  }

  // ── Utilidades ──────────────────────────────────────────────────────────

  /// Ancho mínimo del campo: caracteres de la opción más larga.
  int calcularAncho(List<String> listOpciones) {
    int iAncho = 0;
    for (final String sOpcion in listOpciones) {
      if (sOpcion.length > iAncho) iAncho = sOpcion.length;
    }
    return iAncho;
  }

  // ── Campos de los tres grupos ───────────────────────────────────────────

  List<ClaseCampoAbm> crearCampos() {

    final String sIdioma = widget.oPreferencias.getIdioma();

    final List<String> listIva = <String>[
      ClaseIdiomas.getTexto(sIdioma, 'empIvaGeneral'),
      ClaseIdiomas.getTexto(sIdioma, 'empIvaSimplificado'),
      ClaseIdiomas.getTexto(sIdioma, 'empNoPagaIva'),
    ];
    final List<String> listPaises = <String>[
      'ARG - ${ClaseIdiomas.getTexto(sIdioma, 'paisArgentina')}',
      'PRY - ${ClaseIdiomas.getTexto(sIdioma, 'paisParaguay')}',
      'PER - ${ClaseIdiomas.getTexto(sIdioma, 'paisPeru')}',
    ];
    final List<String> listSiNo = <String>[
      ClaseIdiomas.getTexto(sIdioma, 'si'),
      ClaseIdiomas.getTexto(sIdioma, 'no'),
    ];

    return <ClaseCampoAbm>[

      // ── Grupo 1: Generales ──────────────────────────────────────────────────────────
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
        iAnchoCaracteres : calcularAncho(listPaises),
        listOpciones     : listPaises,
        oTipo            : EnumTipoCampoAbm.lista,
        sClave           : 'pais',
        sEtiqueta        : ClaseIdiomas.getTexto(sIdioma, 'empPais'),
        sGrupo           : 'empGrupoGenerales',
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
        iAnchoCaracteres : 10,
        oTipo            : EnumTipoCampoAbm.texto,
        sClave           : 'ruc',
        sEtiqueta        : ClaseIdiomas.getTexto(sIdioma, 'empRuc'),
        sGrupo           : 'empGrupoGenerales',
        sHint            : ClaseIdiomas.getTexto(sIdioma, 'empHintRuc'),
      ),

      // ── Grupo 2: Varios ─────────────────────────────────────────────────────────────
      ClaseCampoAbm(
        bObligatorio     : true,
        iAnchoCaracteres : 4,
        oTipo            : EnumTipoCampoAbm.numero,
        sClave           : 'ejercicio',
        sEtiqueta        : ClaseIdiomas.getTexto(sIdioma, 'empEjercicio'),
        sGrupo           : 'empGrupoVarios',
      ),

      // ── Grupo 3: Impuestos ──────────────────────────────────────────────────────────
      ClaseCampoAbm(
        iAnchoCaracteres : calcularAncho(listIva),
        listOpciones     : listIva,
        oTipo            : EnumTipoCampoAbm.lista,
        sClave           : 'iva',
        sEtiqueta        : ClaseIdiomas.getTexto(sIdioma, 'empIva'),
        sGrupo           : 'empGrupoImpuestos',
      ),
      ClaseCampoAbm(
        iAnchoCaracteres : calcularAncho(listSiNo),
        listOpciones     : listSiNo,
        oTipo            : EnumTipoCampoAbm.lista,
        sClave           : 'ireSimple',
        sEtiqueta        : ClaseIdiomas.getTexto(sIdioma, 'empIreSimple'),
        sGrupo           : 'empGrupoImpuestos',
      ),
      ClaseCampoAbm(
        iAnchoCaracteres : calcularAncho(listSiNo),
        listOpciones     : listSiNo,
        oTipo            : EnumTipoCampoAbm.lista,
        sClave           : 'irp',
        sEtiqueta        : ClaseIdiomas.getTexto(sIdioma, 'empIrp'),
        sGrupo           : 'empGrupoImpuestos',
      ),
    ];
  }

  // ── Datos de prueba (se reemplazarán por Firebird) ──────────────────────

  List<Map<String, dynamic>> crearRegistrosPrueba() {
    final String sIdioma = widget.oPreferencias.getIdioma();
    return <Map<String, dynamic>>[
      <String, dynamic>{
        'apellidos'    : '',
        'departamento' : 'Central',
        'direccion'    : 'Av. España 1234',
        'ejercicio'    : '2026',
        'email'        : 'info@empresa.com.py',
        'ireSimple'    : ClaseIdiomas.getTexto(sIdioma, 'no'),
        'irp'          : ClaseIdiomas.getTexto(sIdioma, 'si'),
        'iva'          : ClaseIdiomas.getTexto(sIdioma, 'empIvaGeneral'),
        'localidad'    : 'Luque',
        'nombre'       : 'Empresa de Prueba S.A.',
        'nombres'      : '',
        'pais'         : 'PRY - ${ClaseIdiomas.getTexto(sIdioma, 'paisParaguay')}',
        'ramo'         : 'Servicios contables',
        'ruc'          : '80012345-6',
        'telefono'     : '021 500 400',
      },
    ];
  }

}
