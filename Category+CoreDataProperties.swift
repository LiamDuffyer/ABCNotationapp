import Foundation
import CoreData
extension Category {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Category> {
        return NSFetchRequest<Category>(entityName: "Category")
    }
    @NSManaged public var categoryName: String?
    @NSManaged public var categoryInventory: NSSet?
}
extension Category {
    @objc(addCategoryInventoryObject:)
    @NSManaged public func addToCategoryInventory(_ value: Inventory)
    @objc(removeCategoryInventoryObject:)
    @NSManaged public func removeFromCategoryInventory(_ value: Inventory)
    @objc(addCategoryInventory:)
    @NSManaged public func addToCategoryInventory(_ values: NSSet)
    @objc(removeCategoryInventory:)
    @NSManaged public func removeFromCategoryInventory(_ values: NSSet)
}
