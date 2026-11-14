import 'package:flutter/material.dart';

import 'colores.dart';
import 'estilos_textos.dart';

/// Especificaciones de los temas claro y oscuro de la aplicación.
///
/// Regla de oro: los widgets toman los colores de esta clase (directamente o
/// vía Theme.of), nunca de colores.dart, para respetar el modo claro/oscuro.
abstract final class ClaseGenTemas {

  // ── Esquema claro ────────────────────────────────────────────────────────
  static const ColorScheme _oEsquemaClaro = ColorScheme(
    brightness              : Brightness.light,
    primary                 : ClaseGenColores.colorAzulOscuro1,
    onPrimary               : ClaseGenColores.colorBlanco,
    primaryContainer        : ClaseGenColores.colorPrimarioContenedorClaro,
    onPrimaryContainer      : ClaseGenColores.colorAzulOscuro1,
    secondary               : ClaseGenColores.colorGris4,
    onSecondary             : ClaseGenColores.colorBlanco,
    secondaryContainer      : ClaseGenColores.colorSecundarioContenedorClaro,
    onSecondaryContainer    : ClaseGenColores.colorGris4,
    tertiary                : ClaseGenColores.colorMorado1,
    onTertiary              : ClaseGenColores.colorBlanco,
    tertiaryContainer       : ClaseGenColores.colorTerciarioContenedorClaro,
    onTertiaryContainer     : ClaseGenColores.colorMorado1,
    error                   : ClaseGenColores.colorError,
    onError                 : ClaseGenColores.colorBlanco,
    errorContainer          : ClaseGenColores.colorErrorContenedorClaro,
    onErrorContainer        : ClaseGenColores.colorRojo1,
    surface                 : ClaseGenColores.colorSuperficieClara,
    onSurface               : ClaseGenColores.colorGris4,
    surfaceContainerLowest  : ClaseGenColores.colorSuperficieClara,
    surfaceContainerLow     : ClaseGenColores.colorGris1,
    surfaceContainer        : ClaseGenColores.colorGris1,
    surfaceContainerHigh    : ClaseGenColores.colorGris2,
    surfaceContainerHighest : ClaseGenColores.colorGris2,
    // AA para texto normal: 7.6:1 sobre blanco y 5.6:1 sobre la fila
    // seleccionada (colorGris3 solo daba 2.5:1).
    onSurfaceVariant        : ClaseGenColores.colorTextoSecundarioClaro,
    outline                 : ClaseGenColores.colorGris3,
    outlineVariant          : ClaseGenColores.colorGris2,
    inverseSurface          : ClaseGenColores.colorGris4,
    onInverseSurface        : ClaseGenColores.colorBlanco,
    surfaceTint             : ClaseGenColores.colorAzulOscuro1,
    shadow                  : ClaseGenColores.colorNegro,
    scrim                   : ClaseGenColores.colorNegro,
  );

  // ── Esquema oscuro ───────────────────────────────────────────────────────
  static const ColorScheme _oEsquemaOscuro = ColorScheme(
    brightness              : Brightness.dark,
    primary                 : ClaseGenColores.colorCyan1,
    onPrimary               : ClaseGenColores.colorNegro,
    primaryContainer        : ClaseGenColores.colorPrimarioContenedorOscuro,
    onPrimaryContainer      : ClaseGenColores.colorCyan1,
    secondary               : ClaseGenColores.colorGris3,
    onSecondary             : ClaseGenColores.colorNegro,
    secondaryContainer      : ClaseGenColores.colorSecundarioContenedorOscuro,
    onSecondaryContainer    : ClaseGenColores.colorGris1,
    tertiary                : ClaseGenColores.colorRosa1,
    onTertiary              : ClaseGenColores.colorNegro,
    tertiaryContainer       : ClaseGenColores.colorTerciarioContenedorOscuro,
    onTertiaryContainer     : ClaseGenColores.colorRosa1,
    // AA para texto normal: 7.7:1 sobre #1E1F22 (colorError solo daba 3.3:1).
    error                   : ClaseGenColores.colorErrorOscuro,
    onError                 : ClaseGenColores.colorNegro,
    errorContainer          : ClaseGenColores.colorErrorContenedorOscuro,
    onErrorContainer        : ClaseGenColores.colorBlanco,
    surface                 : ClaseGenColores.colorSuperficieOscura,
    onSurface               : ClaseGenColores.colorGris1,
    surfaceContainerLowest  : ClaseGenColores.colorNegro,
    surfaceContainerLow     : ClaseGenColores.colorGris4,
    surfaceContainer        : ClaseGenColores.colorSuperficieOscuraElevada,
    surfaceContainerHigh    : ClaseGenColores.colorSuperficieOscuraElevada,
    surfaceContainerHighest : ClaseGenColores.colorGris4,
    onSurfaceVariant        : ClaseGenColores.colorGris3,
    outline                 : ClaseGenColores.colorGris3,
    outlineVariant          : ClaseGenColores.colorGris4,
    inverseSurface          : ClaseGenColores.colorGris1,
    onInverseSurface        : ClaseGenColores.colorGris4,
    surfaceTint             : ClaseGenColores.colorCyan1,
    shadow                  : ClaseGenColores.colorNegro,
    scrim                   : ClaseGenColores.colorNegro,
  );

  // ── Colores de los botones ABM (respetan el modo claro/oscuro) ────────────
  // Regla de diseño: habilitado = #1E88E5 con texto blanco, igual en ambos
  // modos (3.7:1 con el texto grande del botón). Deshabilitado cambia según
  // el modo: en oscuro el gris claro deslumbra.
  static Color colorBotonHabilitado(BuildContext oContexto) =>
      ClaseGenColores.colorBotonHabilitado;

  static Color colorTextoBotonHabilitado(BuildContext oContexto) =>
      ClaseGenColores.colorTextoBotonHabilitado;

  static Color colorBotonDeshabilitado(BuildContext oContexto) =>
      _esModoOscuro(oContexto)
          ? ClaseGenColores.colorBotonDeshabilitadoOscuro
          : ClaseGenColores.colorBotonDeshabilitado;

  static Color colorTextoBotonDeshabilitado(BuildContext oContexto) =>
      _esModoOscuro(oContexto)
          ? ClaseGenColores.colorTextoBotonDeshabilitadoOscuro
          : ClaseGenColores.colorTextoBotonDeshabilitado;

  static bool _esModoOscuro(BuildContext oContexto) =>
      Theme.of(oContexto).brightness == Brightness.dark;

  // ── Temas cacheados (se reconstruyen si cambia el factor de texto) ────────
  static double    _dFactorCache = -1.0;
  static ThemeData? _temaClaroCache;
  static ThemeData? _temaOscuroCache;

  static ThemeData get getTemaClaro  { _actualizarTemas(); return _temaClaroCache!; }
  static ThemeData get getTemaOscuro { _actualizarTemas(); return _temaOscuroCache!; }

  static void _actualizarTemas() {
    if (_dFactorCache != ClaseGenEstilosTexto.dFactorTexto) {
      _dFactorCache    = ClaseGenEstilosTexto.dFactorTexto;
      _temaClaroCache  = _construir(_oEsquemaClaro);
      _temaOscuroCache = _construir(_oEsquemaOscuro);
    }
  }

  static ThemeData _construir(ColorScheme oEsquema) {
    // Base M3 completa: provee `headlineSmall`, `titleSmall`, `labelLarge`,
    // `displaySmall`, `headlineMedium`, `headlineLarge` (que
    // `ClaseGenEstilosTexto.oTextTheme` no define). Sin este merge, esos
    // estilos quedan `null` y widgets como `AppBar`, `Dialog`, `ListTile`
    // los heredan de `DefaultTextStyle`, rompiendo la consistencia.
    final ThemeData oTemaBase = ThemeData(
      colorScheme : oEsquema,
      useMaterial3: true,
    );
    return oTemaBase.copyWith(
      scaffoldBackgroundColor: oEsquema.surface,
      // Punto 5: el factor de texto escala TODO el TextTheme del tema, incluidos los estilos de Material que no pasan por
      // ClaseGenEstilosTexto. No hay doble escala: los métodos de ClaseGenEstilosTexto parten del oTextTheme constante y 
      // multiplican por su cuenta.
      textTheme : oTemaBase.textTheme
          .merge(ClaseGenEstilosTexto.oTextTheme)
          .apply(fontSizeFactor: ClaseGenEstilosTexto.dFactorTexto),
    );
  }

}

