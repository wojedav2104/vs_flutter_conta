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

    // ── Pantalla Clientes (claves que usa clientes.dart) ─────────────
    'cliCodigo'            : 'Código',
    'cliNombre'            : 'Nombre',
    'cliCelular'           : 'Celular',
    'cliLocalidad'         : 'Localidad',
    'cliEmail'             : 'Correo electrónico',
    'cliTipoIdentificacion': 'Tipo de identificación',
    'cliIdentificacion'    : 'Identificación N°',
    'cliTipoCliente'       : 'Tipo de cliente',
    'cliHintNombre'        : 'Nombre de este cliente',
    'cliHintDireccion'     : 'Calle y N° donde reside',
    'cliHintTelefono'      : 'Nro teléfono',
    'cliHintCelular'       : 'Nro celular',
    'cliHintLocalidad'     : 'Localidad de su domicilio',
    'cliHintEmail'         : 'Correo electrónico',
    'cliHintIdentificacion': 'N° documento',

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
    'prvHintNombre'        : 'Nombre de este proveedor',
    'prvHintDireccion'     : 'Calle y N° donde reside',
    'prvHintTelefono'      : 'Nro teléfono',
    'prvHintCelular'       : 'Nro celular',
    'prvHintLocalidad'     : 'Localidad de su domicilio',
    'prvHintEmail'         : 'Correo electrónico',
    'prvHintIdentificacion': 'N° documento',

    // ── Timbrados (claves usadas en las dos pantallas) ───────────────
    'timUltimoDocumento'   : 'Número del último documento',
    'timPrvNombre'         : 'Nombre del proveedor',
    'timPrvRuc'            : 'R.U.C.',
    'timPrvHintNombre'     : 'Nombre fiscal del proveedor',
    'timPrvHintRuc'        : 'RUC proveedor',

    // ── Timbrados (campos comunes, ClaseTimbradosComun) ──────────────
    'timTimbrado'          : 'N° de timbrado',
    'timFechaInicio'       : 'Fecha de inicio',
    'timFechaFin'          : 'Fecha de fin',
    'timAfectaA'           : 'Afecta a',
    'timMedioGeneracion'   : 'Medio de generación',

    // ── Timbrados (opciones de Afecta a y Medio de generación) ───────
    'timFactura'           : 'Factura',
    'timNotaCredito'       : 'Nota de crédito',
    'timNotaDebito'        : 'Nota de débito',
    'timNotaRemision'      : 'Nota de remisión',
    'timAutoImpresores'    : 'Autoimpresores',
    'timPreImpresos'       : 'Preimpresos',
    'timComprobantesVirtuales'  : 'Comprobantes virtuales',
    'timDocumentosElectronicos' : 'Documentos electrónicos',

    // ── Opciones compartidas de terceros ─────────────────────────────
    'valorLocal'           : 'Local',
    'valorExterior'        : 'Exterior',

  };




  static const Map<String, String> mapFr = <String, String> {

    // ── Pantalla Proveedores (ABM) ──────────────────────────────────

    'proAlta'               : 'Création',
    'proApellidoMaterno'    : 'Nom de famille maternel',
    'proApellidoPaterno'    : 'Nom de famille paternel',
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
    'proNombreFantasia'     : 'Nom de marque',
    'proRazonSocial'        : 'Raison sociale',
    'proRuc'                : 'R.U.C.',
    'proTelefono'           : 'Téléphone',
    'proTerceroPorDefecto'  : 'Fournisseur par défaut',

    // ── Pantalla Clientes (ABM) ────────────────────────────────────

    'terTerceros'           : 'Tiers',

    'cliAlta'               : 'Création',
    'cliApellidoMaterno'    : 'Nom de famille maternel',
    'cliApellidoPaterno'    : 'Nom de famille paternel',
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
    'cliNombreFantasia'     : 'Nom de marque',    
    'cliRazonSocial'        : 'Raison sociale',
    'cliRuc'                : 'R.U.C.',
    'cliTelefono'           : 'Téléphone',

    // ── Pantalla Clientes (claves que usa clientes.dart) ─────────────
    'cliCodigo'            : 'Code',
    'cliNombre'            : 'Nom',
    'cliCelular'           : 'Portable',
    'cliLocalidad'         : 'Localité',
    'cliEmail'             : 'Adresse e-mail',
    'cliTipoIdentificacion': "Type d'identification",
    'cliIdentificacion'    : 'Identification N°',
    'cliTipoCliente'       : 'Type de client',
    'cliHintNombre'        : 'Nom de ce client',
    'cliHintDireccion'     : 'Rue et N° où il réside',
    'cliHintTelefono'      : 'N° de téléphone',
    'cliHintCelular'       : 'N° de portable',
    'cliHintLocalidad'     : 'Localité de son domicile',
    'cliHintEmail'         : 'Adresse électronique',
    'cliHintIdentificacion': 'N° de document',

    // ── Tipos de documento de identidad (compartido) ─────────────────
    'docRuc'               : 'R.U.C.',
    'docCedulaIdentidad'   : "Carte d'identité",
    'docPasaporte'         : 'Passeport',
    'docCedulaExtranjera'  : "Carte d'identité étrangère",
    'docSinNombre'         : 'Sans nom',
    'docDiplomatico'       : 'Diplomatique',
    
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
    'prvHintNombre'        : 'Nom de ce fournisseur',
    'prvHintDireccion'     : 'Rue et N° où il réside',
    'prvHintTelefono'      : 'N° de téléphone',
    'prvHintCelular'       : 'N° de portable',
    'prvHintLocalidad'     : 'Localité de son domicile',
    'prvHintEmail'         : 'Adresse électronique',
    'prvHintIdentificacion': 'N° de document',

    // ── Timbrados (claves usadas en las dos pantallas) ───────────────
    'timUltimoDocumento'   : 'Numéro du dernier document',
    'timPrvNombre'         : 'Nom du fournisseur',
    'timPrvRuc'            : 'R.U.C.',
    'timPrvHintNombre'     : 'Nom fiscal du fournisseur',
    'timPrvHintRuc'        : 'RUC fournisseur',

    // ── Timbrados (campos comunes, ClaseTimbradosComun) ──────────────
    'timTimbrado'          : 'Numéro de timbrado',
    'timFechaInicio'       : 'Date de début',
    'timFechaFin'          : 'Date de fin',
    'timAfectaA'           : "S'applique à",
    'timMedioGeneracion'   : 'Mode de génération',

    // ── Timbrados (opciones de Afecta a y Medio de generación) ───────
    'timFactura'           : 'Facture',
    'timNotaCredito'       : 'Note de crédit',
    'timNotaDebito'        : 'Note de débit',
    'timNotaRemision'      : "Note d'expédition",
    'timAutoImpresores'    : 'Auto-impression',
    'timPreImpresos'       : 'Pré-imprimés',
    'timComprobantesVirtuales'  : 'Justificatifs virtuels',
    'timDocumentosElectronicos' : 'Documents électroniques',

    // ── Opciones compartidas de terceros ─────────────────────────────
    'valorLocal'           : 'Local',
    'valorExterior'        : 'Étranger',

  };  

}
