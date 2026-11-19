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

  // ── Anchos ────────────────────────────────────────────────────────────────

  /// Ancho del campo dentro de un formulario (incluye los iconos laterales).
  /// sMascaraEfectiva es la máscara que realmente se muestra (la dinámica de
  /// funcMascara manda sobre sMascara); si es null se usa la del campo.
  /// Es la única fuente del ancho de los campos: lo usan los formularios y la
  /// grilla editable de detalles.
  double getAnchoCampo({String? sMascaraEfectiva}) {
    final int iCaracteres =
        (sMascaraEfectiva ?? sMascara)?.length ?? iAnchoCaracteres;
    // El ancho por carácter se escala con el modo texto grande: sin esto,
    // los campos quedan angostos cuando ClaseGenEstilosTexto.dFactorTexto
    // es 1.25.
    final double dAnchoTexto = iCaracteres * ClaseGenLayout.dAnchoCaracter * ClaseGenEstilosTexto.dFactorTexto * ClaseGenLayout.dEscala;
    switch (oTipo) {
      case EnumTipoCampoAbm.comentario:
        return ClaseGenLayout.dAnchoCampoComentario;
      case EnumTipoCampoAbm.casillas:
      case EnumTipoCampoAbm.lista:
        // dAnchoExtraLista cubre la flecha, el padding interno y el margen.
        return dAnchoTexto + ClaseGenLayout.dAnchoExtraLista;
      case EnumTipoCampoAbm.fecha:
      case EnumTipoCampoAbm.hora:
        // Fila: texto + padding + borde, icono de calendario/reloj (48 px,
        // IconButton) y icono de borrado (48 px, aparece al editar),
        // separados por 4 px. Antes se reservaba dAnchoIconoFlecha (32 px),
        // que es de los combobox: faltaban 22 px y el texto se cortaba.
        return dAnchoTexto
               + ClaseGenEspacios.dEspacio24 + ClaseGenLayout.dAnchoBordeCampo
               + ClaseGenLayout.dAnchoIconoBorrar * 2
               + ClaseGenEspacios.dEspacio04;
      case EnumTipoCampoAbm.logico:
      case EnumTipoCampoAbm.numero:
      case EnumTipoCampoAbm.texto:
        // El icono de borrado es suffixIcon, dentro del campo.
        return dAnchoTexto
               + ClaseGenEspacios.dEspacio24 + ClaseGenLayout.dAnchoBordeCampo
               + ClaseGenLayout.dAnchoIconoBorrar;
    }
  }

  /// Ancho de la etiqueta de un campo (incluye el asterisco de los
  /// obligatorios y el padding derecho). Única fuente del ancho de las
  /// etiquetas: lo usan campo_formulario y las filas compartidas de
  /// abm_comun. Escala con el modo texto grande (dFactorTexto) y con la
  /// escala de la ventana (dEscala), igual que la fuente de la etiqueta:
  /// con un ancho fijo en píxeles, las etiquetas largas (ej: "Nombre de la
  /// Empresa *") se partían en dos líneas.
  static double getAnchoEtiqueta() {
    return ClaseGenLayout.dAnchoEtiquetaCampo
           * ClaseGenEstilosTexto.dFactorTexto
           * ClaseGenLayout.dEscala;
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

