# CLAUDE.md

Este archivo contiene reglas de estilo de programación para Claude cuando trabaja en VS_CONTA.

## 1. Filosofía de la programación

Sin código muerto: no dejar comentarios, variables, funciones o widgets sin uso.
Los diseños se mantienen lo más simple posible (principio KISS).
Reutilizar antes que agregar (principio DRY).
Código mantenible a largo plazo: el código se lee más veces de las que se escribe.
Complejidad mínima: eliminar código no usado y la complejidad innecesaria.
Preferir soluciones pequeñas y frecuentes a soluciones grandes y poco frecuentes (principio YAGNI).

## 2. Tipografía y tamaños

Los tamaños de la tipografía de toda la aplicación se calculan en función de 2 factores: dFactorTexto (estilos_textos.dart, 1.0 / 1.25 texto grande) y dEscala (calcularEscala según el ancho de ventana, base 1920): ambos afectan todo lo visual.
La escala de texto del sistema operativo o del navegador está anulada (TextScaler.noScaling en main.dart): solo dFactorTexto y dEscala escalan el texto, porque la escala externa rompe el cálculo de los anchos.
El ancho de un carácter del texto de los campos se mide en tiempo de ejecución (ClaseCampoAbm.medirAnchoCaracter, con TextPainter y el estilo del campo): la constante ClaseGenLayout.dAnchoCaracter es solo la estimación de respaldo.
Toda la interfaz debe adaptarse al tamaño de letra. Texto grande no debe romper el diseño ni provocar desplazamientos horizontales.

## 3. Reglas de programación

1. Máx. 250 líneas por método o clase.
2. Cada método y clase debe tener un comentario inicial que explique su objetivo (en español).
3. Cada línea debe tener como máximo 176 caracteres.
4. Los colores de los componentes de un tema se deben definir y usar a través de las clases de la subcarpeta temas/.
5. Las validaciones se deben definir y usar a través de las clases de la subcarpeta validaciones/.
6. Los roles y permisos se deben definir y usar a través de la clase permisos.dart.
7. La sesión de la aplicación se debe definir y usar a través de la clase sesion.dart.
8. La fecha del sistema (y del chat) es viernes 20 de noviembre de 2026.
9. En las preferencias se guardan y recuperan los datos de las preferencias del usuario.
10. El manejo de archivos lo hacen los archivos de la subcarpeta modelos/archivos/.
11. La aplicación se conectará a bases de datos Firebird por medio de la subcarpeta modelos/bases_de_datos/.
12. Los atributos de las clases están al principio de la misma, las funciones al final, y los constructores antes de las funciones. Colocar los atributos y funciones estáticas al principio de su grupo.
13. La interfaz de usuario debe ser clara, simple y fácil de utilizar, para personas noveles en el uso de las computadoras.
14. Las traducciones de textos deben ser correctas y su adaptación natural, "como si el texto hubiera sido escrito originalmente en el idioma de destino". La traducción de los textos al idioma francés es de alta prioridad.
15. Los nombres de las variables, clases, funciones y demás componentes de la programación deben estar en castellano, siguiendo el manual de estilo que hay en el proyecto.

16. Sin print() en el código de producción: el diagnóstico temporal se retira al cerrar el problema.

## 4. Reglas UI/UX

1. En toda la interfaz el usuario debe poder ver claramente los límites de cada campo y de cada región de la pantalla (región de datos del formulario, grilla lateral de registros).
2. Los rótulos de los campos y los textos de los mensajes deben estar en negrita, salvo la fecha y la hora del chat, que se muestran con tipografía normal.
3. Si un campo de tipo numérico tiene una máscara de entrada, esa máscara determina la cantidad máxima de dígitos que puede tener ese campo. Los números se justifican hacia la derecha. Ejemplos: máscara de entrada = "999.999.999", el usuario escribe: 12345, se le muestra 1.234, justificado a la derecha; máscara de entrada = "999.999,99", el usuario escribe: 1234,5 y se le muestra: 1.234,50.
4. Los campos que tengan dato obligatorio deben indicarlo con un asterisco rojo inmediatamente después del rótulo del campo. El rótulo de un campo obligatorio también debe estar en negrita.
5. El comentario en todos los formularios se debe mostrar con un área de entrada de texto de 3 líneas de alto, con un contador de caracteres a la derecha, en la misma fila que el rótulo del campo. El contador debe mostrar la cantidad de caracteres usados y la cantidad máxima de caracteres que se pueden ingresar en el campo (por ejemplo 27/500).
6. Los campos de entrada de datos (texto, numéricos, importes, fecha, hora) deben tener un alto mínimo de 48 px y un ancho de padding interno generoso, a fin de ser cómodos para usuarios noveles. Los objetivos táctiles deben ser cómodos (mínimo 48 px para botones y listas).
7. La tipografía de todos los números (cantidades e importes), de todos los campos numéricos y de todos los importes de todas las grillas (grilla de registros y grilla de detalles) debe ser monoespaciada, a fin de alinear los decimales en todas partes. El resto de los textos de la interfaz pueden no ser monoespaciados.
8. Los números se justifican hacia la derecha: los rótulos de los campos numéricos se justifican a la derecha (a diferencia de los rótulos de los campos no numéricos, que se justifican a la izquierda), y los números en los campos de entrada se justifican hacia la derecha (regla 7). Los importes de las grillas se justifican a la derecha (regla 7).
9. Cuando se entre en un campo se debe seleccionar todo el contenido de ese campo. Si se selecciona un objeto de una lista, el foco debe saltar inmediatamente al campo siguiente. Si se teclea dentro de un campo con contenido, al final del contenido existente, la entrada de datos debe continuar al final del dato presente, como si el campo estuviera vacío (nunca sobrescribir el dato existente); los números con máscara de entrada solo se formatean al salir del campo (mientras escribe el usuario debe poder seguir escribiendo), respetando la máscara de entrada (si la máscara no trae separador, el número no se agrupa).
10. En los formularios el campo inicial debe estar seleccionado, para que el usuario pueda comenzar inmediatamente a cargar datos. El orden de tabulación de los campos debe ser lógico y consistente.
11. Los botones de la botonera deben ser de igual tamaño, y el botón con que se confirma una acción (Agregar, Borrar, Cancelar, Grabar) debe resaltar mientras se posiciona el mouse sobre él. La ventana de confirmación de borrado se muestra en gris oscuro, a fin de no distraer la atención del usuario.
12. El ingreso de fechas debe ser cómodo y flexible: El usuario debe poder escribir la fecha como más le acomode. Por ejemplo, debe poder escribir solo 16 y el sistema asume que es el día 16 del mes y año en curso. Si el usuario escribe 127 el sistema entenderá 12/07/año en curso. Si escribe 1611 se asume que es 16/11/año en curso. Si teclea 161126 el sistema entenderá 16/11/2026.
13. El ingreso de las horas debe ser igual de flexible y cómodo que el de las fechas.
14. Si se produce un error el campo recibirá foco y se marcará en rojo el dato erróneo, para que el usuario pueda ver inmediatamente dónde está el problema y poder corregirlo.
15. Siempre que exista la posibilidad de realizar una acción que afecte a la integridad de los datos de la base de datos se debe realizar una confirmación al usuario mediante una ventana modal de confirmación.
16. En todos los formularios, al entrar al mismo por primera vez, se deben deshabilitar los controles que están en la región de datos del formulario (a fin de obligar al usuario a elegir una acción). Los botones de la botonera deben quedar habilitados (Agregar, Encontrar y Fin), y los botones Modificar, Grabar y Cancelar se habilitan únicamente al entrar en modo de edición, y el botón Borrar se habilita únicamente cuando hay un registro elegido y no se está editando. Ninguna acción puede bloquear o inmovilizar la interfaz.
17. En los formularios con datos que dependen de otros datos (Tipo de documento, Identificación), los campos dependientes deben actualizarse automáticamente según la selección del usuario.
18. En los formularios con datos que dependen de otros datos los campos dependientes deben actualizarse automáticamente según la selección del usuario, y sus valores se recalculan también al perder el foco el campo del que dependen.
19. Si un campo es de solo lectura entonces se debe mostrar claramente (por ejemplo, con un color de fondo distinto o un borde).
20. Los números de las grillas deben ser fáciles de leer y de comparar, para lo cual se deben mostrar alineados por la derecha, con separadores de miles y de decimales según el formato elegido (inicialmente Paraguay), con tipografía monoespaciada (a fin de alinear los decimales) y con dos decimales fijos. Los importes en cero no se muestran.
21. El usuario podrá navegar dentro de una grilla de datos usando las flechas del teclado.
22. Cuando se navega por una grilla usando las flechas del teclado, los registros que no caben en la pantalla deben desplazarse automáticamente para que el registro actual quede siempre visible.
23. El usuario deberá poder navegar por la grilla lateral de los formularios (y por las grillas de datos, incluida la grilla de detalles) usando las flechas arriba/abajo del teclado, y debe poder hacerlo también cuando no esté en modo de edición de datos del formulario (solo esté viendo un registro).
24. El campo suficiente debe ocupar el ancho suficiente para sus caracteres, a fin de evitar el desborde o el campo excesivamente grande.

25. La "X" de borrado de los campos obligatorios (y, en general, de todo campo que la muestre) se tiene en cuenta en el ancho del campo: la "X" debe quedar cerca del último carácter del texto (pero sin pegarse) y cerca del borde derecho del campo (pero sin pegarse); en ambos casos 3 o 4 píxeles de separación son adecuados. El hueco de la "X" (dAnchoSuffixBorrar: icono 18 + 3 px por lado) se reserva siempre en los campos de texto, número y lógico; la "X" de los campos de fecha y de hora queda fuera del campo, junto al selector (esa regla no cambia).

26. Las máscaras de entrada se escriben con sus separadores visibles ("9.999", "99/99/9999", "999-999-9999999"): el largo de la máscara define el ancho del campo y el formato mostrado, y la cantidad de "9" define el máximo de dígitos tecleables. El valor formateado debe caber completo en el campo: ningún dígito se corta nunca. El campo "Ejercicio contable" usa la máscara "9.999" en todos los formularios donde existe.

### Calculo de medidas de los controles

El objetivo de estas reglas es simplificar el cálculo de las medidas de los controles para que sea más sencillo mantenerlas y ajustarlas en caso de problemas.
Las medidas de cada widget deben declararse en una única ubicación conocida y centralizada. Nunca se deben definir medidas "mágicas" repetidas en varios lugares. Cada medida debe calcularse y fluir desde un único punto de cambio hacia el resto de la interfaz. La estructura jerárquica de dependencias se define a continuación.

Medidas que usan las medidas de la etiqueta y de un campo:

- ClaseCampoAbm: el modelo de datos de un campo (tipo, opciones, validación) y los cálculos de medidas (getAnchoCampo, getAnchoEtiqueta, getAnchoColumna) viven en ClaseCampoAbm: es la única fuente de los anchos, para que todos los formularios midan igual. getAnchoCampo incluye el hueco de la "X" (regla 25) y el margen de seguridad ClaseGenLayout.dMargenTextoCampo; el ancho del carácter se mide en tiempo de ejecución (medirAnchoCaracter).
- ClaseCampoFormulario: los anchos de etiqueta y control, el estilo del texto del campo y el color del texto de la etiqueta (getAnchoCampo, _construirControl, _getEstiloCampo, _construirEtiqueta) viven en ClaseCampoFormulario: es el único punto de cambio visual de los campos. En las filas compartidas la etiqueta se angosta (Flexible) y el control conserva siempre su ancho natural: el valor del campo nunca se corta.
- ClaseFormularioCampos._construirFila (abm_comun.dart): row+flex con tope máximo por campo (si la fila no cabe se angosta la etiqueta; el control nunca se recorta).

Medidas que usan los anchos de columna de una grilla editable de detalles:

- ClaseCampoAbm: modelo de datos del campo de la columna y cálculo de medidas (getAnchoColumna).
- ClaseFormularioCabeceraDetalle: cálculo del ancho total de la grilla (getAnchoTotalGrilla) y de la lista de columnas (getListCamposVisibles, crearColumnas).
- ClaseFilaDetalle: anchos de los controles de la fila.
- ClaseBotonFilaDetalle: tamaño de los botones de las filas.

Medidas que usan las medidas de la grilla lateral de registros de los formularios ABM:

- ClaseGrillaRegistros: ancho total, tira izquierda, ancho de columnas, número de fila, acciones por fila.
- ClaseAccionesFila: ancho y visibilidad de las acciones.

Medidas que usan las medidas de las filas de las grillas compactas:

- ClaseFormularioCabeceraDetalle: alto del encabezado (dAltoEncabezadoDetalleCompacto) y de las filas (dAltoFilaDetalleCompacta).
- ClaseCeldaNumero: ancho de columna y estilo numérico.

Diseño responsive: el controlador principal recalcula dEscala al abrir y al redimensionar; todos los tamaños, posiciones, anchos y altos dependen de escala y de dFactorTexto (el alto de los botones ABM se mantiene en 48 px para preservar objetivos táctiles cómodos), y el ancho real de un carácter se re-mide en cada dibujado (medirAnchoCaracter).

### Reglas de las grillas de datos

1. Las grillas muestran los datos con formato (números y fechas) pero conservan el valor plano para el formulario.
2. Las grillas se expanden horizontalmente para ocupar todo el ancho disponible y distribuyen el excedente entre las columnas marcadas como expansibles.
3. La primera columna ocupa 48 px como anclaje visual estable de las filas.
4. Cada celda conserva al menos 8 px de aire para que ningún contenido quede pegado al borde.

## 5. Especificaciones funcionales

El orden de los formularios y sus reglas funcionales deben responder a los archivos de especificaciones funcionales que se encuentran en el subdirectorio "docs".

- Filosofía, rol, permisos de roles y session: especificación 00_01
- Menú lateral de opciones de la aplicación: 00_02
- Elementos de los formularios, los grillas y validaciones: 00_00_03
- Reglas de interfaz de usuario (UI/UX): 00_03_01
- Formulario de la tabla empresa: 01_01
- Formulario de la tabla configuración: 01_02
- Formulario de la tabla sucursales: 01_03
- Formulario de la tabla clientes: 01_04
- Formulario de la tabla proveedores: 01_05
- Formulario de la tabla timbrados propios: 01_06
- Formulario de la tabla timbrados de proveedores: 01_07
- Formulario de la tabla cuentas asignadas: 01_08
- Formulario de la tabla de plan de cuentas: 02_01
- Formulario de la tabla asientos: 02_02
- Formulario de la tabla compras: 02_03
- Formulario de la tabla ventas: 02_04
- Formulario de la tabla de retenciones de los clientes: 02_05

La arquitectura de la aplicación se basa en Flutter, el objetivo principal son equipos de escritorio y secundario la web, con navegación estructurada bajo lib/, rutas/ y utilidades generales para diseño responsive y gestión de idiomas. El código debe seguir esta estructura organizacional y estas convenciones de diseño para mantener la coherencia con el sistema ya implementado.

Las aplicaciones deben estar preparadas para utilizar las bases de datos de libre disposición (de manera inicial Firebird) y soportar múltiples empresas, sucursales y países, con configuración flexible de formatos y monedas (Paraguay, Argentina, Uruguay, Perú, Francia, entre otros).

Campos frecuentes: fecha de modificación; usuario que modificó; fecha de creación; usuario que creó.
Es posible que todos los datos deban tener borrado suave.

Autenticación de usuarios y control de acceso por roles.

Cada formulario debe incluir cabecera con la base de datos y país del asiento (Ver documento 1.0 Roles). [cit. doc 1]

Lista de los archivos más importantes con su ruta:

- lib/main.dart → Punto de entrada de la aplicación, configura el tema, la localización y ejecuta la app.
- lib/generales/temas/colores.dart → Define todos los colores del tema claro y oscuro.
- lib/generales/temas/radios.dart → Define los tamaños de los bordes redondeados (radios) de la interfaz.
- lib/generales/temas/estilos_textos.dart → Define los estilos de texto y el tema de tipografía.
- lib/generales/temas/temas.dart → Define los temas completos de la aplicación.
- lib/generales/idiomas/idiomas_*.dart → Traducciones y gestión de idiomas de la interfaz.
- lib/generales/utilitarios/formatos.dart → Funciones de formato para números, monedas, fechas y horas.
- lib/generales/varios/listas.dart → Funciones para listas desplegables con estilos personalizados.
- lib/generales/varios/paises.dart → Catálogo de países y monedas soportadas.
- lib/generales/validaciones/cap_validar.dart → Validaciones de formularios y comprobaciones generales.
- lib/generales/inicio/login.dart → Módulo de autenticación de usuarios.
- lib/generales/inicio/menu_lateral.dart → Menú lateral de navegación de la aplicación.
- lib/generales/inicio/pantalla_principal.dart → Nivel superior de los formularios.
- lib/generales/modelos/documentos.dart → Lógica para tipos de documentos.
- lib/generales/modelos/permisos.dart → Control de acceso y permisos de usuario.
- lib/generales/modelos/sesion.dart → Manejo de sesión de usuario.
- lib/generales/preferencias/preferencias.dart → Acceso y gestión de preferencias.
