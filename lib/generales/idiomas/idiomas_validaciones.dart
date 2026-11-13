/// Textos del idioma: plantillas genéricas de validación (ClaseCapValidar).
/// Los parámetros {0}, {1}, etc. se reemplazan por _traducir().
abstract final class ClaseIdiomasValidaciones {

  static const Map<String, String> mapEs = <String, String>{
    'validAlMenosUno'       : 'Debe seleccionar al menos una opción en "{0}"',
    'validCuentaSuperior'   : 'La cuenta de nivel superior es obligatoria cuando el número de cuenta tiene más de 1 dígito',
    'validDigitosExactos'   : 'El campo "{0}" debe tener exactamente {1} dígitos',
    'validEjercicioRango'   : 'El campo "{0}" debe ser un ejercicio entre 2020 y el año actual',
    'validFechaAnterior'    : 'El campo "{0}" no puede ser anterior al {1}',
    'validFechaFinPosterior': 'La fecha de fin de vigencia debe ser posterior a la fecha de inicio de vigencia',
    'validFechaInvalida'    : 'El campo "{0}" tiene un formato de fecha inválido',
    'validFechaRango'       : 'La fecha de {0} debe estar entre el {1} y el {2}',
    'validFormatoCuenta'    : 'El número de cuenta debe tener el formato 9.99.99.99 (ejemplos válidos: 1, 1.01, 1.01.04, 2.03.05.17)',
    'validHoraInvalida'     : 'El campo "{0}" tiene un formato de hora inválido. Use hh:mm',
    'validLongMaxima'       : 'El campo "{0}" admite un máximo de {1} caracteres',
    'validLongMinima'       : 'El campo "{0}" debe tener al menos {1} caracteres',
    'validNivelCuenta'      : 'El campo "{0}" debe ser un dígito entre 1 y 9',
    'validNoNegativo'       : '{0} debe ser mayor o igual que cero',
    'validNumeroDocumento'  : 'El campo "{0}" debe tener exactamente 13 dígitos con el formato 999-999-9999999',    
    'validObligatorio'      : 'El campo "{0}" es obligatorio',
    'validRangoEntero'      : 'El campo "{0}" debe ser un número entre {1} y {2}',
    'validSoloEntero'       : 'El campo "{0}" debe ser un número entero',
    'validSubcuentaRango'   : 'El campo "{0}" debe tener 5 dígitos entre 00001 y 99999',
    'validSumaDebeHaber'    : 'La suma del Debe debe ser exactamente igual a la suma del Haber',
    'validIdentCedula'      : 'El campo "{0}" debe ser un número de cédula de 5 a 8 dígitos (se permiten puntos como separadores)',
    'validIdentPasaporte'   : 'El campo "{0}" debe contener solo letras mayúsculas, dígitos y guiones',
    'validIdentRuc'         : 'El campo "{0}" debe ser un RUC con el formato 9999999-9 (número y dígito verificador)',
    'validIdentRucDv'       : 'El dígito verificador del campo "{0}" no es correcto. Revise el número de RUC.',

  };

  static const Map<String, String> mapFr = <String, String>{
    'validAlMenosUno'       : 'Vous devez sélectionner au moins une option dans "{0}"',
    'validCuentaSuperior'   : 'Le compte de niveau supérieur est obligatoire lorsque le numéro de compte a plus de 1 chiffre',
    'validDigitosExactos'   : 'Le champ "{0}" doit avoir exactement {1} chiffres',
    'validEjercicioRango'   : 'Le champ "{0}" doit être un exercice entre 2020 et l\'année en cours',
    'validFechaAnterior'    : 'Le champ "{0}" ne peut pas être antérieur au {1}',
    'validFechaFinPosterior': 'La date de fin de validité doit être postérieure à la date de début de validité',
    'validFechaInvalida'    : 'Le champ "{0}" a un format de date invalide',
    'validFechaRango'       : 'La date de {0} doit être entre le {1} et le {2}',
    'validFormatoCuenta'    : 'Le numéro de compte doit avoir le format 9.99.99.99 (exemples valides : 1, 1.01, 1.01.04, 2.03.05.17)',
    'validHoraInvalida'     : 'Le champ "{0}" a un format d\'heure invalide. Utilisez hh:mm',
    'validLongMaxima'       : 'Le champ "{0}" accepte un maximum de {1} caractères',
    'validLongMinima'       : 'Le champ "{0}" doit avoir au moins {1} caractères',
    'validNivelCuenta'      : 'Le champ "{0}" doit être un chiffre entre 1 et 9',
    'validNoNegativo'       : '{0} doit être supérieur ou égal à zéro',
    'validNumeroDocumento'  : 'Le champ "{0}" doit avoir exactement 13 chiffres au format 999-999-9999999',    
    'validObligatorio'      : 'Le champ "{0}" est obligatoire',
    'validRangoEntero'      : 'Le champ "{0}" doit être un nombre entre {1} et {2}',
    'validSoloEntero'       : 'Le champ "{0}" doit être un nombre entier',
    'validSubcuentaRango'   : 'Le champ "{0}" doit avoir 5 chiffres entre 00001 et 99999',
    'validSumaDebeHaber'    : 'La somme du Doit doit être exactement égale à la somme de l\'Avoir',
    'validIdentCedula'      : 'Le champ "{0}" doit être un numéro de carte d\'identité de 5 à 8 chiffres (les points sont acceptés comme séparateurs)',
    'validIdentPasaporte'   : 'Le champ "{0}" doit contenir uniquement des lettres majuscules, des chiffres et des traits d\'union',
    'validIdentRuc'         : 'Le champ "{0}" doit être un RUC au format 9999999-9 (numéro et chiffre de contrôle)',
    'validIdentRucDv'       : 'Le chiffre de contrôle du champ "{0}" n\'est pas correct. Vérifiez le numéro de RUC.',

  };

}
