# CLAUDE.md — Contexto del proyecto VS_CONTA

Este archivo es la memoria del proyecto. Al iniciar una sesión, leerlo completo
para continuar sin repreguntar. Actualizarlo al final de cada sesión de trabajo.

---

## 1. Mi rol

Actúo como programador súper experto en Dart/Flutter, en principios y paradigmas
de programación (SOLID, DRY, KISS, YAGNI), en UI/UX, en instalación de
aplicaciones en Linux, en configuración de VPS y en Firebird 2.5.9. Trabajo en
cotrabajo con el usuario (dueño del proyecto). Él decide, yo propongo; él prueba
y reporta, yo diagnostico y entrego parches. Respondo en español, tono técnico
sobrio, sin adornos.

## 2. El proyecto

VS_CONTA: aplicación de Contabilidad multi-país, multi-moneda, multi-sucursal,
multi-usuario y multi-idioma (español/francés). Para contadores y empresas.
Hoy opera en Paraguay (SET, DNIT, Marangatú, IVA 10%/5%, I.R.E., I.R.P.,
Retención 30%, plan contable Paraguay), pero la arquitectura es multi-país.

- Plataformas: la aplicación WEB es la plataforma principal (navegador).
  También Desktop Windows (con pantalla táctil, uso intensivo) y Android.
  Sin programación específica por plataforma.
- Pantallas objetivo: el diseño base es 1920x1080 (allí se ve exactamente
  igual que siempre). La aplicación es responsive y debe verse bien también en
  1366x768 y 1024x768 (regla de escala en la sección 6).
- Estado: FASE 1 — 8 pantallas ABM con datos de prueba (Empresa, Configuración,
  Sucursales, Clientes, Proveedores, Timbrados Propios, Timbrados de
  Proveedores, Cuentas Asignadas) + Login + menú drawer. Además: Asientos,
  Compras y Cuentas (Plan de Cuentas) implementados con datos de prueba.
- Base de Datos: especificada Firebird, conectada a 17/06/2026 (habilitada con
  ClaseBaseDatos). Mientras tanto: listas de datos de prueba en cada pantalla.
- Pendiente mayor: validaciones de unicidad (esperan la BD); usuario que graba
  por defecto 'admin'.

## 3. Especificaciones (fuente de verdad)

En `Documentación/` (25 archivos que empiezan con "0", leídos completos):
- 00_00_01..03_Especificaciones de la aplicación (UI/UX, nomenclatura,
  ventanas, mensajes, máscaras)
- 00_01_Carpetas, 00_02_Opciones drawer
- 00_03_01/02_ABMs (23 reglas ABM + regla 24 de alineación de columnas,
  agregada por el usuario)
- 00_04_Monedas, 00_05_Países
- 01_01..01_08: una spec por tabla (Empresa, Configuración, Sucursales,
  Clientes, Proveedores, Timbrados Propios, Timbrados de Proveedores,
  Cuentas Asignadas)
- 02_01_Cuentas, 02_02_Asientos, 02_03_01/02_Compras
- 09_01_01/02_Guía VPS para Firebird, 09_02_01/02_Enlaces_GitHub

Si la spec dice algo distinto al código, la spec manda.

## 4. Arquitectura y archivos clave

MVVM con widgets. Formularios autocontenidos (sin ViewModel): cada pantalla
arma `List<ClaseCampoAbm>` + `List<Map<String, dynamic>>` de prueba y entrega
todo a `ClaseFormularioAbm` (tablas simples) o
`ClaseFormularioCabeceraDetalle` (Asientos/Compras).

- lib/main.dart — MaterialApp, tema claro/oscuro, rutas, delegates de
  localización, supportedLocales es/fr, locale desde preferencias. Clase de
  Estado con WidgetsBindingObserver: didChangeMetrics → setState (recalcula la
  escala al redimensionar). En build() recalcula
  ClaseGenLayout.calcularEscala(ancho) con MediaQueryData.fromView(View.of()).
- lib/generales/temas/layout.dart — ClaseGenLayout: constantes de layout +
  dEscala (factor responsive, recalculada), dEscalaMinima (0.55) y
  dSeparacionCampo (8.0). calcularEscala(dAncho) usa SOLO el ancho:
  dAncho/1920 acotado a [dEscalaMinima, 1.0].
- lib/generales/temas/estilos_textos.dart — ClaseGenEstilosTexto; _estilo()
  multiplica el fontSize por dFactorTexto (1.0 o 1.25 con "texto grande")
  y por ClaseGenLayout.dEscala. Fuente mono para campos.
- lib/generales/modelos/campo_abm.dart — ClaseCampoAbm: getAnchoCampo()/
  getAnchoColumna() escalados (solo la parte de texto). NUEVO: enum
  EnumAlineacion { centro, derecha, izquierda }; propiedad oAlineacion
  (nullable, orden alfabético junto a oTipo); getAlineacion() devuelve
  oAlineacion o el default por tipo (numero→derecha, resto→izquierda,
  regla 00_03_01). iAnchoVisible, iFila (campos con el mismo número > 0
  comparten fila visual; orden de Tab = orden visual).
- lib/generales/widgets/abm_comun.dart — ClaseFormularioCampos: pestañas
  ficha (_construirPestana), _construirFila, funcExtraGrupo, mapFocos.
  ClaseEstadoGrillaRegistros: _getAlineacionCelda() (Alignment para el
  encabezado), _getTextAlignCelda() (TextAlign para la celda),
  _getPaddingCelda() (gutter horizontal dEspacio08 * dEscala; encabezado y
  celdas lo usan para que los nombres de columnas vecinas no se peguen y el
  valor quede alineado con su encabezado); anchos de grilla escalados;
  flechita de orden; foco en la grilla (item 23). ClaseBotoneraAbm: botones
  con icono, ancho escalado, alto 48 fijo (táctil), colores por estados.
- lib/generales/inicio/menu_lateral.dart — drawer con Scrollbar
  (thumbVisibility + trackVisibility) envolviendo ListView(primary: true):
  la barra de desplazamiento se ve SIEMPRE (usuarios noveles). Opciones:
  _listArchivos usa 'menuPlanCuentas', 'menuAsientos', 'menuCompras',
  'menuVentas', 'menuRetencionesClientes', 'menuRetencionesProveedores';
  _listInformes conserva 'menuLibroCompras'/'menuLibroVentas' (informes
  4.8/4.9).
- lib/generales/idiomas/idiomas_interfaz.dart — claves 'menuCompras'
  (Compras/Achats) y 'menuVentas' (Ventas/Ventes); 'menuLibroCompras' y
  'menuLibroVentas' sin cambios (informes).
- lib/generales/widgets/campo_formulario.dart — separación inferior uniforme
  dSeparacionCampo * dEscala; hintStyle con el mismo estilo escalado que el
  texto del campo; IconButtons (picker, "X"), Checkbox y Switch con
  MaterialTapTargetSize.shrinkWrap; etiqueta dAnchoEtiquetaCampo * dEscala;
  Enter = Tab vía _alEnterCampo(); números con máscara; fechas/horas con
  completado inteligente.
- lib/generales/widgets/formulario_abm.dart — ABM simple; grabación exitosa
  con cierre automático 3 s.
- lib/generales/widgets/formulario_cabecera_detalle.dart — cabecera con o
  sin pestañas (sGrupoConDetalles); grilla editable de detalles con scroll
  horizontal compartido, fila de totales, celdas numéricas formateadas;
  cierre automático 3 s. PENDIENTE de revisión responsive (etapa 2).
- lib/generales/widgets/ventana_mensaje.dart — funcMostrarAdvertencia/
  Confirmacion/Error/Informacion (iSegundosAutoCierre en Informacion),
  funcConstruirBoton (siempre con icono), selectores de fecha y de hora.
  PENDIENTE de revisión responsive (etapa 2).
- lib/generales/validaciones/cap_validar.dart — ClaseCapValidar; mensajes
  via ClaseIdiomas.getTexto + replaceAll('{0}',...). can_validar.dart
  (con BD) para cuando haya conexión.
- lib/generales/idiomas/ — 8 archivos es/fr (paridad de claves); getTexto
  devuelve la clave si falta.
- lib/generales/utilitarios/formatos.dart — fechas/horas/números, máscaras,
  funcAplicarMascara, funcDigitoVerificador.
- lib/generales/varios/listas.dart — ClaseSiNo, ClaseLocalExterior,
  ClaseAfectaA, ClaseTipoDocumento, ClaseTipoIdentificacion, etc.
- lib/opciones/tablas/*.dart y lib/opciones/archivos/*.dart — pantallas
  (campos, validaciones cruzadas y datos de prueba). En asientos.dart y
  compras.dart, 'ejercicio' y 'fecha' llevan oAlineacion: centro; en
  cuentas.dart, 'ejercicio' lleva oAlineacion: centro.
- herramienta/partir_lectura.dart — parte archivos en fragmentos de ~5k en
  `lectura/` para lectura por sesiones.

## 5. Flujo de trabajo

1. El usuario prueba (web/Windows/táctil) y reporta el problema en sus palabras
   ("combobox" = campo tipo lista/dropdown).
2. Yo releo los fragmentos necesarios de `lectura/` (o el .dart completo en
   GitHub) y doy: diagnóstico + parches con bloques "Buscar:"/"Reemplazar:"
   exactos, listos para pegar en el archivo .dart REAL.
3. El usuario aplica, compila/prueba y reporta.
4. Al cerrar sesión: actualizar este archivo y el estado de sesión.

Reglas operativas:
- EDITAR SIEMPRE los .dart reales de lib/, NUNCA los fragmentos de lectura/.
- Si un cambio no se refleja tras recompilar: `flutter clean` y recompilar.
  El hot reload NO sirve tras cambios de clases de Estado ni de
  recursos/idiomas.
- Parches: texto exacto actual → texto nuevo. Si varios parches en un archivo
  y la sección nueva contiene texto que otro parche necesita como "Buscar",
  aplicar en orden inverso; si no, en orden directo.
- Verificar anchors de "Buscar:" contra el .dart real antes de entregar
  parches; si el scrape falla, decirlo y trabajar con lo confirmado.

## 6. Convenciones de código (resumen)

- Dart 3.13.7+, Flutter 3.41+, Material (sin Material 3). Android minSdk 24.
- Prefijos: Clase, Enum; s (String), d (double), i (int), f (DateTime),
  b (bool), o (otro), list (List), map (Map), func (función), _privado.
- `final` / `required` / `const` / `super.key`; propiedades ordenadas
  alfabéticamente; `abstract final class` para clases estáticas.
- Alineación estricta de `:` (parámetros) y `=>` (getters); bloques de casos
  alineados. `const` solo en valores, nunca en widgets. `late` solo en campos
  de estado.
- Sin emojis. Textos SIEMPRE en Español neutro (nombres de variables,
  funciones, clases, claves de idioma). Valores de idioma en español/francés.
- KISS / DRY / YAGNI; "Un archivo, una responsabilidad"; composición por
  delegación. Comentarios en español, sin secciones "Historial de cambios".
- Tipos de enum cortos (ej: EnumAlineacion y no EnumAlineacionCampo) para no
  romper la alineación de nombres de propiedades.

Reglas UI/UX (aplicar en todo lo nuevo):
- a) Enter = Tab en campos de entrada (Comentario conserva su Enter);
  IconButtons (picker, "X") fuera del orden de foco (ExcludeFocus).
- b) Pestañas: siempre como fichas visibles (_construirPestana).
- c) Controles: relleno distinto al fondo del formulario; habilitado =
  cian suave + texto cian con contraste; deshabilitado = gris tenue + texto
  gris/negro. Todo color vía ClaseGenTemas/Theme.of, nunca en los widgets.
- d) Botón con foco de teclado: fondo amarillo + texto negro.
- e) Ventana de grabación exitosa: se cierra sola a los 3 s.
- f) Grilla lateral: flechita de orden por columna (asc/desc).
- g) Formularios con muchos campos: varios campos por fila (iFila), cada uno a
  su ancho mínimo (nunca se estira); filas de pocos campos: uno debajo del otro.
- h) Números: valor interno plano; SIEMPRE mostrados con su máscara
  (2.200.000) salvo que se estén editando.
- i) Mensajes al usuario: SIEMPRE de "tú" (es y fr; tu/toi).
- j) Traducciones francesas: R.U.C. no se traduce; "apellido materno/paterno"
  = "nom de famille maternel/paternel"; "compte" masculino (ce compte).
- k) ESCALA RESPONSIVE: todo tamaño visible en pantalla pasa por
  ClaseGenLayout.dEscala. Textos en ClaseGenEstilosTexto._estilo(); anchos de
  campo en getAnchoCampo()/getAnchoColumna() (solo la parte de texto);
  etiqueta, grilla y botonera en su punto de uso. Iconos, paddings internos y
  el alto de los botones ABM (48 px táctiles) NO escalan. En 1920 de ancho
  dEscala = 1.0 (idéntico al diseño base).
- l) SEPARACIÓN VERTICAL ENTRE CONTROLES: siempre la misma visible para
  todos los tipos de control = dSeparacionCampo * dEscala. Lograda con
  MaterialTapTargetSize.shrinkWrap en IconButtons/Checkbox/Switch y con el
  mismo hintStyle escalado que el texto del campo.
- m) Hint del campo: mismo estilo escalado que el texto del campo (nunca el
  estilo crudo del tema: en ventanas menores a 1920 se ve más grande y se
  corta por abajo).
- n) Nombres de menú: Archivos 1.3 "Compras" y 1.4 "Ventas" (claves
  'menuCompras'/'menuVentas'); Informes 4.8/4.9 conservan "Libro Compras" y
  "Libro Ventas". Antes de cambiar el valor de una clave de idioma,
  verificar si se comparte entre secciones; si se comparte, crear clave nueva.
- o) Barra de desplazamiento del drawer SIEMPRE visible (Scrollbar con
  thumbVisibility y trackVisibility; ListView con primary: true).
- p) ALINEACIÓN DE COLUMNAS de la grilla lateral (regla 24 de
  00_03_02_ABMs.txt): configurable por campo (oAlineacion: izquierda,
  centro o derecha). Default por tipo: números a la derecha, resto a la
  izquierda. El encabezado usa la misma alineación que sus celdas. Siempre
  debe separarse visualmente el nombre de una columna del de la columna
  vecina (gutter interno de celda, dEspacio08 * dEscala, mismo padding en
  encabezado y valores).

## 7. Historial reciente

- Sesión de cierre previa (18/11/2026, madrugada): escala responsive
  (dEscala por ancho, piso 0.55), separación vertical uniforme
  (dSeparacionCampo), hintStyle escalado, shrinkWrap en controles. Se
  generaron CLAUDE.md y Proyecto VS_CONTA_16.txt.
- Sesión 18/11/2026 (jornada de mañana, la actual): el usuario pidió
  refuerzo del rol (experto también en Linux, VPS y Firebird 2.5.9).
  Trabajo entregado y probado OK:
  1) Drawer: barra de desplazamiento siempre visible (Scrollbar con
     thumbVisibility + trackVisibility, ListView primary: true).
  2) Menú Archivos: 1.3 "Compras" y 1.4 "Ventas" (claves nuevas
     'menuCompras'/'menuVentas' es/fr); informes 4.8/4.9 intactos.
  3) Grilla lateral: alineación de columnas configurable por campo
     (EnumAlineacion/oAlineacion/getAlineacion en campo_abm.dart; helpers
     _getAlineacionCelda/_getTextAlignCelda/_getPaddingCelda y gutter
     dEspacio08 * dEscala en abm_comun.dart). Aplicado: 'ejercicio' y
     'fecha' centrados en asientos.dart y compras.dart; 'ejercicio'
     centrado en cuentas.dart. El usuario agregó la regla 24 a
     00_03_02_ABMs.txt.
- Sesiones anteriores: escalado de textos y anchos; separación vertical
  uniforme; iconos en los 7 botones ABM; claves de idioma faltantes
  (cli*, tim*, prv*, doc*); picker de fecha con localizationsDelegates;
  fecha/hora con máscara y completado inteligente; foco al campo con error;
  Enter = Tab con ExcludeFocus; filas multi-campo con ancho mínimo;
  colores de controles (cian/gris); pestañas como fichas; grilla con
  flechita de orden; cierre automático 3 s.

## 8. Pendientes

1. [PREGUNTAR AL INICIAR] Restos de la lista de "detalles puntuales" de
   UI/UX del usuario (ya se hicieron 3: scrollbar del drawer, nombres
   Compras/Ventas, alineación de la grilla). Confirmar si hay más.
2. [PREGUNTAR AL INICIAR] Estado del parche D (título de la ventana de
   compras.dart con 'menuCompras') y del cambio en spec
   00_02_Opciones drawer.txt (1.3 Compras / 1.4 Ventas). Si no los aplicó,
   entregarlos de nuevo.
3. Etapa 2 responsive: login.dart (tarjeta dAnchoTarjetaLogin 420),
   ventana_mensaje.dart (iAnchoColumnasMensaje), formulario_cabecera_detalle
   (grilla de detalles: dAnchoMinimoGrillaDetalles 700, altos de fila
   fijos), menu_lateral.dart, y decisiones sobre legibilidad mínima del
   texto.
4. Decidir con los usuarios: colores exactos de controles habilitados/
   deshabilitados y tamaño del texto (dFactorTexto hoy 1.25; baja a 1.0 si
   lo piden; vive en ClaseGenEstilosTexto).
5. Mejoras sustanciales al botón "Encontrar" (no tocar hasta entonces).
6. Barrer claves crudas restantes si aparecen (Sucursales, Cuentas, Cuentas
   Asignadas, Configuración).
7. Ajustar redacciones es/fr de validFechaInvalida/validHoraInvalida a
   gusto (verificar que mapFr acompañe).
8. Solo si el usuario lo quiere: renombrar informes 4.8/4.9 (requiere
   claves nuevas; hoy quedan "Libro Compras"/"Libro Ventas").
9. Mayores (fases siguientes): DDL de la BD de las 8 tablas (specs 01_01..
   01_08, incluye validaciones de unicidad), instalación de Firebird 2.5.9
   en el VPS, API en el VPS (la app web no puede hablar directo con
   Firebird), Lector de archivos de Marangatú (01_06), Entorno 00_00_01,
   pantallas de Informes/Procesos.
10. HTTPS + dominio del VPS cuando el DNS se propague.

## 9. Lecciones aprendidas (no repetir errores)

- Nunca editar fragmentos de lectura/: solo .dart reales.
- Si un texto/idioma no cambia tras recompilar: flutter clean. El hot reload
  causa "Assertion failed: framework.dart" con cambios de clases de Estado.
- errorText inline en campos angostos se corta: usar ventanas popup
  (funcMostrarError) para mensajes de error.
- La validación al salir del campo no debe interrumpir botones de acción:
  condicionarla a que el foco haya pasado a otro campo de entrada.
- El foco de botones NO es confiable para detectar clics: usar condiciones
  positivas (¿el foco está en otro campo de entrada?).
- Los IconButtons (picker, "X") reciben foco y ensucian el Tab: ExcludeFocus.
- Verificar anchors de "Buscar:" contra el .dart real antes de entregar
  parches; si el scrape falla, decirlo y trabajar con lo confirmado.
- El hint de los campos debe usar el MISMO estilo escalado que el texto del
  campo: si toma el estilo del tema (sin escalar), en ventanas menores a
  1920 se ve más grande y se corta por abajo.
- El área táctil mínima de 48 px de IconButton/Checkbox/Switch ensancha las
  filas y hace desiguales las separaciones visibles:
  MaterialTapTargetSize.shrinkWrap en controles de formulario.
- En web, los píxeles lógicos son píxeles CSS: con Windows al 125% una
  notebook de 1366x768 muestra ~1093 px lógicos. La escala responsive debe
  pensarse contra el ancho lógico real, no contra el de la pantalla física.
- Escalar SOLO por ancho (no min(ancho, alto)): 1366x768 es 16:9 y acompaña
  solo; además una ventana de 1920 de ancho se ve igual con o sin barra del
  navegador (regla del usuario: "en 1920x1080 se ve todo muy bien").
- Columnas de grilla: sin gutter interno, los nombres de columnas vecinas se
  leen como una palabra. Padding horizontal simétrico y del mismo tamaño en
  encabezado y celdas (así el valor queda alineado con su encabezado).
- Alineación de columnas: un solo resolutor (getAlineacion) + dos mapeos
  finos (Alignment para el encabezado, TextAlign para la celda); nunca
  duplicar la lógica de alineación en dos puntos.
- Claves de idioma compartidas entre secciones del menú: no cambiar el valor
  compartido; crear clave nueva para la sección que cambia.
- Drawer con scroll siempre visible: Scrollbar(thumbVisibility,
  trackVisibility) + ListView(primary: true); antes verificar que no haya
  otro scrollable con primary en la misma pantalla (pantalla_principal body
  es SizedBox.shrink() → seguro).
- Tipos de enum largos rompen la alineación de nombres de propiedades del
  modelo: usar nombres cortos (EnumAlineacion).

## 10. Terminología del usuario

- "combobox" = campo de tipo lista (DropdownButtonFormField).
- "grilla" = tabla de registros (izquierda) o de detalles (abajo).
- "la X" = botón de borrar contenido del campo.
- "picker" = selector de fecha/hora de Material.