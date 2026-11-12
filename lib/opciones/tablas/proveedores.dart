import 'package:flutter/material.dart';

import '../../generales/idiomas/idiomas.dart';
import '../../generales/modelos/campo_abm.dart';
import '../../generales/preferencias/preferencias.dart';
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
      listCampos    : listCampos,
      listRegistros : listRegistros,
      oPreferencias : widget.oPreferencias,
      sTitulo       : ClaseIdiomas.getTexto(
                        widget.oPreferencias.getIdioma(), 'menuProveedores'),
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
      ClaseIdiomas.getTexto(sIdioma, 'prvSinNombre'),
      ClaseIdiomas.getTexto(sIdioma, 'docDiplomatico'),
    ];
    final List<String> listTipoProveedor = <String>[
      ClaseIdiomas.getTexto(sIdioma, 'valorLocal'),
      ClaseIdiomas.getTexto(sIdioma, 'prvExterior'),
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
        iAnchoCaracteres : calcularAncho(listTipoIdentificacion),
        listOpciones     : listTipoIdentificacion,
        oTipo            : EnumTipoCampoAbm.lista,
        sClave           : 'tipoIdentificacion',
        sEtiqueta        : ClaseIdiomas.getTexto(sIdioma, 'prvTipoIdentificacion'),
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
        iAnchoCaracteres : calcularAncho(listTipoProveedor),
        listOpciones     : listTipoProveedor,
        oTipo            : EnumTipoCampoAbm.lista,
        sClave           : 'tipoProveedor',
        sEtiqueta        : ClaseIdiomas.getTexto(sIdioma, 'prvTipoProveedor'),
      ),
      ClaseCampoAbm(
        iAnchoCaracteres : calcularAncho(listSiNo),
        listOpciones     : listSiNo,
        oTipo            : EnumTipoCampoAbm.lista,
        sClave           : 'esServicioPublico',
        sEtiqueta        : ClaseIdiomas.getTexto(sIdioma, 'prvEsServicioPublico'),
      ),
    ];
  }

  // ── Datos de prueba (se reemplazarán por Firebird) ──────────────────────

  List<Map<String, dynamic>> crearRegistrosPrueba() {
    final String sIdioma = widget.oPreferencias.getIdioma();
    return <Map<String, dynamic>>[
      <String, dynamic>{
        'celular'            : '0981 987 654',
        'codigo'             : '000001',
        'direccion'          : 'Av. Mariscal López 2500',
        'email'              : 'pedro@email.com',
        'esServicioPublico'  : ClaseIdiomas.getTexto(sIdioma, 'no'),
        'identificacion'     : '80098765-4',
        'localidad'          : 'Asunción',
        'nombre'             : 'Distribuidora del Sur S.A.',
        'telefono'           : '021 300 200',
        'tipoProveedor'      : ClaseIdiomas.getTexto(sIdioma, 'valorLocal'),
        'tipoIdentificacion' : ClaseIdiomas.getTexto(sIdioma, 'docRuc'),
      },
      <String, dynamic>{
        'celular'            : '0983 456 789',
        'codigo'             : '000002',
        'direccion'          : 'Ruta Transchaco Km 5',
        'email'              : 'contacto@essap.com.py',
        'esServicioPublico'  : ClaseIdiomas.getTexto(sIdioma, 'si'),
        'identificacion'     : '80011223-9',
        'localidad'          : 'Loma Plata',
        'nombre'             : 'Energía S.A.',
        'telefono'           : '021 400 300',
        'tipoProveedor'      : ClaseIdiomas.getTexto(sIdioma, 'valorLocal'),
        'tipoIdentificacion' : ClaseIdiomas.getTexto(sIdioma, 'docRuc'),
      },
      <String, dynamic>{
        'celular'            : '+55 11 98765 4321',
        'codigo'             : '000003',
        'direccion'          : 'Av. Paulista 1000',
        'email'              : 'import@brasil.com.br',
        'esServicioPublico'  : ClaseIdiomas.getTexto(sIdioma, 'no'),
        'identificacion'     : 'EX789012',
        'localidad'          : 'Ciudad del Este',
        'nombre'             : 'Importadora Brasil Ltda.',
        'telefono'           : '061 500 400',
        'tipoProveedor'      : ClaseIdiomas.getTexto(sIdioma, 'prvExterior'),
        'tipoIdentificacion' : ClaseIdiomas.getTexto(sIdioma, 'docPasaporte'),
      },
    ];
  }

}
