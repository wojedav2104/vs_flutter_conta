# VS_CONTA — Guía de trabajo del proyecto

Aplicación de Contabilidad multi-país, multi-moneda, multi-sucursal, multi-usuario y multi-idioma (español/francés), escrita en Flutter (web + escritorio). Desarrollo en equipo entre el usuario (contador, no programador) y el asistente de IA.

## Fuentes de verdad

- `Documentación/00_*` — reglas del código, las specs y la lectura del proyecto (00_00_01 calidad, 00_00_02 nomenclatura, 00_00_03 UI/UX, 00_03_01/00_03_02 specs ABM).
- `Documentación/01_*` — conceptos de gestión (pantalla principal, países, cambio de moneda, importación de datos).
- `Documentación/02_0X_*` — especificaciones de cada tabla, con `01` = datos y `02` = reglas de validación.
- `lectura/` — espejo de lectura del código fuente en fragmentos de ~5 KB (`ruta__parteNdeM.txt`). El usuario lo regenera después de cada tanda de cambios; es la vía para releer el código con el scraper.
- Ante conflicto, ganan las specs de `Documentación/`; el código se ajusta a ellas.

## Reglas de trabajo con el asistente

1. Cuando se pida reemplazar código, indicar SIEMPRE primero lo que hay que **buscar** (texto exacto que está en el archivo) y a continuación lo que lo **reemplaza**. Formato: bloque "Buscar:" + bloque "Reemplazar por:".
2. En el código fuente y en los comentarios usar los **176 caracteres** visibles por fila del monitor del usuario (00_00_02).
3. El asistente trabaja con texto: no recibe imágenes. Las descripciones de pantalla se hacen con palabras.
4. Idioma de trabajo: español. Código, comentarios y docs en español (salvo identificadores ya existentes).
5. Nomenclatura obligatoria (00_00_02): prefijo `Clase` para clases; `list`/`map`/`set` para colecciones; `s` cadenas, `i` enteros, `d` decimales, `b` booleanos, `f` fechas, `o` objetos, `c` caracteres; `func` para funciones; `enum Enum...`; constantes `ClaseGen...`; sin ñ ni tildes en identificadores; `get`/`set` en accesores; `has`/`is` en consultas booleanas.

## Convenciones de código (resumen)

- SOLID, KISS, DRY, YAGNI; alta cohesión y bajo acoplamiento (00_00_01). Clases pequeñas, archivos pequeños.
- Un punto de cambio por comportamiento; sin duplicación de lógica.
- Validaciones centralizadas en `ClaseCapValidar`; los campos declaran su validación con `funcValidarCampo`.
- Textos SIEMPRE vía `ClaseIdiomas.getTexto('clave', sIdioma)`, con archivos `idiomas_*.dart` por módulo. Nunca texto duro en el código.
- Colores SIEMPRE desde `ClaseGenColores` (paleta) y `ClaseGenTemas` (semántica con modo claro/oscuro). Ningún widget declara `Color(0x...)`.
- Formatos por `ClaseFormatos`/`formatos.dart`; preferencias por `ClasePreferencias`.
- Widgets genéricos reutilizables en `lib/generales/widgets/`; cada pantalla nueva los reutiliza en lugar de duplicarlos.

## Reglas de UI/UX acordadas

- Etiquetas: alineadas a la derecha, con asterisco rojo si el campo es obligatorio. Ancho por defecto **240 px** (`ClaseGenLayout.dAnchoEtiquetaCampo`) cuando el campo no especifica `iAnchoEtiqueta`; con valor, `iAnchoEtiqueta` está en caracteres. La primera columna de Compras/Ventas usa la constante `iAnchoEtiquetasPrimeraColumna = 29`.
- Los cinco backcolors de los formularios son distintos entre sí y se centralizan en `ClaseGenTemas`: pestaña seleccionada (`colorFondoPestanaActiva`), pestaña no seleccionada (`colorFondoPestanaInactiva`), campo habilitado (`colorFondoCampoHabilitado`), campo deshabilitado (`colorFondoCampoDeshabilitado`) y formulario (`scaffoldBackgroundColor`). Valores crudos en `ClaseGenColores`.
- Anchos de controles: mínimos necesarios (00_03_01 regla 6). Fórmulas en `ClaseCampoAbm.getAnchoCampo()`; las reservas viven en `ClaseGenLayout` (`dAnchoExtraLista`, `dAnchoBotonCalendario`, `dAnchoBotonBorrarCampo`, `dMargenTextoCampo`). Los números conservan margen de seguridad de 24 px (sin él, en web se corta el último dígito del valor formateado).
- Importes de Compras/Ventas: se escriben en la pestaña 2 (Detalles) y se duplican deshabilitados en la pestaña 3 (Resolución 90/2021), como referencia. El "Total" del Grupo 2 debe ser idéntico al "Total del comprobante" del Grupo 3; los importes del Grupo 3 son reflejo de los escritos en el Grupo 2 (las referencias "del Grupo 2" en las specs son correctas y NO se cambian).
- Grilla editable de detalles: encabezado fijo, filas con acciones (subir, bajar, borrar), fila de totales con botón "Agregar fila" a la izquierda, campo Comentarios al pie. Columnas expansibles (Concepto) absorben el sobrante de ancho.
- Países: Paraguay (PRY) y Perú (PER) cargan datos; Francia (FRA) solo visualiza; Argentina y Uruguay, próximamente. `paises.json` es el catálogo; la lista de países que cargan datos se declara en `empresa.dart`.

## Estructura del código

- `lib/generales/` — `idiomas/`, `modelos/`, `preferencias/`, `temas/`, `utilitarios/`, `validaciones/`, `varios/`, `widgets/`.
- `lib/opciones/` — `archivos/` (tablas del libro contable), `tablas/` (Empresas, Clientes, Proveedores, Sucursales, Timbrados, Cuentas, etc.).
- Archivos grandes ya divididos: `compras.dart` → `compras` + `compras_campos` + `compras_logica` + `compras_datos`; `ventas.dart` → igual con prefijo `ventas`; `formulario_cabecera_detalle.dart` → `formulario_cabecera_detalle` + `grilla_detalles` + `detalle_validar`. Nuevos modulos seguirán este patrón (widget delgado + campos + lógica + datos de prueba).
- Pantallas cabecera/detalle usan `ClaseFormularioCabeceraDetalle`; ABM simples usan `ClaseFormularioAbm`. Las clases de campos son `abstract final class` con métodos estáticos.

## Flujo de trabajo

1. El usuario pide un cambio → el asistente da "Buscar:" / "Reemplazar por:" listos para pegar en VS Code.
2. El usuario aplica, prueba y sube a GitHub.
3. El usuario regenera `lectura/` cuando se pide releer código.
4. Para leer el repositorio con el scraper: usar el prefijo `https://r.jina.ai/` delante de la URL de `raw.githubusercontent.com`.
5. Errores de IDE con todo rojo: casi siempre es `.dart_tool/package_config.json`. Solución: `flutter pub get` (tras `flutter clean`, SIEMPRE correr `flutter clean && flutter pub get`).
6. Errores en tiempo de ejecución en VS Code ("Main isolate is paused in the debugger"): el error real está en la Consola de depuración.
