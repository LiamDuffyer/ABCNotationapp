import Foundation
import CoreData
extension Inventory {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Inventory> {
        return NSFetchRequest<Inventory>(entityName: "Inventory")
    }
    @NSManaged public var dateOfPurchase: NSDate?
    @NSManaged public var image: NSData?
    @NSManaged public var imageFileName: String?
    @NSManaged public var inventoryName: String?
    @NSManaged public var invoice: NSData?
    @NSManaged public var invoiceFileName: String?
    @NSManaged public var price: Int32
    @NSManaged public var remark: String?
    @NSManaged public var serialNumber: String?
    @NSManaged public var timeStamp: NSDate?
    @NSManaged public var warranty: Int32
    @NSManaged public var id: UUID?
    @NSManaged public var inventoryBrand: Brand?
    @NSManaged public var inventoryCategory: Category?
    @NSManaged public var inventoryOwner: Owner?
    @NSManaged public var inventoryRoom: Room?
}
