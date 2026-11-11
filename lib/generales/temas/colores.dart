import 'package:flutter/painting.dart';

/// Paleta cromática única de la aplicación.
///
/// Regla de oro: **ningún** widget debe declarar `Color(0x...)` directamente.
/// Todo color proviene de esta clase para garantizar consistencia y permitir
/// branding futuro desde un único punto.

abstract final class ClaseGenColores {

  // ── Neutrales ────────────────────────────────────────────────────────────
  static const colorGris1 = Color(0xFFF5F5F5);
  static const colorGris2 = Color(0xFFE2E2E2);
  static const colorGris3 = Color(0xFF9CA3AF);
  static const colorGris4 = Color(0xFF374151);

  // ── Paleta extendida ─────────────────────────────────────────────────────
  static const colorAmarillo1   = Color(0xFFF5A623);
  static const colorAzulOscuro1 = Color(0xFF0080B0);
  static const colorAzulPuro1   = Color(0xFF0000FF); // antes: colorAzulClaro1 (mal nombrado)
  static const colorBlanco      = Color(0xFFFFFFFF);
  static const colorCyan1       = Color(0xFF06B6D4);
  static const colorMorado1     = Color(0xFF8B5CF6);
  static const colorNaranja1    = Color(0xFFF97316);
  static const colorNegro       = Color(0xFF000000);
  static const colorRojo1       = Color(0xFFB00000);
  static const colorRosa1       = Color(0xFFF472B6);
  static const colorVerde1      = Color(0xFF10B981);

  // ── Semánticos ───────────────────────────────────────────────────────────
  // #D32F2F ≈ 5.9:1 sobre blanco (WCAG AA). Antes #FF0000 ≈ 4.0:1 (insuficiente).
  static const colorError = Color(0xFFD32F2F);
  static const colorOk    = Color(0xFF3FB950);

  // ── Superficies por tema ────────────────────────────────────────────────
  static const colorSuperficieClara         = Color(0xFFFFFFFF);
  static const colorSuperficieOscura        = Color(0xFF1E1F22);
  static const colorSuperficieOscuraElevada = Color(0xFF2A2B2F);

  // ── Containers Material 3 ────────────────────────────────────────────────
  static const colorPrimarioContenedorClaro   = Color(0xFFEAD5FF);
  static const colorPrimarioContenedorOscuro  = Color(0xFF4A1470);

  static const colorSecundarioContenedorClaro  = Color(0xFFE5E5E6);
  static const colorSecundarioContenedorOscuro = Color(0xFF2A2B2C);

  static const colorTerciarioContenedorClaro   = Color(0xFFEDE4FF);
  static const colorTerciarioContenedorOscuro  = Color(0xFF452B85);

  static const colorAdvertenciaContenedorClaro   = Color(0xFFFFF3CD);
  static const colorAdvertenciaContenedorOscuro  = Color(0xFF664D03);

  static const colorErrorContenedorClaro   = Color(0xFFFFDAD6);
  static const colorErrorContenedorOscuro  = Color(0xFF6B0000);

}
