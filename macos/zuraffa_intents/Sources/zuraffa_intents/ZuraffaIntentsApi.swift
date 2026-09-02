import Foundation
import FlutterMacOS
import zuraffa_intents_models

private func wrapResult(_ result: Any?, _ error: FlutterError?) -> [String : Any?]? {
    var errorDict: [String : Any]?
    if let error = error {
        errorDict = [
            "code": error.code ,
            "message": error.message ?? NSNull(),
            "details": error.details ?? NSNull()
        ]
    }
    return ["result": result, "error": errorDict]
}

class ZuraffaIntentsApiCodecReader: FlutterStandardReader {
    override func readValue(ofType type: UInt8) -> Any? {
        switch type {
        case 128:
            return SharedAttachment.fromMap(map: self.readValue() as? Dictionary<String, Any?>)
        case 129:
            return SharedMedia.fromMap(map: self.readValue() as? Dictionary<String, Any?>)
        case 130:
            return SharedMedia.fromMap(map: self.readValue() as? Dictionary<String, Any?>)
        default:
            return super.readValue(ofType: type)
        }
    }
}

class ZuraffaIntentsApiCodecWriter: FlutterStandardWriter {
    override func writeValue(_ value: Any) {
        if let _value = value as? SharedAttachment {
            self.writeByte(128)
            self.writeValue(_value.toDictionary())
        } else if let _value = value as? SharedMedia {
            self.writeByte(129)
            self.writeValue(_value.toDictionary())
        } else if let _value = value as? SharedMedia {
            self.writeByte(130)
            self.writeValue(_value.toDictionary())
        } else {
            super.writeValue(value)
        }
    }
}

class ZuraffaIntentsApiCodecReaderWriter: FlutterStandardReaderWriter {
    override func writer(with data: NSMutableData) -> FlutterStandardWriter {
        return ZuraffaIntentsApiCodecWriter.init(data: data)
    }

    override func reader(with data: Data) -> FlutterStandardReader {
        ZuraffaIntentsApiCodecReader.init(data: data)
    }
}

let ZuraffaIntentsApiGetCodecSSharedObject: FlutterStandardMessageCodec = {
    var sSharedObject = FlutterStandardMessageCodec(readerWriter: ZuraffaIntentsApiCodecReaderWriter())
    return sSharedObject
}()

func ZuraffaIntentsApiGetCodec() -> (NSObjectProtocol & FlutterMessageCodec) {
    return ZuraffaIntentsApiGetCodecSSharedObject
}

protocol ZuraffaIntentsApi: AnyObject {
    func getInitialSharedMedia(_ error: AutoreleasingUnsafeMutablePointer<FlutterError?>) -> SharedMedia?
    func recordSentMessage(_ media: SharedMedia?, error: AutoreleasingUnsafeMutablePointer<FlutterError?>)
    func resetInitialSharedMedia(_ error: AutoreleasingUnsafeMutablePointer<FlutterError?>)
}

func ZuraffaIntentsApiSetup(_ binaryMessenger: FlutterBinaryMessenger, _ api: (NSObjectProtocol & ZuraffaIntentsApi)) {
    do {
        let channel = FlutterBasicMessageChannel(
            name: "dev.flutter.pigeon.ZuraffaIntentsApi.getInitialSharedMedia",
            binaryMessenger: binaryMessenger,
            codec: ZuraffaIntentsApiGetCodec())

        channel.setMessageHandler() { (message, callback) -> () in
            var error: FlutterError?
            let output = api.getInitialSharedMedia(&error)
            callback(wrapResult(output?.toDictionary(), error))
        }
    }
    do {
        let channel = FlutterBasicMessageChannel(
            name: "dev.flutter.pigeon.ZuraffaIntentsApi.recordSentMessage",
            binaryMessenger: binaryMessenger,
            codec: ZuraffaIntentsApiGetCodec())

        channel.setMessageHandler() { (message, callback) -> () in
            var media: SharedMedia?
            if let args = message as? NSArray {
                media = args[0] as? SharedMedia
            }
            var error: FlutterError?

            api.recordSentMessage(media, error: &error)

            callback(wrapResult(nil, error))
        }
    }
    do {
        let channel = FlutterBasicMessageChannel(
            name: "dev.flutter.pigeon.ZuraffaIntentsApi.resetInitialSharedMedia",
            binaryMessenger: binaryMessenger,
            codec: ZuraffaIntentsApiGetCodec())

        channel.setMessageHandler() { (message, callback) -> () in
            var error: FlutterError?
            api.resetInitialSharedMedia(&error)
            callback(wrapResult(nil, error))
        }
    }
}
