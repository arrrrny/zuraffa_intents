import AppKit
import Foundation
import UniformTypeIdentifiers

@available(macOS 11.0, *)
@available(macOSApplicationExtension 11.0, *)
open class ShareIntentMacosViewController: NSViewController {
    static var hostAppBundleIdentifier = ""
    static var appGroupId = ""
    let sharedKey = "ShareKey"
    var sharedText: [String] = []
    let urlContentType = UTType.url.identifier
    let fileURLType = UTType.fileURL.identifier
    let textContentType = UTType.text.identifier
    var sharedAttachments: [SharedAttachment] = []
    var usedFileNames: Set<String> = []
    lazy var userDefaults: UserDefaults = {
        return UserDefaults(suiteName: ShareIntentMacosViewController.appGroupId)!
    }()

    public func loadIds() {
        let shareExtensionAppBundleIdentifier = Bundle.main.bundleIdentifier!

        let lastIndexOfPoint = shareExtensionAppBundleIdentifier.lastIndex(of: ".")
        ShareIntentMacosViewController.hostAppBundleIdentifier = String(
            shareExtensionAppBundleIdentifier[..<lastIndexOfPoint!])

        // An empty-string AppGroupId is as broken as a missing one: the ??
        // fallback only fires on nil, and UserDefaults(suiteName: "") returns
        // nil (the lazy userDefaults force-unwrap would trap), so empty and
        // missing both take the fallback here.
        if let configured = Bundle.main.object(forInfoDictionaryKey: "AppGroupId") as? String,
            !configured.isEmpty
        {
            ShareIntentMacosViewController.appGroupId = configured
        } else {
            ShareIntentMacosViewController.appGroupId =
                "group.\(ShareIntentMacosViewController.hostAppBundleIdentifier)"
            print(
                "[zuraffa_intents] AppGroupId missing or empty in Info.plist — the group.<bundle-id> fallback is iOS-shaped and will not resolve on macOS (App Group ids need the Team ID prefix)"
            )
        }
    }

    open override func viewDidLoad() {
        super.viewDidLoad()
        loadIds()
        Task {
            await handleInputItems()
        }
    }

    func handleInputItems() async {
        if let content = extensionContext!.inputItems[0] as? NSExtensionItem {
            if let contents = content.attachments {
                for (index, attachment) in (contents).enumerated() {
                    do {
                        // public.file-url conforms to public.url, so the
                        // file check MUST come first: with the url check
                        // first, every shared file matches the url branch,
                        // is handled as text, and the App Group copy in
                        // handleFiles is never reached (the iOS controller
                        // checks files first for the same reason).
                        if attachment.hasItemConformingToTypeIdentifier(fileURLType) {
                            try await handleFiles(
                                content: content, attachment: attachment, index: index)
                        } else if attachment.hasItemConformingToTypeIdentifier(urlContentType) {
                            try await handleUrl(
                                content: content, attachment: attachment, index: index)
                        } else if attachment.hasItemConformingToTypeIdentifier(textContentType) {
                            try await handleText(
                                content: content, attachment: attachment, index: index)
                        } else {
                            print(
                                "Attachment not handled with registered type identifiers: \(attachment.registeredTypeIdentifiers)"
                            )
                        }
                    } catch {
                        print("[ERROR] Error handling attachment: \(error)")
                    }
                }
            }
            redirectToHostApp()
        }
    }

    public func handleText(content: NSExtensionItem, attachment: NSItemProvider, index: Int)
        async throws
    {
        let data = try await attachment.loadItem(forTypeIdentifier: textContentType, options: nil)
        if let item = data as? String {
            sharedText.append(item)
        }
    }

    public func handleUrl(content: NSExtensionItem, attachment: NSItemProvider, index: Int)
        async throws
    {
        let data = try await attachment.loadItem(forTypeIdentifier: urlContentType, options: nil)
        if let item = data as? URL {
            // Some senders register a file URL under public.url without
            // public.file-url; the branch order alone would let those slip
            // through as text. Route real file URLs through the same App
            // Group copy — a raw sender path must never cross into the host.
            if item.isFileURL {
                if let destinationURL = copySharedFile(at: item) {
                    sharedAttachments.append(
                        SharedAttachment.init(path: destinationURL.absoluteString, type: .file))
                }
            } else {
                sharedText.append(item.absoluteString)
            }
        }
    }

    public func handleFiles(content: NSExtensionItem, attachment: NSItemProvider, index: Int)
        async throws
    {
        // loadFileRepresentation (not loadItem): the provider vends a
        // coordinated copy the extension is guaranteed to read, and the
        // returned URL is only valid inside this completion handler — so the
        // copy into the App Group container happens here, before the block
        // returns and the temporary URL disappears.
        let copiedURL: URL? = try await withCheckedThrowingContinuation {
            (continuation: CheckedContinuation<URL?, Error>) in
            attachment.loadFileRepresentation(forTypeIdentifier: fileURLType) {
                tempURL, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                guard let tempURL = tempURL else {
                    continuation.resume(returning: nil)
                    return
                }
                continuation.resume(returning: self.copySharedFile(at: tempURL))
            }
        }

        if let destinationURL = copiedURL {
            sharedAttachments.append(
                SharedAttachment.init(path: destinationURL.absoluteString, type: .file))
        }
    }

    /// Copies a shared file into the App Group container while the extension
    /// still holds the provider's transient sandbox grant, returning the
    /// copied URL — or nil when the container or the copy is unavailable.
    func copySharedFile(at sourceURL: URL) -> URL? {
        let fileName = getFileName(from: sourceURL, type: .file)
        guard let destinationURL = getNewFileUrl(fileName: fileName) else {
            return nil
        }
        return copyFile(at: sourceURL, to: destinationURL) ? destinationURL : nil
    }

    public func getNewFileUrl(fileName: String) -> URL? {
        // On macOS the App Group identifier must carry the Team ID prefix
        // (e.g. "2D3QTPZG5J.group.dev.zuzu.zuraffa") and both the host app
        // and this extension must list it in their
        // com.apple.security.application-groups entitlements. When the
        // AppGroupId Info.plist entry is missing or unprefixed,
        // containerURL returns nil here — fail loudly and skip the
        // attachment instead of crashing the extension mid-share.
        guard
            let groupURL = FileManager.default.containerURL(
                forSecurityApplicationGroupIdentifier:
                    ShareIntentMacosViewController.appGroupId)
        else {
            print(
                "[zuraffa_intents] cannot resolve App Group container for \"\(ShareIntentMacosViewController.appGroupId)\" — set AppGroupId in Info.plist to the team-prefixed macOS group id and add the com.apple.security.application-groups entitlement"
            )
            return nil
        }
        return groupURL.appendingPathComponent(fileName)
    }

    public func redirectToHostApp() {
        loadIds()

        let sharedMedia = SharedMedia.init(
            attachments: sharedAttachments,
            conversationIdentifier: nil,
            content: sharedText.joined(separator: "\n"),
            speakableGroupName: nil,
            serviceName: nil,
            senderIdentifier: nil,
            imageFilePath: nil,
            subject: nil,
            recipientIdentifiers: nil
        )

        guard let json = sharedMedia.toJson() else {
            print("failed to encode SharedMedia")
            return
        }
        userDefaults.set(json, forKey: sharedKey)
        userDefaults.synchronize()

        guard
            let url = URL(
                string:
                    "ShareMedia-\(ShareIntentMacosViewController.hostAppBundleIdentifier)://\(ShareIntentMacosViewController.hostAppBundleIdentifier)?key=\(sharedKey)"
            )
        else {
            extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
            return
        }

        // Open the host app URL and call completeRequest from the completion
        // handler so the source app only processes the dismissal after the
        // host app has launched.
        NSWorkspace.shared.open(url, configuration: NSWorkspace.OpenConfiguration()) {
            [weak self] _, _ in
            self?.extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
        }
    }

    func getFileName(from url: URL, type: SharedAttachmentType) -> String {
        var name = url.lastPathComponent
        if name.isEmpty {
            name = UUID().uuidString + "." + getExtension(from: url, type: type)
        }

        var finalName = name
        var counter = 1
        while usedFileNames.contains(finalName) {
            let nameWithoutExtension = (name as NSString).deletingPathExtension
            let fileExtension = (name as NSString).pathExtension
            if fileExtension.isEmpty {
                finalName = "\(nameWithoutExtension) (\(counter))"
            } else {
                finalName = "\(nameWithoutExtension) (\(counter)).\(fileExtension)"
            }
            counter += 1
        }
        usedFileNames.insert(finalName)
        return finalName
    }

    func getExtension(from url: URL, type: SharedAttachmentType) -> String {
        let parts = url.lastPathComponent.components(separatedBy: ".")
        var ex: String? = nil
        if parts.count > 1 {
            ex = parts.last
        }
        if ex == nil {
            switch type {
            case .image:
                ex = "PNG"
            case .video:
                ex = "MP4"
            case .file:
                ex = "TXT"
            default:
                ex = ""
            }
        }
        return ex ?? "Unknown"
    }

    func copyFile(at srcURL: URL, to dstURL: URL) -> Bool {
        do {
            if FileManager.default.fileExists(atPath: dstURL.path) {
                try FileManager.default.removeItem(at: dstURL)
            }
            try FileManager.default.copyItem(at: srcURL, to: dstURL)
        } catch (let error) {
            print("Cannot copy item at \(srcURL) to \(dstURL): \(error)")
            return false
        }
        return true
    }
}
