# VS_CONTA — CLAUDE.md

## Proyecto
- Nombre: vs_conta (VS_CONTA). Aplicación Flutter de contabilidad multi-país, multi-moneda, multi-sucursal, multi-usuario y multi-idioma.
- Repo: github.com/wojedav2104/vs_flutter_conta, rama main.
- SDK Dart ^3.13.7. Dependencias: flutter_localizations, intl, shared_preferences, web.
- Idiomas: español (es) y francés (fr). Todos los textos visibles pasan por ClaseIdiomas.getTexto(clave, idioma).

## Reglas de estilo del código
- Líneas de hasta 176 caracteres (el usuario ve 176 col en VS Code). Usar todo el ancho disponible en código y comentarios; partir solo lo que no entre.
- Prefijos: clases Clase…; enums Enum…; cadenas s…; enteros i…; booleanos b…; doubles d…; mapas map…; listas list…; objetos o…; funciones func….
- Constructor y parámetros con alineación de dos puntos y orden alfabético de parámetros.
- Métodos de una línea con => si queda legible.
- Comentarios en español, formato de sección ── Título ─────.
- Identificadores de idioma: claves tipo 'menuPlanCuentas', 'comTipoDocNN', 'venTipoDocNN', 'empHintNombre'. Textos ES y FR obligatorios.
- Campos ABM (ClaseCampoAbm): parámetros orden alfabético; sGrupo para pestañas; iFila para la fila dentro de la pestaña; sMascara '999-999-9999999' (documentos), '99/99/9999' (fecha), '99:99' (hora), '999.999.999.999' (importes).

## Sistema de anchos (vigente)
- ClaseGenLayout (lib/generales/temas/layout.dart): constantes de ancho/alto/escala.
- ClaseCampoAbm.getAnchoCampo(): única fuente del ancho de los campos (caracteres × dAnchoCaracter × dFactorTexto × dEscala + extras por tipo).
- ClaseCampoAbm.getAnchoEtiqueta(): única fuente del ancho de etiquetas. iAnchoEtiqueta (en caracteres) por campo; 0 = ancho general ClaseGenLayout.dAnchoEtiquetaCampo (300 px). Escala igual que la fuente.
- dAnchoSuffixBorrar: hueco de la "X" de borrado dentro de los campos texto/número (24 = icono 18 + 3 px por lado).
- dFactorTexto (estilos_textos.dart, 1.0 / 1.25 texto grande) y dEscala (calcularEscala según el ancho de ventana, base 1920) afectan todo lo visual.

## Formato de los parches de código
- Siempre entregar los cambios como pares "Buscar:" / "Reemplazar por:" en bloques de código.
- Siempre indicar la RUTA COMPLETA del archivo .dart (ej: lib/opciones/archivos/compras.dart).
- El texto Buscar debe ser único en el archivo; incluir contexto (sClave, sGrupo, iFila) cuando haya bloques similares.
- El usuario aplica los cambios y confirma; si un Buscar no encuentra, el usuario pega el bloque y se devuelve el reemplazo exacto.
- Traducciones al francés: proponerlas siempre; el usuario las acepta salvo cambio.

## Estructura de carpetas (lib/)
- main.dart → ClaseAplicacion → ClaseLogin → ClasePantallaPrincipal (drawer ClaseMenuLateral).
- lib/rutas/: rutas.dart (30 rutas nombradas), generador_rutas.dart (onGenerateRoute + oObservadorRutas).
- lib/generales/: idiomas/ (9 módulos + idiomas.dart), inicio/ (login, pantalla_principal, menu_lateral), modelos/ (campo_abm, documentos, sesion, permisos, opcion_menu...), permisos/, preferencias/, temas/ (temas, layout, espacios, radios, estilos_textos), utilitarios/ (formatos, generales, paletas, rangos_fechas), validaciones/ (cap_validar), varios/ (listas, timbrados_comun, pantalla_proximamente), widgets/ (abm_comun, campo_formulario, formulario_abm, formulario_cabecera_detalle, controles_preferencias, ventana_*).
- lib/opciones/archivos/: asientos, compras, cuentas, ventas (cabecera + grilla de detalles).
- lib/opciones/tablas/: clientes, configuracion, cuentas_asignadas, empresa, proveedores, sucursales, timbrados_propios, timbrados_proveedores.
- lectura/: fragmentos .txt del código fuente para lectura remota (parte X de Y).

## Reglas funcionales vigentes
- Empresa: tabla de un solo registro (bTablaUnSoloRegistro: true, bPermitirEncontrar: false). 3 pestañas: Generales, Varios, Impuestos. Las listas de Impuestos y Emite Factura Electrónica son obligatorias y SIN valor por defecto (el usuario debe indicar).
- Ventas: 14 tipos de documento ('01'..'14'), máscara en 01, 02, 03, 06, 07, 11; esFacturaCredito = '02'.
- Compras: 18 tipos de documento ('01'..'18'), máscara en 01, 02, 03, 04, 06, 09, 10.
- Drawer: orden de grupos 1 Archivos, 2 Tablas, 3 Procesos, 4 Informes, 5 Utilitarios, 6 Sistema, 7 Fin. Sin numeración visible. "Importar desde SQL_CONTA" y "Marangatú" solo Paraguay (listPaises).
- El campo "Mostrar en Libro Compras/Ventas" va debajo de Total (Compras: iFila 13; Ventas: iFila 12).
- La X de borrado: suffixIcon con hueco angosto (dAnchoSuffixBorrar), sin Transform; solo texto/número. Fecha/Hora conservan su X fuera del campo (junto al picker).
