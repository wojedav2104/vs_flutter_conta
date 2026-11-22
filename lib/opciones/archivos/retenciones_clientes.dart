import 'package:flutter/material.dart';

import '../../generales/idiomas/idiomas.dart';
import '../../generales/modelos/campo_abm.dart';
import '../../generales/preferencias/preferencias.dart';
import '../../generales/widgets/formulario_cabecera_detalle.dart';

import 'retenciones_clientes_campos.dart';
import 'retenciones_clientes_datos.dart';
import 'retenciones_clientes_logica.dart';

/// Pantalla de Retenciones a Clientes (cabecera + grilla editable de detalles).
///
/// Cabecera con dos grupos (Generales y Detalles): la grilla editable de
/// detalles se muestra en la pestaña Detalles, debajo de los importes, y las
/// filas del asiento generado quedan en la clave 'detalles'.
///
/// La especificación de los campos vive en retenciones_clientes_campos.dart,
/// los auto-cálculos y las validaciones cruzadas en
/// retenciones_clientes_logica.dart y los datos de prueba en
/// retenciones_clientes_datos.dart.
class ClaseRetencionesClientes extends StatefulWidget {

  const ClaseRetencionesClientes({
    super.key,
    required this.oPreferencias,
  });

  final ClasePreferencias oPreferencias;

  @override
  State<ClaseRetencionesClientes> createState() => ClaseEstadoRetencionesClientes();
}

class ClaseEstadoRetencionesClientes extends State<ClaseRetencionesClientes> {

  late final List<ClaseCampoAbm>        listCamposCabecera;
  late final List<ClaseCampoAbm>        listCamposDetalle;
  late final List<Map<String, dynamic>> listRegistros;

  @override
  void initState() {
    super.initState();
    listCamposCabecera = ClaseRetencionesClientesCampos.crearCamposCabecera(getIdioma());
    listCamposDetalle  = ClaseRetencionesClientesCampos.crearCamposDetalle(getIdioma());
    listRegistros      = ClaseRetencionesClientesDatos.crearRegistrosPrueba();
  }

  @override
  Widget build(BuildContext oContexto) {
    return ClaseFormularioCabeceraDetalle(
      funcActualizarCampos : ClaseRetencionesClientesLogica.actualizarCampos,
      funcValidarRegistro  : (Map<String, dynamic> oRegistro) =>
          ClaseRetencionesClientesLogica.validarRegistro(oRegistro, getIdioma()),
      listCamposCabecera   : listCamposCabecera,
      listCamposDetalle    : listCamposDetalle,
      listRegistros        : listRegistros,
      oPreferencias        : widget.oPreferencias,
      sClaveCampoAlPie     : 'comentarios',
      sGrupoConDetalles    : 'retDetalles',
      sTitulo              : ClaseIdiomas.getTexto('menuRetencionesClientes', getIdioma()),
    );
  }

  String getIdioma() => widget.oPreferencias.getIdioma();

}