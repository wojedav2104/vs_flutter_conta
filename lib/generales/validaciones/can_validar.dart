// ============================================================================
//  ARCHIVO: lib/generales/validaciones/can_validar.dart
//  TODAS las validaciones que SÍ requieren acceso a la Base de Datos
//
//  Ejemplos de validaciones que irán aquí:
//    · Verificar que un código/registro NO exista antes de agregar (alta)
//    · Verificar que un código/registro SÍ exista antes de modificar/borrar
//    · Extraer datos relacionados de la BD para validar (ej: obtener el nombre del cliente a partir de su código)
//    · Verificar que no haya asientos que referencien una cuenta antes de permitir borrarla
//
//  NOTA: Estos métodos serán async porque deben consultar Firebird.
//  Se implementarán cuando tengamos la conexión a la Base de Datos.
// ============================================================================

class ClaseCanValidar {

  // ── Ejemplos de métodos futuros (comentados hasta tener Firebird) ───────

  // static Future<String?> validarClienteExiste(String sCodigo) async { ... }
  // static Future<String?> validarClienteNoExista(String sCodigo) async { ... }
  // static Future<String?> validarCuentaNoTengaAsientos(String sCuenta) async { ... }
  // static Future<String?> validarProveedorExiste(String sCodigo) async { ... }

}

