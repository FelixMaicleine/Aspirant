import 'package:aspirant/pages/change.dart';
import 'package:aspirant/pages/changeusn.dart';
import 'package:aspirant/pages/forgot.dart';
import 'package:aspirant/pages/verif.dart';
import 'package:flutter/material.dart';
import 'package:aspirant/pages/profile.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets("Deteksi Text pada Page Profile", (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: Profile()));
    expect(find.text("Profile"), findsOneWidget);
    expect(find.text("Edit Profile"), findsOneWidget);
    expect(find.text("Delete Account"), findsOneWidget);
    expect(find.text("Halo"), findsNothing);
  });

  testWidgets("Deteksi Text pada Page Change Username",
      (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: UpdateUsername()));
    expect(find.text("New Username"), findsOneWidget);
    expect(find.text("Change Username"), findsOneWidget);
    expect(find.text("Halo"), findsNothing);
  });

  testWidgets("Testing Routing pada Page Profile", (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(initialRoute: '/profile', routes: {
      '/profile': (context) => const Profile(),
      '/changeusn': (context) => const UpdateUsername(),
    }));
    expect(find.text("Profile"), findsOneWidget);
    expect(find.text("Edit Profile"), findsOneWidget);
    expect(find.text("Delete Account"), findsOneWidget);
    await tester.tap(find.text("Edit Profile"));
    await tester.pumpAndSettle();
    expect(find.text("New Username"), findsOneWidget);
    expect(find.text("Change Username"), findsOneWidget);
  });

  testWidgets("Deteksi Icon Text dan Textfield pada Page Forgot",
      (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: Forgot()));
    expect(find.byIcon(Icons.error_outline), findsOneWidget);
    expect(find.byIcon(Icons.email), findsOneWidget);
    expect(find.text("Forgot Password?"), findsOneWidget);
    expect(find.text("E-mail"), findsOneWidget);
    expect(find.text("Enter your e-mail"), findsOneWidget);
    expect(find.text("Send Code"), findsOneWidget);
    expect(find.text("Back to"), findsOneWidget);
    expect(find.text("Login"), findsOneWidget);
    expect(find.text("Register"), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    expect(find.text("Halo"), findsNothing);
  });

  testWidgets("Deteksi Text dan Textfield pada Page Verif",
      (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: Verif()));
    expect(find.text("Enter Verification Code"), findsOneWidget);
    expect(find.text("Verify"), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(6));
    expect(find.text("Halo"), findsNothing);
  });

  testWidgets("Deteksi Icon Text dan Textfield pada Page Change Pass",
      (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: Change()));
    expect(find.byIcon(Icons.person), findsOneWidget);
    expect(find.byIcon(Icons.lock_outline), findsOneWidget);
    expect(find.byIcon(Icons.lock), findsOneWidget);
    expect(find.text("Username"), findsOneWidget);
    expect(find.text("New password"), findsOneWidget);
    expect(find.text("Confirm new password"), findsOneWidget);
    expect(find.text("Change Password"), findsOneWidget);
    expect(find.text("Back to"), findsOneWidget);
    expect(find.text("Login"), findsOneWidget);
    expect(find.text("Register"), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(3));
    expect(find.text("Halo"), findsNothing);
  });

  testWidgets(
      'Testing Logika Pengisian Email Valid dan Routing pada Page Forgot',
      (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(initialRoute: '/forgot', routes: {
      '/forgot': (context) => const Forgot(),
      '/verif': (context) => const Verif(),
    }));
    expect(find.byType(TextField), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'test');
    await tester.pump();
    expect(find.text('Enter a valid email'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'test@example.com');
    expect(find.text('test@example.com'), findsOneWidget);
    final sendCodeButton = find.text('Send Code');
    await tester.tap(sendCodeButton);
    await tester.pumpAndSettle();
    expect(find.text('Enter Verification Code'), findsOneWidget);
    expect(find.text('Verify'), findsOneWidget);
  });

  testWidgets(
      'Testing Logika Pengisian Kode Verifikasi dan Routing pada Page Verif',
      (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(initialRoute: '/verif', routes: {
      '/verif': (context) => const Verif(),
      '/change': (context) => const Change(),
    }));
    final textFieldFinder = find.byType(TextField);
    expect(textFieldFinder, findsNWidgets(6));
    for (int i = 0; i < 6; i++) {
      await tester.enterText(textFieldFinder.at(i), (i + 1).toString());
    }
    final verifyButtonFinder = find.text('Verify');
    expect(verifyButtonFinder, findsOneWidget);
    await tester.tap(verifyButtonFinder);
    await tester.pumpAndSettle();
    expect(find.text("Change Password"), findsOneWidget);
  });

  testWidgets('Testing Logika Validasi Password Rumit pada Page Change Pass',
      (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: Change()));
    final usernameField = find.byType(TextField).first;
    final newPasswordField = find.byType(TextField).at(1);
    final confirmPasswordField = find.byType(TextField).last;
    final changePasswordButton = find.text('Change Password');
    expect(changePasswordButton, findsOneWidget);
    expect(tester.widget<ElevatedButton>(find.byType(ElevatedButton)).enabled,
        false);
    await tester.enterText(usernameField, 'testuser');
    await tester.pump();
    expect(find.text('testuser'),findsOneWidget);
    await tester.enterText(newPasswordField, 'abc'); 
    await tester.pump();
    expect(find.text('Password must be at least 5 characters long'),findsOneWidget);
    await tester.enterText(newPasswordField, 'Abc@123');
    await tester.pump();
    expect(find.text('Password must be at least 5 characters long'), findsNothing);
    await tester.enterText(confirmPasswordField, 'Abc@124');
    await tester.pump();
    expect(find.text('Passwords do not match'), findsOneWidget);
    await tester.enterText(confirmPasswordField, 'Abc@123');
    await tester.pump();
    expect(find.text('Passwords do not match'), findsNothing);
    final elevatedButton =
        tester.widget<ElevatedButton>(find.byType(ElevatedButton));
    expect(elevatedButton.enabled, true);
  });
}
