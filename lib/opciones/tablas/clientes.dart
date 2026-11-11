import 'package:flutter/material.dart';

import '../../generales/idiomas/idiomas.dart';
import '../../generales/modelos/campo_abm.dart';
import '../../generales/preferencias/preferencias.dart';
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
      listCampos    : listCampos,
      listRegistros : listRegistros,
      oPreferencias : widget.oPreferencias,
      sTitulo       : ClaseIdiomas.getTexto(
                        widget.oPreferencias.getIdioma(), 'menuClientes'),
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

  // ── Campos ──────────────────────────────────────────────────────────────

  List<ClaseCampoAbm> crearCampos() {

    final String sIdioma = widget.oPreferencias.getIdioma();

    final List<String> listTipoIdentificacion = <String>[
      ClaseIdiomas.getTexto(sIdioma, 'docRuc'),
      ClaseIdiomas.getTexto(sIdioma, 'docCedulaIdentidad'),
      ClaseIdiomas.getTexto(sIdioma, 'docPasaporte'),
      ClaseIdiomas.getTexto(sIdioma, 'docCedulaExtranjera'),
      ClaseIdiomas.getTexto(sIdioma, 'cliSinNombre'),
      ClaseIdiomas.getTexto(sIdioma, 'docDiplomatico'),
    ];
    final List<String> listTipoCliente = <String>[
      ClaseIdiomas.getTexto(sIdioma, 'valorLocal'),
      ClaseIdiomas.getTexto(sIdioma, 'cliExterior'),
    ];
    final List<String> listSiNo = <String>[
      ClaseIdiomas.getTexto(sIdioma, 'si'),
      ClaseIdiomas.getTexto(sIdioma, 'no'),
    ];

    return <ClaseCampoAbm>[
      ClaseCampoAbm(
        bObligatorio     : true,
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
        iAnchoCaracteres : calcularAncho(listTipoIdentificacion),
        listOpciones     : listTipoIdentificacion,
        oTipo            : EnumTipoCampoAbm.lista,
        sClave           : 'tipoIdentificacion',
        sEtiqueta        : ClaseIdiomas.getTexto(sIdioma, 'cliTipoIdentificacion'),
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
        iAnchoCaracteres : calcularAncho(listTipoCliente),
        listOpciones     : listTipoCliente,
        oTipo            : EnumTipoCampoAbm.lista,
        sClave           : 'tipoCliente',
        sEtiqueta        : ClaseIdiomas.getTexto(sIdioma, 'cliTipoCliente'),
      ),
      ClaseCampoAbm(
        iAnchoCaracteres : calcularAncho(listSiNo),
        listOpciones     : listSiNo,
        oTipo            : EnumTipoCampoAbm.lista,
        sClave           : 'esDiplomatico',
        sEtiqueta        : ClaseIdiomas.getTexto(sIdioma, 'cliEsDiplomatico'),
      ),
    ];
  }

  // ── Datos de prueba (se reemplazarán por Firebird) ──────────────────────

  List<Map<String, dynamic>> crearRegistrosPrueba() {
    final String sIdioma = widget.oPreferencias.getIdioma();
    return <Map<String, dynamic>>[
      <String, dynamic>{
        'celular'            : '0981 123 456',
        'codigo'             : '000001',
        'direccion'          : 'Av. España 1234',
        'email'              : 'juan@email.com',
        'esDiplomatico'      : ClaseIdiomas.getTexto(sIdioma, 'no'),
        'identificacion'     : '80012345-6',
        'localidad'          : 'Asunción',
        'nombre'             : 'Juan Pérez',
        'telefono'           : '021 500 400',
        'tipoCliente'        : ClaseIdiomas.getTexto(sIdioma, 'valorLocal'),
        'tipoIdentificacion' : ClaseIdiomas.getTexto(sIdioma, 'docRuc'),
      },
      <String, dynamic>{
        'celular'            : '0982 654 321',
        'codigo'             : '000002',
        'direccion'          : 'Mariscal López 567',
        'email'              : 'maria@email.com',
        'esDiplomatico'      : ClaseIdiomas.getTexto(sIdioma, 'no'),
        'identificacion'     : '1234567',
        'localidad'          : 'Luque',
        'nombre'             : 'María González',
        'telefono'           : '021 600 500',
        'tipoCliente'        : ClaseIdiomas.getTexto(sIdioma, 'valorLocal'),
        'tipoIdentificacion' : ClaseIdiomas.getTexto(sIdioma, 'docCedulaIdentidad'),
      },
      <String, dynamic>{
        'celular'            : '+33 6 12 34 56 78',
        'codigo'             : '000003',
        'direccion'          : 'Ruta 1 Km 8',
        'email'              : 'pierre@email.com',
        'esDiplomatico'      : ClaseIdiomas.getTexto(sIdioma, 'si'),
        'identificacion'     : 'AB123456',
        'localidad'          : 'Encarnación',
        'nombre'             : 'Pierre Dupont',
        'telefono'           : '071 200 300',
        'tipoCliente'        : ClaseIdiomas.getTexto(sIdioma, 'cliExterior'),
        'tipoIdentificacion' : ClaseIdiomas.getTexto(sIdioma, 'docPasaporte'),
      },
    ];
  }

}
