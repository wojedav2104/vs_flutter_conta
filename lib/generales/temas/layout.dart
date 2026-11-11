/// Constantes de layout generales: anchos de referencia, factores de escala, elevaciones y grosores.
/// Complementa a `ClaseGenEspacios` (que solo maneja margins/paddings) y a `ClaseGenRadios` (que solo maneja radios).
abstract final class ClaseGenLayout {

  static const double dAltoBotonAbm         =   48.0;
  static const double dAltoFilaGrillaAbm    =   26.0;
  static const double dAnchoBotonAbm        =  150.0;  
  static const double dAnchoCampoComentario =  400.0;
  static const double dAnchoCampoFecha      =  180.0;
  static const double dAnchoCampoHora       =  120.0;
  static const double dAnchoCaracter        =    8.6;   // ancho de 1 carácter en Roboto Mono
  static const double dAnchoGrillaAbm       =  280.0;
  static const double dAnchoIconoBorrar     =   48.0;   // espacio que ocupa el icono "X" de borrado
  static const double dAnchoIconoFlecha     =   32.0;   // espacio que ocupa la flecha de una lista
  static const double dAnchoReferencia      = 1366.0;
  static const double dAnchoTarjetaLogin    =  420.0;
  static const double dElevacionTarjeta     =    4.0;
  static const double dFactorEscalaMax      =    1.3;
  static const double dFactorEscalaMin      =    0.8;
  static const double dGrosorSpinner        =    2.0;
  
  static const int    iCaracteresGrillaAbierta  =   75;
  static const int    iCaracteresGrillaCerrada  =   25;
  static const int    iFilasPorPagina           =   25;
  static const int    iMaxCaracteresCampoGrilla =   20;  

}
