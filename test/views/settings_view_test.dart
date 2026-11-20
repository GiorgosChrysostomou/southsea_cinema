import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:southsea_cinema/views/settings_view.dart';

Future<void> pumpSettings(WidgetTester tester) async {
  await tester.pumpWidget(
    const MaterialApp(
      home: SettingsView(),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> tapSave(WidgetTester tester) async {
  await tester.ensureVisible(find.text('SAVE CHANGES'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('SAVE CHANGES'));
  await tester.pumpAndSettle();
}

void main() {
  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });

  testWidgets('Settings form displays all fields', (WidgetTester tester) async {
    await pumpSettings(tester);

    expect(find.text('Customer Profile'), findsOneWidget);
    expect(find.text('First Name'), findsOneWidget);
    expect(find.text('Last Name'), findsOneWidget);
    expect(find.text('Email Address'), findsOneWidget);
    expect(find.text('Phone Number'), findsOneWidget);
    expect(find.text('Email me cinema news'), findsOneWidget);
    expect(find.text('SAVE CHANGES'), findsOneWidget);
  });

  testWidgets('Empty form displays validation errors',
      (WidgetTester tester) async {
    await pumpSettings(tester);

    await tester.ensureVisible(find.text('SAVE CHANGES'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('SAVE CHANGES'));
    await tester.pump();

    expect(find.text('Please enter your first name'), findsOneWidget);
    expect(find.text('Please enter your last name'), findsOneWidget);
    expect(find.text('Please enter a valid email address'), findsOneWidget);
    expect(find.text('Please enter your phone number'), findsOneWidget);
  });

  testWidgets('Empty preferences leave the form empty and news off',
      (WidgetTester tester) async {
    await pumpSettings(tester);

    final Finder fields = find.byType(TextFormField);
    for (int i = 0; i < 4; i++) {
      final TextFormField field = tester.widget<TextFormField>(fields.at(i));
      expect(field.controller!.text, isEmpty);
    }

    final SwitchListTile newsSwitch =
        tester.widget<SwitchListTile>(find.byType(SwitchListTile));
    expect(newsSwitch.value, isFalse);
  });

  testWidgets('Saved profile is loaded when the page opens',
      (WidgetTester tester) async {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.withData({
      profileFirstNameKey: 'Sam',
      profileLastNameKey: 'Example',
      profileEmailKey: 'sam.example@example.com',
      profilePhoneKey: '07700 900123',
      profileEmailNewsKey: true,
    });

    await pumpSettings(tester);

    expect(find.text('Sam'), findsOneWidget);
    expect(find.text('Example'), findsOneWidget);
    expect(find.text('sam.example@example.com'), findsOneWidget);
    expect(find.text('07700 900123'), findsOneWidget);

    final SwitchListTile newsSwitch =
        tester.widget<SwitchListTile>(find.byType(SwitchListTile));
    expect(newsSwitch.value, isTrue);
  });

  testWidgets('Saving stores the profile under the named keys',
      (WidgetTester tester) async {
    await pumpSettings(tester);

    final Finder fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Sam');
    await tester.enterText(fields.at(1), 'Example');
    await tester.enterText(fields.at(2), 'sam.example@example.com');
    await tester.enterText(fields.at(3), '07700 900123');

    await tester.ensureVisible(find.byType(SwitchListTile));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(SwitchListTile));
    await tester.pumpAndSettle();

    await tapSave(tester);

    expect(find.text('Profile updated successfully!'), findsOneWidget);

    final SharedPreferencesAsync prefs = SharedPreferencesAsync();
    expect(await prefs.getString(profileFirstNameKey), 'Sam');
    expect(await prefs.getString(profileLastNameKey), 'Example');
    expect(await prefs.getString(profileEmailKey), 'sam.example@example.com');
    expect(await prefs.getString(profilePhoneKey), '07700 900123');
    expect(await prefs.getBool(profileEmailNewsKey), isTrue);
  });

  // NEW: edit values that were already saved, then save again.
  testWidgets('Editing saved values and saving updates the stored profile',
      (WidgetTester tester) async {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.withData({
      profileFirstNameKey: 'Sam',
      profileLastNameKey: 'Example',
      profileEmailKey: 'sam.example@example.com',
      profilePhoneKey: '07700 900123',
      profileEmailNewsKey: true,
    });

    await pumpSettings(tester);

    final Finder fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Alex');
    await tester.enterText(fields.at(2), 'alex.example@example.com');

    await tester.ensureVisible(find.byType(SwitchListTile));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(SwitchListTile));
    await tester.pumpAndSettle();

    await tapSave(tester);

    final SharedPreferencesAsync prefs = SharedPreferencesAsync();
    expect(await prefs.getString(profileFirstNameKey), 'Alex');
    expect(await prefs.getString(profileLastNameKey), 'Example');
    expect(await prefs.getString(profileEmailKey), 'alex.example@example.com');
    expect(await prefs.getString(profilePhoneKey), '07700 900123');
    expect(await prefs.getBool(profileEmailNewsKey), isFalse);
  });

  // NEW: save, close the page, then open a fresh settings page.
  testWidgets('Saved profile is still there when the form is reopened',
      (WidgetTester tester) async {
    await pumpSettings(tester);

    final Finder fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Sam');
    await tester.enterText(fields.at(1), 'Example');
    await tester.enterText(fields.at(2), 'sam.example@example.com');
    await tester.enterText(fields.at(3), '07700 900123');

    await tester.ensureVisible(find.byType(SwitchListTile));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(SwitchListTile));
    await tester.pumpAndSettle();

    await tapSave(tester);

    // Remove the page completely so its state is disposed.
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();

    // Open a brand new settings page: it must load the saved values.
    await pumpSettings(tester);

    expect(find.text('Sam'), findsOneWidget);
    expect(find.text('Example'), findsOneWidget);
    expect(find.text('sam.example@example.com'), findsOneWidget);
    expect(find.text('07700 900123'), findsOneWidget);

    final SwitchListTile newsSwitch =
        tester.widget<SwitchListTile>(find.byType(SwitchListTile));
    expect(newsSwitch.value, isTrue);
  });
}
