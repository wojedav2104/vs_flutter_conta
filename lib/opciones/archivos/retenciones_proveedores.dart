import 'package:flutter/material.dart';

import '../../generales/idiomas/idiomas.dart';
import '../../generales/modelos/campo_abm.dart';
import '../../generales/preferencias/preferencias.dart';
import '../../generales/widgets/formulario_cabecera_detalle.dart';

import 'retenciones_proveedores_campos.dart';
import 'retenciones_proveedores_datos.dart';
import 'retenciones_proveedores_logica.dart';

/// Pantalla de Retenciones a Proveedores (cabecera + grilla editable de detalles).
///
/// Cabecera con dos grupos (Generales y Detalles): la grilla editable de
/// detalles se muestra en la pestaña Detalles, debajo de los importes, y las
/// filas del asiento generado quedan en la clave 'detalles'.
///
/// La especificación de los campos vive en retenciones_proveedores_campos.dart,
/// los auto-cálculos y las validaciones cruzadas en
/// retenciones_proveedores_logica.dart y los datos de prueba en
/// retenciones_proveedores_datos.dart.
class ClaseRetencionesProveedores extends StatefulWidget {

  const ClaseRetencionesProveedores({
    super.key,
    required this.oPreferencias,
  });

  final ClasePreferencias oPreferencias;

  @override
  State<ClaseRetencionesProveedores> createState() => ClaseEstadoRetencionesProveedores();
}

class ClaseEstadoRetencionesProveedores extends State<ClaseRetencionesProveedores> {

  late final List<ClaseCampoAbm>        listCamposCabecera;
  late final List<ClaseCampoAbm>        listCamposDetalle;
  late final List<Map<String, dynamic>> listRegistros;

  @override
  void initState() {
    super.initState();
    listCamposCabecera = ClaseRetencionesProveedoresCampos.crearCamposCabecera(getIdioma());
    listCamposDetalle  = ClaseRetencionesProveedoresCampos.crearCamposDetalle(getIdioma());
    listRegistros      = ClaseRetencionesProveedoresDatos.crearRegistrosPrueba();
  }

  @override
  Widget build(BuildContext oContexto) {
    return ClaseFormularioCabeceraDetalle(
      funcActualizarCampos : ClaseRetencionesProveedoresLogica.actualizarCampos,
      funcValidarRegistro  : (Map<String, dynamic> oRegistro) =>
          ClaseRetencionesProveedoresLogica.validarRegistro(oRegistro, getIdioma()),
      listCamposCabecera   : listCamposCabecera,
      listCamposDetalle    : listCamposDetalle,
      listRegistros        : listRegistros,
      oPreferencias        : widget.oPreferencias,
      sClaveCampoAlPie     : 'comentarios',
      sGrupoConDetalles    : 'retDetalles',
      sTitulo              : ClaseIdiomas.getTexto('menuRetencionesProveedores', getIdioma()),
    );
  }

  String getIdioma() => widget.oPreferencias.getIdioma();

}
