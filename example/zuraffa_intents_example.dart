/// zuraffa_intents — the incoming-share seam for the Zuraffa ecosystem.
///
/// A publish-ready Flutter plugin replacing `zikzak_share_handler`:
/// receive the boot-time initial share, listen to live share events, and
/// record sent messages so share menus can suggest conversations. This
/// example drives the pure-Dart `InMemoryShareIntentAdapter` so it runs
/// anywhere; a Flutter app calls `ShareIntentService.platform()` (or
/// `registerShareIntentDependencies`) to talk to the real native plugins.
library;

import 'package:zuraffa_intents/zuraffa_intents.dart';

Future<void> main() async {
  final intents = ShareIntentService();
  final adapter = intents.port as InMemoryShareIntentAdapter;

  // A native driver would seed the boot-time share; the in-memory
  // adapter exposes the producer side for tests and dev.
  adapter.storeInitial(
    SharedMedia(
      content: 'Check this out',
      attachments: [
        SharedAttachment(
          path: '/tmp/pic.jpg',
          type: SharedAttachmentType.image,
        ),
      ],
    ),
  );

  final boot = await intents.getInitialSharedMedia();
  print('initial share: ${boot?.content}');
  if (boot != null) await intents.resetInitialSharedMedia();

  adapter.sharedMediaStream.listen((media) {
    print('live share: ${media.content}');
  });
  adapter.emit(SharedMedia(content: 'hello from the share sheet'));

  await intents.recordSentMessage(
    conversationIdentifier: 'conv-9',
    conversationName: 'Mom',
  );
  print('suggestions: ${adapter.sentMessageRecords.length}');

  // A Flutter app swaps in the platform driver with one call — same
  // facade, same four operations:
  //
  //   final intents = ShareIntentService.platform();
  //   final boot = await intents.getInitialSharedMedia();
  //   intents.sharedMediaStream.listen(handleShare);
  //   await intents.recordSentMessage(...);
  //
  // or binds it through the composition root:
  //
  //   registerShareIntentDependencies(GetIt.instance);
  //   final intents = GetIt.instance<ShareIntentService>();
}
