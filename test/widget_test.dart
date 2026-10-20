import 'package:flutter_test/flutter_test.dart';
import 'package:tics_game/main.dart';
import 'package:tics_game/models/concept_pair.dart';

void main() {
  testWidgets('Memorama adapts board to screen size and displays header', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const AIMemoramaApp());
    await tester.pump();

    expect(kAllConceptPairs.length, 15);
    expect(find.text('Memorama IA'), findsOneWidget);
  });
}
