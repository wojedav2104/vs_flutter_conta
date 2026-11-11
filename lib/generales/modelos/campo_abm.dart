/// Tipo de dato de un campo de un formulario ABM.
enum EnumTipoCampoAbm { comentario, fecha, hora, lista, logico, numero, texto }


/// Especificación de un campo de un formulario ABM.
class ClaseCampoAbm {

  ClaseCampoAbm({
    required this.oTipo,
    required this.sClave,
    required this.sEtiqueta,
    this.bEnGrilla              = true,
    this.bObligatorio           = false,
    this.bSiempreDeshabilitado  = false,
    this.bSoloLecturaPorRol     = false,
    this.iAnchoCaracteres       =  10,
    this.iMaxComentario         = 500,
    this.listOpciones,
    this.sGrupo,
    this.sHint,
    this.sMascara,
  });

  // ── Propiedades ─────────────────────────────────────────────────────────
  bool              bEnGrilla;
  bool              bObligatorio;
  bool              bSiempreDeshabilitado;
  bool              bSoloLecturaPorRol;
  int               iAnchoCaracteres;
  int               iMaxComentario;
  List<String>?     listOpciones;
  EnumTipoCampoAbm  oTipo;
  String            sClave;
  String            sEtiqueta;
  String?           sGrupo;        // clave del grupo/pestaña (se traduce con ClaseIdiomas)
  String?           sHint;
  String?           sMascara;

}
