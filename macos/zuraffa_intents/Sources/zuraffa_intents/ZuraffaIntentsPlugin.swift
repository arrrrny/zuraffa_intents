import FlutterMacOS
import Foundation
import zuraffa_intents_models

public class ZuraffaIntentsPlugin: NSObject, FlutterPlugin, FlutterStreamHandler,
    ZuraffaIntentsApi
{

    static let kEventsChannel = "dev.zuraffa.zuraffa_intents/sharedMediaStream"

    private var customSchemePrefix = "ShareMedia"

    private var initialMedia: SharedMedia? = nil
    private var latestMedia: SharedMedia? = nil

    private var eventSink: FlutterEventSink? = nil

    public static let instance = ZuraffaIntentsPlugin()

    public static func register(with registrar: FlutterPluginRegistrar) {
        let messenger: FlutterBinaryMessenger = registrar.messenger
        let api: ZuraffaIntentsApi & NSObjectProtocol = instance
        ZuraffaIntentsApiSetup(messenger, api)

        let eventsChannel = FlutterEventChannel(name: kEventsChannel, binaryMessenger: messenger)
        eventsChannel.setStreamHandler(instance)

        registrar.addApplicationDelegate(instance)
    }

    public func onListen(
        withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink
    ) -> FlutterError? {
        eventSink = events
        return nil
    }

    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        eventSink = nil
        return nil
    }

    public func hasMatchingSchemePrefix(url: URL?) -> Bool {
        if let url = url, let appDomain = Bundle.main.bundleIdentifier {
            return url.absoluteString.hasPrefix("\(self.customSchemePrefix)-\(appDomain)")
                || url.absoluteString.hasPrefix("file://")
        }
        return false
    }

    public func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool)
        -> Bool
    {
        return true
    }

    /// The lifecycle-delegate open-URL hook `FlutterAppDelegate` actually
    /// calls: it probes the *Objective-C selector* `handleOpenURLs:` on every
    /// registered delegate (`FlutterAppDelegate.mm`, `application:openURLs:`).
    /// Swift's importer renames the protocol requirement to `handleOpen(_:)`
    /// (Swift 3 omit-needless-words), but the runtime only knows the selector:
    /// a method named `handleOpen(_:)` is exported as `handleOpen:`, which the
    /// engine never probes — verified on host Swift 6.2.4 with
    /// `responds(to: Selector("handleOpenURLs:"))` (false bare, true pinned).
    /// Hence the explicit `@objc` pin; the `FlutterAppLifecycleDelegate`
    /// conformance declared below keeps the contract visible.
    @objc(handleOpenURLs:)
    public func handleOpen(_ urls: [URL]) -> Bool {
        var handled = false
        for url in urls {
            if hasMatchingSchemePrefix(url: url) {
                handled = true
                // `setInitialData: true` on purpose: on a cold launch the
                // URL arrives before the Dart isolate subscribes to
                // sharedMediaStream, so `eventSink` is nil and the live
                // event is dropped. Buffering is what getInitialSharedMedia()
                // hands back once Dart boots; the live emit still fires
                // either way, so warm and cold delivery behave the same.
                _ = handleUrl(url: url, setInitialData: true)
            }
        }
        return handled
    }

    public func application(_ application: NSApplication, open urls: [URL]) {
        for url in urls {
            if hasMatchingSchemePrefix(url: url) {
                _ = handleUrl(url: url, setInitialData: true)
            }
        }
    }

    public func application(_ sender: NSApplication, openFile filename: String) -> Bool {
        let url = URL(fileURLWithPath: filename)
        if hasMatchingSchemePrefix(url: url) {
            return handleUrl(url: url, setInitialData: false)
        }
        return false
    }

    public func application(_ sender: NSApplication, openFiles filenames: [String]) -> Bool {
        for filename in filenames {
            let url = URL(fileURLWithPath: filename)
            if hasMatchingSchemePrefix(url: url) {
                return handleUrl(url: url, setInitialData: false)
            }
        }
        return false
    }

    public func applicationDidFinishLaunching(_ notification: Notification) {
        if let userDefaults = notification.userInfo?[
            NSApplication.launchUserNotificationUserInfoKey] as? [AnyHashable: Any]
        {
            for (_, value) in userDefaults {
                if let url = value as? URL {
                    if hasMatchingSchemePrefix(url: url) {
                        _ = handleUrl(url: url, setInitialData: true)
                    }
                }
            }
        }
    }

    private func handleUrl(url: URL?, setInitialData: Bool) -> Bool {
        if let url = url {
            let appGroupId =
                (Bundle.main.object(forInfoDictionaryKey: "AppGroupId") as? String)
                ?? "group.\(Bundle.main.bundleIdentifier!)"
            let userDefaults = UserDefaults(suiteName: appGroupId)

            var sharedMedia: SharedMedia?

            let params = url.queryDictionary
            if let sharedPreferencesKey = params?["key"] {
                if let data = userDefaults?.object(forKey: sharedPreferencesKey) as? Data {
                    sharedMedia = try? JSONDecoder().decode(SharedMedia.self, from: data)
                }
            } else if url.absoluteString.hasPrefix("file://") {
                sharedMedia = SharedMedia.init(
                    attachments: [
                        SharedAttachment.init(
                            path: url.absoluteString, type: SharedAttachmentType.file)
                    ],
                    conversationIdentifier: nil,
                    content: nil,
                    speakableGroupName: nil,
                    serviceName: nil,
                    senderIdentifier: nil,
                    imageFilePath: nil,
                    subject: nil,
                    recipientIdentifiers: nil
                )
            }

            if let media = sharedMedia {
                media.attachments?.forEach { $0.path = getAbsolutePath(for: $0.path) ?? $0.path }
                latestMedia = media
                if setInitialData {
                    initialMedia = media
                }
                let map = media.toDictionary()
                eventSink?(map)
                return true
            }
        }
        latestMedia = nil
        return false
    }

    private func getAbsolutePath(for identifier: String) -> String? {
        if identifier.starts(with: "file://") {
            return identifier.replacingOccurrences(of: "file://", with: "")
        }
        return identifier
    }

    func getInitialSharedMedia(_ error: AutoreleasingUnsafeMutablePointer<FlutterError?>)
        -> SharedMedia?
    {
        let sharedMedia = initialMedia
        return sharedMedia
    }

    func recordSentMessage(
        _ media: SharedMedia?, error: AutoreleasingUnsafeMutablePointer<FlutterError?>
    ) {
        // macOS: Intent donation not implemented yet
    }

    public func resetInitialSharedMedia(_ error: AutoreleasingUnsafeMutablePointer<FlutterError?>) {
        initialMedia = nil
    }
}

// `addApplicationDelegate:` takes `NSObject<FlutterAppLifecycleDelegate>*`, so
// the declared conformance documents the plugin's lifecycle-delegate role and
// names the protocol the open-URL hook belongs to. Note every requirement of
// that protocol is `@optional`, so conformance alone does not compiler-check the
// method names — the `@objc(handleOpenURLs:)` pin above is what fixes the
// selector.
extension ZuraffaIntentsPlugin: FlutterAppLifecycleDelegate {}

extension URL {
    var queryDictionary: [String: String]? {
        guard let query = self.query else { return nil }

        var queryStrings = [String: String]()
        for pair in query.components(separatedBy: "&") {
            // A parameter may carry no "=" at all — indexing the split
            // unconditionally crashes the host on such URLs.
            let components = pair.components(separatedBy: "=")
            guard components.count > 1 else { continue }
            let key = components[0]
            let value =
                components[1]
                .replacingOccurrences(of: "+", with: " ")
                .removingPercentEncoding ?? ""
            queryStrings[key] = value
        }
        return queryStrings
    }
}
