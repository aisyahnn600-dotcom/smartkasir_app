
import 'package:flutter_test/flutter_test.dart';
import 'package:smartkasir_app/main.dart';

void main() {
  testWidgets('SmartKasir menampilkan Splash Screen',
      (WidgetTester tester) async {
    await tester.pumpWidget(const SmartKasirApp());

    expect(find.text('SmartKasir'), findsOneWidget);
    expect(
      find.text('Solusi Kasir Digital UMKM'),
      findsOneWidget,
    );
    expect(
      find.text('Memulai dalam 3...'),
      findsOneWidget,
    );
  });
}
