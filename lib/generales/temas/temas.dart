import 'package:flutter/material.dart';

import 'colores.dart';
import 'estilos_textos.dart';

/// Especificaciones de los temas claro y oscuro de la aplicación.
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
    onSurfaceVariant        : ClaseGenColores.colorGris3,
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
    error                   : ClaseGenColores.colorError,
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

  // ── Temas cacheados (`_construir` es idempotente) ───────────────────────
  static final ThemeData _temaClaro  = _construir(_oEsquemaClaro);
  static final ThemeData _temaOscuro = _construir(_oEsquemaOscuro);

  static ThemeData get getTemaClaro  => _temaClaro;
  static ThemeData get getTemaOscuro => _temaOscuro;

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
      textTheme              : oTemaBase.textTheme.merge(ClaseGenEstilosTexto.oTextTheme),
    );
  }

}
