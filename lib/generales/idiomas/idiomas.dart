import 'idiomas_asientos.dart';
import 'idiomas_compras.dart';
import 'idiomas_cuentas.dart';
import 'idiomas_general.dart';
import 'idiomas_interfaz.dart';
import 'idiomas_tablas.dart';
import 'idiomas_terceros.dart';
import 'idiomas_validaciones.dart';

/// Textos de la interfaz en los idiomas de la aplicación.
///
/// Los textos están organizados en módulos por área (uno por archivo).
/// Este archivo los reúne y ofrece getTexto().
abstract final class ClaseIdiomas {

  static final Map<String, String> mapTextosEs = <String, String>{
    ...ClaseIdiomasGeneral.mapEs,
    ...ClaseIdiomasInterfaz.mapEs,
    ...ClaseIdiomasValidaciones.mapEs,
    ...ClaseIdiomasAsientos.mapEs,
    ...ClaseIdiomasTablas.mapEs,
    ...ClaseIdiomasTerceros.mapEs,
    ...ClaseIdiomasCuentas.mapEs,
    ...ClaseIdiomasCompras.mapEs,
  };

  static final Map<String, String> mapTextosFr = <String, String>{
    ...ClaseIdiomasGeneral.mapFr,
    ...ClaseIdiomasInterfaz.mapFr,
    ...ClaseIdiomasValidaciones.mapFr,
    ...ClaseIdiomasAsientos.mapFr,
    ...ClaseIdiomasTablas.mapFr,
    ...ClaseIdiomasTerceros.mapFr,
    ...ClaseIdiomasCuentas.mapFr,
    ...ClaseIdiomasCompras.mapFr,
  };

  /// Devuelve el texto traducido. Si la clave no existe, devuelve la propia
  /// clave (facilita detectar textos faltantes durante el desarrollo).
  static String getTexto(String sIdioma, String sClave) {
    final Map<String, String> mapTextos = (sIdioma == 'fr') ? mapTextosFr : mapTextosEs;
    return mapTextos[sClave] ?? sClave;
  }

}
