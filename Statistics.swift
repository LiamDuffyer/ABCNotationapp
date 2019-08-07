import Foundation
import os
class Statistics: NSObject{
    static let shared = Statistics()
    var setup: String
    var inventory: [Inventory]
    var images: Int {
        var numberOfImages = 0
        for inv in inventory{
            if inv.image != nil{
                numberOfImages += 1
            }
        }
        return numberOfImages
    }
    var pdfs: Int {
        var numberOfpdf = 0
        for inv in inventory{
            if inv.invoice != nil{
                numberOfpdf += 1
            }
        }
        return numberOfpdf
    }
    override init() {
        self.setup = "setup"
        let store = CoreDataStorage.shared
        self.inventory = store.fetchInventory()
    }
    func getStatisticsForImages() -> Double{
        var sum : Double = 0.0
        for inv in inventory{
            if let size = inv.image?.length{
                sum += Double(size)
            }
        }
        return sum
    }
    func getInventoryItemCount() -> Int{
        return inventory.count
    }
    public func getInventorySizeinMegaBytes() -> Double{
        var storageSize = 0.0
        for inv in inventory{
            if let imgSize = inv.image?.length{
                storageSize += Double(imgSize)
            }
            if let pdfSize = inv.invoice?.length{
                storageSize += Double(pdfSize)
            }
            storageSize += Double(MemoryLayout.size(ofValue: inv))
        }
        if storageSize > 0{
            return storageSize / 1024.0 / 1024.0
        }
        return 0.0
    }
    public func itemPricesSum() -> Int{
        var sum = 0
        for inv in inventory{
            sum += Int(inv.price)
        }
        return sum
    }
    public func refresh(){
        let store = CoreDataStorage.shared
        self.inventory = store.fetchInventory()
    }
    func countItemsByRoomDict() -> [(key: String, value: Int)]{
        var arr : [String] = []
        for inv in inventory{
            arr.append(inv.inventoryRoom?.roomName ?? "")
        }
        let dict = arr.reduce(into: [:]) { counts, word in counts[word, default: 0] += 1 }
        return dict.sorted { $0.value > $1.value }
    }
    func countItemsByOwnerDict() -> [(key: String, value: Int)]{
        var arr : [String] = []
        for inv in inventory{
            arr.append(inv.inventoryOwner?.ownerName ?? "")
        }
        let dict = arr.reduce(into: [:]) { counts, word in counts[word, default: 0] += 1 }
        return dict.sorted { $0.value > $1.value }
    }
    func countItemsByCategoryDict() -> [(key: String, value: Int)]{
        var arr : [String] = []
        for inv in inventory{
            arr.append(inv.inventoryCategory?.categoryName ?? "")
        }
        let dict = arr.reduce(into: [:]) { counts, word in counts[word, default: 0] += 1 }
        return dict.sorted { $0.value > $1.value }
    }
    func countItemsByBrandDict() -> [(key: String, value: Int)]{
        var arr : [String] = []
        for inv in inventory{
            arr.append(inv.inventoryBrand?.brandName ?? "")
        }
        let dict = arr.reduce(into: [:]) { counts, word in counts[word, default: 0] += 1 }
        return dict.sorted { $0.value > $1.value }
    }
    func allInventory(elementsCount: Int) -> [Inventory]{
        return inventory.first(elementCount: elementsCount)
    }
    func mostExpensiveItems(elementsCount: Int) -> [Inventory]{
        if inventory.count > 0{
            let sortedByPrice = inventory.sorted(by: {$0.price > $1.price})
            return sortedByPrice.first(elementCount: elementsCount)
        }
        return []
    }
}
extension Array {
    func first(elementCount: Int) -> Array {
        let min = Swift.min(elementCount, count)
        return Array(self[0..<min])
    }
}
