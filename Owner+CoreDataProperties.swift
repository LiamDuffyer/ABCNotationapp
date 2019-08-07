import Foundation
import CoreData
extension Owner {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Owner> {
        return NSFetchRequest<Owner>(entityName: "Owner")
    }
    @NSManaged public var ownerName: String?
    @NSManaged public var ownerInventory: NSSet?
}
extension Owner {
    @objc(addOwnerInventoryObject:)
    @NSManaged public func addToOwnerInventory(_ value: Inventory)
    @objc(removeOwnerInventoryObject:)
    @NSManaged public func removeFromOwnerInventory(_ value: Inventory)
    @objc(addOwnerInventory:)
    @NSManaged public func addToOwnerInventory(_ values: NSSet)
    @objc(removeOwnerInventory:)
    @NSManaged public func removeFromOwnerInventory(_ values: NSSet)
}
