import 'package:flutter_test/flutter_test.dart';
import 'package:prioritek/main.dart';

void main() {
  testWidgets('shows the priority queue and example tasks', (tester) async {
    await tester.pumpWidget(const PrioritekApp());

    expect(find.text('Priority queue'), findsOneWidget);
    expect(find.text('Resolve checkout error'), findsOneWidget);
    expect(find.text('Add task'), findsOneWidget);
  });
}
