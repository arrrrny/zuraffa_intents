// The zuraffa_intents example: a fully working share-intents app for
// android, ios and macos.
//
// It exercises every operation the plugin exposes over the REAL platform
// driver (ShareIntentService.platform):
//
//   - getInitialSharedMedia  — the boot-time share, read repeatably until
//     reset (the Reset card action demonstrates resetInitialSharedMedia).
//   - sharedMediaStream      — the live broadcast stream, every event
//     appended to the feed below.
//   - recordSentMessage      — the form at the bottom carries ALL four
//     arguments (conversationIdentifier, conversationName,
//     conversationImageFilePath, serviceName) and maps them onto the
//     carrier exactly like the plugin does.
//   - PlatformException      — surfaced verbatim in the error banner
//     (e.g. `channel-error` when a native half is missing).
//
// The "in-memory demo" switch swaps the platform driver for the pure-Dart
// InMemoryShareIntentAdapter, whose producer side (storeInitial / emit)
// powers the Simulate actions — so the full receive flow can be tried
// without an OS share sheet.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:zuraffa_intents/zuraffa_intents.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // The plugin's composition root: binds ShareIntentPort to the
  // method-channel driver and ShareIntentService to that port (lazy
  // singletons). Swap-in for tests: GetIt.reset() + register again.
  registerShareIntentDependencies(GetIt.instance);
  final service = GetIt.instance<ShareIntentService>();
  runApp(ShareIntentsApp(initialService: service));
}

class ShareIntentsApp extends StatelessWidget {
  const ShareIntentsApp({super.key, this.initialService});

  /// Injectable for tests: omit it to use the GetIt-registered platform
  /// service (see [main]).
  final ShareIntentService? initialService;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'zuraffa_intents example',
      theme: ThemeData(colorSchemeSeed: const Color(0xFF7B61FF), useMaterial3: true),
      home: ShareIntentsPage(service: initialService),
    );
  }
}

class ShareIntentsPage extends StatefulWidget {
  const ShareIntentsPage({super.key, this.service});

  final ShareIntentService? service;

  @override
  State<ShareIntentsPage> createState() => _ShareIntentsPageState();
}

class _ShareIntentsPageState extends State<ShareIntentsPage> {
  late ShareIntentService _service;
  StreamSubscription<SharedMedia>? _subscription;
  final _events = <SharedMedia>[];
  SharedMedia? _initialShare;
  String? _error;
  bool _demoMode = false;

  // recordSentMessage form — all four arguments the plugin carries.
  final _conversationId = TextEditingController(text: 'conv-9');
  final _conversationName = TextEditingController(text: 'Mom');
  final _conversationImage = TextEditingController();
  final _serviceName = TextEditingController();

  @override
  void initState() {
    super.initState();
    _bindService(widget.service ?? GetIt.instance<ShareIntentService>());
    _readInitialShare();
  }

  void _bindService(ShareIntentService service) {
    _subscription?.cancel();
    _service = service;
    _demoMode = service.port is InMemoryShareIntentAdapter;
    _subscription = service.sharedMediaStream.listen(
      (media) => setState(() => _events.insert(0, media)),
      onError: (Object error) => setState(() => _error = error.toString()),
    );
  }

  Future<void> _readInitialShare() async {
    try {
      final media = await _service.getInitialSharedMedia();
      setState(() {
        _initialShare = media;
        _error = null;
      });
    } on PlatformException catch (error) {
      setState(() => _error = 'code=${error.code} message=${error.message}');
    }
  }

  Future<void> _resetInitialShare() async {
    try {
      await _service.resetInitialSharedMedia();
      await _readInitialShare();
    } on PlatformException catch (error) {
      setState(() => _error = 'code=${error.code} message=${error.message}');
    }
  }

  Future<void> _recordSentMessage() async {
    try {
      await _service.recordSentMessage(
        conversationIdentifier: _conversationId.text.trim(),
        conversationName: _conversationName.text.trim(),
        conversationImageFilePath:
            _conversationImage.text.trim().isEmpty
                ? null
                : _conversationImage.text.trim(),
        serviceName: _serviceName.text.trim().isEmpty
            ? null
            : _serviceName.text.trim(),
      );
      setState(() => _error = null);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('suggestion recorded')),
      );
    } on PlatformException catch (error) {
      setState(() => _error = 'code=${error.code} message=${error.message}');
    }
  }

  // ---- demo-mode producers (the in-memory adapter's test side) ----

  void _simulateInitialShare() {
    final port = _service.port as InMemoryShareIntentAdapter;
    port.storeInitial(
      SharedMedia(
        content: 'Check this out',
        attachments: [
          SharedAttachment(path: '/tmp/pic.jpg', type: SharedAttachmentType.image),
        ],
      ),
    );
    _readInitialShare();
  }

  void _simulateLiveShare() {
    (_service.port as InMemoryShareIntentAdapter).emit(
      SharedMedia(content: 'hello from the share sheet'),
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _conversationId.dispose();
    _conversationName.dispose();
    _conversationImage.dispose();
    _serviceName.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('zuraffa_intents'),
        actions: [
          Switch(
            value: _demoMode,
            onChanged: (demo) => setState(() {
              _bindService(
                demo ? ShareIntentService() : GetIt.instance<ShareIntentService>(),
              );
              _events.clear();
              _readInitialShare();
            }),
          ),
          const Padding(
            padding: EdgeInsets.only(right: 12),
            child: Center(child: Text('in-memory demo')),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (_error != null)
            Card(
              color: Theme.of(context).colorScheme.errorContainer,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(_error!, key: const Key('error-banner')),
              ),
            ),
          Card(
            child: ListTile(
              key: const Key('initial-share'),
              leading: const Icon(Icons.launch),
              title: const Text('Boot-time initial share'),
              subtitle: Text(_initialShare == null
                  ? 'nothing stored'
                  : '${_initialShare!.content ?? '(no content)'}'
                    ' — ${_describe(_initialShare!)}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    key: const Key('refresh-initial'),
                    tooltip: 'getInitialSharedMedia',
                    onPressed: _readInitialShare,
                    icon: const Icon(Icons.refresh),
                  ),
                  IconButton(
                    key: const Key('reset-initial'),
                    tooltip: 'resetInitialSharedMedia',
                    onPressed: _resetInitialShare,
                    icon: const Icon(Icons.delete_sweep),
                  ),
                ],
              ),
            ),
          ),
          if (_demoMode)
            Wrap(
              spacing: 8,
              children: [
                OutlinedButton(
                  key: const Key('simulate-initial'),
                  onPressed: _simulateInitialShare,
                  child: const Text('Simulate boot share'),
                ),
                OutlinedButton(
                  key: const Key('simulate-live'),
                  onPressed: _simulateLiveShare,
                  child: const Text('Simulate live share'),
                ),
              ],
            ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Live share stream (${_events.length})',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  if (_events.isEmpty)
                    const Text('no live shares yet — share something into the app'),
                  for (final media in _events)
                    ListTile(
                      key: Key('event-${_events.indexOf(media)}'),
                      dense: true,
                      leading: const Icon(Icons.share),
                      title: Text(media.content ?? '(no content)'),
                      subtitle: Text(_describe(media)),
                    ),
                ],
              ),
            ),
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Record sent message',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  TextField(
                    key: const Key('field-conversation-id'),
                    controller: _conversationId,
                    decoration: const InputDecoration(
                        labelText: 'conversationIdentifier (required)'),
                  ),
                  TextField(
                    key: const Key('field-conversation-name'),
                    controller: _conversationName,
                    decoration: const InputDecoration(
                        labelText: 'conversationName (required) → speakableGroupName'),
                  ),
                  TextField(
                    key: const Key('field-conversation-image'),
                    controller: _conversationImage,
                    decoration: const InputDecoration(
                        labelText:
                            'conversationImageFilePath (optional) → imageFilePath'),
                  ),
                  TextField(
                    key: const Key('field-service-name'),
                    controller: _serviceName,
                    decoration: const InputDecoration(
                        labelText: 'serviceName (optional)'),
                  ),
                  const SizedBox(height: 8),
                  FilledButton(
                    key: const Key('record-button'),
                    onPressed: _recordSentMessage,
                    child: const Text('recordSentMessage'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _describe(SharedMedia media) {
    final parts = <String>[
      if (media.conversationIdentifier != null)
        'conversation=${media.conversationIdentifier}',
      if (media.speakableGroupName != null) 'group=${media.speakableGroupName}',
      if (media.serviceName != null) 'service=${media.serviceName}',
      if (media.attachments != null)
        '${media.attachments!.length} attachment(s)',
    ];
    return parts.isEmpty ? 'no extra fields' : parts.join(' · ');
  }
}
