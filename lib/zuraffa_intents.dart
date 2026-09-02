/// zuraffa_intents — the incoming-share seam for the Zuraffa
/// ecosystem.
///
/// A pure-Dart reimplementation of the `zikzak_share_handler` plugin
/// contract: receive shared text/media (a boot-time initial share plus a
/// live stream while the app runs) and record sent messages so the share
/// menu can suggest conversations. Any delivery driver — the native
/// plugin side on a device, the in-memory adapter in tests — implements
/// [ShareIntentPort] behind one facade.
///
/// ```dart
/// final intents = ShareIntentService();
/// final boot = await intents.getInitialSharedMedia();
/// if (boot != null) await intents.resetInitialSharedMedia();
/// intents.sharedMediaStream.listen(handleShare);
/// ```
library;

export 'src/data/intents/in_memory_share_intent_adapter.dart';
export 'src/domain/entities/enums/shared_attachment_type.dart';
export 'src/domain/entities/shared_attachment/shared_attachment.dart';
export 'src/domain/entities/shared_media/shared_media.dart';
export 'src/domain/intents/share_intent_port.dart';
export 'src/platform/method_channel/method_channel_share_intent_port.dart';
export 'src/platform/wire/share_intents_wire.dart';
export 'src/share_intent_service.dart';
