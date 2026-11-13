import 'package:flutter/material.dart';

import '../../generales/idiomas/idiomas.dart';
import '../../generales/modelos/campo_abm.dart';
import '../../generales/preferencias/preferencias.dart';
import '../../generales/utilitarios/formatos.dart';
import '../../generales/validaciones/cap_validar.dart';
import '../../generales/varios/listas.dart';
import '../../generales/widgets/formulario_abm.dart';

/// Pantalla de la tabla Clientes (ABM de múltiples registros).
///
/// Se muestra la grilla lateral izquierda y el botón Encontrar está habilitado.
class ClaseClientes extends StatefulWidget {

  const ClaseClientes({
    super.key,
    required this.oPreferencias,
  });

  final ClasePreferencias oPreferencias;

  @override
  State<ClaseClientes> createState() => ClaseEstadoClientes();
}

class ClaseEstadoClientes extends State<ClaseClientes> {

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
      sTitulo             : ClaseIdiomas.getTexto(getIdioma(), 'menuClientes'),
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
      ClaseIdiomas.getTexto(sIdioma, 'cliIdentificacion'),
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
            sValor, ClaseIdiomas.getTexto(sIdioma, 'cliCodigo'), sIdioma),
        iAnchoCaracteres : 6,
        oTipo            : EnumTipoCampoAbm.texto,
        sClave           : 'codigo',
        sEtiqueta        : ClaseIdiomas.getTexto(sIdioma, 'cliCodigo'),
      ),
      ClaseCampoAbm(
        bObligatorio     : true,
        iAnchoCaracteres : 40,
        oTipo            : EnumTipoCampoAbm.texto,
        sClave           : 'nombre',
        sEtiqueta        : ClaseIdiomas.getTexto(sIdioma, 'cliNombre'),
        sHint            : ClaseIdiomas.getTexto(sIdioma, 'cliHintNombre'),
      ),
      ClaseCampoAbm(
        iAnchoCaracteres : 60,
        oTipo            : EnumTipoCampoAbm.texto,
        sClave           : 'direccion',
        sEtiqueta        : ClaseIdiomas.getTexto(sIdioma, 'cliDireccion'),
        sHint            : ClaseIdiomas.getTexto(sIdioma, 'cliHintDireccion'),
      ),
      ClaseCampoAbm(
        iAnchoCaracteres : 15,
        oTipo            : EnumTipoCampoAbm.texto,
        sClave           : 'telefono',
        sEtiqueta        : ClaseIdiomas.getTexto(sIdioma, 'cliTelefono'),
        sHint            : ClaseIdiomas.getTexto(sIdioma, 'cliHintTelefono'),
      ),
      ClaseCampoAbm(
        iAnchoCaracteres : 15,
        oTipo            : EnumTipoCampoAbm.texto,
        sClave           : 'celular',
        sEtiqueta        : ClaseIdiomas.getTexto(sIdioma, 'cliCelular'),
        sHint            : ClaseIdiomas.getTexto(sIdioma, 'cliHintCelular'),
      ),
      ClaseCampoAbm(
        iAnchoCaracteres : 40,
        oTipo            : EnumTipoCampoAbm.texto,
        sClave           : 'localidad',
        sEtiqueta        : ClaseIdiomas.getTexto(sIdioma, 'cliLocalidad'),
        sHint            : ClaseIdiomas.getTexto(sIdioma, 'cliHintLocalidad'),
      ),
      ClaseCampoAbm(
        iAnchoCaracteres : 40,
        oTipo            : EnumTipoCampoAbm.texto,
        sClave           : 'email',
        sEtiqueta        : ClaseIdiomas.getTexto(sIdioma, 'cliEmail'),
        sHint            : ClaseIdiomas.getTexto(sIdioma, 'cliHintEmail'),
      ),
      ClaseCampoAbm(
        iAnchoCaracteres : funcAnchoOpcion(
            ClaseTipoIdentificacion.getListOpciones(sIdioma)),
        listOpciones     : ClaseTipoIdentificacion.getListOpciones(sIdioma),
        listValores      : ClaseTipoIdentificacion.listValores,
        oTipo            : EnumTipoCampoAbm.lista,
        sClave           : 'tipoIdentificacion',
        sEtiqueta        : ClaseIdiomas.getTexto(sIdioma, 'cliTipoIdentificacion'),
        sValorDefecto    : ClaseTipoIdentificacion.ruc,
      ),
      ClaseCampoAbm(
        bObligatorio     : true,
        iAnchoCaracteres : 15,
        oTipo            : EnumTipoCampoAbm.texto,
        sClave           : 'identificacion',
        sEtiqueta        : ClaseIdiomas.getTexto(sIdioma, 'cliIdentificacion'),
        sHint            : ClaseIdiomas.getTexto(sIdioma, 'cliHintIdentificacion'),
      ),
      ClaseCampoAbm(
        iAnchoCaracteres : funcAnchoOpcion(ClaseLocalExterior.getListOpciones(sIdioma)),
        listOpciones     : ClaseLocalExterior.getListOpciones(sIdioma),
        listValores      : ClaseLocalExterior.listValores,
        oTipo            : EnumTipoCampoAbm.lista,
        sClave           : 'tipoCliente',
        sEtiqueta        : ClaseIdiomas.getTexto(sIdioma, 'cliTipoCliente'),
        sValorDefecto    : ClaseLocalExterior.local,
      ),
      ClaseCampoAbm(
        iAnchoCaracteres : funcAnchoOpcion(ClaseSiNo.getListOpciones(sIdioma)),
        listOpciones     : ClaseSiNo.getListOpciones(sIdioma),
        listValores      : ClaseSiNo.listValores,
        oTipo            : EnumTipoCampoAbm.lista,
        sClave           : 'esDiplomatico',
        sEtiqueta        : ClaseIdiomas.getTexto(sIdioma, 'cliEsDiplomatico'),
        sValorDefecto    : ClaseSiNo.no,
      ),
    ];
  }

  // ── Datos de prueba (se reemplazarán por Firebird) ──────────────────────

  List<Map<String, dynamic>> crearRegistrosPrueba() {
    return <Map<String, dynamic>>[
      <String, dynamic>{
        'celular'            : '0981 123 456',
        'codigo'             : '000001',
        'direccion'          : 'Av. España 1234',
        'email'              : 'juan@email.com',
        'esDiplomatico'      : ClaseSiNo.no,
        'identificacion'     : '1234567-9',
        'localidad'          : 'Asunción',
        'nombre'             : 'Juan Pérez',
        'telefono'           : '021 500 400',
        'tipoCliente'        : ClaseLocalExterior.local,
        'tipoIdentificacion' : ClaseTipoIdentificacion.ruc,
      },
      <String, dynamic>{
        'celular'            : '0982 654 321',
        'codigo'             : '000002',
        'direccion'          : 'Mariscal López 567',
        'email'              : 'maria@email.com',
        'esDiplomatico'      : ClaseSiNo.no,
        'identificacion'     : '2345678',
        'localidad'          : 'Luque',
        'nombre'             : 'María González',
        'telefono'           : '021 600 500',
        'tipoCliente'        : ClaseLocalExterior.local,
        'tipoIdentificacion' : ClaseTipoIdentificacion.cedula,
      },
      <String, dynamic>{
        'celular'            : '+33 6 12 34 56 78',
        'codigo'             : '000003',
        'direccion'          : 'Ruta 1 Km 8',
        'email'              : 'pierre@email.com',
        'esDiplomatico'      : ClaseSiNo.si,
        'identificacion'     : 'AB123456',
        'localidad'          : 'Encarnación',
        'nombre'             : 'Pierre Dupont',
        'telefono'           : '071 200 300',
        'tipoCliente'        : ClaseLocalExterior.exterior,
        'tipoIdentificacion' : ClaseTipoIdentificacion.pasaporte,
      },
    ];
  }

}
