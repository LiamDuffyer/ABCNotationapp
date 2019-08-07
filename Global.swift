import Foundation
import UIKit
import UserNotifications
import os
import LocalAuthentication
import AVFoundation
import CoreData
class Global: UIViewController {
    static let imageQuality: CGFloat = 0.0
    static let systemSound = 1322
    static let AppLink = "https://itunes.apple.com/de/app/MyInventory-App/id1475731973?l=de&ls=1&mt=8"
    static let emailAdr = "lilvovich.roza@mail.ru"
    static let website = "https://github.com/LiamDuffyer/MyInventory-App"
    static let csvFile = "inventoryAppExport.csv"
    static let pdfFile = NSLocalizedString("Inventory App Report.pdf", comment: "Inventory App Report.pdf") 
    static let keyUserName = "UserName"
    static let keyHouseName = "UserHouse"
    static let item = NSLocalizedString("Item", comment: "Item")
    static let category = NSLocalizedString("Category", comment: "Category")
    static let owner = NSLocalizedString("Owner", comment: "Owner")
    static let room = NSLocalizedString("Room", comment: "Room")
    static let brand = NSLocalizedString("Brand", comment: "Brand")
    static let price = NSLocalizedString("Price", comment: "Price")
    static let all = NSLocalizedString("All", comment: "All")
    static let ok = NSLocalizedString("OK", comment: "OK")
    static let cancel = NSLocalizedString("Cancel", comment: "Cancel")
    static let delete = NSLocalizedString("Delete", comment: "Delete")
    static let confirm = NSLocalizedString("Confirm", comment: "Confirm")
    static let dismiss = NSLocalizedString("Dismiss", comment: "Dismiss")
    static let error = NSLocalizedString("Error", comment: "Error")
    static let done = NSLocalizedString("Done", comment: "Done")
    static let none = NSLocalizedString("None", comment: "None")
    static let duplicate = NSLocalizedString("Duplicate", comment: "Duplicate")
    static let edit = NSLocalizedString("Edit", comment: "Edit")
    static let copy = NSLocalizedString("Copy", comment: "Copy")
    static let printInvoice = NSLocalizedString("Print Invoice", comment: "Print Invoice")
    static let documentNotFound = NSLocalizedString("Document not found!", comment: "Document not found")
    static let chooseDifferentName = NSLocalizedString("Please choose a different name", comment: "Please choose a different name")
    static let emailNotSent = NSLocalizedString("Email could not be sent", comment: "Email could not be sent")
    static let emailDevice = NSLocalizedString("Your device could not send email", comment: "Your device could not send email")
    static let emailConfig = NSLocalizedString("Please check your email configuration", comment: "Please check your email configuration")
    static let support = NSLocalizedString("Support", comment: "Support")
    static let takePhoto = NSLocalizedString("Take Photo", comment: "Take Photo")
    static let cameraRoll = NSLocalizedString("Camera Roll", comment: "Camera Roll")
    static let photoLibrary = NSLocalizedString("Photo Library", comment: "Photo Library")
    static let inventoryName_csv = "inventoryName"
    static let dateofPurchase_csv = "dateofPurchase"
    static let price_csv = "price"
    static let serialNumber_csv = "serialNumber"
    static let remark_csv = "remark"
    static let timeStamp_csv = "timeStamp"
    static let roomName_csv = "roomName"
    static let ownerName_csv = "ownerName"
    static let categoryName_csv = "categoryName"
    static let brandName_csv = "brandName"
    static let warranty_csv = "warranty"
    static let imageFileName_csv = "imageFileName"
    static let invoiceFileName_csv = "invoiceFileName"
    static let id_csv = "id"
    static let csvMetadata = "\(Global.inventoryName_csv),\(Global.dateofPurchase_csv),\(Global.price_csv),\(Global.serialNumber_csv),\(Global.remark_csv),\(Global.timeStamp_csv),\(Global.roomName_csv),\(Global.ownerName_csv),\(Global.categoryName_csv),\(Global.brandName_csv),\(Global.warranty_csv),\(Global.imageFileName_csv),\(Global.invoiceFileName_csv),\(Global.id_csv)\n"
    class func sendLocalNotification(title: String, subtitle: String, body: String, badge: NSNumber) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.subtitle = subtitle
        content.body = body
        content.badge = badge
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5,
                                                        repeats: false)
        let requestIdentifier = "demoNotification"
        let request = UNNotificationRequest(identifier: requestIdentifier,
                                            content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request,
                                               withCompletionHandler: { (error) in
        })
    }
    class func generateUUID() -> String{
        return UUID().uuidString
    }
    class func generateUUID() -> UUID{
        return UUID()
    }
    class func minMax(array: [Int]) -> (min: Int, max: Int)? {
        if array.isEmpty { return nil }
        var currentMin = array[0]
        var currentMax = array[0]
        for value in array[1..<array.count] {
            if value < currentMin {
                currentMin = value
            } else if value > currentMax {
                currentMax = value
            }
        }
        return (currentMin, currentMax)
    }
    class func callAppSettings(){
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else { return }
        if UIApplication.shared.canOpenURL(settingsUrl) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                })
            } else {
                UIApplication.shared.openURL(settingsUrl)
            }
        }
    }
    class func authWithTouchID(_ sender: Any) -> Bool{
        let context = LAContext()
        var error: NSError?
        var successFlag : Bool = false
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = NSLocalizedString("Authenticate with Touch ID", comment: "Authenticate with Touch ID")
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason, reply:
                {(success, error) in
                    if success {
                        os_log("Global authWithTouchID: touch ID Authentication succeeded", log: Log.viewcontroller, type: .info)
                        successFlag = true
                    }
                    else {
                        os_log("Global authWithTouchID: touch ID Authentication failed", log: Log.viewcontroller, type: .error)
                    }
            })
        }
        else {
            os_log("Global authWithTouchID: touch ID not available", log: Log.viewcontroller, type: .error)
        }
        return successFlag
    }
    class func checkCameraPermission() -> Bool{
        var allowed : Bool = true
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized: 
            allowed = true
            break
        case .notDetermined: 
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                    allowed = true
                }
            }
        case .denied: 
            allowed = false
            break
        case .restricted: 
            allowed = false
            break
        @unknown default:
            os_log("Global checkCameraPermission", log: Log.viewcontroller, type: .error)
        }
        return allowed
    }
    static func generateFilename(invname: String) -> String{
        let cal = Calendar.current
        let now = Date()
        let comps = cal.dateComponents([.day, .month, .year, .hour, .minute, .second], from: now)
        let imageName = invname + "_" + String(comps.year!) + "_" + String(comps.day!) + "_" + String(comps.month!) + "_" + String(comps.hour!) + "_" + String(comps.minute!) + "_" + String(comps.second!)
        return imageName
    }
    static func createTempDropObject(fileItems: [DropFile]) -> URL?{
        let docURL = (FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)).last as NSURL?
        let dropFilePath = docURL!.appendingPathComponent("File")!.appendingPathExtension("pdf")
        for file in fileItems {
            do {
                try file.fileData?.write(to:dropFilePath)
            } catch {
                os_log("Global createTempDropObject", log: Log.viewcontroller, type: .error)
            }
        }
        return dropFilePath
    }
    static func scaleImage (image:UIImage, width: CGFloat) -> UIImage {
        let oldWidth = image.size.width
        let scaleFactor = width / oldWidth
        let newHeight = image.size.height * scaleFactor
        let newWidth = oldWidth * scaleFactor
        UIGraphicsBeginImageContext(CGSize(width:newWidth, height:newHeight))
        image.draw(in: CGRect(x:0, y:0, width:newWidth, height:newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
    static func getRTFFileFromBundle(fileName: String) -> NSAttributedString{
        let str = "rtf file not found!"
        let attributedText = NSAttributedString(string: str)
        if let rtfPath = Bundle.main.url(forResource: fileName, withExtension: "rtf") {
            do {
                let attributedStringWithRtf: NSAttributedString = try NSAttributedString(url: rtfPath, options: [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.rtf], documentAttributes: nil)
                return attributedStringWithRtf
            } catch _ {
                os_log("AboutViewController helpButton", log: Log.viewcontroller, type: .error)
            }
        }
        return attributedText
    }
}
extension UIDevice {
    var iPhoneX: Bool {
        return UIScreen.main.nativeBounds.height == 2436
    }
    var iPhone5: Bool {
        return UIScreen.main.nativeBounds.height == 1136
    }
    var iPhone: Bool {
        return UIDevice.current.userInterfaceIdiom == .phone
    }
    enum ScreenType: String {
        case iPhones_4_4S = "iPhone 4 or iPhone 4S"
        case iPhones_5_5s_5c_SE = "iPhone 5, iPhone 5s, iPhone 5c or iPhone SE"
        case iPhones_6_6s_7_8 = "iPhone 6, iPhone 6S, iPhone 7 or iPhone 8"
        case iPhones_6Plus_6sPlus_7Plus_8Plus = "iPhone 6 Plus, iPhone 6S Plus, iPhone 7 Plus or iPhone 8 Plus"
        case iPhones_X_XS = "iPhone X or iPhone XS"
        case iPhone_XR = "iPhone XR"
        case iPhone_XSMax = "iPhone XS Max"
        case unknown
    }
    var screenType: ScreenType {
        switch UIScreen.main.nativeBounds.height {
        case 960:
            return .iPhones_4_4S
        case 1136:
            return .iPhones_5_5s_5c_SE
        case 1334:
            return .iPhones_6_6s_7_8
        case 1792:
            return .iPhone_XR
        case 1920, 2208:
            return .iPhones_6Plus_6sPlus_7Plus_8Plus
        case 2436:
            return .iPhones_X_XS
        case 2688:
            return .iPhone_XSMax
        default:
            return .unknown
        }
    }
}
extension String {
    func truncate(length: Int, trailing: String = "…") -> String {
        return (self.count > length) ? self.prefix(length) + trailing : self
    }
    var lines: [String] {
        return self.components(separatedBy: "\n")
    }
}
extension URL {
    static func createFolder(folderName: String) -> URL? {
        let fileManager = FileManager.default
        if let documentDirectory = fileManager.urls(for: .documentDirectory,
                                                    in: .userDomainMask).first {
            let folderURL = documentDirectory.appendingPathComponent(folderName)
            if !fileManager.fileExists(atPath: folderURL.path) {
                do {
                    try fileManager.createDirectory(atPath: folderURL.path,
                                                    withIntermediateDirectories: true,
                                                    attributes: nil)
                } catch {
                    print(error.localizedDescription)
                    return nil
                }
            }
            return folderURL
        }
        return nil
    }
}
extension UIApplication {
    static var appVersion: String? {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
    }
    static var appBuild: String? {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String
    }
    static var appName: String? {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String
    }
}
extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    func displayAlert(title: String, message: String, buttonText: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: buttonText, style: .default, handler: { action in
            self.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }
}
extension UIViewController {
    public func addActionSheetForiPad(actionSheet: UIAlertController) {
        if let popoverPresentationController = actionSheet.popoverPresentationController {
            popoverPresentationController.sourceView = self.view
            popoverPresentationController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popoverPresentationController.permittedArrowDirections = []
        }
    }
}
extension ImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}
