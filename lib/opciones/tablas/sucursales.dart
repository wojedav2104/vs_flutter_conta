import 'package:flutter/material.dart';

import '../../generales/idiomas/idiomas.dart';
import '../../generales/modelos/campo_abm.dart';
import '../../generales/preferencias/preferencias.dart';
import '../../generales/widgets/formulario_abm.dart';


/// Pantalla de la tabla Sucursales (ABM de múltiples registros).
///
/// Una Empresa puede tener varias sucursales, por lo tanto se muestra la
/// grilla lateral izquierda y el botón Encontrar está habilitado.
class ClaseSucursales extends StatefulWidget {

  const ClaseSucursales({
    super.key,
    required this.oPreferencias,
  });

  final ClasePreferencias oPreferencias;

  @override
  State<ClaseSucursales> createState() => ClaseEstadoSucursales();
}

class ClaseEstadoSucursales extends State<ClaseSucursales> {

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
                        widget.oPreferencias.getIdioma(), 'menuSucursales'),
    );
  }

  // ── Campos ──────────────────────────────────────────────────────────────

  List<ClaseCampoAbm> crearCampos() {

    final String sIdioma = widget.oPreferencias.getIdioma();

    return <ClaseCampoAbm>[
      ClaseCampoAbm(
        bObligatorio     : true,
        iAnchoCaracteres : 4,
        oTipo            : EnumTipoCampoAbm.texto,
        sClave           : 'codigo',
        sEtiqueta        : ClaseIdiomas.getTexto(sIdioma, 'sucCodigo'),
      ),
      ClaseCampoAbm(
        bObligatorio     : true,
        iAnchoCaracteres : 40,
        oTipo            : EnumTipoCampoAbm.texto,
        sClave           : 'nombre',
        sEtiqueta        : ClaseIdiomas.getTexto(sIdioma, 'sucNombre'),
        sHint            : ClaseIdiomas.getTexto(sIdioma, 'sucHintNombre'),
      ),
      ClaseCampoAbm(
        iAnchoCaracteres : 60,
        oTipo            : EnumTipoCampoAbm.texto,
        sClave           : 'direccion',
        sEtiqueta        : ClaseIdiomas.getTexto(sIdioma, 'sucDireccion'),
        sHint            : ClaseIdiomas.getTexto(sIdioma, 'sucHintDireccion'),
      ),
      ClaseCampoAbm(
        iAnchoCaracteres : 15,
        oTipo            : EnumTipoCampoAbm.texto,
        sClave           : 'telefono',
        sEtiqueta        : ClaseIdiomas.getTexto(sIdioma, 'sucTelefono'),
        sHint            : ClaseIdiomas.getTexto(sIdioma, 'sucHintTelefono'),
      ),
      ClaseCampoAbm(
        bObligatorio     : true,
        iAnchoCaracteres : 40,
        oTipo            : EnumTipoCampoAbm.texto,
        sClave           : 'localidad',
        sEtiqueta        : ClaseIdiomas.getTexto(sIdioma, 'sucLocalidad'),
        sHint            : ClaseIdiomas.getTexto(sIdioma, 'sucHintLocalidad'),
      ),
    ];
  }

  // ── Datos de prueba (se reemplazarán por Firebird) ──────────────────────

  List<Map<String, dynamic>> crearRegistrosPrueba() {
    return <Map<String, dynamic>>[
      <String, dynamic>{
        'codigo'    : '0001',
        'nombre'    : 'Sucursal Central',
        'direccion' : 'Av. España 1234',
        'telefono'  : '021 500 400',
        'localidad' : 'Asunción',
      },
      <String, dynamic>{
        'codigo'    : '0002',
        'nombre'    : 'Sucursal Luque',
        'direccion' : 'Mariscal López 567',
        'telefono'  : '021 600 500',
        'localidad' : 'Luque',
      },
      <String, dynamic>{
        'codigo'    : '0003',
        'nombre'    : 'Sucursal Encarnación',
        'direccion' : 'Ruta 1 Km 8',
        'telefono'  : '071 200 300',
        'localidad' : 'Encarnación',
      },
    ];
  }

}