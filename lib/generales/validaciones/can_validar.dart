// ============================================================================
//  ARCHIVO: lib/generales/validaciones/can_validar.dart
//  TODAS las validaciones que SÍ requieren acceso a la Base de Datos
//
//  Ejemplos de validaciones que irán aquí:
//    · Verificar que un código/registro NO exista antes de agregar (alta)
//    · Verificar que un código/registro SÍ exista antes de modificar/borrar
//    · Extraer datos relacionados de la BD para validar
//    · Verificar que no haya asientos que referencien una cuenta antes de borrarla
//
//  NOTA: Estos métodos serán async porque deben consultar Firebird.
//  Se implementarán cuando tengamos la conexión a la Base de Datos.
// ============================================================================

/// Validaciones que requieren consultar la Base de Datos (Firebird).
///
/// Hoy devuelven null (sin error) porque no hay BD conectada; cuando se
/// implemente cada query, se reemplaza el cuerpo de la función.
abstract final class ClaseCanValidar {

  // ── Unicidad ─────────────────────────────────────────────────────────────

  /// Valida que el N° de timbrado no exista en la tabla Timbrados Propios.
  static Future<String?> validarTimbradoPropioUnico(
    String sTimbradoNumero,
    String? sClaveActual,
    String  sIdioma,
  ) async {
    // TODO: SELECT 1 FROM TIMBRADOS_PROPIOS WHERE TIMBRADO_NUMERO = ?
    return null;
  }

  /// Valida que el N° de timbrado no exista en Timbrados de Proveedores.
  static Future<String?> validarTimbradoProveedorUnico(
    String sTimbradoNumero,
    String? sClaveActual,
    String  sIdioma,
  ) async {
    // TODO: SELECT 1 FROM TIMBRADOS_PROVEEDORES WHERE TIMBRADO_NUMERO = ?
    return null;
  }

  /// Valida que Ejercicio + Sucursal no exista en Cuentas Asignadas.
  static Future<String?> validarCuentaAsignadaUnica(
    String sEjercicio,
    String sSucursal,
    String? sClaveActual,
    String  sIdioma,
  ) async {
    // TODO: SELECT 1 FROM CUENTAS_ASIGNADAS WHERE EJERCICIO = ? AND SUCURSAL = ?
    return null;
  }

  /// Valida que Ejercicio + Sucursal + Cuenta no exista en Plan de Cuentas.
  static Future<String?> validarCuentaUnica(
    String sEjercicio,
    String sSucursal,
    String sCuenta,
    String? sClaveActual,
    String  sIdioma,
  ) async {
    // TODO: SELECT 1 FROM PLAN_CUENTAS WHERE EJERCICIO = ? AND SUCURSAL = ? AND CUENTA = ?
    return null;
  }

  /// Valida que el N° de comprobante no exista en Libro Compras.
  static Future<String?> validarCompraUnica(
    String sTipoDocumento,
    String sNumero,
    String? sClaveActual,
    String  sIdioma,
  ) async {
    // TODO: SELECT 1 FROM LIBRO_COMPRAS WHERE TIPO_DOCUMENTO = ? AND NUMERO = ?
    return null;
  }

  /// Valida que el N° de asiento no exista en Asientos.
  static Future<String?> validarAsientoUnico(
    String sNumero,
    String? sClaveActual,
    String  sIdioma,
  ) async {
    // TODO: SELECT 1 FROM ASIENTOS WHERE NUMERO = ?
    return null;
  }

  // ── Claves foráneas ──────────────────────────────────────────────────────

  /// Valida que la sucursal exista en Sucursales.
  static Future<String?> validarSucursalExiste(
    String sSucursal,
    String sIdioma,
  ) async {
    // TODO: SELECT 1 FROM SUCURSAL WHERE SUCURSAL = ?
    return null;
  }

  /// Valida que la cuenta exista en el Plan de Cuentas del ejercicio.
  static Future<String?> validarCuentaExiste(
    String sEjercicio,
    String sCuenta,
    String sIdioma,
  ) async {
    // TODO: SELECT 1 FROM PLAN_CUENTAS WHERE EJERCICIO = ? AND CUENTA = ?
    return null;
  }

  /// Valida que el proveedor exista en Proveedores.
  static Future<String?> validarProveedorExiste(
    String sProveedor,
    String sIdioma,
  ) async {
    // TODO: SELECT 1 FROM PROVEEDORES WHERE NOMBRE = ?
    return null;
  }

  // ── Vigencia de timbrados ────────────────────────────────────────────────

  /// Valida que la fecha de compra esté dentro de la vigencia del timbrado.
  static Future<String?> validarCompraDentroVigencia(
    String sTimbradoNumero,
    String sFechaCompra,
    String sIdioma,
  ) async {
    // TODO: SELECT 1 FROM TIMBRADOS_PROVEEDORES WHERE TIMBRADO_NUMERO = ?
    //          AND FECHA_INICIO <= ? AND (FECHA_FIN IS NULL OR FECHA_FIN >= ?)
    return null;
  }

  /// Valida que la fecha de venta esté dentro de la vigencia del timbrado.
  static Future<String?> validarVentaDentroVigencia(
    String sTimbradoNumero,
    String sFechaVenta,
    String sIdioma,
  ) async {
    // TODO: SELECT 1 FROM TIMBRADOS_PROPIOS WHERE TIMBRADO_NUMERO = ?
    //          AND FECHA_INICIO <= ? AND (FECHA_FIN IS NULL OR FECHA_FIN >= ?)
    return null;
  }

}
