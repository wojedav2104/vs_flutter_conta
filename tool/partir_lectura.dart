// tool/partir_lectura.dart  →  dart run tool/partir_lectura.dart
//
// Genera el espejo de lectura en lectura/: cada archivo de texto del proyecto
// partido en fragmentos de iTamano caracteres (caiga donde caiga) y un índice.
// Los fragmentos no necesitan compilar; son solo material de lectura.
import 'dart:io';
import 'dart:math' show max;

const int iTamano = 4000;   // por debajo del corte observado (~5000)

/// Solo archivos de texto: los binarios (zip, fuentes, imágenes) no se leen.
const Set<String> setTexto = <String>{
  '.dart', '.json', '.yaml', '.yml', '.txt', '.csv', '.md',
};

bool esTexto(String sPath) {
  final String sMinus = sPath.toLowerCase();
  for (final String sExt in setTexto) {
    if (sMinus.endsWith(sExt)) return true;
  }
  return false;
}

void main() {

  // Borra el espejo anterior.
  final Directory dirSalida = Directory('lectura')..createSync(recursive: true);
  for (final FileSystemEntity o in dirSalida.listSync()) {
    o.deleteSync(recursive: true);
  }

  // Fuentes: todo lib/, los archivos de texto de assets/ y el pubspec.
  final List<String> listRutas = <String>[
    ...Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .map((File o) => o.path),
    ...Directory('assets')
        .listSync(recursive: true)
        .whereType<File>()
        .map((File o) => o.path),
    'pubspec.yaml',
  ]..sort();

  // Trocea cada archivo y anota el índice.
  final List<String> listIndice = <String>[];
  for (final String sPath in listRutas) {
    final File oArchivo = File(sPath);
    if (!oArchivo.existsSync()) continue;
    final String sRuta = sPath.replaceAll('\\', '/');
    if (!esTexto(sRuta)) continue;

    String sTexto;
    try {
      sTexto = oArchivo.readAsStringSync();
    } on FileSystemException {
      print('Omitido (no es texto utf-8): $sRuta');
      continue;
    }

    final int iPartes = max(1, (sTexto.length + iTamano - 1) ~/ iTamano);
    for (int i = 0; i < iPartes; i++) {
      final int ini = i * iTamano;
      final int fin = (ini + iTamano < sTexto.length) ? ini + iTamano : sTexto.length;
      final String sNombre =
          '${sRuta.replaceAll('/', '__')}__parte${i + 1}de$iPartes.txt';
      File('lectura/$sNombre').writeAsStringSync(
        'RUTA ORIGINAL: $sRuta\nPARTE ${i + 1} DE $iPartes\n---\n'
        '${sTexto.substring(ini, fin)}',
      );
      listIndice.add(sNombre);
    }
  }

  // Índice en casilleros fijos de 60 líneas (menos de 4000 caracteres),
  // para poder leerlos sin saber de antemano cuántos hay.
  const int iLineasPorParte = 60;
  for (int i = 0; i < 6; i++) {
    final int ini = i * iLineasPorParte;
    final int fin = (ini + iLineasPorParte < listIndice.length)
        ? ini + iLineasPorParte
        : listIndice.length;
    final List<String> listParte =
        (ini < listIndice.length) ? listIndice.sublist(ini, fin) : <String>[];
    File('lectura/00_indice_${i + 1}.txt').writeAsStringSync(listParte.join('\n'));
  }
  File('lectura/00_total.txt').writeAsStringSync('${listIndice.length} fragmentos\n');
  print('${listIndice.length} fragmentos escritos en lectura/');

  print('${listIndice.length} fragmentos escritos en lectura/');

}

