/// Sesión de trabajo: Base de Datos conectada, país y sucursal.
///
/// Cada Base de Datos corresponde a un país y a una sucursal dentro de ese país. Los valores son predefinidos; la conexión real llegará más 
/// adelante.
abstract final class ClaseSesion {

  // ── Países ──────────────────────────────────────────────────────────────
  static const String paisArgentina = 'AR';
  static const String paisFrancia   = 'FR';
  static const String paisParaguay  = 'PY';
  static const String paisPeru      = 'PE';
  static const String paisUruguay   = 'UY';

  // ── Valores por defecto ─────────────────────────────────────────────────
  static const String sBaseDatosPorDefecto = 'ASUNCION';

  // ── País de cada Base de Datos (sin la extensión .fdb) ──────────────────
  static const Map<String, String> mapPaisPorBase = <String, String>{
    'ASUNCION'      : paisParaguay,
    'LA_PLATA'      : paisArgentina,
    'LIMA'          : paisPeru,
    'POZO_COLORADO' : paisParaguay,
  };

  // ── Estado de la sesión ─────────────────────────────────────────────────
  static String sBaseDatos = sBaseDatosPorDefecto;

  // ── Métodos ─────────────────────────────────────────────────────────────
  static String getPais() => mapPaisPorBase[sBaseDatos] ?? paisParaguay;

  static String getClavePais() {
    switch (getPais()) {
      case paisArgentina : return 'paisArgentina';
      case paisFrancia   : return 'paisFrancia';
      case paisPeru      : return 'paisPeru';
      case paisUruguay   : return 'paisUruguay';
      default            : return 'paisParaguay';
    }
  }
}