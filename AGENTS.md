# AGENTS.md — VS_CONTA

Flutter (web + escritorio) de contabilidad multi-país. Trabajo en **español**: código, comentarios y docs (nombres de identificadores también en español, sin ñ ni tildes).

## Guía completa

Leer `Documentación/CLAUDE.md` (reglas, UI/UX, estructura) y `Documentación/Proyecto VS_CONTA_21.txt` (estado y pendientes de la sesión 19/20-nov-2026). Fuentes de verdad en `Documentación/`:

- `00_*` reglas del código: `00_00_01` calidad, `00_00_02` nomenclatura, `00_00_03` UI/UX, `00_03_01/00_03_02` specs ABM.
- `01_*` conceptos de gestión (pantalla principal, países, cambio de moneda, importación de datos).
- `02_0X_*` specs por tabla: `01` = datos, `02` = reglas de validación.
- `lectura/` espejo de lectura del código en fragmentos de ~5 KB (`ruta__parteNdeM.txt`); se regenera con `dart run tool/partir_lectura.dart` tras cada tanda de cambios; no editar a mano.

Ante conflicto entre specs y código, **ganan las specs**; el código se ajusta a ellas. `README.md` es plantilla de Flutter: ignorarlo.

## Comandos

```bash
flutter pub get                 # tras tocar pubspec o si la IDE se pone roja
flutter analyze                 # verificación principal (gate del proyecto)
dart run tool/partir_lectura.dart   # regenera el espejo lectura/ (no editar a mano)
```

- Orden habitual: `flutter analyze` → (si hace falta) `flutter run` / `flutter test`.
- Leer el repo con el scraper: prefijo `https://r.jina.ai/` delante de la URL de `raw.githubusercontent.com`.
- Después de `flutter clean` correr **siempre** `flutter clean && flutter pub get` (si no, `.dart_tool/package_config.json` queda roto y todo el IDE se pone rojo).
- `flutter analyze` hoy: 0 errores/warnings, ~7 info preexistentes (lints cosméticos en `lib/generales/widgets/` y `tool/`). No “arreglar” el baseline salvo que se pida.
- Tests: solo `test/widget_test.dart` (login). **`flutter test` puede colgarse** (`SharedPreferences` sin mock / `pumpAndSettle`); confiar en `flutter analyze`. No hay CI ni `opencode.json`.

## Convenciones que se suelen omitir

- SOLID, KISS, DRY, YAGNI; alta cohesión/bajo acoplamiento, clases y archivos pequeños; un punto de cambio por comportamiento (00_00_01).
- **Nomenclatura obligatoria** (`Documentación/00_00_02_*.txt`): `Clase*` clases; `func*` funciones propias; colecciones `list`/`map`/`set`; prefijos de tipo `s` `i` `d` `b` `f` `o` `c` `n` `w`; constantes `ClaseGen...`; `get`/`set` en accesores; orden de propiedades por tipo y alfabético; `=` y `:` alineados en columna; ancho de fila **176** caracteres.
- Textos **nunca** hardcodeados: solo `ClaseIdiomas.getTexto(clave, sIdioma)` con claves en `lib/generales/idiomas/idiomas_*.dart` (falta de clave devuelve la clave).
- Colores **nunca** `Color(0x...)` en widgets: solo `ClaseGenColores` (paleta) y `ClaseGenTemas` (semántica claro/oscuro).
- Validaciones centralizadas en `ClaseCapValidar` + `funcValidarCampo`.
- Reutilizar widgets de `lib/generales/widgets/` (`ClaseFormularioAbm`, `ClaseFormularioCabeceraDetalle`, `ClaseCampoAbm`, `ClaseGenLayout`); no duplicar controles.
- Fuente monoespaciada (Roboto Mono) en controles; botones con icono a la izquierda.
- Los cambios se aplican **directamente en los archivos del disco** con las herramientas de edición, según la sección "Flujo con el usuario" (no se da código para pegar).
- El asistente **no recibe imágenes**: describir pantallas y errores con palabras.
- Formatos de fechas/números por `formatos.dart`; preferencias por `ClasePreferencias`.

## UI/UX acordadas

- Etiquetas alineadas a la derecha, asterisco rojo si obligatoria. Ancho por defecto **240 px** (`ClaseGenLayout.dAnchoEtiquetaCampo`) si el campo no trae `iAnchoEtiqueta`; con valor, está en caracteres. Primera columna de Compras/Ventas: `iAnchoEtiquetasPrimeraColumna = 29` (conservar tal cual).
- Cinco backcolors de formulario distintos, centralizados en `ClaseGenTemas`: pestaña activa `colorFondoPestanaActiva`, pestaña inactiva `colorFondoPestanaInactiva`, campo habilitado `colorFondoCampoHabilitado`, campo deshabilitado `colorFondoCampoDeshabilitado`, formulario `scaffoldBackgroundColor`. Valores crudos en `ClaseGenColores` (claro/oscuro).
- Anchos de controles mínimos necesarios (00_03_01 regla 6): fórmulas en `ClaseCampoAbm.getAnchoCampo()`; reservas en `ClaseGenLayout` (`dAnchoExtraLista`, `dAnchoBotonCalendario`, `dAnchoBotonBorrarCampo`, `dMargenTextoCampo`). Texto con margen 8 px; **números conservan 24 px** (sin él, en web se corta el último dígito).
- Importes de Compras/Ventas: se **escriben en la pestaña 2** (Detalles) y se **duplican deshabilitados en la pestaña 3** (Resolución 90/2021). Total del Grupo 2 = "Total del comprobante" del Grupo 3; las referencias "del Grupo 2" en las specs son correctas y **no se cambian**.
- Grilla editable de detalles: encabezado fijo, acciones subir/bajar/borrar por fila, fila de totales con "Agregar fila" a la izquierda, Comentarios al pie; columnas expansibles (Concepto) absorben el sobrante de ancho.

## Estructura (no obvia por nombres)

- `lib/main.dart` → login → `lib/rutas/generador_rutas.dart` (`funcGenerarRuta` + `ClaseRutas`).
- `lib/generales/` — infra: `idiomas/`, `temas/`, `preferencias/`, `validaciones/`, `widgets/`, `modelos/`, `varios/`, `utilitarios/` (`formatos.dart` = fechas/formatos libres, no una clase `ClaseFormatos`).
- `lib/opciones/archivos/` — libro contable: `compras`, `ventas`, `asientos`, `cuentas`. `lib/opciones/tablas/` — ABM: `empresa`, `clientes`, `proveedores`, etc.
- Módulos grandes van partidos: `X.dart` → `X` + `X_campos` + `X_logica` + `X_datos` (patrón de `compras`/`ventas`). `formulario_cabecera_detalle.dart` → `formulario_cabecera_detalle` + `grilla_detalles` + `detalle_validar`. Clases de campos: `abstract final class` con métodos estáticos. Seguir ese patrón al dividir.
- Nota pendiente: en `grilla_detalles.dart` uniformizar el import estilo `package:vs_conta/...` de `campo_formulario.dart` a relativo.
- Varias carpetas están **vacías a propósito** (placeholders): `lib/generales/basesdatos`, `lib/generales/errores`, `lib/opciones/{sistema,procesos,consultas,informes,impresiones,graficos,utilitarios}`. No borrar; no inventar contenido.
- Países con datos: `PRY`, `PER` (lista en `lib/opciones/tablas/empresa.dart`); `FRA` solo consulta. Catálogo: `assets/datos/paises.json`.

## Estado y pendientes (sesión 19/20-nov-2026)

- Estado: compila y corre sin errores ni warnings (0 errores/warnings en `flutter analyze`); módulos de Retenciones Clientes (specs 02_05) y Retenciones Proveedores (specs 02_04) implementados completamente.
- Verificaciones rápidas al retomar: `empresa.dart` debe tener `['PRY', 'PER']` con comentario de spec 01_01; `campo_abm.dart getAnchoEtiqueta()` = 240 px fijos sin `iAnchoEtiqueta` y escalado con valor; specs 02_04 con rename de grupos; regenerar `lectura/` (archivos nuevos aún en 404).
- H6 cerrado (20-nov-2026): hints `comHintProveedor`/`venHintCliente` = "Código y Nombre del proveedor/cliente" (es) y "Code et nom du fournisseur/client" (fr); etiquetas `comIdentificacion`/`venIdentificacion` = "Identificación N°" (es) y "Identification N°" (fr); `iAnchoEtiqueta` = 17 en el campo identificacion de compras y ventas.
- Hints cerrados (20-nov-2026): `idiomas_terceros.dart` (es+fr) unificado a specs 01_04/01_05/01_07 — `cliHintNombre`/`prvHintNombre` = "Nombre de este cliente/proveedor"; `cliHintDireccion`/`prvHintDireccion` = "Calle y N° donde reside"; `cliHintLocalidad`/`prvHintLocalidad` = "Localidad de su domicilio"; `cliHintIdentificacion`/`prvHintIdentificacion` = "N° documento"; `timPrvHintNombre` = "Nombre fiscal del proveedor"; `timPrvHintRuc` = "RUC proveedor". Clave `prvHintDireccion` agregada (antes `proveedores.dart` mostraba la clave literal como hint). Resto de hints del proyecto (01_01–01_03, 01_08, 02_01–02_05) ya coincidía con las specs.
- Pendientes abiertos: 00_00_03 puntos en suspenso (menú contextual clic derecho, errata "paa"→"pa"); módulo Monedas sin definir; NOTA opcional en specs sobre disposición de importes (no aplicar sin pedido); despliegue web, búsqueda de proveedor/cliente auto-completable, tablas SQL de vigencia de timbrado.
- Decisión (20-nov-2026): la etiqueta `comTipoIdentificacion`/`venTipoIdentificacion` queda **"Identificación"** (no cambiar a "Tipo de identificación" aunque las specs 02_03_01/02_04_01 lo digan; decisión explícita del usuario de no ensanchar `iAnchoEtiqueta` ni la fila 4). No volver a plantear.
- Cómo continuar: cerrar pendientes de specs (00_00_03) y luego implementaciones (Firebird, tablas SQL, búsqueda, monedas). Preguntar al usuario por dónde seguir.

## Flujo con el usuario

1. Cambios de código: aplicar los cambios **directamente en los archivos del proyecto** usando tus herramientas de edición, mostrando un resumen breve de lo modificado. Ejecutar `flutter analyze` al finalizar cada tarea.
2. Si se modifican archivos en `lib/` o `Documentación/`, ejecutar `dart run tool/partir_lectura.dart` si corresponde.
3. No borrar las carpetas vacías de `lib/opciones/` ni `lib/generales/` (son placeholders intencionales).
4. Error en runtime de VS Code (“Main isolate is paused”): el error real está en la consola de depuración.


