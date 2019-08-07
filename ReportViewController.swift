import UIKit
import PDFKit
import CoreData
import MessageUI
import os
private let store = CoreDataStorage.shared
class ReportViewController: UIViewController, MFMailComposeViewControllerDelegate, UIPopoverPresentationControllerDelegate {
    @IBOutlet weak var paperFormatSegment: UISegmentedControl!
    @IBOutlet weak var sortOrderSegment: UISegmentedControl!
    @IBOutlet weak var pdfView: PDFView!
    @IBOutlet weak var roomsSegment: UISegmentedControl!
    @IBOutlet weak var ownersSegment: UISegmentedControl!
    @IBOutlet weak var roomFilterLabel: UILabel!
    @IBOutlet weak var ownerFilterLabel: UILabel!
    @IBOutlet weak var shareActionBarButton: UIBarButtonItem!
    @IBOutlet weak var emailActionButton: UIBarButtonItem!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var helpButton: UIButton!
    @IBOutlet weak var imageSwitch: UISwitch!
    var rooms : [Room] = []
    var brands : [Brand] = []
    var owners : [Owner] = []
    var categories : [Category] = []
    var all : String = ""
    enum PaperSize {
        case dinA4
        case usLetter
    }
    var url : URL?
    var currentPaperSize = PaperSize.dinA4
    enum SortOrder : String{
        case item = "inventoryName"
        case category = "inventoryCategory.categoryName"
        case owner = "inventoryOwner.ownerName"
        case room = "inventoryRoom.roomName"
    }
    var currentSortOrder = SortOrder.item
    let kvStore = NSUbiquitousKeyValueStore()
    var paperWidth = 0.0
    var paperHeight = 0.0
    var pageNumber_pos_x = 0.0
    var pageNumber_pos_y = 0.0
    var title_pos_x = 0.0
    var title_pos_y = 0.0
    var title_height = 0.0
    var title_width = 0.0
    let dinA4Width = 595.2
    let dinA4Height = 841.8
    let usLetterWidth = 612.0
    let usLetterHeight = 792.0
    let columnWidth = 110.0
    let columnHeight = 20.0
    let columnWidthItem = 130.0
    let columnWidthCategory = 90.0
    let columnWidthPrice = 60.0
    let columnWidthRoom = 90.0
    let columnWidthOwner = 90.0
    let columnWidthBrand = 90.0
    let contentsBegin = 50.0
    let leftMargin = 30.0
    let rightMargin = 30.0
    var footer_pos_x = 0.0
    var footer_pos_y = 0.0
    let logoSizeHeight = 35.0
    let logoSizeWidth = 35.0
    let logoPosX = 30.0
    let logoPosY = 10.0
    let imageSizeWidth = 30.0
    let imageSizeHeight = 30.0
    var results: [Inventory] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.contentSize = CGSize(width: self.view.frame.width, height: self.view.frame.height+500)
        all = Global.all
        roomsSegment.tintColor = themeColorUIControls
        ownersSegment.tintColor = themeColorUIControls
        sortOrderSegment.tintColor = themeColorUIControls
        paperFormatSegment.tintColor = themeColorUIControls
        shareActionBarButton.tintColor =  themeColorUIControls
        emailActionButton.tintColor = themeColorUIControls
        imageSwitch.tintColor = themeColorUIControls
        imageSwitch.onTintColor = themeColorUIControls
        if #available(iOS 11.0, *) {
            self.navigationItem.largeTitleDisplayMode = .never
            self.navigationItem.largeTitleDisplayMode = .always
        }
        navigationController?.navigationBar.prefersLargeTitles = true
        self.title = NSLocalizedString("Reports", comment: "Reports")
        let segmentDinA4 = NSLocalizedString("DIN A4", comment: "DIN A4")
        let segmentUsLetter = NSLocalizedString("US Letter", comment: "US Letter")
        replaceSegmentContents(segments: [segmentDinA4, segmentUsLetter], control: paperFormatSegment)
        paperFormatSegment.selectedSegmentIndex = 0 
        replaceSegmentContents(segments: [Global.item, Global.category, Global.owner, Global.room], control: sortOrderSegment)
        sortOrderSegment.selectedSegmentIndex = 0 
        pdfInit()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        rooms = store.fetchAllRooms()
        brands = store.fetchAllBrands()
        owners = store.fetchAllOwners()
        categories = store.fetchAllCategories()
        var listOwners :[String] = []
        var listRooms :[String] = []
        let allOwners = all
        listOwners.append(allOwners)
        for owner in owners{
            listOwners.append((owner.ownerName)!)
        }
        replaceSegmentContents(segments: listOwners, control: ownersSegment)
        ownersSegment.selectedSegmentIndex = 0
        let allRooms = all
        listRooms.append(allRooms)
        for room in rooms{
            listRooms.append((room.roomName)!)
        }
        replaceSegmentContents(segments: listRooms, control: roomsSegment)
        roomsSegment.selectedSegmentIndex = 0
        roomFilterLabel.text = listRooms.first
        ownerFilterLabel.text = listOwners.first
        pdfViewGestureWhenTapped()
        fetchData()
        pdfCreateInventoryReport()
    }
    func replaceSegmentContents(segments: Array<String>, control: UISegmentedControl) {
        control.removeAllSegments()
        for segment in segments {
            control.insertSegment(withTitle: segment, at: control.numberOfSegments, animated: false)
        }
    }
    private func inventoryFetchRequest(sortOrder: String, filterWhere: String, filterCompare1: String, filterCompare2: String) -> NSFetchRequest<Inventory> {
        let request:NSFetchRequest<Inventory> = Inventory.fetchRequest()
        if(filterWhere.count > 0){
            request.predicate = NSPredicate(format: filterWhere, filterCompare1, filterCompare2)
        }
        request.fetchBatchSize = 20
        request.sortDescriptors = [NSSortDescriptor(key: sortOrder, ascending: true)]
        return request
    }
    private func inventoryFetchRequest(sortOrder: String, filterWhere: String, filterCompare: String) -> NSFetchRequest<Inventory> {
        let request:NSFetchRequest<Inventory> = Inventory.fetchRequest()
        if(filterWhere.count > 0){
            request.predicate = NSPredicate(format: filterWhere, filterCompare)
        }
        request.fetchBatchSize = 20
        request.sortDescriptors = [NSSortDescriptor(key: sortOrder, ascending: true)]
        return request
    }
    func fetchData(){
        let context = store.getContext()
        if ownerFilterLabel.text! != all && roomFilterLabel.text! != all{
            let filterWhere = "inventoryOwner.ownerName == %@ && inventoryRoom.roomName == %@"
            let filterCompare1 = ownerFilterLabel.text!
            let filterCompare2 = roomFilterLabel.text!
            do {
                results = try context.fetch(self.inventoryFetchRequest(sortOrder: currentSortOrder.rawValue, filterWhere: filterWhere, filterCompare1: filterCompare1, filterCompare2: filterCompare2))
            } catch{
                os_log("ReportViewController context.fetch", log: Log.viewcontroller, type: .error)
            }
        }
        else{
            if ownerFilterLabel.text! == all && roomFilterLabel.text! != all{
                let filterWhere = "inventoryRoom.roomName == %@"
                let filterCompare = roomFilterLabel.text!
                do {
                    results = try context.fetch(self.inventoryFetchRequest(sortOrder: currentSortOrder.rawValue, filterWhere: filterWhere, filterCompare: filterCompare))
                } catch{
                    os_log("ReportViewController context.fetch", log: Log.viewcontroller, type: .error)
                }
            }
            else{
                if ownerFilterLabel.text! == all && roomFilterLabel.text! == all{
                    let filterWhere = ""
                    let filterCompare = ""
                    do {
                        results = try context.fetch(self.inventoryFetchRequest(sortOrder: currentSortOrder.rawValue, filterWhere: filterWhere, filterCompare: filterCompare))
                    } catch{
                        os_log("ReportViewController context.fetch", log: Log.viewcontroller, type: .error)
                    }
                }
                else{
                    let filterWhere = "inventoryOwner.ownerName == %@"
                    let filterCompare = String(ownerFilterLabel.text!)
                    do {
                        results = try context.fetch(self.inventoryFetchRequest(sortOrder: currentSortOrder.rawValue, filterWhere: filterWhere, filterCompare: filterCompare))
                    } catch{
                        os_log("ReportViewController context.fetch", log: Log.viewcontroller, type: .error)
                    }
                }
            }
        }
    }
    func sharePdf(path: URL) {
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: path.path) {
            let activityViewController: UIActivityViewController = UIActivityViewController(activityItems: [path], applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = self.view
            self.present(activityViewController, animated: true, completion: nil)
        } else {
            os_log("ReportViewController sharePdf", log: Log.viewcontroller, type: .error)
            let alertController = UIAlertController(title: Global.error, message: Global.documentNotFound, preferredStyle: .alert)
            let defaultAction = UIAlertAction.init(title: Global.ok, style: UIAlertAction.Style.default, handler: nil)
            alertController.addAction(defaultAction)
            navigationController!.present(alertController, animated: true, completion: nil)
        }
    }
    @IBAction func imageSwitch(_ sender: UISwitch) {
        fetchData()
        pdfCreateInventoryReport()
    }
    @IBAction func emailActionButton(_ sender: UIBarButtonItem) {
        sendPDFEmail()
    }
    @IBAction func shareActionBarButton(_ sender: UIBarButtonItem) {
        sharePdf(path: url!)
    }
    @IBAction func roomsSegmentAction(_ sender: UISegmentedControl) {
        roomFilterLabel.text = roomsSegment.titleForSegment(at: roomsSegment.selectedSegmentIndex)
        fetchData()
        pdfCreateInventoryReport()
    }
    @IBAction func ownersSegmentAction(_ sender: UISegmentedControl) {
        ownerFilterLabel.text = ownersSegment.titleForSegment(at: ownersSegment.selectedSegmentIndex)
        fetchData()
        pdfCreateInventoryReport()
    }
    @IBAction func paperFormatSegmentAction(_ sender: UISegmentedControl) {
        switch paperFormatSegment.selectedSegmentIndex
        {
        case 0:
            currentPaperSize = .dinA4
            fetchData()
            pdfCreateInventoryReport()
        case 1:
            currentPaperSize = .usLetter
            fetchData()
            pdfCreateInventoryReport()
        default:
            break
        }
    }
    @IBAction func sortOrderSegmentAction(_ sender: UISegmentedControl) {
        switch sortOrderSegment.selectedSegmentIndex
        {
        case 0:
            currentSortOrder = .item
        case 1:
            currentSortOrder = .category
        case 2:
            currentSortOrder = .owner
        case 3:
            currentSortOrder = .room
        default:
            break
        }
        fetchData()
        pdfCreateInventoryReport()
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == "fullscreenPDF" {
            let destination =  segue.destination as! PDFViewController
            destination.currentPDF = pdfView
            destination.currentTitle = NSLocalizedString("Inventory Report (PDF)", comment: "Inventory Report (PDF)")
            destination.currentPath = url
        }
        if segue.identifier == "reportPopover"{
            if let dest = segue.destination as? PopupViewController,
                let popPC = dest.popoverPresentationController,
                let btn = sender as? UIButton
            {
                popPC.permittedArrowDirections = [.up]
                popPC.sourceRect = btn.bounds
                popPC.delegate = self
                var fileName : String
                switch Local.currentLocaleForDate(){
                case "de_DE", "de_AT", "de_CH", "de":
                    fileName = "Reportview Help German"
                    break
                default: 
                    fileName = "Reportview Help English"
                    break
                }
                dest.myText = Global.getRTFFileFromBundle(fileName: fileName)
            }
        }
    }
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    func pdfInit(){
        switch (currentPaperSize){
        case .dinA4:
            paperWidth = dinA4Width
            paperHeight = dinA4Height
            pageNumber_pos_x = dinA4Width - 140.0
            pageNumber_pos_y = dinA4Height - 20
            title_pos_x = leftMargin
            title_pos_y = 20.0
            title_width = 500.0
            title_height = 30.0
            footer_pos_x = leftMargin
            footer_pos_y = dinA4Height - 20.0
            break
        case .usLetter:
            paperWidth = usLetterWidth
            paperHeight = usLetterHeight
            pageNumber_pos_x = usLetterWidth - 140.0
            pageNumber_pos_y = usLetterHeight - 20
            title_pos_x = leftMargin
            title_pos_y = 20.0
            title_width = 500.0
            title_height = 30.0
            footer_pos_x = leftMargin
            footer_pos_y = usLetterHeight - 20.0
            break
        }
    }
    func pdfImageLogo(){
        let image = UIImage(named: "InventorySplash.jpg")
        image!.draw(in: CGRect(x: logoPosX, y: logoPosY, width: logoSizeHeight, height: logoSizeWidth))
    }
    func pdfImageForIntenvory(xPos: Double, yPos: Double, imageData: NSData?){
        guard (imageData != nil) else{
            return
        }
        if let image = UIImage(data: imageData! as Data, scale: 0.1){
            image.draw(in: CGRect(x: xPos, y: yPos, width: imageSizeWidth, height: imageSizeHeight))
        }
    }
    func pdfSummaryPage(numberOfRows: Int, context: UIGraphicsRendererContext){
        var y : Double
        let summary = NSLocalizedString("Summary", comment: "Summary")
        pdfPageTitleHeading(title: summary, fontSize: 25.0, context: context)
        pdfPageUserInfo(userName: UserInfo.userName, address: UserInfo.addressName)
        y = contentsBegin
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .left
        let font = UIFont(name: "HelveticaNeue", size: 15.0)
        let attributes = [
            NSAttributedString.Key.paragraphStyle: paragraphStyle,
            NSAttributedString.Key.font: font,
            NSAttributedString.Key.foregroundColor: UIColor.black
        ]
        y = y + 15
        var sortOrderText : String
        switch (currentSortOrder){
        case .item:
            sortOrderText = NSLocalizedString("Sorted by item", comment: "Sorted by item")
            break
        case .owner:
            sortOrderText = NSLocalizedString("Sorted by owner", comment: "Sorted by owner")
            break
        case .category:
            sortOrderText = NSLocalizedString("Sorted by category", comment: "Sorted by category")
            break
        case .room:
            sortOrderText = NSLocalizedString("Sorted by room", comment: "Sorted by room")
            break
        }
        let printSortOrder = sortOrderText as NSString
        printSortOrder.draw(in: CGRect(x: title_pos_x, y: y, width: title_width, height: title_height), withAttributes: attributes as [NSAttributedString.Key : Any])
        y = y + 30
        let tmp = NSLocalizedString("Room filter applied", comment: "Room filter applied")
        if roomFilterLabel.text == Global.all{
            let printRoomFilter = tmp + ": " + Global.none as NSString
            printRoomFilter.draw(in: CGRect(x: title_pos_x, y: y, width: title_width, height: title_height), withAttributes: attributes as [NSAttributedString.Key : Any])
        }
        else{
            let printRoomFilter = tmp + ": " + roomFilterLabel.text! as NSString
            printRoomFilter.draw(in: CGRect(x: title_pos_x, y: y, width: title_width, height: title_height), withAttributes: attributes as [NSAttributedString.Key : Any])
        }
        y = y + 30
        let tmp2 = NSLocalizedString("Owner filter applied", comment: "Owner filter applied")
        if ownerFilterLabel.text == Global.all{
            let printOwnerFilter = tmp2 + ": " + Global.none as NSString
            printOwnerFilter.draw(in: CGRect(x: title_pos_x, y: y, width: title_width, height: title_height), withAttributes: attributes as [NSAttributedString.Key : Any])
        }
        else{
            let printOwnerFilter = tmp2 + ": " + ownerFilterLabel.text! as NSString
            printOwnerFilter.draw(in: CGRect(x: title_pos_x, y: y, width: title_width, height: title_height), withAttributes: attributes as [NSAttributedString.Key : Any])
        }
        y = y + 30
        let tmp3 = NSLocalizedString("Number of inventory items", comment: "Number of inventory item")
        let numberOfRowsText = tmp3 + ": " + String(numberOfRows)
        numberOfRowsText.draw(in: CGRect(x: title_pos_x, y: y, width: title_width, height: title_height), withAttributes: attributes as [NSAttributedString.Key : Any])
        y = y + 30
        let stat = Statistics.shared
        let sum = stat.itemPricesSum()
        let tmp4 = NSLocalizedString("Amount of money spent on items", comment: "Amount of money spent on items")
        let priceSumText = tmp4 + ": " + String(sum) + Local.currencySymbol!
        priceSumText.draw(in: CGRect(x: title_pos_x, y: y, width: title_width, height: title_height), withAttributes: attributes as [NSAttributedString.Key : Any])
        y = y + 30
        let tmp5 = NSLocalizedString("Database size used for images, pdf files etc.", comment: "Database size")
        let storageText = tmp5 + ": " + String(format: "%.2f", Statistics.shared.getInventorySizeinMegaBytes()) + " MB"
        storageText.draw(in: CGRect(x: title_pos_x, y: y, width: title_width, height: title_height), withAttributes: attributes as [NSAttributedString.Key : Any])
        y = y + 30
        let (key, value) = Statistics.shared.countItemsByRoomDict().first ?? ("", 0)
        let roomString = key + ", " + String(value) + " " + NSLocalizedString("Items", comment: "Items")
        let tmp6 = NSLocalizedString("Room with most items in", comment: "Room with most items in")
        let roomItemsText = tmp6 + ": " + roomString
        roomItemsText.draw(in: CGRect(x: title_pos_x, y: y, width: title_width, height: title_height), withAttributes: attributes as [NSAttributedString.Key : Any])
        y = y + 30
        let mostExpensiveItem = Statistics.shared.mostExpensiveItems(elementsCount: 1)
        if mostExpensiveItem.count > 0{
            let tmp7 = NSLocalizedString("Most expensive item", comment: "Most expensive item")
            let mostExp = tmp7 + ": " + mostExpensiveItem[0].inventoryName! + ", " + String(mostExpensiveItem[0].price) + Local.currencySymbol!
            mostExp.draw(in: CGRect(x: title_pos_x, y: y, width: title_width, height: title_height), withAttributes: attributes as [NSAttributedString.Key : Any])
        }
        y = y + 30
        let appInfoText = NSLocalizedString("Provided by", comment: "Provided by") + ": " + UIApplication.appName! + " " + UIApplication.appVersion! + " (" + UIApplication.appBuild! + ")"
        appInfoText.draw(in: CGRect(x: title_pos_x, y: y, width: title_width, height: title_height), withAttributes: attributes as [NSAttributedString.Key : Any])
    }
    func pdfPageUserInfo(userName: String, address: String){
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .right
        let font = UIFont(name: "HelveticaNeue", size: 8.0)
        let attributes = [
            NSAttributedString.Key.paragraphStyle: paragraphStyle,
            NSAttributedString.Key.font: font,
            NSAttributedString.Key.foregroundColor: UIColor.black
        ]
        let userText = NSLocalizedString("User", comment: "User")
        let addressText = NSLocalizedString("Address", comment: "Address")
        let text1 = userText + ": " + userName + ", " + addressText + ": " + address
        let text = text1 as NSString
        text.draw(in: CGRect(x: paperWidth - 250 - leftMargin, y: title_pos_y + 15, width: 250, height: 20), withAttributes: attributes as [NSAttributedString.Key : Any])
    }
    func pdfPageTitleHeading(title: String, fontSize: CGFloat, context: UIGraphicsRendererContext){
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .left
        let font = UIFont(name: "HelveticaNeue-Bold", size: fontSize)
        let attributes = [
            NSAttributedString.Key.paragraphStyle: paragraphStyle,
            NSAttributedString.Key.font: font,
            NSAttributedString.Key.foregroundColor: UIColor.black
        ]
        let text = title as NSString
        text.draw(in: CGRect(x: title_pos_x + logoSizeWidth + 10, y: title_pos_y, width: title_width, height: title_height), withAttributes: attributes as [NSAttributedString.Key : Any])
        context.cgContext.setStrokeColor(UIColor.black.cgColor)
        context.cgContext.setLineWidth(2)
        context.cgContext.move(to: CGPoint(x: leftMargin, y: 20 + title_height))
        context.cgContext.addLine(to: CGPoint(x: paperWidth - rightMargin, y: 20 + title_height))
        context.cgContext.drawPath(using: .fillStroke)
    }
    func pdfPageNumber(pageNumber: Int){
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .right
        let font = UIFont(name: "HelveticaNeue", size: 8.0)
        let attributes = [
            NSAttributedString.Key.paragraphStyle: paragraphStyle,
            NSAttributedString.Key.font: font,
            NSAttributedString.Key.foregroundColor: UIColor.black
        ]
        let page = NSLocalizedString("Page", comment: "Page")
        let text = page + " " + String(pageNumber) as NSString
        text.draw(in: CGRect(x: pageNumber_pos_x, y: pageNumber_pos_y - 5, width: 110, height: 20), withAttributes: attributes as [NSAttributedString.Key : Any])
    }
    func pdfPageFooter(footerText: String, context: UIGraphicsRendererContext){
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .left
        let font = UIFont(name: "HelveticaNeue", size: 8.0)
        let attributes = [
            NSAttributedString.Key.paragraphStyle: paragraphStyle,
            NSAttributedString.Key.font: font,
            NSAttributedString.Key.foregroundColor: UIColor.black
        ]
        let text = footerText as NSString
        text.draw(in: CGRect(x: footer_pos_x, y: footer_pos_y - 5, width: 300, height: 10), withAttributes: attributes as [NSAttributedString.Key : Any])
        context.cgContext.setStrokeColor(UIColor.black.cgColor)
        context.cgContext.setLineWidth(2)
        context.cgContext.move(to: CGPoint(x: footer_pos_x, y: paperHeight - 30))
        context.cgContext.addLine(to: CGPoint(x: paperWidth - rightMargin, y: footer_pos_y - 10))
        context.cgContext.drawPath(using: .fillStroke)
    }
    func itemColumn(xPos: Double, yPos: Double, text: String) -> Double{
        let x = leftMargin
        var stringRect = CGRect(x: 0, y: 0, width: 0, height: 0) 
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .left
        let font = UIFont(name: "HelveticaNeue-Bold", size: 10.0)
        let attributes = [
            NSAttributedString.Key.paragraphStyle: paragraphStyle,
            NSAttributedString.Key.font: font,
            NSAttributedString.Key.foregroundColor: UIColor.black
        ]
        stringRect = CGRect(x: xPos, y: yPos, width: columnWidthItem, height: columnHeight)
        let textToDraw = text
        textToDraw.draw(in: stringRect, withAttributes: attributes as [NSAttributedString.Key : Any])
        return x + columnWidthItem
    }
    func pdfTableHeader(context: UIGraphicsRendererContext){
        var y = 0.0 
        var x = 0.0 
        var stringRect = CGRect(x: 0, y: 0, width: 0, height: 0) 
        var text = ""
        y = contentsBegin + 15
        x = leftMargin
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .left
        let font = UIFont(name: "HelveticaNeue-Bold", size: 10.0)
        let attributes = [
            NSAttributedString.Key.paragraphStyle: paragraphStyle,
            NSAttributedString.Key.font: font,
            NSAttributedString.Key.foregroundColor: UIColor.black
        ]
        switch (currentSortOrder){
        case .item:
            x = itemColumn(xPos: x, yPos: y, text: Global.item)
            stringRect = CGRect(x: x, y: y, width: columnWidthOwner, height: columnHeight)
            text = Global.owner
            text.draw(in: stringRect, withAttributes: attributes as [NSAttributedString.Key : Any])
            x = x + columnWidthOwner
            stringRect = CGRect(x: x, y: y, width: columnWidthRoom, height: columnHeight)
            text = Global.room
            text.draw(in: stringRect, withAttributes: attributes as [NSAttributedString.Key : Any])
            x = x + columnWidthRoom
            stringRect = CGRect(x: x, y: y, width: columnWidthCategory, height: columnHeight)
            text = Global.category
            text.draw(in: stringRect, withAttributes: attributes as [NSAttributedString.Key : Any])
            x = x + columnWidthCategory
            stringRect = CGRect(x: x, y: y, width: columnWidthBrand, height: columnHeight)
            text = Global.brand
            text.draw(in: stringRect, withAttributes: attributes as [NSAttributedString.Key : Any])
            x = x + columnWidthBrand
            stringRect = CGRect(x: x, y: y, width: columnWidthRoom, height: columnHeight)
            text = Global.price
            text.draw(in: stringRect, withAttributes: attributes as [NSAttributedString.Key : Any])
            x = x + columnWidthPrice
            break
        case .owner:
            stringRect = CGRect(x: x, y: y, width: columnWidthOwner, height: columnHeight)
            text = Global.owner
            text.draw(in: stringRect, withAttributes: attributes as [NSAttributedString.Key : Any])
            x = x + columnWidthOwner
            stringRect = CGRect(x: x, y: y, width: columnWidthItem, height: columnHeight)
            text = Global.item
            text.draw(in: stringRect, withAttributes: attributes as [NSAttributedString.Key : Any])
            x = x + columnWidthItem
            stringRect = CGRect(x: x, y: y, width: columnWidthRoom, height: columnHeight)
            text = Global.room
            text.draw(in: stringRect, withAttributes: attributes as [NSAttributedString.Key : Any])
            x = x + columnWidthRoom
            stringRect = CGRect(x: x, y: y, width: columnWidthCategory, height: columnHeight)
            text = Global.category
            text.draw(in: stringRect, withAttributes: attributes as [NSAttributedString.Key : Any])
            x = x + columnWidthCategory
            stringRect = CGRect(x: x, y: y, width: columnWidthBrand, height: columnHeight)
            text = Global.brand
            text.draw(in: stringRect, withAttributes: attributes as [NSAttributedString.Key : Any])
            x = x + columnWidthBrand
            stringRect = CGRect(x: x, y: y, width: columnWidthRoom, height: columnHeight)
            text = Global.price
            text.draw(in: stringRect, withAttributes: attributes as [NSAttributedString.Key : Any])
            x = x + columnWidthPrice
            break
        case .category:
            stringRect = CGRect(x: x, y: y, width: columnWidthCategory, height: columnHeight)
            text = Global.category
            text.draw(in: stringRect, withAttributes: attributes as [NSAttributedString.Key : Any])
            x = x + columnWidthCategory
            stringRect = CGRect(x: x, y: y, width: columnWidthItem, height: columnHeight)
            text = Global.item
            text.draw(in: stringRect, withAttributes: attributes as [NSAttributedString.Key : Any])
            x = x + columnWidthItem
            stringRect = CGRect(x: x, y: y, width: columnWidthOwner, height: columnHeight)
            text = Global.owner
            text.draw(in: stringRect, withAttributes: attributes as [NSAttributedString.Key : Any])
            x = x + columnWidthOwner
            stringRect = CGRect(x: x, y: y, width: columnWidthRoom, height: columnHeight)
            text = Global.room
            text.draw(in: stringRect, withAttributes: attributes as [NSAttributedString.Key : Any])
            x = x + columnWidthRoom
            stringRect = CGRect(x: x, y: y, width: columnWidthBrand, height: columnHeight)
            text = Global.brand
            text.draw(in: stringRect, withAttributes: attributes as [NSAttributedString.Key : Any])
            x = x + columnWidthBrand
            stringRect = CGRect(x: x, y: y, width: columnWidthRoom, height: columnHeight)
            text = Global.price
            text.draw(in: stringRect, withAttributes: attributes as [NSAttributedString.Key : Any])
            x = x + columnWidthPrice
            break
        case .room:
            stringRect = CGRect(x: x, y: y, width: columnWidthRoom, height: columnHeight)
            text = Global.room
            text.draw(in: stringRect, withAttributes: attributes as [NSAttributedString.Key : Any])
            x = x + columnWidthRoom
            stringRect = CGRect(x: x, y: y, width: columnWidthItem, height: columnHeight)
            text = Global.item
            text.draw(in: stringRect, withAttributes: attributes as [NSAttributedString.Key : Any])
            x = x + columnWidthItem
            stringRect = CGRect(x: x, y: y, width: columnWidthOwner, height: columnHeight)
            text = Global.owner
            text.draw(in: stringRect, withAttributes: attributes as [NSAttributedString.Key : Any])
            x = x + columnWidthOwner
            stringRect = CGRect(x: x, y: y, width: columnWidthCategory, height: columnHeight)
            text = Global.category
            text.draw(in: stringRect, withAttributes: attributes as [NSAttributedString.Key : Any])
            x = x + columnWidthCategory
            stringRect = CGRect(x: x, y: y, width: columnWidthBrand, height: columnHeight)
            text = Global.brand
            text.draw(in: stringRect, withAttributes: attributes as [NSAttributedString.Key : Any])
            x = x + columnWidthBrand
            stringRect = CGRect(x: x, y: y, width: columnWidthRoom, height: columnHeight)
            text = Global.price
            text.draw(in: stringRect, withAttributes: attributes as [NSAttributedString.Key : Any])
            x = x + columnWidthPrice
            break
        }
        x = leftMargin
        context.cgContext.setStrokeColor(UIColor.black.cgColor)
        context.cgContext.setLineWidth(1)
        context.cgContext.move(to: CGPoint(x: leftMargin, y: 48 + title_height))
        context.cgContext.addLine(to: CGPoint(x: (5.0 * columnWidth), y: 48 + title_height))
        context.cgContext.drawPath(using: .fillStroke)
    }
    func pdfSave(_ pdf: Data) -> URL{
        var docURL = (FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)).last as NSURL?
        docURL = docURL?.appendingPathComponent(Global.pdfFile) as NSURL?
        do {
            try pdf.write(to: docURL! as URL, options: .atomic)
        } catch {
            os_log("ReportViewController pdfSave error", log: Log.viewcontroller, type: .error)
        }
        return docURL! as URL
    }
    func pdfCreateInventoryReport(){
        var y = 0.0 
        var x = 0.0 
        var stringRect = CGRect(x: 0, y: 0, width: 0, height: 0) 
        let paragraphStyle = NSMutableParagraphStyle() 
        paragraphStyle.alignment = .left
        let font = UIFont(name: "HelveticaNeue", size: 10.0) 
        var text = ""
        let attributes = [
            NSAttributedString.Key.paragraphStyle: paragraphStyle,
            NSAttributedString.Key.font: font,
            NSAttributedString.Key.foregroundColor: UIColor.black
        ]
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = [ kCGPDFContextAuthor as String : UIApplication.appName! ]      
        format.documentInfo = [ kCGPDFContextCreator as String : UIApplication.appName! ]
        format.documentInfo = [ kCGPDFContextTitle as String: UIApplication.appName! ]         
        let renderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: paperWidth, height: paperHeight), format: format)
        let dateformatter = DateFormatter()
        dateformatter.locale = Locale(identifier: Local.currentLocaleForDate())
        dateformatter.dateStyle = DateFormatter.Style.short
        dateformatter.timeStyle = DateFormatter.Style.short
        let now = dateformatter.string(from: Date())
        let tmp = NSLocalizedString("generated by Inventory App (c) 2019 Marcus Deuß", comment: "generated by Inventory App (c) 2019 Marcus Deuß")
        let footerText = tmp + ", " + now
        var paperPrintableRows : Int
        switch (currentPaperSize){
        case .dinA4:
            paperPrintableRows = 19
            break
        case .usLetter:
            paperPrintableRows = 18
            break
        }
        var numberOfPages = 0
        let pdf = renderer.pdfData { (context) in
            context.beginPage()
            numberOfPages += 1
            pdfImageLogo()
            let title = NSLocalizedString("Inventory Report", comment: "Inventory Report")
            pdfPageTitleHeading(title: title, fontSize: 25.0, context: context)
            pdfPageUserInfo(userName: UserInfo.userName, address: UserInfo.addressName)
            y = contentsBegin
            pdfTableHeader(context: context)
            y = y + 15
            var numberOfRows = 0
            for inv in results{
                y = y + 35 
                numberOfRows += 1
                x = leftMargin
                switch (currentSortOrder){
                case .item:
                    stringRect = CGRect(x: x, y: y, width: columnWidthItem, height: columnHeight)
                    text = inv.inventoryName!.truncate(length: 14)
                    text.draw(in: stringRect, withAttributes: attributes as [NSAttributedString.Key : Any])
                    x = x + columnWidthItem
                    stringRect = CGRect(x: x, y: y, width: columnWidthOwner, height: columnHeight)
                    text = inv.inventoryOwner!.ownerName!
                    text.draw(in: stringRect, withAttributes: attributes as [NSAttributedString.Key : Any])
                    x = x + columnWidthOwner
                    stringRect = CGRect(x: x, y: y, width: columnWidthRoom, height: columnHeight)
                    text = inv.inventoryRoom!.roomName!
                    text.draw(in: stringRect, withAttributes: attributes as [NSAttributedString.Key : Any])
                    x = x + columnWidthRoom
                    stringRect = CGRect(x: x, y: y, width: columnWidthCategory, height: columnHeight)
                    text = inv.inventoryCategory!.categoryName!
                    text.draw(in: stringRect, withAttributes: attributes as [NSAttributedString.Key : Any])
                    x = x + columnWidthCategory
                    stringRect = CGRect(x: x, y: y, width: columnWidthBrand, height: columnHeight)
                    text = inv.inventoryBrand!.brandName!
                    text.draw(in: stringRect, withAttributes: attributes as [NSAttributedString.Key : Any])
                    x = x + columnWidthBrand
                    stringRect = CGRect(x: x, y: y, width: columnWidthRoom, height: columnHeight)
                    text = String(inv.price) + Local.currencySymbol!
                    text.draw(in: stringRect, withAttributes: attributes as [NSAttributedString.Key : Any])
                    x = x + columnWidthPrice
                    if imageSwitch.isOn{
                        pdfImageForIntenvory(xPos: columnWidthItem - imageSizeWidth + 20, yPos: y, imageData: inv.image)
                    }
                    break
                case .owner:
                    stringRect = CGRect(x: x, y: y, width: columnWidthOwner, height: columnHeight)
                    text = inv.inventoryOwner!.ownerName!
                    text.draw(in: stringRect, withAttributes: attributes as [NSAttributedString.Key : Any])
                    x = x + columnWidthOwner
                    stringRect = CGRect(x: x, y: y, width: columnWidthItem, height: columnHeight)
                    text = inv.inventoryName!.truncate(length: 14)
                    text.draw(in: stringRect, withAttributes: attributes as [NSAttributedString.Key : Any])
                    x = x + columnWidthItem
                    stringRect = CGRect(x: x, y: y, width: columnWidthRoom, height: columnHeight)
                    text = inv.inventoryRoom!.roomName!
                    text.draw(in: stringRect, withAttributes: attributes as [NSAttributedString.Key : Any])
                    x = x + columnWidthRoom
                    stringRect = CGRect(x: x, y: y, width: columnWidthCategory, height: columnHeight)
                    text = inv.inventoryCategory!.categoryName!
                    text.draw(in: stringRect, withAttributes: attributes as [NSAttributedString.Key : Any])
                    x = x + columnWidthCategory
                    stringRect = CGRect(x: x, y: y, width: columnWidthBrand, height: columnHeight)
                    text = inv.inventoryBrand!.brandName!
                    text.draw(in: stringRect, withAttributes: attributes as [NSAttributedString.Key : Any])
                    x = x + columnWidthBrand
                    stringRect = CGRect(x: x, y: y, width: columnWidthRoom, height: columnHeight)
                    text = String(inv.price) + Local.currencySymbol!
                    text.draw(in: stringRect, withAttributes: attributes as [NSAttributedString.Key : Any])
                    x = x + columnWidthPrice
                    if imageSwitch.isOn{
                        pdfImageForIntenvory(xPos: columnWidthOwner + columnWidthItem - imageSizeWidth + 20, yPos: y, imageData: inv.image)
                    }
                    break
                case .category:
                    stringRect = CGRect(x: x, y: y, width: columnWidthCategory, height: columnHeight)
                    text = inv.inventoryCategory!.categoryName!
                    text.draw(in: stringRect, withAttributes: attributes as [NSAttributedString.Key : Any])
                    x = x + columnWidthCategory
                    stringRect = CGRect(x: x, y: y, width: columnWidthItem, height: columnHeight)
                    text = inv.inventoryName!.truncate(length: 14)
                    text.draw(in: stringRect, withAttributes: attributes as [NSAttributedString.Key : Any])
                    x = x + columnWidthItem
                    stringRect = CGRect(x: x, y: y, width: columnWidthOwner, height: columnHeight)
                    text = inv.inventoryOwner!.ownerName!
                    text.draw(in: stringRect, withAttributes: attributes as [NSAttributedString.Key : Any])
                    x = x + columnWidthOwner
                    stringRect = CGRect(x: x, y: y, width: columnWidthRoom, height: columnHeight)
                    text = inv.inventoryRoom!.roomName!
                    text.draw(in: stringRect, withAttributes: attributes as [NSAttributedString.Key : Any])
                    x = x + columnWidthRoom
                    stringRect = CGRect(x: x, y: y, width: columnWidthBrand, height: columnHeight)
                    text = inv.inventoryBrand!.brandName!
                    text.draw(in: stringRect, withAttributes: attributes as [NSAttributedString.Key : Any])
                    x = x + columnWidthBrand
                    stringRect = CGRect(x: x, y: y, width: columnWidthRoom, height: columnHeight)
                    text = String(inv.price) + Local.currencySymbol!
                    text.draw(in: stringRect, withAttributes: attributes as [NSAttributedString.Key : Any])
                    x = x + columnWidthPrice
                    if imageSwitch.isOn{
                        pdfImageForIntenvory(xPos: columnWidthCategory + columnWidthItem - imageSizeWidth + 20, yPos: y, imageData: inv.image)
                    }
                    break
                case .room:
                    stringRect = CGRect(x: x, y: y, width: columnWidthRoom, height: columnHeight)
                    text = inv.inventoryRoom!.roomName!
                    text.draw(in: stringRect, withAttributes: attributes as [NSAttributedString.Key : Any])
                    x = x + columnWidthRoom
                    stringRect = CGRect(x: x, y: y, width: columnWidthItem, height: columnHeight)
                    text = inv.inventoryName!.truncate(length: 14)
                    text.draw(in: stringRect, withAttributes: attributes as [NSAttributedString.Key : Any])
                    x = x + columnWidthItem
                    stringRect = CGRect(x: x, y: y, width: columnWidthOwner, height: columnHeight)
                    text = inv.inventoryOwner!.ownerName!
                    text.draw(in: stringRect, withAttributes: attributes as [NSAttributedString.Key : Any])
                    x = x + columnWidthOwner
                    stringRect = CGRect(x: x, y: y, width: columnWidthCategory, height: columnHeight)
                    text = inv.inventoryCategory!.categoryName!
                    text.draw(in: stringRect, withAttributes: attributes as [NSAttributedString.Key : Any])
                    x = x + columnWidthCategory
                    stringRect = CGRect(x: x, y: y, width: columnWidthBrand, height: columnHeight)
                    text = inv.inventoryBrand!.brandName!
                    text.draw(in: stringRect, withAttributes: attributes as [NSAttributedString.Key : Any])
                    x = x + columnWidthBrand
                    stringRect = CGRect(x: x, y: y, width: columnWidthRoom, height: columnHeight)
                    text = String(inv.price) + Local.currencySymbol!
                    text.draw(in: stringRect, withAttributes: attributes as [NSAttributedString.Key : Any])
                    x = x + columnWidthPrice
                    if imageSwitch.isOn{
                        pdfImageForIntenvory(xPos: columnWidthRoom + columnWidthItem - imageSizeWidth + 20, yPos: y, imageData: inv.image)
                    }
                    break
                }
                x = leftMargin
                if numberOfRows > paperPrintableRows{
                    numberOfRows = 0
                    y = contentsBegin
                    pdfPageFooter(footerText: footerText, context: context)
                    pdfPageNumber(pageNumber: numberOfPages)
                    numberOfPages += 1
                    context.beginPage()
                    pdfImageLogo()
                    pdfPageTitleHeading(title: title, fontSize: 25.0, context: context)
                    pdfPageUserInfo(userName: UserInfo.userName, address: UserInfo.addressName)
                    pdfTableHeader(context: context)
                }
            }
            pdfPageFooter(footerText: footerText, context: context)
            pdfPageNumber(pageNumber: numberOfPages)
            context.beginPage()
            pdfImageLogo()
            pdfSummaryPage(numberOfRows: results.count, context: context)
            pdfPageFooter(footerText: footerText, context: context)
            pdfPageNumber(pageNumber: numberOfPages + 1)
        }
        url = pdfSave(pdf)
        pdfDisplay(file: url!)
    }
    func pdfDisplay(file: URL){
        if let pdfDocument = PDFDocument(url: file) {
            pdfView.autoScales = true
            pdfView.displayMode = .singlePageContinuous
            pdfView.displayDirection = .vertical
            DispatchQueue.main.async
                {
                    guard let firstPage = self.pdfView.document?.page(at: 0) else { return }
                    self.pdfView.go(to: CGRect(x: 0, y: Int.max, width: 0, height: 0), on: firstPage)
            }
            pdfView.document = pdfDocument
        }
    }
    func pdfViewGestureWhenTapped() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ReportViewController.gestureAction))
        tap.cancelsTouchesInView = false
        pdfView.addGestureRecognizer(tap)
    }
    @objc func gestureAction() {
        performSegue(withIdentifier: "fullscreenPDF", sender: nil)
    }
    func sendPDFEmail(){
        self.view.endEditing(true)
        let mailComposeViewController = configuredMailComposeViewController(url: url)
        if MFMailComposeViewController.canSendMail()
        {
            self.present(mailComposeViewController, animated: true, completion: nil)
        }
        else
        {
            displayAlert(title: Global.emailNotSent, message: Global.emailDevice, buttonText: Global.emailConfig)
        }
    }
    func configuredMailComposeViewController(url: URL?) -> MFMailComposeViewController
    {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self
        mailComposerVC.setSubject(UIApplication.appName! + " " + (UIApplication.appVersion!) + " " + Global.support)
        let msg = NSLocalizedString("My Inventory Report", comment: "My Inventory Report")
        mailComposerVC.setMessageBody(msg, isHTML: false)
        if url != nil{
            do{
            let attachmentData = try Data(contentsOf: url!)
            mailComposerVC.addAttachmentData(attachmentData, mimeType: "application/pdf", fileName: Global.pdfFile)
            }
            catch let error {
                os_log("ReportViewController email attachement error: %s", log: Log.viewcontroller, type: .error, error.localizedDescription)
            }
        }
        return mailComposerVC
    }
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?)
    {
        controller.dismiss(animated: true, completion: nil)
    }
}
