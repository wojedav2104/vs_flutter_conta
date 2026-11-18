import 'package:flutter/material.dart';

import 'layout.dart';


/// Estilos de texto y `TextTheme` central de la aplicación.
///
/// Punto 5 (texto grande): todos los estilos pasan por _estilo, que
/// multiplica el tamaño por dFactorTexto. Un solo punto de cambio.
abstract final class ClaseGenEstilosTexto {

  static const String _sFamiliaBase = 'Roboto';
  static const String _sFamiliaMono = 'Roboto Mono';

  /// Factor del modo texto grande.
  static const double dFactorTextoGrande = 1.25;

  /// Factor de escala del texto: 1.0 = normal, 1.25 = texto grande.
  /// Lo fija main.dart al arrancar y ClaseControlesPreferencias al cambiar
  /// la preferencia.
  static double dFactorTexto = 1.0;

  static const TextTheme oTextTheme = TextTheme(
    bodySmall    : TextStyle(fontSize: 12, fontWeight: FontWeight.w400, letterSpacing: 0.2),
    bodyMedium   : TextStyle(fontSize: 14, fontWeight: FontWeight.w400, letterSpacing: 0.2),
    bodyLarge    : TextStyle(fontSize: 16, fontWeight: FontWeight.w400, letterSpacing: 0.2),
    displayMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, letterSpacing: 0.2),
    displayLarge : TextStyle(fontSize: 20, fontWeight: FontWeight.w600, letterSpacing: 0.2),
    labelMedium  : TextStyle(fontSize: 12, fontWeight: FontWeight.w500, letterSpacing: 0.2),
    labelSmall   : TextStyle(fontSize: 11, fontWeight: FontWeight.w500, letterSpacing: 0.2),
    titleMedium  : TextStyle(fontSize: 26, fontWeight: FontWeight.w700, letterSpacing: 0.2),
    titleLarge   : TextStyle(fontSize: 32, fontWeight: FontWeight.w700, letterSpacing: 0.2),
  );

  static TextStyle _estilo(
    BuildContext oContexto,
    TextStyle?   oBase, {
      Color?       color,
      FontWeight?  oPeso,
      String?      sFamilia,
    }
  ) {
    final ThemeData oTema   = Theme.of(oContexto);
    final TextStyle oEstilo = oBase ?? oTema.textTheme.bodyMedium ?? const TextStyle();
    return oEstilo.copyWith(
      fontSize   : (oEstilo.fontSize ?? 14.0) * dFactorTexto * ClaseGenLayout.dEscala,
      color      : color ?? oTema.colorScheme.onSurface,
      fontFamily : sFamilia,
      fontWeight : oPeso,
    );
  }

  // ── Variantes de negocio ─────────────────────────────────────────────────
  static TextStyle importeNormal   (BuildContext oContexto) => _estilo(oContexto, oTextTheme.labelMedium  , sFamilia: _sFamiliaMono);
  static TextStyle importeResaltado(BuildContext oContexto) => _estilo(oContexto, oTextTheme.labelMedium  , sFamilia: _sFamiliaMono, oPeso: FontWeight.w900);
  static TextStyle normalChico     (BuildContext oContexto) => _estilo(oContexto, oTextTheme.bodySmall    , sFamilia: _sFamiliaBase, color: Theme.of(oContexto).colorScheme.onSurfaceVariant);
  static TextStyle normalMediano   (BuildContext oContexto) => _estilo(oContexto, oTextTheme.bodyMedium   , sFamilia: _sFamiliaBase);
  static TextStyle normalGrande    (BuildContext oContexto) => _estilo(oContexto, oTextTheme.bodyLarge    , sFamilia: _sFamiliaBase);
  static TextStyle subtituloMediano(BuildContext oContexto) => _estilo(oContexto, oTextTheme.displayMedium, sFamilia: _sFamiliaBase);
  static TextStyle subtituloGrande (BuildContext oContexto) => _estilo(oContexto, oTextTheme.displayLarge , sFamilia: _sFamiliaBase);
  static TextStyle textoCampo      (BuildContext oContexto) => _estilo(oContexto, oTextTheme.bodyMedium   , sFamilia: _sFamiliaMono).copyWith(letterSpacing: 0);
  static TextStyle tituloMediano   (BuildContext oContexto) => _estilo(oContexto, oTextTheme.titleMedium  , sFamilia: _sFamiliaBase);
  static TextStyle tituloGrande    (BuildContext oContexto) => _estilo(oContexto, oTextTheme.titleLarge   , sFamilia: _sFamiliaBase);

  /// Etiqueta flotante de los campos de texto (16 px, semibold).
  static TextStyle etiquetaCampo   (BuildContext oContexto) => _estilo(oContexto, oTextTheme.bodyLarge    , sFamilia: _sFamiliaBase, oPeso: FontWeight.w600);

  /// Texto de los botones grandes (ABM, Ingresar, Cancelar).
  /// 20 px en negrita: cumple WCAG AA como texto grande sobre los colores
  /// de los botones y es más legible para usuarios noveles.
  static TextStyle botonGrande(BuildContext oContexto) {
    return _estilo(oContexto, oTextTheme.displayLarge, sFamilia: _sFamiliaBase);
  }

  /// Texto destacado (nombre de la Base en la cabecera, opción Fin).
  static TextStyle textoDestacado(BuildContext oContexto) {
    return textoCampo(oContexto).copyWith(fontWeight: FontWeight.w600);
  }

    /// Encabezado de la grilla lateral de registros: en negritas para
  /// distinguirlo de las celdas de abajo (regla UI/UX).
  static TextStyle encabezadoGrilla(BuildContext oContexto) =>
      normalChico(oContexto).copyWith(fontWeight: FontWeight.bold);

  /// Encabezado de la grilla de detalles (Asientos, Compras): mismos forecolor
  /// y negritas que encabezadoGrilla (los dos encabezados se ven iguales);
  /// solo cambia el tamaño, que es el de las etiquetas de campo.
  static TextStyle encabezadoGrillaDetalle(BuildContext oContexto) =>
      encabezadoGrilla(oContexto).copyWith(
        fontSize: etiquetaCampo(oContexto).fontSize,
      );
      
}
