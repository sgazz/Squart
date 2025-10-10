import 'package:flutter_test/flutter_test.dart';
import 'package:squart/main.dart';

void main() {
  testWidgets('App loads successfully', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const SquartApp());
    await tester.pumpAndSettle();

    // Verify that the app title is displayed
    expect(find.text('SQUART'), findsOneWidget);
    
    // Verify home screen elements
    expect(find.text('New Game'), findsOneWidget);
    expect(find.text('How to Play'), findsOneWidget);
  });
}
