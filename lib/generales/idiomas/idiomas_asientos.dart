/// Textos del idioma: Asientos y detalle contable.
///
/// Las claves det* son compartidas por los formularios cabecera/detalle
/// (Asientos y Libro Compras); las claves asi* son exclusivas de Asientos.
abstract final class ClaseIdiomasAsientos {

  static const Map<String, String> mapEs = <String, String>{
    // ── Detalle contable (compartido) ────────────────────────────────────
    'detAgregarFila'     : 'Agregar fila',
    'detBorrarFila'      : 'Eliminar esta fila',
    'detConcepto'        : 'Concepto',
    'detCuenta'          : 'Cuenta N°',
    'detDebe'            : 'Debe',
    'detDetalleVacio'    : 'Debe agregar al menos una fila de detalle con una cuenta',
    'detErrorDebeHaber'  : 'Debe indicar el importe del Debe o el del Haber en cada fila de detalle (uno solo de los dos)',
    'detErrorFila'       : 'Fila {0}: {1}',
    'detFila'            : 'Fila',
    'detHaber'           : 'Haber',
    'detNombreCuenta'    : 'Nombre de la cuenta',
    'detSubcuenta'       : 'Subc.',
    'detTotales'         : 'TOTALES',
    'detHintCuenta'      : 'Número de cuenta',
    'detHintConcepto'    : 'Concepto del movimiento',
    'detHintNombreCuenta': 'Nombre de la cuenta contable',
    'detHintSubcuenta'   : 'N° subcuenta',
    // ── Pantalla Asientos ───────────────────────────────────────────────
    'asiComentarios'     : 'Comentarios',
    'asiFecha'           : 'Fecha del asiento',
    'asiHintComentarios' : 'Comentarios sobre este asiento contable',
    'asiNumero'          : 'Número del asiento',
  };

  static const Map<String, String> mapFr = <String, String>{
    // ── Detalle contable (compartido) ────────────────────────────────────
    'detAgregarFila'     : 'Ajouter une ligne',
    'detBorrarFila'      : 'Supprimer cette ligne',
    'detConcepto'        : 'Libellé',
    'detCuenta'          : 'Compte N°',
    'detDebe'            : 'Doit',
    'detDetalleVacio'    : 'Vous devez ajouter au moins une ligne de détail avec un compte',
    'detErrorDebeHaber'  : 'Vous devez indiquer le montant du Doit ou de l\'Avoir dans chaque ligne de détail (un seul des deux)',
    'detErrorFila'       : 'Ligne {0} : {1}',
    'detFila'            : 'Ligne',
    'detHaber'           : 'Avoir',
    'detNombreCuenta'    : 'Nom du compte',
    'detSubcuenta'       : 'Sous-c.',
    'detTotales'         : 'TOTAUX',
    'detHintCuenta'      : 'Numéro de compte',
    'detHintConcepto'    : 'Libellé du mouvement',
    'detHintNombreCuenta': 'Nom du compte comptable',
    'detHintSubcuenta'   : 'N° sous-compte',
    // ── Pantalla Asientos ───────────────────────────────────────────────
    'asiComentarios'     : 'Commentaires',
    'asiFecha'           : 'Date de l\'écriture',
    'asiHintComentarios' : 'Commentaires sur cette écriture comptable',
    'asiNumero'          : 'Numéro de l\'écriture',
  };

}
