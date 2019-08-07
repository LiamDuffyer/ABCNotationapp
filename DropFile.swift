import UIKit
import MobileCoreServices
class DropFile : NSObject, NSItemProviderReading {
    let fileData:Data?
    required init(data:Data, typeIdentifier:String) {
        fileData = data
    }
    static var readableTypeIdentifiersForItemProvider: [String] {
        return [kUTTypePDF as String]
    }
    static func object(withItemProviderData data: Data, typeIdentifier: String) throws -> Self {
        return self.init(data: data, typeIdentifier: typeIdentifier)
    }
}
