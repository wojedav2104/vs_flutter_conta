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

  /// Color del icono de la ventana de advertencia (respetando el modo).
  static Color colorIconoAdvertencia(BuildContext oContexto) =>
      _esModoOscuro(oContexto)
          ? ClaseGenColores.colorAmarillo1
          : ClaseGenColores.colorAmarilloOscuro1;

  /// Color de acento decorativo (línea bajo el título del login).
  static Color colorAcento(BuildContext oContexto) => ClaseGenColores.colorAmarillo1;
            
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

  // ── Colores de los controles de entrada (regla UI/UX) ───────────────────
  // Relleno y forecolor del control cambian según esté habilitado o
  // deshabilitado, para distinguirlos a simple vista (usuarios noveles).

  /// Relleno del control habilitado: cian suave que llama la atención,
  /// distinto del fondo del formulario.
  static Color colorFondoCampoHabilitado(BuildContext oContexto) =>
      _esModoOscuro(oContexto)
          ? ClaseGenColores.colorCampoHabilitadoOscuro
          : ClaseGenColores.colorCampoHabilitadoClaro;

  /// Relleno del control deshabilitado: el gris tenue (el que antes usaba
  /// el habilitado), casi fundido con el formulario.
  static Color colorFondoCampoDeshabilitado(BuildContext oContexto) =>
      Theme.of(oContexto).colorScheme.surfaceContainerHighest;

  /// Relleno de los resultados de una suma (campos Total y fila de totales
  /// de la grilla de detalles): distinto del relleno de los datos sumados,
  /// para resaltarlos. En modo claro, ámbar suave; en modo oscuro, el gris
  /// elevado (decidido con los usuarios).
  static Color colorFondoCampoTotal(BuildContext oContexto) =>
      _esModoOscuro(oContexto)
          ? ClaseGenColores.colorCampoTotalOscuro
          : ClaseGenColores.colorCampoTotalClaro;

  /// Fondo del encabezado de las grillas (nombres de columnas de la grilla
  /// lateral de los ABM y de la grilla de detalles): distinto del fondo de
  /// las celdas de abajo, para que se distingan a simple vista. Color exacto
  /// pendiente de decidir con los usuarios.
  static Color colorFondoEncabezadoGrilla(BuildContext oContexto) =>
      _esModoOscuro(oContexto)
          ? ClaseGenColores.colorEncabezadoGrillaOscuro
          : ClaseGenColores.colorEncabezadoGrillaClaro;

  /// Texto del encabezado de las grillas (nombres de columnas y flechita de
  /// orden): el tono del par ámbar que contrasta con la banda. Color exacto
  /// pendiente de decidir con los usuarios.
  static Color colorTextoEncabezadoGrilla(BuildContext oContexto) =>
      _esModoOscuro(oContexto)
          ? ClaseGenColores.colorTextoEncabezadoGrillaOscuro
          : ClaseGenColores.colorTextoEncabezadoGrillaClaro;
          
  /// Forecolor del control habilitado: buen contraste sobre el relleno
  /// habilitado (nunca gris ni negro: esos quedan para el deshabilitado,
  /// que conserva el color de texto normal).
  static Color colorTextoCampoHabilitado(BuildContext oContexto) =>
      _esModoOscuro(oContexto)
          ? ClaseGenColores.colorTextoCampoHabilitadoOscuro
          : ClaseGenColores.colorTextoCampoHabilitadoClaro;

  /// Forecolor del texto de ejemplo (hint) de los controles de entrada:
  /// gris muy apagado, distinto del dato introducido (regla UI/UX).
  static Color colorTextoHintCampo(BuildContext oContexto) =>
      _esModoOscuro(oContexto)
          ? ClaseGenColores.colorHintCampoOscuro
          : ClaseGenColores.colorHintCampoClaro;

  // ── Colores de los botones con foco de teclado (regla UI/UX) ────────────
  // El fondo del botón enfocado debe ser bastante distinto al de los botones
  // sin foco (mismo color en claro y en oscuro, para que sea inmediato).

  /// Fondo del botón con foco de teclado (amarillo de atención).
  static Color colorBotonConFoco(BuildContext oContexto) =>
      ClaseGenColores.colorAmarillo1;

  /// Texto del botón con foco de teclado (buen contraste sobre el amarillo).
  static Color colorTextoBotonConFoco(BuildContext oContexto) =>
      ClaseGenColores.colorNegro;

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
      // Regla UI/UX: los controles de entrada (texto, número, fecha, hora, lista) llevan un relleno distinto al fondo del formulario para que se distingan a simple vista 
      //(usuarios noveles). Único punto de cambio: aplica a todos los InputDecoration de la aplicación.
      inputDecorationTheme   : InputDecorationTheme(
        filled    : true,
        fillColor : oEsquema.surfaceContainerHighest,
      ),

      // Punto 5: el factor de texto escala TODO el TextTheme del tema, incluidos los estilos de Material que no pasan por
      // ClaseGenEstilosTexto. No hay doble escala: los métodos de ClaseGenEstilosTexto parten del oTextTheme constante y
      // multiplican por su cuenta.
      textTheme : _escalarTexto(oTemaBase.textTheme.merge(ClaseGenEstilosTexto.oTextTheme)),
    );
  }

  /// Escala todos los estilos del TextTheme por dFactorTexto.
  /// Se calcula el tamaño estilo por estilo en vez de usar
  /// TextStyle.apply(fontSizeFactor:), porque apply exige fontSize definido
  /// cuando el factor no es 1.0 y algún estilo del tema base no lo trae.
  static TextTheme _escalarTexto(TextTheme oText) {
    TextStyle escalar(TextStyle? oEstilo) =>
        (oEstilo ?? const TextStyle()).copyWith(
            fontSize: (oEstilo?.fontSize ?? 14.0) * ClaseGenEstilosTexto.dFactorTexto);
    return TextTheme(
      displayLarge  : escalar(oText.displayLarge),
      displayMedium : escalar(oText.displayMedium),
      displaySmall  : escalar(oText.displaySmall),
      headlineLarge : escalar(oText.headlineLarge),
      headlineMedium: escalar(oText.headlineMedium),
      headlineSmall : escalar(oText.headlineSmall),
      titleLarge    : escalar(oText.titleLarge),
      titleMedium   : escalar(oText.titleMedium),
      titleSmall    : escalar(oText.titleSmall),
      bodyLarge     : escalar(oText.bodyLarge),
      bodyMedium    : escalar(oText.bodyMedium),
      bodySmall     : escalar(oText.bodySmall),
      labelLarge    : escalar(oText.labelLarge),
      labelMedium   : escalar(oText.labelMedium),
      labelSmall    : escalar(oText.labelSmall),
    );
  }

}

