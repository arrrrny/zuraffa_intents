/// zuraffa_intents — the incoming-share seam for the Zuraffa ecosystem.
///
/// Reimplements the `zikzak_share_handler` plugin contract in pure Dart:
/// receive the boot-time initial share, listen to live share events, and
/// record sent messages so share menus can suggest conversations.
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
            path: '/tmp/pic.jpg', type: SharedAttachmentType.image),
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
}
