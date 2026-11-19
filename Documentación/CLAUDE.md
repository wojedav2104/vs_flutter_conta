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
- Estado: FASE 1 — pantallas ABM con datos de prueba (Empresa, Configuración,
  Sucursales, Clientes, Proveedores, Timbrados Propios, Timbrados de
  Proveedores, Cuentas Asignadas) + Login + menú drawer. Además: Asientos,
  Compras, Ventas y Cuentas (Plan de Cuentas) implementados con datos de prueba.
  Faltan por implementar los formularios de ingreso de datos: Retenciones a
  Clientes y Retenciones de Proveedores.
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
- La spec de Ventas llegó por chat en dos documentos (no está en el repo aún):
  conviene subirla como 02_04_01/02_Archivo_Ventas.txt.
- 09_01_01/02_Guía VPS para Firebird, 09_02_01/02_Enlaces_GitHub

Si la spec dice algo distinto al código, la spec manda.

## 4. Arquitectura y archivos clave

MVVM con widgets. Formularios autocontenidos (sin ViewModel): cada pantalla
arma `List<ClaseCampoAbm>` + `List<Map<String, dynamic>>` de prueba y entrega
todo a `ClaseFormularioAbm` (tablas simples) o
`ClaseFormularioCabeceraDetalle` (Asientos/Compras/Ventas).

- lib/main.dart — MaterialApp, tema claro/oscuro, rutas, delegates de
  localización, supportedLocales es/fr, locale desde preferencias. Clase de
  Estado con WidgetsBindingObserver: didChangeMetrics → setState (recalcula la
  escala al redimensionar). En build() recalcula
  ClaseGenLayout.calcularEscala(ancho) con MediaQueryData.fromView(View.of()).
- lib/generales/temas/colores.dart — ClaseGenColores: paleta completa de la
  especificación 00_00_02 (azules, cian, grises 1..4, ámbar, rojos, morados,
  rosas, fondos, botones, campos, encabezados de grilla). Incluye los colores
  nuevos de resultados de suma (colorCampoTotalClaro/Oscuro) y de hints
  (colorHintCampoClaro/Oscuro).
- lib/generales/temas/temas.dart — ClaseGenTemas: dos ColorScheme (claro y
  oscuro) con contraste WCAG AA documentado; temas cacheados por factor de
  texto (getTemaClaro/getTemaOscuro); métodos de color por contexto
  (botones, campos, totales, encabezados de grilla, hints). Regla de oro: los
  widgets toman los colores de esta clase (nunca de colores.dart).
  - colorFondoCampoTotal: ámbar suave en claro (#FFEAC2), gris elevado en
    oscuro (#2A2B2C). Los totales se distinguen de los campos de ingreso en
    AMBOS modos (pedido del usuario).
  - colorTextoHintCampo: gris muy apagado; el hint nunca debe parecer un dato
    introducido por el usuario.
- lib/generales/temas/layout.dart — ClaseGenLayout: constantes de layout +
  dEscala (factor responsive, recalculada), dEscalaMinima (0.55) y
  dSeparacionCampo (8.0). calcularEscala(dAncho) usa SOLO el ancho:
  dAncho/1920 acotado a [dEscalaMinima, 1.0]. dAnchoEtiquetaCampo = 300
  (antes 220: las etiquetas largas se partían en dos líneas).
  dAnchoAccionesFila = 144 (3 iconos por fila de detalle).
- lib/generales/temas/estilos_textos.dart — ClaseGenEstilosTexto; _estilo()
  multiplica el fontSize por dFactorTexto (1.0 o 1.25 con "texto grande")
  y por ClaseGenLayout.dEscala. Fuente mono para campos.
- lib/generales/modelos/campo_abm.dart — ClaseCampoAbm: getAnchoCampo()/
  getAnchoColumna() escalados (solo la parte de texto). getAnchoEtiqueta()
  (nuevo): ancho de etiqueta escalado por dFactorTexto y dEscala; única
  fuente del ancho de las etiquetas. EnumAlineacion { centro, derecha,
  izquierda }; getAlineacion() (numero→derecha, resto→izquierda, regla
  00_03_01). iAnchoVisible, iFila (campos con el mismo número > 0 comparten
  fila visual; orden de Tab = orden visual). bColumnaExpansible (nuevo):
  columna de la grilla de detalles que absorbe el sobrante de la ventana
  (hoy: Concepto).
- lib/generales/modelos/documentos.dart — ClaseTipoDocumento (compras) y
  ClaseTipoDocumentoVentas (nuevo, 16 tipos con códigos '01'..'16';
  sMascaraNumero '999-999-9999999'; con máscara: 01,02,03,06,08,09,13).
- lib/generales/widgets/abm_comun.dart — ClaseFormularioCampos: pestañas
  ficha (_construirPestana), _construirFila con Flexible/ConstrainedBox para
  TODAS las filas (incluidas las de un solo campo: sin esto, campos largos
  como "Carpeta para Marangatú" desbordaban), funcExtraGrupo, mapFocos.
  ClaseEstadoGrillaRegistros: alineación de celdas/encabezados, gutter
  dEspacio08 * dEscala, flechita de orden, foco en la grilla (item 23).
  ClaseBotoneraAbm: botones con icono, ancho escalado, alto 48 fijo (táctil).
- lib/generales/widgets/campo_formulario.dart — ClaseCampoFormulario:
  etiqueta + control según EnumTipoCampoAbm; etiqueta con ancho
  ClaseCampoAbm.getAnchoEtiqueta(); hintStyle con colorTextoHintCampo.
- lib/generales/widgets/formulario_abm.dart — ClaseFormularioAbm: ABM
  completo (agregar/modificar/borrar/encontrar/grabar/cancelar/fin).
  bTablaUnSoloRegistro, bPermitirEncontrar, funcAlPerderFoco,
  funcActualizarCampos, funcValidarRegistro, funcEtiquetaGrupo.
- lib/generales/widgets/formulario_cabecera_detalle.dart —
  ClaseFormularioCabeceraDetalle: cabecera + grilla editable de detalles con
  fila de totales (mismos colores que en asientos.dart: back/forecolor
  idénticos por construcción). sClaveDetalles 'detalles'; sClaveCampoAlPie
  (Comentarios al pie, spec 02_02/02_03); sGrupoConDetalles (la grilla vive
  dentro de su pestaña); columnas expansibles vía LayoutBuilder +
  _listAnchosColumnas (al contraer la grilla lateral, Concepto se ensancha y
  se ven los 60 caracteres). Validaciones: fila sin contenido, Debe XOR
  Haber por fila, suma Debe = suma Haber (validarSumaDebeHaber).
- lib/generales/widgets/ventana_mensaje.dart — ventanas de la spec
  00_00_03: advertencia, confirmación, error, información (auto-cierre 3 s),
  selector de fecha, selector de hora, pedir texto. Shell visual unificada.
- lib/generales/idiomas/ — ClaseIdiomas + un archivo por pantalla. Prefijos:
  gen_, abm_, mnu_, opg_, men_, con_, suc_, cli_, prv_, tim_, cta_, plan_,
  asi_, com_, ven_, cfg_, emp_, det_ (compartido por Asientos/Compras/Ventas).
  Español y francés con claves idénticas. idiomas_ventas.dart (nuevo).
- lib/rutas/rutas.dart + generador_rutas.dart — rutas nombradas; las
  opciones usan MaterialPageRoute con los parámetros de la ventana_config.
- lib/opciones/archivos/ — asientos.dart, compras.dart, ventas.dart (nuevo),
  cuentas.dart. lib/opciones/tablas/ — las 8 pantallas ABM.

## 5. Convenciones de código

- Nomenclatura (spec 00_00_01): clases Clase + sustantivo; métodos
  camelCase (get_/set_/es/tiene/crear/construir/validar/hay cuando aplique);
  variables con prefijo de tipo (sTexto, iNumero, dImporte, bBandera,
  listLista, mapMapa, oObjeto, fFecha); constantes solo en temas/
  (sustantivo con prefijo de tipo); privados con guion bajo.
- Comentarios y specs en español. Orden alfabético de parámetros, propiedades
  y claves de mapas; claves de idioma ordenadas por sección.
- DRY: un solo punto de cambio por regla UI/UX (colores en ClaseGenTemas,
  anchos en ClaseGenLayout, validaciones en ClaseCapValidar).
- Los cambios nuevos se marcan con `// ← CAMBIO` cuando el usuario lo pide.
- Espejo `lectura/`: los archivos .txt se regeneran con el script de troceado
  del usuario después de cada cambio.

## 6. Reglas UI/UX activas (decisiones de sesiones)

- Los campos de suma (Total, Total del comprobante, fila de totales) tienen
  relleno distinto al de los campos de ingreso en modo claro Y oscuro.
- Los hints son gris muy apagado, apenas visibles; jamás el color del dato.
- Las etiquetas largas caben en una sola línea (ancho escalado).
- La columna Concepto de la grilla de detalles se expande con el sobrante de
  la ventana (bColumnaExpansible); la ventana de texto largo y el icono por
  fila se probaron y se eliminaron por innecesarios.
- Modo texto grande (dFactorTexto 1.25) y escala de ventana (dEscala) se
  aplican a fuentes y a anchos para que nada se corte a menos de 1920.

## 7. Próximos pasos (hoja de ruta)

1. Implementar Retenciones a Clientes y Retenciones de Proveedores (specs
   pendientes de recibir; son muy similares entre sí). Con eso terminan los
   formularios de ingreso de datos.
2. Implementar todas las validaciones que NO requieren Base de Datos.
3. Instalar Firebird en el VPS (guía 09_01) y crear la Base de Datos.
4. Grabación y consultas (la parte más compleja e interesante).
