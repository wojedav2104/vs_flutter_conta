import 'package:flutter/material.dart';

import '../../generales/idiomas/idiomas.dart';
import '../../generales/modelos/campo_abm.dart';
import '../../generales/preferencias/preferencias.dart';
import '../../generales/widgets/formulario_cabecera_detalle.dart';

import 'ventas_campos.dart';
import 'ventas_datos.dart';
import 'ventas_logica.dart';

/// Pantalla de la tabla Libro Ventas (cabecera + grilla editable de detalles).
///
/// Cabecera con tres grupos (Generales, Detalles y Resolución 90/2021): los
/// importes se escriben en la pestaña Detalles, encima de la grilla editable
/// de detalles, y se duplican deshabilitados en la pestaña Resolución
/// 90/2021, como referencia. Las filas del asiento generado quedan en la
/// clave 'detalles'.
///
/// La especificación de los campos vive en ventas_campos.dart, los
/// auto-cálculos y las validaciones cruzadas en ventas_logica.dart y los
/// datos de prueba en ventas_datos.dart.
class ClaseVentas extends StatefulWidget {

  const ClaseVentas({
    super.key,
    required this.oPreferencias,
  });

  final ClasePreferencias oPreferencias;

  @override
  State<ClaseVentas> createState() => ClaseEstadoVentas();
}

class ClaseEstadoVentas extends State<ClaseVentas> {

  late final List<ClaseCampoAbm>        listCamposCabecera;
  late final List<ClaseCampoAbm>        listCamposDetalle;
  late final List<Map<String, dynamic>> listRegistros;

  @override
  void initState() {
    super.initState();
    listCamposCabecera = ClaseVentasCampos.crearCamposCabecera(getIdioma());
    listCamposDetalle  = ClaseVentasCampos.crearCamposDetalle(getIdioma());
    listRegistros      = ClaseVentasDatos.crearRegistrosPrueba();
  }

  @override
  Widget build(BuildContext oContexto) {
    return ClaseFormularioCabeceraDetalle(
      funcActualizarCampos : ClaseVentasLogica.actualizarCampos,
      funcValidarRegistro  : (Map<String, dynamic> oRegistro) =>
          ClaseVentasLogica.validarRegistro(oRegistro, getIdioma()),
      listCamposCabecera   : listCamposCabecera,
      listCamposDetalle    : listCamposDetalle,
      listRegistros        : listRegistros,
      oPreferencias        : widget.oPreferencias,
      sClaveCampoAlPie     : 'comentarios',
      sGrupoConDetalles    : 'venDetalles',
      sTitulo              : ClaseIdiomas.getTexto('menuVentas', getIdioma()),
    );
  }

  String getIdioma() => widget.oPreferencias.getIdioma();

}

