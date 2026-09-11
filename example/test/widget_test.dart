// Executable documentation: pumps the example app over the in-memory
// driver and drives every plugin operation end to end.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zuraffa_intents/zuraffa_intents.dart';
import 'package:zuraffa_intents_example/main.dart';

void main() {
  testWidgets('the full share-intents flow works end to end',
      (tester) async {
    final adapter = InMemoryShareIntentAdapter();
    final app = ShareIntentsApp(initialService: ShareIntentService(port: adapter));
    await tester.pumpWidget(app);

    // Boot: nothing stored yet on a fresh driver.
    expect(find.text('nothing stored'), findsOneWidget);

    // Simulate the OS handing over a boot-time share; the card re-reads.
    await tester.tap(find.byKey(const Key('simulate-initial')));
    await tester.pumpAndSettle();
    expect(find.textContaining('Check this out'), findsOneWidget);
    expect(find.textContaining('1 attachment'), findsOneWidget);

    // The reset contract: reset clears; refresh keeps it cleared.
    await tester.tap(find.byKey(const Key('reset-initial')));
    await tester.pumpAndSettle();
    expect(find.text('nothing stored'), findsOneWidget);

    // Live stream: a simulated share lands in the feed.
    await tester.tap(find.byKey(const Key('simulate-live')));
    await tester.pumpAndSettle();
    expect(find.text('hello from the share sheet'), findsOneWidget);

    // recordSentMessage: all four arguments map onto the carrier.
    await tester.scrollUntilVisible(
      find.byKey(const Key('record-button')),
      160,
      scrollable: find
          .descendant(of: find.byType(ListView), matching: find.byType(Scrollable))
          .first,
    );
    await tester.enterText(
        find.byKey(const Key('field-conversation-image')), '/tmp/mom.png');
    await tester.enterText(
        find.byKey(const Key('field-service-name')), 'iMessage');
    // Dismiss the test keyboard so it does not occlude the record button.
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pump();
    await tester.tap(find.byKey(const Key('record-button')));
    await tester.pumpAndSettle();
    expect(find.text('suggestion recorded'), findsOneWidget);
    expect(adapter.sentMessageRecords.single.conversationIdentifier, 'conv-9');
    expect(adapter.sentMessageRecords.single.speakableGroupName, 'Mom');
    expect(adapter.sentMessageRecords.single.imageFilePath, '/tmp/mom.png');
    expect(adapter.sentMessageRecords.single.serviceName, 'iMessage');
  });

  testWidgets('a missing native half surfaces as a channel-error banner',
      (tester) async {
    // A port whose channel no native answers: getInitialSharedMedia maps
    // the null reply to PlatformException(code: channel-error) — the app
    // must surface it verbatim instead of crashing.
    TestWidgetsFlutterBinding.ensureInitialized();
    // On a device whose native half is missing, the channel replies null;
    // replicate that exactly so the port maps it to the canonical
    // channel-error.
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockDecodedMessageHandler<Object?>(
      const BasicMessageChannel<Object?>(
        'dev.flutter.pigeon.ZuraffaIntentsApi.getInitialSharedMedia',
        ShareIntentsApiCodec(),
      ),
      (message) async => null,
    );
    await tester.pumpWidget(
        ShareIntentsApp(initialService: ShareIntentService.platform()));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('error-banner')), findsOneWidget);
    expect(find.textContaining('channel-error'), findsOneWidget);
  });
}
