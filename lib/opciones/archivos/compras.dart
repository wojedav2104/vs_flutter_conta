import 'package:flutter/material.dart';

import '../../generales/idiomas/idiomas.dart';
import '../../generales/modelos/campo_abm.dart';
import '../../generales/preferencias/preferencias.dart';
import '../../generales/widgets/formulario_cabecera_detalle.dart';

import 'compras_campos.dart';
import 'compras_datos.dart';
import 'compras_logica.dart';

/// Pantalla de la tabla Libro Compras (cabecera + grilla editable de detalles).
///
/// Cabecera con tres grupos (Generales, Detalles y Resolución 90/2021): la
/// grilla editable de detalles se muestra en la pestaña Detalles, debajo de
/// los importes de solo lectura, y las filas del asiento generado quedan en
/// la clave 'detalles'.
///
/// La especificación de los campos vive en compras_campos.dart, los
/// auto-cálculos y las validaciones cruzadas en compras_logica.dart y los
/// datos de prueba en compras_datos.dart.
class ClaseCompras extends StatefulWidget {

  const ClaseCompras({
    super.key,
    required this.oPreferencias,
  });

  final ClasePreferencias oPreferencias;

  @override
  State<ClaseCompras> createState() => ClaseEstadoCompras();
}

class ClaseEstadoCompras extends State<ClaseCompras> {

  late final List<ClaseCampoAbm>        listCamposCabecera;
  late final List<ClaseCampoAbm>        listCamposDetalle;
  late final List<Map<String, dynamic>> listRegistros;

  @override
  void initState() {
    super.initState();
    listCamposCabecera = ClaseComprasCampos.crearCamposCabecera(getIdioma());
    listCamposDetalle  = ClaseComprasCampos.crearCamposDetalle(getIdioma());
    listRegistros      = ClaseComprasDatos.crearRegistrosPrueba();
  }

  @override
  Widget build(BuildContext oContexto) {
    return ClaseFormularioCabeceraDetalle(
      funcActualizarCampos : ClaseComprasLogica.actualizarCampos,
      funcValidarRegistro  : (Map<String, dynamic> oRegistro) =>
          ClaseComprasLogica.validarRegistro(oRegistro, getIdioma()),
      listCamposCabecera   : listCamposCabecera,
      listCamposDetalle    : listCamposDetalle,
      listRegistros        : listRegistros,
      oPreferencias        : widget.oPreferencias,
      sClaveCampoAlPie     : 'comentarios',
      sGrupoConDetalles    : 'comDetalles',
      sTitulo              : ClaseIdiomas.getTexto('menuCompras', getIdioma()),
    );
  }

  String getIdioma() => widget.oPreferencias.getIdioma();

}

