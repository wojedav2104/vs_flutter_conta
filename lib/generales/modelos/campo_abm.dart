import '../temas/espacios.dart';
import '../temas/layout.dart';

/// Tipo de dato de un campo de un formulario ABM.
enum EnumTipoCampoAbm { casillas, comentario, fecha, hora, lista, logico, numero, texto }


/// Especificación de un campo de un formulario ABM.
class ClaseCampoAbm {

  ClaseCampoAbm({
    required this.oTipo,
    required this.sClave,
    required this.sEtiqueta,
    this.bCompletarCeros        = false,
    this.bEnGrilla              = true,
    this.bMayusculas            = false,
    this.bObligatorio           = false,
    this.bSiempreDeshabilitado  = false,
    this.bSoloLecturaPorRol     = false,
    this.bTieneDecimales        = false,    
    this.iAnchoCaracteres       = 10,
    this.iMaxComentario         = 500,
    this.listOpciones,
    this.listValores,
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
  bool              bCompletarCeros;
  bool              bEnGrilla;
  bool              bMayusculas;
  bool              bObligatorio;
  bool              bSiempreDeshabilitado;
  bool              bSoloLecturaPorRol;
  bool              bTieneDecimales;
  int               iAnchoCaracteres;
  int               iMaxComentario;
  List<String>?     listOpciones;

  /// Valores internos que se guardan en el registro (códigos estables, ej:
  /// '01' para Factura Contado, 'S'/'N' para Sí/No). Si es null se guardan
  /// los textos de listOpciones. Debe tener la misma cantidad de elementos.
  List<String>?     listValores;
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

  /// Ancho del campo dentro de un formulario (incluye los iconos laterales).
  double getAnchoCampo() {
    switch (oTipo) {
      case EnumTipoCampoAbm.comentario:
        return ClaseGenLayout.dAnchoCampoComentario;
      case EnumTipoCampoAbm.casillas:
      case EnumTipoCampoAbm.lista:
        return iAnchoCaracteres * ClaseGenLayout.dAnchoCaracter
               + ClaseGenLayout.dAnchoIconoFlecha;
      case EnumTipoCampoAbm.fecha:
      case EnumTipoCampoAbm.hora:
        return iAnchoCaracteres * ClaseGenLayout.dAnchoCaracter
               + ClaseGenEspacios.dEspacio24 + ClaseGenLayout.dAnchoIconoBorrar
               + ClaseGenLayout.dAnchoIconoFlecha;
      case EnumTipoCampoAbm.logico:
      case EnumTipoCampoAbm.numero:
      case EnumTipoCampoAbm.texto:
        final int iCaracteres =
            (sMascara != null) ? sMascara!.length : iAnchoCaracteres;
        return iCaracteres * ClaseGenLayout.dAnchoCaracter
               + ClaseGenEspacios.dEspacio24 + ClaseGenLayout.dAnchoIconoBorrar;
    }
  }

  /// Ancho de la columna de este campo dentro de la grilla editable de
  /// detalles (sin iconos: el borrado es por fila completa).
  double getAnchoColumna() {
    final int iCaracteres =
        (sMascara != null) ? sMascara!.length : iAnchoCaracteres;
    return iCaracteres * ClaseGenLayout.dAnchoCaracter
           + ClaseGenEspacios.dEspacio48;
  }

}
