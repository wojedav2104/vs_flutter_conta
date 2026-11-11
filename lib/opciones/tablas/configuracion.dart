import 'package:flutter/material.dart';

import '../../generales/idiomas/idiomas.dart';
import '../../generales/modelos/campo_abm.dart';
import '../../generales/preferencias/preferencias.dart';
import '../../generales/widgets/formulario_abm.dart';


/// Pantalla de la tabla Configuración (ABM de un solo registro con pestañas).
///
/// Reglas propias de esta tabla:
///   · Debe tener un solo registro: Agregar se deshabilita si ya hay uno.
///   · El botón Encontrar debe estar siempre deshabilitado.
class ClaseConfiguracion extends StatefulWidget {

  const ClaseConfiguracion({
    super.key,
    required this.oPreferencias,
  });

  final ClasePreferencias oPreferencias;

  @override
  State<ClaseConfiguracion> createState() => ClaseEstadoConfiguracion();
}

class ClaseEstadoConfiguracion extends State<ClaseConfiguracion> {

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
      bPermitirEncontrar   : false,
      bTablaUnSoloRegistro : true,
      listCampos           : listCampos,
      listRegistros        : listRegistros,
      oPreferencias        : widget.oPreferencias,
      sTitulo              : ClaseIdiomas.getTexto(
                               widget.oPreferencias.getIdioma(), 'menuConfiguracion'),
    );
  }

  // ── Campos de los dos grupos ────────────────────────────────────────────

  List<ClaseCampoAbm> crearCampos() {

    final String sIdioma = widget.oPreferencias.getIdioma();

    return <ClaseCampoAbm>[

      // ── Grupo 1: Empresa ─────────────────────────────────────────────────────────────
      ClaseCampoAbm(
        bObligatorio     : true,
        iAnchoCaracteres : 44,
        oTipo            : EnumTipoCampoAbm.texto,
        sClave           : 'sucursal',
        sEtiqueta        : ClaseIdiomas.getTexto(sIdioma, 'cfgSucursal'),
        sGrupo           : 'cfgGrupoEmpresa',
        sHint            : ClaseIdiomas.getTexto(sIdioma, 'cfgHintSucursal'),
      ),
      ClaseCampoAbm(
        bObligatorio     : true,
        iAnchoCaracteres : 100,
        oTipo            : EnumTipoCampoAbm.texto,
        sClave           : 'carpetaMarangatu',
        sEtiqueta        : ClaseIdiomas.getTexto(sIdioma, 'cfgCarpetaMarangatu'),
        sGrupo           : 'cfgGrupoEmpresa',
        sHint            : ClaseIdiomas.getTexto(sIdioma, 'cfgHintCarpetaMarangatu'),
      ),

      // ── Grupo 2: Backups ─────────────────────────────────────────────────────────────
      ClaseCampoAbm(
        iAnchoCaracteres : 5,
        oTipo            : EnumTipoCampoAbm.hora,
        sClave           : 'horaBackup',
        sEtiqueta        : ClaseIdiomas.getTexto(sIdioma, 'cfgCrearBackup'),
        sGrupo           : 'cfgGrupoBackups',
      ),
      ClaseCampoAbm(
        bObligatorio     : true,
        iAnchoCaracteres : 3,
        oTipo            : EnumTipoCampoAbm.numero,
        sClave           : 'cantidadBackups',
        sEtiqueta        : ClaseIdiomas.getTexto(sIdioma, 'cfgCantidadBackups'),
        sGrupo           : 'cfgGrupoBackups',
      ),
    ];
  }

  // ── Datos de prueba (se reemplazarán por Firebird) ──────────────────────

  List<Map<String, dynamic>> crearRegistrosPrueba() {
    return <Map<String, dynamic>>[
      <String, dynamic>{
        'cantidadBackups'  : '30',
        'carpetaMarangatu' : 'C:\\Marangatu',
        'horaBackup'       : '02:00',
        'sucursal'         : 'Sucursal Central',
      },
    ];
  }

}
