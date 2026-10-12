import 'package:flutter_test/flutter_test.dart';
import 'package:agricast_app/main.dart';
import 'package:provider/provider.dart';
import 'package:agricast_app/providers/app_state.dart';

void main() {
  testWidgets('AgriCastApp basic smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AppState(),
        child: const AgriCastApp(),
      ),
    );

    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('AgriCAST'), findsWidgets);
  });
}
