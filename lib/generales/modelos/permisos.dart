import 'sesion.dart';

/// Permisos de edición según el país de la Base de Datos conectada.
///
/// Regla de negocio: Francia (FRA) nunca tiene Base de Datos propia;
/// desde allá solamente se visualiza lo cargado en las bases latinoamericanas.
/// Por lo tanto FRA no puede agregar, borrar, modificar ni grabar.
abstract final class ClasePermisos {

  /// Devuelve true si el país puede editar (agregar, borrar, modificar,
  /// grabar, cancelar). Los demás permisos (encontrar, fin, informes)
  /// están siempre disponibles.
  static bool puedeEditar(String sPais) => sPais != ClaseSesion.paisFrancia;
}
