//
//  ShareIntentIosViewController.swift
//  Pods
//
//  Created by Josh Juncker on 7/7/22.
//

import Contacts
import Intents
import MobileCoreServices
import Photos
import Social
import UIKit

@available(iOS 14.0, *)
@available(iOSApplicationExtension 14.0, *)
open class ShareIntentIosViewController: UIViewController {
    static var hostAppBundleIdentifier = ""
    static var appGroupId = ""
    let sharedKey = "ShareKey"
    var sharedText: [String] = []
    let imageContentType = UTType.image.identifier
    let movieContentType = UTType.movie.identifier
    let textContentType = UTType.text.identifier
    let urlContentType = UTType.url.identifier
    let fileURLType = UTType.fileURL.identifier
    let dataContentType = UTType.data.identifier
    var sharedAttachments: [SharedAttachment] = []
    var usedFileNames: Set<String> = []
    lazy var userDefaults: UserDefaults = {
        return UserDefaults(suiteName: ShareIntentIosViewController.appGroupId)!
    }()

    public func loadIds() {
        // loading Share extension App Id
        let shareExtensionAppBundleIdentifier = Bundle.main.bundleIdentifier!

        // convert ShareExtension id to host app id
        // By default it is remove last part of id after last point
        // For example: com.test.ShareExtension -> com.test
        let lastIndexOfPoint = shareExtensionAppBundleIdentifier.lastIndex(of: ".")
        ShareIntentIosViewController.hostAppBundleIdentifier = String(
            shareExtensionAppBundleIdentifier[..<lastIndexOfPoint!])

        // loading custom AppGroupId from Build Settings or use group.<hostAppBundleIdentifier>
        ShareIntentIosViewController.appGroupId =
            (Bundle.main.object(forInfoDictionaryKey: "AppGroupId") as? String)
            ?? "group.\(ShareIntentIosViewController.hostAppBundleIdentifier)"
    }

    open override func viewDidLoad() {
        super.viewDidLoad()

        // load group and app id from build info
        loadIds()
        Task {
            await handleInputItems()
        }
    }

    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    func handleInputItems() async {
        // Guarded access: an extension point that delivers no (or late)
        // input items must not crash the process on the force-unwrapped
        // [0] subscript — see the intent-throw note in saveSharedMedia().
        let items = extensionContext?.inputItems ?? []
        if let content = items.first as? NSExtensionItem {
            if let contents = content.attachments {
                for (index, attachment) in (contents).enumerated() {
                    do {
                        if attachment.hasItemConformingToTypeIdentifier(imageContentType) {
                            try await handleImages(
                                content: content, attachment: attachment, index: index)
                        } else if attachment.hasItemConformingToTypeIdentifier(movieContentType) {
                            try await handleVideos(
                                content: content, attachment: attachment, index: index)
                        } else if attachment.hasItemConformingToTypeIdentifier(fileURLType) {
                            try await handleFiles(
                                content: content, attachment: attachment, index: index)
                        } else if attachment.hasItemConformingToTypeIdentifier(urlContentType) {
                            try await handleUrl(
                                content: content, attachment: attachment, index: index)
                        } else if attachment.hasItemConformingToTypeIdentifier(textContentType) {
                            try await handleText(
                                content: content, attachment: attachment, index: index)
                        } else if attachment.hasItemConformingToTypeIdentifier(dataContentType) {
                            try await handleData(
                                content: content, attachment: attachment, index: index)
                        } else {
                            print(
                                "Attachment not handled with registered type identifiers: \(attachment.registeredTypeIdentifiers)"
                            )
                        }
                    } catch {
                        self.dismissWithError()
                    }

                }
            }
            // Save shared data to UserDefaults and open host app.
            // Do NOT call completeRequest here — the URL open causes an app
            // switch, and calling completeRequest during that switch leaves the
            // source app's dismiss overlay stuck. The system will terminate this
            // extension when the app switches.
            redirectToHostApp()
        } else {
            // Explicit failure path. Returning silently would leave the share
            // sheet on screen with no feedback at all — the user stares at a
            // dead sheet, which is harder to diagnose than the loud crash the
            // guard above replaced.
            dismissWithError()
        }
    }

    public func getNewFileUrl(fileName: String) -> URL {
        let newFileUrl = FileManager.default
            .containerURL(
                forSecurityApplicationGroupIdentifier: ShareIntentIosViewController.appGroupId)!
            .appendingPathComponent(fileName)
        return newFileUrl
    }

    public func handleText(content: NSExtensionItem, attachment: NSItemProvider, index: Int)
        async throws
    {
        let data = try await attachment.loadItem(forTypeIdentifier: textContentType, options: nil)

        if let item = data as? String {
            sharedText.append(item)
        } else {
            if let d = data as? Data {
                do {
                    let contacts = try CNContactVCardSerialization.contacts(with: d)
                    for contact in contacts {
                        let data = try CNContactVCardSerialization.data(with: [contact])
                        let str = String(data: data, encoding: .utf8)!
                        sharedText.append(str)
                    }
                } catch {
                    dismissWithError()
                }
            } else {
                dismissWithError()
            }
        }
    }

    public func handleUrl(content: NSExtensionItem, attachment: NSItemProvider, index: Int)
        async throws
    {
        let data = try await attachment.loadItem(forTypeIdentifier: urlContentType, options: nil)

        if let item = data as? URL {
            sharedText.append(item.absoluteString)
        } else {
            dismissWithError()
        }

    }

    public func handleImages(content: NSExtensionItem, attachment: NSItemProvider, index: Int)
        async throws
    {
        let data = try await attachment.loadItem(forTypeIdentifier: imageContentType, options: nil)

        var fileName: String?
        var imageData: Data?
        var sourceUrl: URL?
        if let url = data as? URL {
            fileName = getFileName(from: url, type: .image)
            sourceUrl = url
        } else if let iData = data as? Data {
            var baseName = UUID().uuidString + ".png"
            var counter = 1
            while usedFileNames.contains(baseName) {
                baseName = UUID().uuidString + ".png"
                counter += 1
            }
            fileName = baseName
            usedFileNames.insert(baseName)
            imageData = iData
        } else if let image = data as? UIImage {
            var baseName = UUID().uuidString + ".png"
            var counter = 1
            while usedFileNames.contains(baseName) {
                baseName = UUID().uuidString + ".png"
                counter += 1
            }
            fileName = baseName
            usedFileNames.insert(baseName)
            imageData = image.pngData()
        }

        if let _fileName = fileName {
            let newFileUrl = getNewFileUrl(fileName: _fileName)
            do {
                if FileManager.default.fileExists(atPath: newFileUrl.path) {
                    try FileManager.default.removeItem(at: newFileUrl)
                }
            } catch {
                print("Error removing item")
            }

            var copied: Bool = false
            if let _data = imageData {
                copied = FileManager.default.createFile(atPath: newFileUrl.path, contents: _data)
            } else if let _sourceUrl = sourceUrl {
                copied = copyFile(at: _sourceUrl, to: newFileUrl)
            }

            if copied {
                sharedAttachments.append(
                    SharedAttachment.init(path: newFileUrl.absoluteString, type: .image))
            } else {
                dismissWithError()
                return
            }

        } else {
            dismissWithError()
            return
        }

    }

    public func handleVideos(content: NSExtensionItem, attachment: NSItemProvider, index: Int)
        async throws
    {
        let data = try await attachment.loadItem(forTypeIdentifier: movieContentType, options: nil)

        if let url = data as? URL {

            // Always copy
            let fileName = getFileName(from: url, type: .video)
            let newFileUrl = getNewFileUrl(fileName: fileName)
            let copied = copyFile(at: url, to: newFileUrl)
            if copied {
                sharedAttachments.append(
                    SharedAttachment.init(path: newFileUrl.absoluteString, type: .video))
            }
        } else {
            dismissWithError()
        }

    }

    public func handleFiles(content: NSExtensionItem, attachment: NSItemProvider, index: Int)
        async throws
    {
        let data = try await attachment.loadItem(forTypeIdentifier: fileURLType, options: nil)

        if let url = data as? URL {

            // Always copy
            let fileName = getFileName(from: url, type: .file)
            let newFileUrl = getNewFileUrl(fileName: fileName)
            let copied = copyFile(at: url, to: newFileUrl)
            if copied {
                sharedAttachments.append(
                    SharedAttachment.init(path: newFileUrl.absoluteString, type: .file))
            }
        } else {
            dismissWithError()
        }

    }

    public func handleData(content: NSExtensionItem, attachment: NSItemProvider, index: Int)
        async throws
    {
        let data = try await attachment.loadItem(forTypeIdentifier: dataContentType, options: nil)

        if let url = data as? URL {

            // Always copy
            let fileName = getFileName(from: url, type: .file)
            let newFileUrl = getNewFileUrl(fileName: fileName)
            let copied = copyFile(at: url, to: newFileUrl)
            if copied {
                sharedAttachments.append(
                    SharedAttachment.init(path: newFileUrl.absoluteString, type: .file))
            }
        } else {
            dismissWithError()
        }

    }

    public func dismissWithError() {
        print("[ERROR] Error loading data!")
        let alert = UIAlertController(
            title: "Error", message: "Error loading data", preferredStyle: .alert)

        let action = UIAlertAction(title: "Error", style: .cancel) { _ in
            self.dismiss(animated: true, completion: nil)
        }

        alert.addAction(action)
        present(alert, animated: true, completion: nil)
        // Nil-tolerant on purpose: the intake guards above now accept a nil
        // extensionContext, so the error path must not turn that tolerance
        // into a second force-unwrap crash.
        extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
    }

    public func redirectToHostApp() {
        // ids may not loaded yet so we need loadIds here too
        loadIds()

        // Save shared data to UserDefaults
        saveSharedMedia()

        // Open the host app via URL scheme.
        // completeRequest is called from the openURL completion handler so
        // the source app only receives the dismiss signal after the app
        // switch has completed — this prevents the gray overlay from getting
        // stuck.
        openHostAppUrl()
    }

    private func saveSharedMedia() {
        // NSExtensionContext.intent THROWS from extension points that don't
        // declare it — an uncaught ObjC exception (SIGSEGV; faulting frame
        // "-[NSExtensionContext(ShareExtension) intent]" under
        // saveSharedMedia) that killed a consumer's Action extension on
        // every tap on iOS 26, because the property is documented only for
        // the Share/Intents extension points (arrrrny/zik_zak#893, fixed
        // there in arrrrny/zik_zak#892). Read the extension point from THIS
        // bundle's Info.plist — the context object exposes no property for
        // it — and call `.intent` only on the share point; every other
        // extension point passes nil intent (the fields it feeds were nil
        // for those flows anyway).
        //
        // NSExtensionPointIdentifier is a CHILD of the NSExtension dictionary
        // (Information Property List → NSExtension →
        // NSExtensionPointIdentifier), so a flat lookup alone returns nil on a
        // stock extension Info.plist — that would make isSharePoint false in
        // every extension and silently drop the intent metadata this guard
        // exists to preserve. The flat key stays as a fallback for
        // hand-flattened Info.plists.
        let extensionInfo = Bundle.main.object(forInfoDictionaryKey: "NSExtension")
            as? [String: Any]
        let extensionPoint = (extensionInfo?["NSExtensionPointIdentifier"] as? String)
            ?? Bundle.main.object(forInfoDictionaryKey: "NSExtensionPointIdentifier")
                as? String
        // The scope is deliberate: only the share extension point declares
        // `intent`. An Intents extension point (com.apple.intents-service /
        // com.apple.intents-ui-service) hosting this controller is NOT in the
        // allowlist and receives a nil intent by design.
        let isSharePoint = extensionPoint == "com.apple.share-services"
        let intent = isSharePoint
            ? self.extensionContext?.intent as? INSendMessageIntent
            : nil

        let conversationIdentifier = intent?.conversationIdentifier
        let sender = intent?.sender
        let serviceName = intent?.serviceName
        let speakableGroupName = intent?.speakableGroupName

        // Guarded access: an extension point that delivers no (or late)
        // input items must not crash the process on the [0] subscript —
        // same crash family as the intent throw above.
        let extensionItem = extensionContext?.inputItems.first as? NSExtensionItem
        let subject = extensionItem?.attributedContentText?.string

        let sharedMedia = SharedMedia.init(
            attachments: sharedAttachments, conversationIdentifier: conversationIdentifier,
            content: sharedText.joined(separator: "\n"),
            speakableGroupName: speakableGroupName?.spokenPhrase, serviceName: serviceName,
            senderIdentifier: sender?.contactIdentifier ?? sender?.customIdentifier,
            imageFilePath: nil, subject: subject, recipientIdentifiers: nil)

        guard let json = sharedMedia.toJson() else {
            print("failed to encode SharedMedia")
            return
        }

        userDefaults.set(json, forKey: sharedKey)
        userDefaults.synchronize()
    }

    private func openHostAppUrl() {
        loadIds()
        guard
            let url = URL(
                string:
                    "ShareMedia-\(ShareIntentIosViewController.hostAppBundleIdentifier)://\(ShareIntentIosViewController.hostAppBundleIdentifier)?key=\(sharedKey)"
            )
        else { return }

        var responder = self as UIResponder?
        while responder != nil {
            if let application = responder as? UIApplication {
                application.open(url, options: [:]) { [weak self] _ in
                    // Call completeRequest AFTER the URL open has triggered the
                    // app switch. This way the source app only processes the
                    // extension dismissal after the host app is in the foreground,
                    // preventing the gray overlay from getting stuck.
                    self?.extensionContext?.completeRequest(
                        returningItems: [], completionHandler: nil)
                }
                return
            }
            responder = responder?.next
        }

        // Fallback: no UIApplication found in responder chain
        extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
    }

    enum RedirectType {
        case media
        case text
        case file
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

    func getFileName(from url: URL, type: SharedAttachmentType) -> String {
        var name = url.lastPathComponent

        if name.isEmpty {
            name = UUID().uuidString + "." + getExtension(from: url, type: type)
        }

        // Check if filename already exists and append counter if needed
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

        // Track this filename
        usedFileNames.insert(finalName)

        return finalName
    }

    func copyFile(at srcURL: URL, to dstURL: URL) -> Bool {
        do {
            // Since we now ensure unique filenames, we don't need to delete existing files
            // But check just in case and delete if needed
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
