import 'package:shared_preferences/shared_preferences.dart';

/// Preferencias del usuario grabadas en su dispositivo.
///
/// Primera ejecución: idioma español y formato de números y de fechas de Paraguay (latinoamericano).
///
/// Cada setter graba de inmediato en el dispositivo.
class ClasePreferencias {

  // ── Valores por defecto ─────────────────────────────────────────────────
  static const String sFormatoFechasPorDefecto  = 'latino';
  static const String sFormatoNumerosPorDefecto = 'latino';
  static const String sIdiomaPorDefecto         = 'es';
  static const String sTemaPorDefecto           = 'claro';

  // ── Claves de grabación ─────────────────────────────────────────────────
  static const String _sClaveFormatoFechas  = 'formato_fechas';
  static const String _sClaveFormatoNumeros = 'formato_numeros';
  static const String _sClaveIdioma         = 'idioma';
  static const String _sClaveTema           = 'tema';

  // ── Estado ──────────────────────────────────────────────────────────────
  String _sFormatoFechas  = sFormatoFechasPorDefecto;
  String _sFormatoNumeros = sFormatoNumerosPorDefecto;
  String _sIdioma         = sIdiomaPorDefecto;
  String _sTema           = sTemaPorDefecto;

  // ── Getters ─────────────────────────────────────────────────────────────
  String getFormatoFechas()  => _sFormatoFechas;
  String getFormatoNumeros() => _sFormatoNumeros;
  String getIdioma()         => _sIdioma;
  String getTema()           => _sTema;

  // ── Setters (graban de inmediato) ───────────────────────────────────────
  Future<void> setFormatoFechas(String sValor) async {
    _sFormatoFechas = sValor;
    await grabar();
  }

  Future<void> setFormatoNumeros(String sValor) async {
    _sFormatoNumeros = sValor;
    await grabar();
  }

  Future<void> setIdioma(String sValor) async {
    _sIdioma = sValor;
    await grabar();
  }

  Future<void> setTema(String sValor) async {
    _sTema = sValor;
    await grabar();
  }

  // ── Carga y grabación ───────────────────────────────────────────────────
  Future<void> cargar() async {
    final SharedPreferences oPrefs = await SharedPreferences.getInstance();
    _sFormatoFechas  = oPrefs.getString(_sClaveFormatoFechas)  ?? sFormatoFechasPorDefecto;
    _sFormatoNumeros = oPrefs.getString(_sClaveFormatoNumeros) ?? sFormatoNumerosPorDefecto;
    _sIdioma         = oPrefs.getString(_sClaveIdioma)         ?? sIdiomaPorDefecto;
    _sTema           = oPrefs.getString(_sClaveTema)           ?? sTemaPorDefecto;
  }

  Future<void> grabar() async {
    final SharedPreferences oPrefs = await SharedPreferences.getInstance();
    await oPrefs.setString(_sClaveFormatoFechas,  _sFormatoFechas);
    await oPrefs.setString(_sClaveFormatoNumeros, _sFormatoNumeros);
    await oPrefs.setString(_sClaveIdioma,         _sIdioma);
    await oPrefs.setString(_sClaveTema,           _sTema);
  }

}