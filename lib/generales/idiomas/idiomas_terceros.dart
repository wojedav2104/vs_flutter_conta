/// Textos del idioma: Clientes, Proveedores y terceros.
///
/// Las pantallas Empresa y Sucursales viven en idiomas_tablas.dart
/// (sus claves emp*/suc* estaban duplicadas acá y tapaban los textos de
/// Tablas; se eliminaron de este archivo).
abstract final class ClaseIdiomasTerceros {

  static const Map<String, String> mapEs = <String, String> {

    // ── Pantalla Proveedores (ABM) ──────────────────────────────────

    'proAlta'               : 'Alta',
    'proApellidoMaterno'    : 'Apellido materno',
    'proApellidoPaterno'    : 'Apellido paterno',
    'proAutonomo'           : 'Autónomo',
    'proCiudad'             : 'Ciudad',
    'proContacto'           : 'Persona de contacto',
    'proCorreo'             : 'Correo electrónico',
    'proDireccion'          : 'Dirección',
    'proDocumentoIdentidad' : 'Documento de identidad',
    'proEsContribuyente'    : 'Es contribuyente',
    'proEsDiplomatico'      : 'Es agente diplomático',
    'proExterior'           : 'Exterior',
    'proLocal'              : 'Local',
    'proNombreComercial'    : 'Nombre comercial',
    'proNombreFantasia'     : 'Nombre de fantasía',
    'proRazonSocial'        : 'Razón social',
    'proRuc'                : 'R.U.C.',
    'proTelefono'           : 'Teléfono',
    'proTerceroPorDefecto'  : 'Proveedor por defecto',

    // ── Pantalla Clientes (ABM) ────────────────────────────────────

    'terTerceros'           : 'Terceros',

    'cliAlta'               : 'Alta',
    'cliApellidoMaterno'    : 'Apellido materno',
    'cliApellidoPaterno'    : 'Apellido paterno',
    'cliAutonomo'           : 'Autónomo',
    'cliCiudad'             : 'Ciudad',
    'cliClientePorDefecto'  : 'Cliente por defecto',
    'cliContacto'           : 'Persona de contacto',
    'cliCorreo'             : 'Correo electrónico',
    'cliDireccion'          : 'Dirección',
    'cliDocumentoIdentidad' : 'Documento de identidad',
    'cliEsContribuyente'    : 'Es contribuyente',
    'cliEsDiplomatico'      : 'Es agente diplomático',
    'cliExterior'           : 'Exterior',
    'cliLocal'              : 'Local',
    'cliNombreComercial'    : 'Nombre comercial',
    'cliNombreFantasia'     : 'Nombre de fantasía',
    'cliRazonSocial'        : 'Razón social',
    'cliRuc'                : 'R.U.C.',
    'cliTelefono'           : 'Teléfono',

    // ── Tipos de documento de identidad (compartido) ─────────────────
    'docRuc'               : 'R.U.C.',
    'docCedulaIdentidad'   : 'Cédula de Identidad',
    'docPasaporte'         : 'Pasaporte',
    'docCedulaExtranjera'  : 'Cédula Extranjera',
    'docSinNombre'         : 'Sin Nombre',
    'docDiplomatico'       : 'Diplomático',

    // ── Pantalla Proveedores (claves que usa proveedores.dart) ───────
    'prvCodigo'            : 'Código',
    'prvNombre'            : 'Nombre',
    'prvDireccion'         : 'Dirección',
    'prvTelefono'          : 'Teléfono',
    'prvCelular'           : 'Celular',
    'prvLocalidad'         : 'Localidad',
    'prvEmail'             : 'Correo electrónico',
    'prvTipoIdentificacion': 'Tipo de identificación',
    'prvIdentificacion'    : 'Identificación N°',
    'prvTipoProveedor'     : 'Tipo de proveedor',
    'prvEsServicioPublico' : 'Es servicio público',
    'prvHintNombre'        : 'Nombre del proveedor',
    'prvHintTelefono'      : 'Nro teléfono',
    'prvHintCelular'       : 'Nro celular',
    'prvHintLocalidad'     : 'Nombre de la localidad',
    'prvHintEmail'         : 'Correo electrónico',
    'prvHintIdentificacion': 'Número de identidad',

    // ── Timbrados (claves usadas en las dos pantallas) ───────────────
    'timUltimoDocumento'   : 'Número del último documento',
    'timPrvNombre'         : 'Nombre del proveedor',
    'timPrvRuc'            : 'R.U.C.',
    'timPrvHintNombre'     : 'Nombre del proveedor',
    'timPrvHintRuc'        : 'Número de RUC del proveedor',

  };




  static const Map<String, String> mapFr = <String, String> {

    // ── Pantalla Proveedores (ABM) ──────────────────────────────────

    'proAlta'               : 'Création',
    'proApellidoMaterno'    : 'Nom de la mère',
    'proApellidoPaterno'    : 'Nom du père',
    'proAutonomo'           : 'Travailleur indépendant',
    'proCiudad'             : 'Ville',
    'proContacto'           : 'Personne de contact',
    'proCorreo'             : 'Adresse e-mail',
    'proDireccion'          : 'Adresse',
    'proDocumentoIdentidad' : 'Pièce d\'identité',
    'proEsContribuyente'    : 'Est contribuable',
    'proEsDiplomatico'      : 'Est agent diplomatique',
    'proExterior'           : 'Étranger',
    'proLocal'              : 'Local',
    'proNombreComercial'    : 'Nom commercial',
    'proNombreFantasia'     : 'Nom de fantaisie',
    'proRazonSocial'        : 'Raison sociale',
    'proRuc'                : 'N.I.T.',
    'proTelefono'           : 'Téléphone',
    'proTerceroPorDefecto'  : 'Fournisseur par défaut',

    // ── Pantalla Clientes (ABM) ────────────────────────────────────

    'terTerceros'           : 'Tiers',

    'cliAlta'               : 'Création',
    'cliApellidoMaterno'    : 'Nom de la mère',
    'cliApellidoPaterno'    : 'Nom du père',
    'cliAutonomo'           : 'Travailleur indépendant',
    'cliCiudad'             : 'Ville',
    'cliClientePorDefecto'  : 'Client par défaut',
    'cliContacto'           : 'Personne de contact',
    'cliCorreo'             : 'Adresse e-mail',
    'cliDireccion'          : 'Adresse',
    'cliDocumentoIdentidad' : 'Pièce d\'identité',
    'cliEsContribuyente'    : 'Est contribuable',
    'cliEsDiplomatico'      : 'Est agent diplomatique',
    'cliExterior'           : 'Étranger',
    'cliLocal'              : 'Local',
    'cliNombreComercial'    : 'Nom commercial',
    'cliNombreFantasia'     : 'Nom de fantaisie',
    'cliRazonSocial'        : 'Raison sociale',
    'cliRuc'                : 'N.I.T.',
    'cliTelefono'           : 'Téléphone',

    // ── Tipos de documento de identidad (compartido) ─────────────────
    'docRuc'               : 'N.I.T.',
    'docCedulaIdentidad'   : "Carte d'identité",
    'docPasaporte'         : 'Passeport',
    'docCedulaExtranjera'  : "Carte d'identité étrangère",
    'docSinNombre'         : 'Sans nom',
    'docDiplomatico'       : 'Diplomate',

    // ── Pantalla Proveedores (claves que usa proveedores.dart) ───────
    'prvCodigo'            : 'Code',
    'prvNombre'            : 'Nom',
    'prvDireccion'         : 'Adresse',
    'prvTelefono'          : 'Téléphone',
    'prvCelular'           : 'Portable',
    'prvLocalidad'         : 'Localité',
    'prvEmail'             : 'Adresse e-mail',
    'prvTipoIdentificacion': "Type d'identification",
    'prvIdentificacion'    : 'Identification N°',
    'prvTipoProveedor'     : 'Type de fournisseur',
    'prvEsServicioPublico' : 'Est un service public',
    'prvHintNombre'        : 'Nom du fournisseur',
    'prvHintTelefono'      : 'N° de téléphone',
    'prvHintCelular'       : 'N° de portable',
    'prvHintLocalidad'     : 'Nom de la localité',
    'prvHintEmail'         : 'Adresse électronique',
    'prvHintIdentificacion': "Numéro de pièce d'identité",

    // ── Timbrados (claves usadas en las dos pantallas) ───────────────
    'timUltimoDocumento'   : 'Numéro du dernier document',
    'timPrvNombre'         : 'Nom du fournisseur',
    'timPrvRuc'            : 'N.I.T.',
    'timPrvHintNombre'     : 'Nom du fournisseur',
    'timPrvHintRuc'        : 'Numéro de N.I.T. du fournisseur',

  };  

}
