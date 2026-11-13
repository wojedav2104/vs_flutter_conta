import 'package:flutter/material.dart';

import '../../generales/idiomas/idiomas.dart';
import '../../generales/modelos/campo_abm.dart';
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
      sTitulo             : ClaseIdiomas.getTexto(getIdioma(), 'menuProveedores'),
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
      ClaseIdiomas.getTexto(sIdioma, 'prvIdentificacion'),
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
            sValor, ClaseIdiomas.getTexto(sIdioma, 'prvCodigo'), sIdioma),
        iAnchoCaracteres : 6,
        oTipo            : EnumTipoCampoAbm.texto,
        sClave           : 'codigo',
        sEtiqueta        : ClaseIdiomas.getTexto(sIdioma, 'prvCodigo'),
      ),
      ClaseCampoAbm(
        bObligatorio     : true,
        iAnchoCaracteres : 40,
        oTipo            : EnumTipoCampoAbm.texto,
        sClave           : 'nombre',
        sEtiqueta        : ClaseIdiomas.getTexto(sIdioma, 'prvNombre'),
        sHint            : ClaseIdiomas.getTexto(sIdioma, 'prvHintNombre'),
      ),
      ClaseCampoAbm(
        iAnchoCaracteres : 60,
        oTipo            : EnumTipoCampoAbm.texto,
        sClave           : 'direccion',
        sEtiqueta        : ClaseIdiomas.getTexto(sIdioma, 'prvDireccion'),
        sHint            : ClaseIdiomas.getTexto(sIdioma, 'prvHintDireccion'),
      ),
      ClaseCampoAbm(
        iAnchoCaracteres : 15,
        oTipo            : EnumTipoCampoAbm.texto,
        sClave           : 'telefono',
        sEtiqueta        : ClaseIdiomas.getTexto(sIdioma, 'prvTelefono'),
        sHint            : ClaseIdiomas.getTexto(sIdioma, 'prvHintTelefono'),
      ),
      ClaseCampoAbm(
        iAnchoCaracteres : 15,
        oTipo            : EnumTipoCampoAbm.texto,
        sClave           : 'celular',
        sEtiqueta        : ClaseIdiomas.getTexto(sIdioma, 'prvCelular'),
        sHint            : ClaseIdiomas.getTexto(sIdioma, 'prvHintCelular'),
      ),
      ClaseCampoAbm(
        iAnchoCaracteres : 40,
        oTipo            : EnumTipoCampoAbm.texto,
        sClave           : 'localidad',
        sEtiqueta        : ClaseIdiomas.getTexto(sIdioma, 'prvLocalidad'),
        sHint            : ClaseIdiomas.getTexto(sIdioma, 'prvHintLocalidad'),
      ),
      ClaseCampoAbm(
        iAnchoCaracteres : 40,
        oTipo            : EnumTipoCampoAbm.texto,
        sClave           : 'email',
        sEtiqueta        : ClaseIdiomas.getTexto(sIdioma, 'prvEmail'),
        sHint            : ClaseIdiomas.getTexto(sIdioma, 'prvHintEmail'),
      ),
      ClaseCampoAbm(
        iAnchoCaracteres : funcAnchoOpcion(
            ClaseTipoIdentificacion.getListOpciones(sIdioma)),
        listOpciones     : ClaseTipoIdentificacion.getListOpciones(sIdioma),
        listValores      : ClaseTipoIdentificacion.listValores,
        oTipo            : EnumTipoCampoAbm.lista,
        sClave           : 'tipoIdentificacion',
        sEtiqueta        : ClaseIdiomas.getTexto(sIdioma, 'prvTipoIdentificacion'),
        sValorDefecto    : ClaseTipoIdentificacion.ruc,
      ),
      ClaseCampoAbm(
        bObligatorio     : true,
        iAnchoCaracteres : 15,
        oTipo            : EnumTipoCampoAbm.texto,
        sClave           : 'identificacion',
        sEtiqueta        : ClaseIdiomas.getTexto(sIdioma, 'prvIdentificacion'),
        sHint            : ClaseIdiomas.getTexto(sIdioma, 'prvHintIdentificacion'),
      ),
      ClaseCampoAbm(
        iAnchoCaracteres : funcAnchoOpcion(ClaseLocalExterior.getListOpciones(sIdioma)),
        listOpciones     : ClaseLocalExterior.getListOpciones(sIdioma),
        listValores      : ClaseLocalExterior.listValores,
        oTipo            : EnumTipoCampoAbm.lista,
        sClave           : 'tipoProveedor',
        sEtiqueta        : ClaseIdiomas.getTexto(sIdioma, 'prvTipoProveedor'),
        sValorDefecto    : ClaseLocalExterior.local,
      ),
      ClaseCampoAbm(
        iAnchoCaracteres : funcAnchoOpcion(ClaseSiNo.getListOpciones(sIdioma)),
        listOpciones     : ClaseSiNo.getListOpciones(sIdioma),
        listValores      : ClaseSiNo.listValores,
        oTipo            : EnumTipoCampoAbm.lista,
        sClave           : 'esServicioPublico',
        sEtiqueta        : ClaseIdiomas.getTexto(sIdioma, 'prvEsServicioPublico'),
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
