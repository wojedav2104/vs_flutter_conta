// ============================================================================
//  ARCHIVO: lib/generales/validaciones/cap_validar.dart
//  Validaciones que NO requieren acceso a la Base de Datos
// ============================================================================

class ClaseCapValidar {

  // ---------------------------------------------------------------------------
  //  Valida que un campo obligatorio tenga contenido
  //  Devuelve null si es correcto, o el texto del error si no lo es
  // ---------------------------------------------------------------------------
  static String? validarObligatorio(String sValor, String sEtiqueta) {
    if (sValor.trim().isEmpty) return 'El campo "$sEtiqueta" es obligatorio';
    return null;
  }

  // ---------------------------------------------------------------------------
  //  Valida que el texto no supere la longitud máxima del campo
  // ---------------------------------------------------------------------------
  static String? validarLongitudMaxima(String sValor, String sEtiqueta, int iLongitudMaxima) {
    if (sValor.length > iLongitudMaxima) return 'El campo "$sEtiqueta" admite un máximo de $iLongitudMaxima caracteres';
    return null;
  }

  // ---------------------------------------------------------------------------
  //  Valida que el campo sea un número entero de una longitud exacta
  // ---------------------------------------------------------------------------
  static String? validarEnteroDeLongitud(String sValor, String sEtiqueta, int iLongitud) {
    final String sDato = sValor.trim();
    if (sDato.isEmpty)            return null;
    if (int.tryParse(sDato) == null) return 'El campo "$sEtiqueta" debe ser un número entero';
    if (sDato.length != iLongitud)    return 'El campo "$sEtiqueta" debe tener exactamente $iLongitud dígitos';
    return null;
  }
}
