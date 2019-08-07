import Foundation
import CoreData
@objc(Inventory)
public class Inventory: NSManagedObject {
    func stringForDateOfPurchase() -> String {
        guard let dateOfPurchase = dateOfPurchase else { return "" }
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.dateFormat = "YY-MM-DD"  
        dateFormatter.timeStyle = .none
        return dateFormatter.string(from: dateOfPurchase as Date)
    }
    func stringForDateTimeStamp() -> String {
        guard let ts = timeStamp else { return "" }
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.dateFormat = "YY-MM-DD"
        dateFormatter.timeStyle = .none
        return dateFormatter.string(from: ts as Date)
    }
    func csv() -> String {
        let coalescedInventoryName = inventoryName ?? ""
        let coalescedPrice = String(price)
        let coalescedRemark = remark ?? ""
        let coalescedSerialNumber = serialNumber ?? ""
        let coalescedWarranty = String(warranty)
        let coalescedRoomName = inventoryRoom?.roomName ?? ""
        let coalescedBrandName = inventoryBrand?.brandName ?? ""
        let coalescedOwnerName = inventoryOwner?.ownerName ?? ""
        let coalescedCategoryName = inventoryCategory?.categoryName ?? ""
        let coalescedImageFileName = imageFileName ?? ""
        let coalescedInvoiceFileName = invoiceFileName ?? ""
        let coalescedID = id?.uuidString ?? ""
        let newLine = """
        \(coalescedInventoryName),\(stringForDateOfPurchase()),\(coalescedPrice),\(coalescedSerialNumber),\(coalescedRemark),\(stringForDateTimeStamp()),\(coalescedRoomName),\(coalescedOwnerName),\(coalescedCategoryName),\(coalescedBrandName),\(coalescedWarranty),\(coalescedImageFileName),\(coalescedInvoiceFileName),\(coalescedID)\n
        """
        return newLine
    }
    func getStorageSizeinMegaBytes(inventory: Inventory) -> Double{
        var storageSize = 0.0
        if let imgSize = image?.length{
            storageSize += Double(imgSize)
        }
        if let pdfSize = invoice?.length{
            storageSize += Double(pdfSize)
        }
        storageSize += Double(MemoryLayout.size(ofValue: inventory))
        if storageSize > 0{
            return storageSize / 1024.0 / 1024.0
        }
        return 0
    }
}
