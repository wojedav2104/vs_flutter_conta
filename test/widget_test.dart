import 'package:flutter_test/flutter_test.dart';

import 'package:vs_conta/generales/preferencias/preferencias.dart';
import 'package:vs_conta/main.dart';


void main() {

  testWidgets('VS_CONTA muestra la pantalla de login', (WidgetTester tester) async {

    final ClasePreferencias oPreferencias = ClasePreferencias();
    await oPreferencias.cargar();

    await tester.pumpWidget(ClaseAplicacion(oPreferencias: oPreferencias));
    await tester.pumpAndSettle();

    // La pantalla de login debe mostrar el nombre de la aplicación
    expect(find.text('VS_CONTA'), findsOneWidget);

  });

}
