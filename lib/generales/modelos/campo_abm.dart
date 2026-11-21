import 'package:flutter/material.dart';

import '../temas/espacios.dart';
import '../temas/estilos_textos.dart';
import '../temas/layout.dart';


/// Alineación del contenido de la columna de un campo en la grilla lateral de registros de los formularios ABM.
enum EnumAlineacion { centro, derecha, izquierda }

/// Tipo de dato de un campo de un formulario ABM.
enum EnumTipoCampoAbm { casillas, comentario, fecha, hora, lista, logico, numero, texto }

/// Especificación de un campo de un formulario ABM.
class ClaseCampoAbm {

  ClaseCampoAbm({
    required this.oTipo,
    required this.sClave,
    required this.sEtiqueta,
    this.bColumnaExpansible     = false,
    this.bCompletarCeros        = false,
    this.bEnGrilla              = true,
    this.bEsTotal               = false,
    this.bMayusculas            = false,
    this.bObligatorio           = false,
    this.bSiempreDeshabilitado  = false,
    this.bSoloLecturaPorRol     = false,
    this.bTieneDecimales        = false,    
    this.bVigencia              = false,
    this.iAnchoCaracteres       = 10,
    this.iAnchoEtiqueta         = 0,
    this.iAnchoVisible          = 0,
    this.iFila                  = 0,
    this.iMaxComentario         = 500,
    this.listOpciones,
    this.listValores,
    this.oAlineacion,
    this.sGrupo,
    this.sHint,
    this.sMascara,
    this.sValorDefecto,
    this.funcActualizarEstado,
    this.funcMascara,
    this.funcValidarCampo,
  });

  // ── Propiedades ─────────────────────────────────────────────────────────

  /// Al grabar, el valor se completa con ceros a la izquierda hasta
  /// iAnchoCaracteres (ej: códigos de cliente: '123' → '000123').
  bool              bColumnaExpansible;
  bool              bCompletarCeros;
  bool              bEnGrilla;
  bool              bEsTotal;
  bool              bMayusculas;
  bool              bObligatorio;
  bool              bSiempreDeshabilitado;
  bool              bSoloLecturaPorRol;
  bool              bTieneDecimales;
  bool              bVigencia;
  int               iAnchoCaracteres;
  int               iAnchoEtiqueta;
  int               iAnchoVisible;
  int               iFila;
  int               iMaxComentario;

  List<String>?     listOpciones;
  List<String>?     listValores;

  EnumAlineacion?   oAlineacion;
  EnumTipoCampoAbm  oTipo;

  String            sClave;
  String            sEtiqueta;
  String?           sGrupo;
  String?           sHint;
  String?           sMascara;

  /// Valor con el que se inicializa el campo al agregar un registro
  /// (ej: 'S' para los campos que se crean con "Sí").
  String?           sValorDefecto;

  // ── Funciones de comportamiento ──────────────────────────────────────────

  /// Habilitación dinámica: devuelve true si el campo debe estar habilitado,
  /// según los valores actuales de todos los campos del formulario.
  final bool Function(Map<String, String> mapValores)? funcActualizarEstado;

  /// Máscara de entrada dinámica, según los valores actuales del formulario
  /// (ej: el número de documento según el tipo de documento elegido).
  /// Si devuelve null, se usa sMascara.
  final String? Function(Map<String, String> mapValores)? funcMascara;

  /// Validación específica del campo. Recibe el valor y el idioma actual.
  final String? Function(String sValor, String sIdioma)? funcValidarCampo;

  // ── Anchos ────────────────────────────────────────────────────────────────

  /// Ancho real de un carácter del texto de los campos, en píxeles ya
  /// escalados. Lo fija medirAnchoCaracter() al empezar cada dibujado: se mide
  /// con TextPainter y el MISMO estilo con el que se dibuja el texto, así que
  /// contempla la fuente real, las escalas y el entorno. Si vale 0 (antes de
  /// la primera medición) los anchos usan la estimación de ClaseGenLayout.
  static double dAnchoCaracterReal = 0;

  /// Mide dAnchoCaracterReal con el estilo del campo (textoCampo) y la escala
  /// de texto del entorno (MediaQuery). La llama ClaseFormularioCampos.build
  /// antes de calcular los anchos de los campos (regla UI/UX: el valor del
  /// campo nunca se corta, en ningún entorno).
  static void medirAnchoCaracter(BuildContext oContexto) {
    const int    iMuestra = 10;
    final TextPainter oMedidor = TextPainter(
      text          : TextSpan(text: '0' * iMuestra, style: ClaseGenEstilosTexto.textoCampo(oContexto)),
      textScaler    : MediaQuery.textScalerOf(oContexto),
      textDirection : TextDirection.ltr,
    )..layout();
    dAnchoCaracterReal = oMedidor.width / iMuestra;
    oMedidor.dispose();
  }

  /// Ancho de la etiqueta del campo dentro de un formulario (incluye el asterisco de los obligatorios y el padding derecho). Si iAnchoEtiqueta es 0 usa el ancho general (ClaseGenLayout.dAnchoEtiquetaCampo);
  double getAnchoEtiqueta() {
    final double dBase = (iAnchoEtiqueta <= 0) ? ClaseGenLayout.dAnchoEtiquetaCampo : iAnchoEtiqueta * ClaseGenLayout.dAnchoCaracter;
    return dBase * ClaseGenEstilosTexto.dFactorTexto * ClaseGenLayout.dEscala;
  }

  /// Ancho del campo dentro de un formulario (incluye los iconos laterales).
  /// sMascaraEfectiva es la máscara que realmente se muestra (la dinámica de
  /// funcMascara manda sobre sMascara); si es null se usa la del campo.
  /// Es la única fuente del ancho de los campos: lo usan los formularios y la
  /// grilla editable de detalles.
  double getAnchoCampo({String? sMascaraEfectiva}) {
    final int iCaracteres =
        (sMascaraEfectiva ?? sMascara)?.length ?? iAnchoCaracteres;
    // El ancho por carácter sale de la medición real (dAnchoCaracterReal, ya
    // escalada): solo si aún no se midió se usa la estimación de
    // ClaseGenLayout.dAnchoCaracter escalada con texto grande y ventana.
    final double dAnchoTexto = iCaracteres *
        ((dAnchoCaracterReal > 0)
            ? dAnchoCaracterReal
            : ClaseGenLayout.dAnchoCaracter * ClaseGenEstilosTexto.dFactorTexto * ClaseGenLayout.dEscala);
    switch (oTipo) {
      case EnumTipoCampoAbm.comentario:
        return ClaseGenLayout.dAnchoCampoComentario;
      case EnumTipoCampoAbm.casillas:
      case EnumTipoCampoAbm.lista:
        // dAnchoExtraLista cubre la flecha (32 px), el padding interno (24 px) y el borde (2 px): sin margen extra (ancho mínimo, spec 00_03_01 regla 6).
        return dAnchoTexto + ClaseGenLayout.dAnchoExtraLista;
      case EnumTipoCampoAbm.fecha:
      case EnumTipoCampoAbm.hora:
        // Fila: texto + padding + borde, botón del calendario/reloj (dAnchoBotonCalendario) y botón "X" (dAnchoBotonBorrarCampo), separados por 4 px. Antes
        // se reservaban 48 px para ambos botones y el campo sobraba unos 2 caracteres (ancho mínimo, spec 00_03_01 regla 6).
        return dAnchoTexto
               + ClaseGenEspacios.dEspacio24 + ClaseGenLayout.dAnchoBordeCampo
               + ClaseGenLayout.dAnchoBotonCalendario
               + ClaseGenLayout.dAnchoBotonBorrarCampo
               + ClaseGenEspacios.dEspacio04;
      case EnumTipoCampoAbm.logico:
      case EnumTipoCampoAbm.numero:
        // Los números conservan el margen de seguridad de 24 px: el área de texto real del control queda unos píxeles más corta que esta cuenta (el hueco de
        // la "X" y el padding que dibuja el decorador de Material), y en web el valor formateado (ej: "2.026") se dibuja más ancho de lo que mide TextPainter.
        return dAnchoTexto + ClaseGenLayout.dMargenTextoCampo
               + ClaseGenEspacios.dEspacio12 + ClaseGenEspacios.dEspacio01
               + ClaseGenLayout.dAnchoSuffixBorrar
               + ClaseGenLayout.dAnchoBordeCampo;
      case EnumTipoCampoAbm.texto:
        // Regla UI/UX (ancho mínimo, spec 00_03_01 regla 6): el campo de texto ocupa exactamente sus caracteres más el hueco de la "X" (18 + 3 px por lado),
        // los paddings (12 px izquierda, 1 px derecha) y el borde, más solo 8 px de margen por el desfase de dibujo en web (antes 24 px: sobraban ~2 caracteres).
        return dAnchoTexto + ClaseGenEspacios.dEspacio08
               + ClaseGenEspacios.dEspacio12 + ClaseGenEspacios.dEspacio01
               + ClaseGenLayout.dAnchoSuffixBorrar
               + ClaseGenLayout.dAnchoBordeCampo;
    }
  }

  /// Ancho de la columna de este campo dentro de la grilla editable de
  /// detalles (sin iconos: el borrado es por fila completa). La columna es de
  /// ancho fijo, por eso usa la máscara estática del campo.
  double getAnchoColumna() {
    final int iCaracteres = sMascara?.length
        ?? (iAnchoVisible > 0 ? iAnchoVisible : iAnchoCaracteres);
    // Mismo escalamiento que getAnchoCampo: el texto de las celdas también
    // crece con el modo texto grande.
    return iCaracteres * ClaseGenLayout.dAnchoCaracter
           * ClaseGenEstilosTexto.dFactorTexto
           * ClaseGenLayout.dEscala
           + ClaseGenEspacios.dEspacio48;
  }

  // ── Alineación ───────────────────────────────────────────────────────────

  /// Alineación de la columna de este campo en la grilla lateral de registros.
  /// Si no se indicó oAlineacion se usa la alineación por tipo de dato:
  /// números a la derecha y el resto a la izquierda (regla 00_03_01).
  EnumAlineacion getAlineacion() {
    return oAlineacion
        ?? ((oTipo == EnumTipoCampoAbm.numero)
            ? EnumAlineacion.derecha
            : EnumAlineacion.izquierda);
  }

}

