import 'package:flutter/material.dart';

import '../../generales/idiomas/idiomas.dart';
import '../../generales/modelos/campo_abm.dart';
import '../../generales/modelos/documentos.dart';
import '../../generales/preferencias/preferencias.dart';
import '../../generales/utilitarios/formatos.dart';
import '../../generales/validaciones/cap_validar.dart';
import '../../generales/varios/listas.dart';
import '../../generales/widgets/formulario_abm.dart';

/// Pantalla de la tabla Proveedores (ABM de múltiples registros).
///
/// Se muestra la grilla lateral izquierda y el botón Encontrar está habilitado.
class ClaseProveedores extends StatefulWidget {

  const ClaseProveedores({
    super.key,
    required this.oPreferencias,
  });

  final ClasePreferencias oPreferencias;

  @override
  State<ClaseProveedores> createState() => ClaseEstadoProveedores();
}

class ClaseEstadoProveedores extends State<ClaseProveedores> {

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
      sTitulo             : ClaseIdiomas.getTexto('menuProveedores', getIdioma()),
    );
  }

  String getIdioma() => widget.oPreferencias.getIdioma();

  // ── Validación cruzada ──────────────────────────────────────────────────

  /// El formato de la identificación depende del Tipo de identificación.
  String? validarRegistro(Map<String, dynamic> oRegistro) {
    final String sIdioma = getIdioma();
    return ClaseCapValidar.validarIdentificacion(
      (oRegistro['identificacion']      ?? '').toString(),
      (oRegistro['tipoIdentificacion']  ?? '').toString(),
      ClaseIdiomas.getTexto('prvIdentificacion', sIdioma),
      sIdioma,
    );
  }

  // ── Campos ──────────────────────────────────────────────────────────────

  List<ClaseCampoAbm> crearCampos() {

    final String sIdioma = getIdioma();

    return <ClaseCampoAbm>[
      ClaseCampoAbm(
        bCompletarCeros  : true,
        bObligatorio     : true,
        funcValidarCampo : (sValor, sIdioma) => ClaseCapValidar.validarSoloEntero(
            sValor, ClaseIdiomas.getTexto('prvCodigo', sIdioma), sIdioma),
        iAnchoCaracteres : 6,
        oTipo            : EnumTipoCampoAbm.texto,
        sClave           : 'codigo',
        sEtiqueta        : ClaseIdiomas.getTexto('prvCodigo', sIdioma),
      ),
      ClaseCampoAbm(
        bObligatorio     : true,
        iAnchoCaracteres : 40,
        oTipo            : EnumTipoCampoAbm.texto,
        sClave           : 'nombre',
        sEtiqueta        : ClaseIdiomas.getTexto('prvNombre', sIdioma),
        sHint            : ClaseIdiomas.getTexto('prvHintNombre', sIdioma),
      ),
      ClaseCampoAbm(
        iAnchoCaracteres : 60,
        oTipo            : EnumTipoCampoAbm.texto,
        sClave           : 'direccion',
        sEtiqueta        : ClaseIdiomas.getTexto('prvDireccion', sIdioma),
        sHint            : ClaseIdiomas.getTexto('prvHintDireccion', sIdioma),
      ),
      ClaseCampoAbm(
        iAnchoCaracteres : 15,
        oTipo            : EnumTipoCampoAbm.texto,
        sClave           : 'telefono',
        sEtiqueta        : ClaseIdiomas.getTexto('prvTelefono', sIdioma),
        sHint            : ClaseIdiomas.getTexto('prvHintTelefono', sIdioma),
      ),
      ClaseCampoAbm(
        iAnchoCaracteres : 15,
        oTipo            : EnumTipoCampoAbm.texto,
        sClave           : 'celular',
        sEtiqueta        : ClaseIdiomas.getTexto('prvCelular', sIdioma),
        sHint            : ClaseIdiomas.getTexto('prvHintCelular', sIdioma),
      ),
      ClaseCampoAbm(
        iAnchoCaracteres : 40,
        oTipo            : EnumTipoCampoAbm.texto,
        sClave           : 'localidad',
        sEtiqueta        : ClaseIdiomas.getTexto('prvLocalidad', sIdioma),
        sHint            : ClaseIdiomas.getTexto('prvHintLocalidad', sIdioma),
      ),
      ClaseCampoAbm(
        iAnchoCaracteres : 40,
        oTipo            : EnumTipoCampoAbm.texto,
        sClave           : 'email',
        sEtiqueta        : ClaseIdiomas.getTexto('prvEmail', sIdioma),
        sHint            : ClaseIdiomas.getTexto('prvHintEmail', sIdioma),
      ),
      ClaseCampoAbm(
        iAnchoCaracteres : funcAnchoOpcion(
            ClaseTipoIdentificacion.getListOpciones(sIdioma)),
        listOpciones     : ClaseTipoIdentificacion.getListOpciones(sIdioma),
        listValores      : ClaseTipoIdentificacion.listValores,
        oTipo            : EnumTipoCampoAbm.lista,
        sClave           : 'tipoIdentificacion',
        sEtiqueta        : ClaseIdiomas.getTexto('prvTipoIdentificacion', sIdioma),
        sValorDefecto    : ClaseTipoIdentificacion.ruc,
      ),
      ClaseCampoAbm(
        bObligatorio     : true,
        iAnchoCaracteres : 15,
        oTipo            : EnumTipoCampoAbm.texto,
        sClave           : 'identificacion',
        sEtiqueta        : ClaseIdiomas.getTexto('prvIdentificacion', sIdioma),
        sHint            : ClaseIdiomas.getTexto('prvHintIdentificacion', sIdioma),
      ),
      ClaseCampoAbm(
        iAnchoCaracteres : funcAnchoOpcion(ClaseLocalExterior.getListOpciones(sIdioma)),
        listOpciones     : ClaseLocalExterior.getListOpciones(sIdioma),
        listValores      : ClaseLocalExterior.listValores,
        oTipo            : EnumTipoCampoAbm.lista,
        sClave           : 'tipoProveedor',
        sEtiqueta        : ClaseIdiomas.getTexto('prvTipoProveedor', sIdioma),
        sValorDefecto    : ClaseLocalExterior.local,
      ),
      ClaseCampoAbm(
        iAnchoCaracteres : funcAnchoOpcion(ClaseSiNo.getListOpciones(sIdioma)),
        listOpciones     : ClaseSiNo.getListOpciones(sIdioma),
        listValores      : ClaseSiNo.listValores,
        oTipo            : EnumTipoCampoAbm.lista,
        sClave           : 'esServicioPublico',
        sEtiqueta        : ClaseIdiomas.getTexto('prvEsServicioPublico', sIdioma),
        sValorDefecto    : ClaseSiNo.no,
      ),
    ];
  }

  // ── Datos de prueba (se reemplazarán por Firebird) ──────────────────────

  List<Map<String, dynamic>> crearRegistrosPrueba() {
    return <Map<String, dynamic>>[
      <String, dynamic>{
        'celular'            : '0981 987 654',
        'codigo'             : '000001',
        'direccion'          : 'Av. Mariscal López 2500',
        'email'              : 'pedro@email.com',
        'esServicioPublico'  : ClaseSiNo.no,
        'identificacion'     : '80098765-9',
        'localidad'          : 'Asunción',
        'nombre'             : 'Distribuidora del Sur S.A.',
        'telefono'           : '021 300 200',
        'tipoIdentificacion' : ClaseTipoIdentificacion.ruc,
        'tipoProveedor'      : ClaseLocalExterior.local,
      },
      <String, dynamic>{
        'celular'            : '0983 456 789',
        'codigo'             : '000002',
        'direccion'          : 'Ruta Transchaco Km 5',
        'email'              : 'contacto@essap.com.py',
        'esServicioPublico'  : ClaseSiNo.si,
        'identificacion'     : '80011223-7',
        'localidad'          : 'Loma Plata',
        'nombre'             : 'Energía S.A.',
        'telefono'           : '021 400 300',
        'tipoIdentificacion' : ClaseTipoIdentificacion.ruc,
        'tipoProveedor'      : ClaseLocalExterior.local,
      },
      <String, dynamic>{
        'celular'            : '+55 11 98765 4321',
        'codigo'             : '000003',
        'direccion'          : 'Av. Paulista 1000',
        'email'              : 'import@brasil.com.br',
        'esServicioPublico'  : ClaseSiNo.no,
        'identificacion'     : 'EX789012',
        'localidad'          : 'Ciudad del Este',
        'nombre'             : 'Importadora Brasil Ltda.',
        'telefono'           : '061 500 400',
        'tipoIdentificacion' : ClaseTipoIdentificacion.cedulaExtranjera,
        'tipoProveedor'      : ClaseLocalExterior.exterior,
      },
    ];
  }

}
