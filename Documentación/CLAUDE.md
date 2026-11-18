# CLAUDE.md — Contexto del proyecto VS_CONTA

Este archivo es la memoria del proyecto. Al iniciar una sesión, leerlo completo
para continuar sin repreguntar. Actualizarlo al final de cada sesión de trabajo.

---

## 1. Mi rol

Actúo como programador senior en Flutter/Dart (asistente de IA), en cotrabajo
con el usuario (dueño del proyecto). Él decide, yo propongo; él prueba y
reporta, yo diagnostico y entrego parches. Respondo en español, tono técnico
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
  Compras y Cuentas (archivo Plan de Cuentas) implementados con datos de prueba.
- Base de Datos: especificada Firebird, conectada a 17/06/2026 (habilitada con
  ClaseBaseDatos). Mientras tanto: listas de datos de prueba en cada pantalla.
- Pendiente mayor: validaciones de unicidad (esperan la BD); usuario que graba
  por defecto 'admin'.

## 3. Especificaciones (fuente de verdad)

En `Documentación/` (25 archivos que empiezan con "0", leídos completos):
- 00_00_01..03_Especificaciones de la aplicación (UI/UX, nomenclatura,
  ventanas, mensajes, máscaras)
- 00_01_Carpetas, 00_02_Opciones drawer
- 00_03_01/02_ABMs (23 reglas ABM)
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
  dEscala (double, factor responsive, recalculada por calcularEscala),
  dEscalaMinima (0.55) y dSeparacionCampo (8.0). calcularEscala(dAncho) usa
  SOLO el ancho: dAncho/1920 acotado a [dEscalaMinima, 1.0]. Ver regla UI/UX
  "escala responsive" en la sección 6.
- lib/generales/temas/estilos_textos.dart — ClaseGenEstilosTexto; _estilo()
  multiplica el fontSize por dFactorTexto (1.0 o 1.25 con "texto grande")
  y por ClaseGenLayout.dEscala. Fuente mono para campos.
- lib/generales/modelos/campo_abm.dart — ClaseCampoAbm: getAnchoCampo()/
  getAnchoColumna(); el texto (iCaracteres * dAnchoCaracter * dFactorTexto)
  se multiplica por dEscala; iconos y paddings NO escalan (son de tamaño
  físico fijo). iAnchoVisible, iFila (campos con el mismo número > 0 comparten
  fila visual; la fila se coloca donde aparece su primer campo y el orden de
  Tab = orden visual).
- lib/generales/widgets/campo_formulario.dart — ClaseCampoFormulario:
  bAnchoFlexible, bEtiquetaArriba; etiqueta con ancho
  dAnchoEtiquetaCampo * dEscala; separación inferior uniforme
  dSeparacionCampo * dEscala (regla nueva); hintStyle con el mismo estilo
  escalado que el texto del campo; IconButtons (picker, "X"), Checkbox y
  Switch con MaterialTapTargetSize.shrinkWrap (sin área táctil de 48 px que
  ensanche las filas). Enter = Tab vía _alEnterCampo(); números con máscara
  (valor interno plano, mostrado formateado); fechas/horas con completado
  inteligente y validación al salir solo si el foco pasó a otro campo.
- lib/generales/widgets/abm_comun.dart — ClaseFormularioCampos: pestañas como
  fichas visibles (_construirPestana); _construirFila para filas multi-campo
  (maxWidth y flex con dAnchoEtiquetaCampo * dEscala; nunca se estiran; si no
  caben se angostan proporcionalmente); funcExtraGrupo; mapFocos (1 FocusNode
  por campo). ClaseGrillaRegistros: anchos dAnchoGrillaRegistros * dEscala y
  dAnchoTiraGrilla * dEscala, flechita de orden, cuadro de búsqueda con colores
  de controles habilitados, foco en la grilla (item 23). ClaseBotoneraAbm:
  botones con icono, ancho dAnchoBotonAbm * dEscala y alto dAltoBotonAbm fijo
  (48 px: objetivo táctil, no se escalan); colores por estados
  (WidgetStateProperty: foco = amarillo + texto negro).
- lib/generales/widgets/formulario_abm.dart — ABM simple; grabación exitosa
  con cierre automático 3 s (iSegundosAutoCierre: 3).
- lib/generales/widgets/formulario_cabecera_detalle.dart — Cabecera con o sin
  pestañas (sGrupoConDetalles); grilla editable de detalles con scroll
  horizontal compartido, fila de totales, botón "Agregar fila", celdas
  numéricas formateadas. Grabación con cierre automático 3 s. PENDIENTE de
  revisión responsive (etapa 2).
- lib/generales/widgets/ventana_mensaje.dart — funcMostrarAdvertencia/
  Confirmacion/Error/Informacion (iSegundosAutoCierre en Informacion),
  funcConstruirBoton (siempre con icono), funcMostrarSelectorFecha (locale) y
  funcMostrarSelectorHora. PENDIENTE de revisión responsive (etapa 2).
- lib/generales/validaciones/cap_validar.dart — ClaseCapValidar: todas las
  validaciones; mensajes via ClaseIdiomas.getTexto + replaceAll('{0}',...).
  can_validar.dart (con BD) para cuando haya conexión.
- lib/generales/idiomas/ — 8 archivos es/fr (paridad de claves completa);
  getTexto(clave, idioma) devuelve la clave si falta. Claves camelCase con
  prefijo de módulo (com, cta, emp, det, asi, valid, cli, prv, tim, doc, cfg,
  suc, plan, abm, menu).
- lib/generales/utilitarios/formatos.dart — fechas/horas/números, máscaras,
  funcAplicarMascara, funcParsearFecha, funcFormatearNumero, funcDigitoVerificador.
- lib/generales/varios/listas.dart — ClaseSiNo, ClaseLocalExterior,
  ClaseAfectaA, ClaseMedioGeneracion, ClaseTipoAfectacion, etc.
- lib/opciones/tablas/*.dart y lib/opciones/archivos/*.dart — pantallas
  (campos, validaciones cruzadas y datos de prueba).
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
  El hot reload NO sirve tras cambios de clases de Estado ("Assertion failed:
  framework.dart") ni de recursos/idiomas.
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
- k) ESCALA RESPONSIVE (nueva): todo tamaño visible en pantalla pasa por
  ClaseGenLayout.dEscala. Los textos escalan en ClaseGenEstilosTexto._estilo();
  los anchos de campo escalan en getAnchoCampo()/getAnchoColumna() (solo la
  parte de texto); etiqueta, grilla y botonera escalan en su punto de uso.
  Iconos, paddings internos y el alto de los botones ABM (48 px táctiles) NO
  escalan. En 1920 de ancho dEscala = 1.0 (idéntico al diseño base).
- l) SEPARACIÓN VERTICAL ENTRE CONTROLES (nueva): siempre la misma visible
  para todos los tipos de control = dSeparacionCampo * dEscala. Lograda con
  MaterialTapTargetSize.shrinkWrap en IconButtons/Checkbox/Switch (sin área
  táctil de 48 px) y con el mismo hintStyle escalado que el texto del campo.
- m) Hint del campo: mismo estilo escalado que el texto del campo (nunca el
  estilo crudo del tema: en ventanas menores a 1920 se ve más grande y se
  corta por abajo).
- n) La barra de desplazamiento del drawer siempre visible (Scrollbar con thumbVisibility/trackVisibility)

## 7. Historial reciente

- Sesión responsive (18/11/2026): el usuario reportó que en 1366x768 el texto
  se veía muy grande y no entraba todo (botonera tapaba campos). Se leyeron
  los 25 archivos "0" de Documentación y los 145 fragmentos de lectura/ (el
  fragmento ventana_mensaje parte 1, que había fallado el scrape, se recuperó).
  Se implementó la escala responsive (regla k) con 3 tandas de parches:
  1) Etapa 1: dEscala + calcularEscala en layout.dart; _estilo() escalado;
     getAnchoCampo/getAnchoColumna escalados; etiqueta, grilla, tira y
     botonera escaladas; WidgetsBindingObserver en main.dart.
  2) Corrección: la fórmula pasó a usar SOLO el ancho (dAncho/1920) porque la
     app es principalmente web y 1366x768 es 16:9 (acompaña solo); el piso
     bajó a dEscalaMinima 0.55 (la notebook corre con Windows al 125%, el
     navegador ve ~1093 px lógicos).
  3) Ajustes finos (regla l/m): dSeparacionCampo 8.0 uniforme y escalado,
     hintStyle escalado, shrinkWrap en IconButtons/Checkbox/Switch.
  Resultado reportado por el usuario: "se ve bastante mejor, ha mejorado
  mucho"; quedan algunos pequeños ajustes pendientes de detallar.
- Sesiones anteriores: anchura de campos con factor de texto; iconos en los 7
  botones ABM; claves de idioma faltantes (cli*, tim*, prv*, doc*); picker de
  fecha con localizationsDelegates; fecha/hora con máscara, completado
  inteligente y validación en ventana popup; foco que vuelve al campo con
  error; Enter = Tab con ExcludeFocus en picker y "X"; números formateados al
  cargar; filas multi-campo con ancho mínimo; colores de controles
  (habilitado cian / deshabilitado gris); pestañas como fichas; grilla con
  flechita de orden; cierre automático 3 s.

## 8. Pendientes

1. Pequeños ajustes responsive que el usuario mencionó ("aún faltan algunos
   pequeños ajustes"): recibir su lista concreta en la próxima sesión y
   corregir (posibles puntos: restos de texto cortado por abajo en algunos
   casos, altos fijos que no escalan).
2. Etapa 2 responsive: login.dart (tarjeta dAnchoTarjetaLogin 420),
   ventana_mensaje.dart (iAnchoColumnasMensaje), formulario_cabecera_detalle
   (grilla de detalles: dAnchoMinimoGrillaDetalles 700, altos de fila fijos),
   menu_lateral.dart, y decisiones sobre legibilidad mínima del texto.
3. Decidir con los usuarios: colores exactos de controles habilitados/
   deshabilitados y tamaño del texto (dFactorTexto hoy 1.25; baja a 1.0 si lo
   piden; vive en ClaseGenEstilosTexto).
4. Mejoras sustanciales al botón "Encontrar" (no tocar hasta entonces).
5. Barrer claves crudas restantes si aparecen (Sucursales, Cuentas, Cuentas
   Asignadas, Configuración).
6. Ajustar redacciones es/fr de validFechaInvalida/validHoraInvalida a gusto
   (verificar que mapFr acompañe).
7. Mayores (fases siguientes): DDL de la BD de las 8 tablas (specs 01_01..
   01_08, incluye validaciones de unicidad), instalación de Firebird 2.5.9 en
   el VPS, API en el VPS (la app web no puede hablar directo con Firebird),
   Lector de archivos de Marangatú (01_06), Entorno 00_00_01, pantallas de
   Informes/Procesos.
8. HTTPS + dominio del VPS cuando el DNS se propague.

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
  campo: si toma el estilo del tema (sin escalar), en ventanas menores a 1920
  se ve más grande y se corta por abajo (causa del "texto cortado" en web).
- El área táctil mínima de 48 px de IconButton/Checkbox/Switch ensancha las
  filas y hace desiguales las separaciones visibles: MaterialTapTargetSize
  .shrinkWrap en controles de formulario.
- En web, los píxeles lógicos son píxeles CSS: con Windows al 125% una
  notebook de 1366x768 muestra ~1093 px lógicos. La escala responsive debe
  pensarse contra el ancho lógico real, no contra el de la pantalla física.
- Escalar SOLO por ancho (no min(ancho, alto)): 1366x768 es 16:9 y acompaña
  solo; además una ventana de 1920 de ancho se ve igual con o sin barra del
  navegador (regla del usuario: "en 1920x1080 se ve todo muy bien").

## 10. Terminología del usuario

- "combobox" = campo de tipo lista (DropdownButtonFormField).
- "grilla" = tabla de registros (izquierda) o de detalles (abajo).
- "la X" = botón de borrar contenido del campo.
- "picker" = selector de fecha/hora de Material.
