import UIKit
import Foundation
import CoreData
public class CoreDataStorage {
    static let shared = CoreDataStorage()
    init(){
    }
    lazy var persistentContainer: NSPersistentContainer =
    {
        let container = NSPersistentContainer(name: "Inventory")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    func getContext() -> NSManagedObjectContext{
        return persistentContainer.viewContext
    }
    func saveContext(){
        let context = getContext()
        do {
            try context.save()
        } catch  {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }
    func saveRoom(room: Room) -> Room
    {
        let context = getContext()
        do {
            try context.save()
            return room
        } catch  {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }
    func fetchRoom(roomName: String) -> Bool{
        let context = getContext()
        let request : NSFetchRequest<Room> = Room.fetchRequest()
        request.predicate = NSPredicate(format: "roomName = %@", roomName)
        do {
            let result = try context.fetch(request)
            if result.count > 0{
                return true
            }
        } catch {
            print("Error with fetch request in fetchRoom \(error)")
        }
        return false
    }
    func fetchRoom(roomName: String) -> Room?{
        let context = getContext()
        let request : NSFetchRequest<Room> = Room.fetchRequest()
        request.fetchLimit = 1
        request.predicate = NSPredicate(format: "roomName = %@", roomName)
        do {
            let result = try context.fetch(request)
            if result.count > 0{
                return result.first
            }
        } catch {
            print("Error with fetch request in fetchRoom \(error)")
        }
        return nil
    }
    func fetchRoomIcon(roomName: String) -> Room?{
        let context = getContext()
        let request : NSFetchRequest<Room> = Room.fetchRequest()
        request.predicate = NSPredicate(format: "roomName = %@", roomName)
        do {
            let result = try context.fetch(request)
            if result.count > 0{
                return result[0]
            }
        } catch {
            print("Error with fetch request in fetchRoom \(error)")
        }
        return nil
    }
    func deleteRoom(room: Room) -> Bool{
        let context = getContext()
        context.delete(room)
        do {
            try context.save()
            return true
        } catch  {
            return false
        }
    }
    func deleteAllRooms() -> Bool{
        let context = getContext()
        let delete = NSBatchDeleteRequest(fetchRequest: Room.fetchRequest())
        do {
            try context.execute(delete)
            return true
        } catch  {
            return false
        }
    }
    func saveCategory(category: Category) -> Category
    {
        let context = getContext()
        do {
            try context.save()
            return category
        } catch  {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }
    func fetchCategory(categoryName: String) -> Bool{
        let context = getContext()
        let request : NSFetchRequest<Category> = Category.fetchRequest()
        request.predicate = NSPredicate(format: "categoryName = %@", categoryName)
        do {
            let result = try context.fetch(request)
            if result.count > 0{
                return true
            }
        } catch {
            print("Error with fetch request in fetchCategory \(error)")
        }
        return false
    }
    func fetchCategory(categoryName: String) -> Category?{
        let context = getContext()
        let request : NSFetchRequest<Category> = Category.fetchRequest()
        request.fetchLimit = 1
        request.predicate = NSPredicate(format: "categoryName = %@", categoryName)
        do {
            let result = try context.fetch(request)
            if result.count > 0{
                return result.first
            }
        } catch {
            print("Error with fetch request in fetchCategory \(error)")
        }
        return nil
    }
    func deleteCategory(category: Category) -> Bool{
        let context = getContext()
        context.delete(category)
        do {
            try context.save()
            return true
        } catch  {
            return false
        }
    }
    func deleteAllCategories() -> Bool{
        let context = getContext()
        let delete = NSBatchDeleteRequest(fetchRequest: Category.fetchRequest())
        do {
            try context.execute(delete)
            return true
        } catch  {
            return false
        }
    }
    func saveOwner(owner: Owner) -> Owner
    {
        let context = getContext()
        do {
            try context.save()
            return owner
        } catch  {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }
    func fetchOwner(ownerName: String) -> Bool{
        let context = getContext()
        let request : NSFetchRequest<Owner> = Owner.fetchRequest()
        request.predicate = NSPredicate(format: "ownerName = %@", ownerName)
        do {
            let result = try context.fetch(request)
            if result.count > 0{
                return true
            }
        } catch {
            print("Error with fetch request in fetchOwner \(error)")
        }
        return false
    }
    func fetchOwner(ownerName: String) -> Owner?{
        let context = getContext()
        let request : NSFetchRequest<Owner> = Owner.fetchRequest()
        request.fetchLimit = 1
        request.predicate = NSPredicate(format: "ownerName = %@", ownerName)
        do {
            let result = try context.fetch(request)
            if result.count > 0{
                return result.first
            }
        } catch {
            print("Error with fetch request in fetchOwner \(error)")
        }
        return nil
    }
    func deleteOwner(owner: Owner) -> Bool{
        let context = getContext()
        context.delete(owner)
        do {
            try context.save()
            return true
        } catch  {
            return false
        }
    }
    func deleteAllOwners() -> Bool{
        let context = getContext()
        let delete = NSBatchDeleteRequest(fetchRequest: Owner.fetchRequest())
        do {
            try context.execute(delete)
            return true
        } catch  {
            return false
        }
    }
    func saveBrand(brand: Brand) -> Brand
    {
        let context = getContext()
        do {
            try context.save()
            return brand
        } catch  {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }
    func fetchBrand(brandName: String) -> Bool{
        let context = getContext()
        let request : NSFetchRequest<Brand> = Brand.fetchRequest()
        request.predicate = NSPredicate(format: "brandName = %@", brandName)
        do {
            let result = try context.fetch(request)
            if result.count > 0{
                return true
            }
        } catch {
            print("Error with fetch request in fetchBrand \(error)")
        }
        return false
    }
    func fetchBrand(brandName: String) -> Brand?{
        let context = getContext()
        let request : NSFetchRequest<Brand> = Brand.fetchRequest()
        request.fetchLimit = 1
        request.predicate = NSPredicate(format: "brandName = %@", brandName)
        do {
            let result = try context.fetch(request)
            if result.count > 0{
                return result.first
            }
        } catch {
            print("Error with fetch request in fetchBrand \(error)")
        }
        return nil
    }
    func deleteBrand(brand: Brand) -> Bool{
        let context = getContext()
        context.delete(brand)
        do {
            try context.save()
            return true
        } catch  {
            return false
        }
    }
    func deleteAllBrands() -> Bool{
        let context = getContext()
        let delete = NSBatchDeleteRequest(fetchRequest: Brand.fetchRequest())
        do {
            try context.execute(delete)
            return true
        } catch  {
            return false
        }
    }
    func getInventoryUUID(uuid: UUID) -> Bool{
        let context = getContext()
        let request : NSFetchRequest<Inventory> = Inventory.fetchRequest()
        request.fetchLimit = 1
        request.predicate = NSPredicate(format: "id = %@", uuid as CVarArg)
        do {
            let result = try context.fetch(request)
            if result.count > 0{
                return true
            }
        } catch {
            print("Error with fetch request in getInventoryUUID \(error)")
        }
        return false
    }
    func saveInventory(inventory: Inventory) -> Inventory{
        let context = getContext()
        do {
            try context.save()
            return inventory
        } catch  {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }
    func saveInventory(inventoryName: String, dateOfPurchase: NSDate, price: Int32, remark: String, serialNumber: String, warranty: Int32, image: NSData, invoice: NSData, imageFileName: String, invoiceFileName: String, brand: Brand, category: Category, owner: Owner, room: Room) -> Inventory
    {
        let context = getContext()
        let inventory = Inventory(context: context)
        inventory.id = UUID()
        inventory.inventoryName = inventoryName
        inventory.dateOfPurchase = dateOfPurchase
        inventory.price = price
        inventory.remark = remark
        inventory.serialNumber = serialNumber
        inventory.warranty = warranty
        inventory.image = image;
        inventory.imageFileName = imageFileName
        inventory.invoice = invoice;
        inventory.invoiceFileName = invoiceFileName
        inventory.inventoryBrand = brand
        inventory.inventoryCategory = category
        inventory.inventoryOwner = owner
        inventory.inventoryRoom = room
        inventory.timeStamp = Date() as NSDate?
        do {
            try context.save()
            return inventory
        } catch  {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }
    func updateInventory(inventory: Inventory) -> Bool{
        let context = getContext()
        let request : NSFetchRequest<Inventory> = Inventory.fetchRequest()
        var found = false
        request.predicate = NSPredicate(format: "inventoryName = %@", inventory.inventoryName!)
        do {
            _ = try context.fetch(request)
            found = true
        } catch {
            print("Error with fetch request in updateInventory \(error)")
        }
        if(found){
            do {
                try context.save()
                return true
            } catch  {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
        return false
    }
    func deleteInventory(inventory: Inventory) -> Bool{
        let context = getContext()
        context.delete(inventory)
        do {
            try context.save()
            return true
        } catch  {
            return false
        }
    }
    func fetchAllCategories() -> [Category]
    {
        let request : NSFetchRequest<Category> = Category.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "categoryName", ascending: true)]
        let context = getContext()
        do {
            let categories = try context.fetch(request)
            return categories
        } catch {
            print("Error with fetch request in fetchAllCategories \(error)")
        }
        return []
    }
    func fetchAllBrands() -> [Brand]
    {
        let request : NSFetchRequest<Brand> = Brand.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "brandName", ascending: true)]
        let context = getContext()
        do {
            let brands = try context.fetch(request)
            return brands
        } catch {
            print("Error with fetch request in fetchAllBrands \(error)")
        }
        return []
    }
    func fetchAllOwners() -> [Owner]
    {
        let request : NSFetchRequest<Owner> = Owner.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "ownerName", ascending: true)]
        let context = getContext()
        do {
            let owners = try context.fetch(request)
            return owners
        } catch {
            print("Error with fetch request in fetchAllOwners \(error)")
        }
        return []
    }
    func fetchAllRooms() -> [Room]
    {
        let request : NSFetchRequest<Room> = Room.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "roomName", ascending: true)]
        let context = getContext()
        do {
            let rooms = try context.fetch(request)
            return rooms
        } catch {
            print("Error with fetch request in fetchAllRooms \(error)")
        }
        return []
    }
    func fetchInventory() -> [Inventory]
    {
        let request : NSFetchRequest<Inventory> = Inventory.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "inventoryName", ascending: true)]
        request.fetchBatchSize = 20
        let context = getContext()
        do {
            let inventory = try context.fetch(request)
            return inventory
        } catch {
            print("Error with fetch request in fetchInventory \(error)")
        }
        return []
    }
    func fetchInventoryByRoom(roomName: String) -> [Inventory]
    {
        let request : NSFetchRequest<Inventory> = Inventory.fetchRequest()
        request.predicate = NSPredicate(format: "inventoryRoom.roomName = %@", roomName)
        request.sortDescriptors = [NSSortDescriptor(key: "inventoryName", ascending: true)]
        let context = getContext()
        do {
            let inventory = try context.fetch(request)
            return inventory
        } catch {
            print("Error with fetch request in fetchInventoryByRoom \(error)")
        }
        return []
    }
    func generateInitialAppData()
    {
        let context = getContext()
        let notDefined = NSLocalizedString("<not defined>", comment: "<not defined>")
        let noCategory = NSLocalizedString("<no category>", comment: "<no category>")
        let noOwner = NSLocalizedString("<nobody>", comment: "<nobody>")
        let noBrand = NSLocalizedString("<other>", comment: "<other>")
        let tech = NSLocalizedString("Technics", comment: "Technics")
        let furniture = NSLocalizedString("Furniture", comment: "Furniture")
        let computer = NSLocalizedString("Computer", comment: "Computer")
        let juwelry = NSLocalizedString("Juwelry", comment: "Juwelry")
        let toy = NSLocalizedString("Toy", comment: "Toy")
        let tv = NSLocalizedString("TV", comment: "TV")
        let smartphone = NSLocalizedString("Smartphone", comment: "Smartphone")
        let tablet = NSLocalizedString("Tablet", comment: "Tablet")
        let videogame = NSLocalizedString("Video Game", comment: "Video Game")
        let livingroom = NSLocalizedString("Living room", comment: "Living room")
        let office = NSLocalizedString("Office", comment: "Office")
        let nursery1 = NSLocalizedString("Nursery 1", comment: "Nursery 1")
        let nursery2 = NSLocalizedString("Nursery 2", comment: "Nursery 2")
        let kitchen = NSLocalizedString("Kitchen", comment: "Kitchen")
        let basement1 = NSLocalizedString("Basement 1", comment: "Basement 1")
        let basement2 = NSLocalizedString("Basement 2", comment: "Basement 2")
        let bedroom = NSLocalizedString("Bedroom", comment: "Bedroom")
        let roomList: [String] = [notDefined, livingroom, office, nursery1,
                                  nursery2, kitchen, basement1, bedroom, basement2]
        var myRoomImage : UIImage
        for name in roomList{
            let room = Room(context: context)
            room.roomName = name
            switch name{
            case livingroom:
                myRoomImage = #imageLiteral(resourceName: "icons8-retro-tv-filled-50")
                break
            case bedroom:
                myRoomImage = #imageLiteral(resourceName: "icons8-bett-50")
                break
            case office:
                myRoomImage = #imageLiteral(resourceName: "icons8-arbeitsplatz-50")
                break
            case basement1, basement2:
                myRoomImage = #imageLiteral(resourceName: "icons8-keller-filled-50")
                break
            case kitchen:
                myRoomImage = #imageLiteral(resourceName: "icons8-kochtopf-50")
                break
            case nursery1, nursery2:
                myRoomImage = #imageLiteral(resourceName: "icons8-teddy-50")
                break
            default:
                myRoomImage = #imageLiteral(resourceName: "icons8-home-filled-50")
                break
            }
            let imageData = myRoomImage.jpegData(compressionQuality: 1.0)
            room.roomImage = imageData! as NSData
            _ = saveRoom(room: room)
        }
        let rooms = fetchAllRooms()
        let categoryList: [String] = [noCategory, tech, furniture, computer,
                                      juwelry, toy, tv, smartphone, tablet, videogame]
        for name in categoryList{
            let category = Category(context: context)
            category.categoryName = name
            _ = saveCategory(category: category)
        }
        let categories = fetchAllCategories()
        let ownerList: [String] = [noOwner, "Mark", "Eva", "Jennifer", "Josef"]
        for name in ownerList{
            let owner = Owner(context: context)
            owner.ownerName = name
            _ = saveOwner(owner: owner)
        }
        let owners = fetchAllOwners()
        let brandList: [String] = [noBrand, "IKEA", "Apple", "Sonos",
                                   "Thermomix", "Sony", "Google", "Amazon", "Nintendo", "KitchenAid", "Xiaomi", "Samsung"]
        for name in brandList{
            let brand = Brand(context: context)
            brand.brandName = name
            _ = saveBrand(brand: brand)
        }
        let brands = fetchAllBrands()
        let date = Date() as NSDate 
        let arr : [UInt32] = [32,4,123,4,5,2]
        let myinvoice = NSData(bytes: arr, length: arr.count * 32)
        let imageSpeaker = UIImage(named: "Speaker")
        let imageSpeakerData = imageSpeaker?.jpegData(compressionQuality: 1.0)
        let imageThermo = UIImage(named: "Thermo")
        let imageThermoData = imageThermo?.jpegData(compressionQuality: 1.0)
        let imageKitchen = UIImage(named: "Kitchen")
        let imageKitchenData = imageKitchen?.jpegData(compressionQuality: 1.0)
        let imageToaster = UIImage(named: "Toaster")
        let imageToasterData = imageToaster?.jpegData(compressionQuality: 1.0)
        let imageGame = UIImage(named: "Game")
        let imageGameData = imageGame?.jpegData(compressionQuality: 1.0)
        let remark = NSLocalizedString("Remark", comment: "Remark") + " " + String(Int.random(in: 1...100))
        let serial = NSLocalizedString("Serial no.", comment: "Serial no.") + " " + String(Int.random(in: 1...100)) + "N" + String(Int.random(in: 1...100)) + "Z" + String(Int.random(in: 1...100))
        _ = saveInventory(inventoryName: NSLocalizedString("Kitchen Helper", comment: "Kitchen Helper"), dateOfPurchase: date, price: Int32(699), remark: remark, serialNumber: serial, warranty: 12, image: imageKitchenData! as NSData, invoice: myinvoice, imageFileName: "", invoiceFileName: "", brand: brands[5], category: categories[8], owner: owners[2], room: rooms[6])
        _ = saveInventory(inventoryName: NSLocalizedString("Toaster", comment: "Toaster"), dateOfPurchase: date, price: Int32(200), remark: remark, serialNumber: serial, warranty: 12, image: imageToasterData! as NSData, invoice: myinvoice, imageFileName: "", invoiceFileName: "", brand: brands[5], category: categories[8], owner: owners[2], room: rooms[6])
        _ = saveInventory(inventoryName: NSLocalizedString("Game", comment: "Game"), dateOfPurchase: date, price: Int32(35), remark: remark, serialNumber: serial, warranty: 12, image: imageGameData! as NSData, invoice: myinvoice, imageFileName: "", invoiceFileName: "", brand: brands[0], category: categories[9], owner: owners[1], room: rooms[2])
        _ = saveInventory(inventoryName: NSLocalizedString("Wizzard", comment: "Wizzard"), dateOfPurchase: date, price: Int32(1190), remark: remark, serialNumber: serial, warranty: 24, image: imageThermoData! as NSData, invoice: myinvoice, imageFileName: "", invoiceFileName: "", brand: brands[10], category: categories[8], owner: owners[2], room: rooms[6])
        _ = saveInventory(inventoryName: NSLocalizedString("Speaker", comment: "Speaker"), dateOfPurchase: date, price: Int32(199), remark: remark, serialNumber: serial, warranty: 24, image: imageSpeakerData! as NSData, invoice: myinvoice, imageFileName: "", invoiceFileName: "", brand: brands[8], category: categories[8], owner: owners[3], room: rooms[2])
    }
    func showSampleData()
    {
        let inventory = fetchInventory()
        let rooms = fetchAllRooms()
        print ("count rooms:\(rooms.count)")
        let categories = fetchAllCategories()
        print ("count categories:\(categories.count)")
        let owners = fetchAllOwners()
        print ("count owners:\(owners.count)")
        let brands = fetchAllBrands()
        print ("count brands:\(brands.count)")
        for i in inventory{
            print("Inventory = \(i.inventoryName!), Room: \(String(describing: i.inventoryRoom?.roomName))), Category: \(String(describing: i.inventoryCategory?.categoryName))) , Owner: \(String(describing: i.inventoryOwner?.ownerName)), Brand: \(String(describing: i.inventoryBrand?.brandName)) ")
        }
        for j in rooms{
            print("Room = \(j.roomName!)")
        }
        for k in categories{
            print("Category = \(k.categoryName!)")
        }
        for l in brands{
            print("Brand = \(l.brandName!)")
        }
        for m in owners{
            print("Owner = \(m.ownerName!)")
        }
        let invWohn = fetchInventoryByRoom(roomName: "Living room")
        print ("count items in living room: \(invWohn.count)")
    }
}
