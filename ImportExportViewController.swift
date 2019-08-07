import UIKit
import CoreData
import PDFKit
import os
import MessageUI
import MobileCoreServices
private let store = CoreDataStorage.shared
class ImportExportViewController: UIViewController, MFMailComposeViewControllerDelegate, UIDocumentPickerDelegate {
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var exportCVSButton: UIButton!
    @IBOutlet weak var shareBarButton: UIBarButtonItem!
    @IBOutlet weak var importedRowsLabel: UILabel!
    @IBOutlet weak var importCVSButton: UIButton!
    var url : URL?
    override func viewDidLoad() {
        super.viewDidLoad()
        exportCVSButton.tintColor = themeColorUIControls
        importCVSButton.tintColor = themeColorUIControls
        shareBarButton.tintColor = themeColorUIControls
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = true
        }
        self.importedRowsLabel.isHidden = true
        progressView.setProgress(0, animated: true)
        progressLabel.isHidden = true
        self.title = NSLocalizedString("Import/Export", comment: "Import/Export")
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.importedRowsLabel.isHidden = true
        progressView.setProgress(0, animated: true)
        progressLabel.isHidden = true
    }
    private func inventoryFetchRequest() -> NSFetchRequest<Inventory> {
        let fetchRequest:NSFetchRequest<Inventory> = Inventory.fetchRequest()
        fetchRequest.fetchBatchSize = 20
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "inventoryName", ascending: true)]
        return fetchRequest
    }
    func exportCSVFile()
    {
        let docPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        self.url = docPath.appendingPathComponent(Global.csvFile)
        let imagesFolderPath = URL.createFolder(folderName: "Images")
        let pdfFolderPath = URL.createFolder(folderName: "PDF")
        let activityIndicator = UIActivityIndicatorView(style: .gray)
        let barButtonItem = UIBarButtonItem(customView: activityIndicator)
        navigationItem.leftBarButtonItem = barButtonItem
        activityIndicator.startAnimating()
        let container = store.persistentContainer
        container.performBackgroundTask { (context) in
            var exportedRows : Int = 0
            var results: [Inventory] = []
            do {
                results = try context.fetch(self.inventoryFetchRequest())
            } catch let error as NSError {
                print("ERROR: \(error.localizedDescription)")
                os_log("ImportExportViewController exportCSVFile", log: Log.viewcontroller, type: .error)
            }
            let docPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let pathURLcvs = docPath.appendingPathComponent(Global.csvFile)
            self.url = pathURLcvs
            var csvText = Global.csvMetadata
            var progress : Int = 0
            for inv in results{
                csvText.append(contentsOf: inv.csv())
                progress += 1
                DispatchQueue.main.async {
                    let progress = Float(progress) / Float(results.count)
                    self.progressView.setProgress(progress, animated: true)
                    self.progressLabel.text = String(progress * 100) + " %"
                }
                exportedRows += 1
            }
            do {
                try csvText.write(to: pathURLcvs, atomically: true, encoding: String.Encoding.utf8)
                DispatchQueue.main.async {
                    self.showExportFinishedAlertView()
                }
            } catch {
                os_log("ImportExportViewController exportCSVFile", log: Log.viewcontroller, type: .error)
                print("Failed to create inventory csv file")
                print("\(error)")
            }
            for inv in results{
                if inv.imageFileName != "" {
                    let pathURLjpg = imagesFolderPath!.appendingPathComponent(inv.imageFileName!)
                    let imageData = inv.image! as Data
                    let image = UIImage(data: imageData, scale: 1.0)
                    if let data = image!.jpegData(compressionQuality: 0.0),
                        !FileManager.default.fileExists(atPath: pathURLjpg.path) {
                        do {
                            try data.write(to: pathURLjpg, options: .atomic)
                        } catch {
                            print("error saving jpg file:", error)
                            os_log("ImportExportViewController exportCSVFile", log: Log.viewcontroller, type: .error)
                        }
                    }
                }
                if inv.invoiceFileName != nil && inv.invoiceFileName != "" {
                    let pathURLpdf = pdfFolderPath!.appendingPathComponent(inv.invoiceFileName!)
                    let invoiceData = inv.invoice! as Data
                    do {
                        try invoiceData.write(to: pathURLpdf, options: .atomic)
                    } catch {
                        print("error saving pdf file:", error)
                        os_log("ImportExportViewController exportCSVFile", log: Log.viewcontroller, type: .error)
                    }
                }
            }
            DispatchQueue.main.async {
                self.importedRowsLabel.isHidden = false
                let message = NSLocalizedString("Exported rows:", comment: "Exported rows:")
                self.importedRowsLabel.text = message + " " + String(exportedRows)
                self.progressView.setProgress(1.0, animated: true)
                self.progressLabel.text = "100 %"
                activityIndicator.stopAnimating()
                self.navigationItem.leftBarButtonItem = nil
            }
        }
    }
    func showExportFinishedAlertView() {
        let message = NSLocalizedString("CSV file can be found in Inventory App documents folder", comment: "The exported CSV file can be found here")
        let title = NSLocalizedString("Export Finished", comment: "Export Finished")
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: Global.dismiss, style: .default)
        alertController.addAction(dismissAction)
        present(alertController, animated: true)
    }
    func importCVSFile(file: String){
        var importedRows : Int = 0
        let imagesFolderPath = URL.createFolder(folderName: "Images")
        let pdfFolderPath = URL.createFolder(folderName: "PDF")
        guard let data = readDataFromCSV(fileName: file) else{
            let message = NSLocalizedString("Importing CSV file", comment: "Importing CSV file")
            let title = NSLocalizedString("No CSV file to import found", comment: "No CSV file to import found")
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let dismissAction = UIAlertAction(title: Global.dismiss, style: .default)
            alertController.addAction(dismissAction)
            present(alertController, animated: true)
            os_log("ImportExportViewController importCVSFile: no file to import available", log: Log.viewcontroller, type: .info)
            return
        }
        let csvRows = csvImportParser(data: data)
        guard let _ = csvCheckMetadata(csvRows: csvRows) else{
            let message = NSLocalizedString("CSV file format different than expected", comment: "CSV file format different than expected")
            let title = NSLocalizedString("CSV file cannot be imported", comment: "CSV file cannot be imported")
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let dismissAction = UIAlertAction(title: Global.dismiss, style: .default)
            alertController.addAction(dismissAction)
            present(alertController, animated: true)
            os_log("ImportExportViewController importCVSFile: csv file format different", log: Log.viewcontroller, type: .info)
            return
        }
        if csvRows.count > 1{
            for x in 1 ... csvRows.count - 1 {
                let progress = Float(x) / Float(csvRows.count)
                progressView.setProgress(progress, animated: true)
                progressLabel.text = String(progress) + " %"
                let inventory = Inventory(context: store.getContext())
                if csvRows[x][0].count == 0{
                    continue
                }
                inventory.inventoryName = csvRows[x][0]
                let dateFormatter = DateFormatter()
                dateFormatter.dateStyle = .short
                let dateOfPurchase = dateFormatter.date(from: csvRows[x][1])
                inventory.dateOfPurchase = dateOfPurchase! as NSDate
                inventory.price = Int32(csvRows[x][2])!
                inventory.serialNumber = csvRows[x][3]
                inventory.remark = csvRows[x][4]
                let timeStamp = dateFormatter.date(from: csvRows[x][1])
                inventory.timeStamp = timeStamp! as NSDate
                var room: Room?
                room = store.fetchRoom(roomName: csvRows[x][6])
                if room != nil{
                    inventory.inventoryRoom = room
                }
                else{
                    let newRoom = Room(context: store.getContext())
                    newRoom.roomName = csvRows[x][6]
                    let myImage = #imageLiteral(resourceName: "icons8-home-filled-50")
                    let imageData = myImage.jpegData(compressionQuality: 1.0)
                    newRoom.roomImage = imageData! as NSData
                    inventory.inventoryRoom = newRoom
                }
                var owner: Owner?
                owner = store.fetchOwner(ownerName: csvRows[x][7])
                if owner != nil{
                    inventory.inventoryOwner = owner
                }
                else{
                    let newOwner = Owner(context: store.getContext())
                    newOwner.ownerName = csvRows[x][7]
                    inventory.inventoryOwner = newOwner
                }
                var category: Category?
                category = store.fetchCategory(categoryName: csvRows[x][8])
                if category != nil{
                    inventory.inventoryCategory = category
                }
                else{
                    let newCategory = Category(context: store.getContext())
                    newCategory.categoryName = csvRows[x][8]
                    inventory.inventoryCategory = newCategory
                }
                var brand: Brand?
                brand = store.fetchBrand(brandName: csvRows[x][9])
                if brand != nil{
                    inventory.inventoryBrand = brand
                }
                else{
                    let newBrand = Brand(context: store.getContext())
                    newBrand.brandName = csvRows[x][9]
                    inventory.inventoryBrand = newBrand
                }
                inventory.warranty = Int32(csvRows[x][10])!
                inventory.imageFileName = csvRows[x][11]
                inventory.invoiceFileName = csvRows[x][12]
                if inventory.imageFileName! != ""{
                    let pathURL = imagesFolderPath!.appendingPathComponent(inventory.imageFileName!)
                    let image = try? UIImage(contentsOfFile: URL(resolvingAliasFileAt: pathURL).path)
                    if image != nil{
                        let imageData: NSData = image!.jpegData(compressionQuality: 1.0)! as NSData
                        inventory.image = imageData
                    }
                    else{
                        inventory.image = nil
                    }
                }
                else{
                    let myImage = #imageLiteral(resourceName: "Room Icon")
                    let imageData = myImage.jpegData(compressionQuality: 1.0)
                    inventory.image = imageData! as NSData
                }
                if inventory.invoiceFileName! != ""{
                    let pathURL = pdfFolderPath!.appendingPathComponent(inventory.invoiceFileName!)
                    if let pdfDocument = PDFDocument(url: pathURL) {
                        inventory.invoice = pdfDocument.dataRepresentation()! as NSData?
                    }
                    else{
                        inventory.invoice = nil
                    }
                }
                else{
                    inventory.invoice = nil
                }
                let uuid = store.getInventoryUUID(uuid: UUID(uuidString: csvRows[x][13])!)
                if !uuid{
                    inventory.id = UUID(uuidString: csvRows[x][13])
                    _ = store.saveInventory(inventory: inventory)
                    importedRows += 1
                }
                else{
                    let context = store.getContext()
                    context.delete(inventory)
                }
            }
        }
        self.importedRowsLabel.isHidden = false
        let rows = NSLocalizedString("Imported rows:", comment: "Imported rows:")
        self.importedRowsLabel.text = rows + " " + String(importedRows)
        progressView.setProgress(1.0, animated: true)
        progressLabel.text = "100 %"
    }
    func csvCheckMetadata(csvRows: [[String]]) -> String?{
        if csvRows[0][0] != Global.inventoryName_csv{
            return nil
        }
        if csvRows[0][1] != Global.dateofPurchase_csv{
            return nil
        }
        if csvRows[0][2] != Global.price_csv{
            return nil
        }
        if csvRows[0][3] != Global.serialNumber_csv{
            return nil
        }
        if csvRows[0][4] != Global.remark_csv{
            return nil
        }
        if csvRows[0][5] != Global.timeStamp_csv{
            return nil
        }
        if csvRows[0][6] != Global.roomName_csv{
            return nil
        }
        if csvRows[0][7] != Global.ownerName_csv{
            return nil
        }
        if csvRows[0][8] != Global.categoryName_csv{
            return nil
        }
        if csvRows[0][9] != Global.brandName_csv{
            return nil
        }
        if csvRows[0][10] != Global.warranty_csv{
            return nil
        }
        if csvRows[0][11] != Global.imageFileName_csv{
            return nil
        }
        if csvRows[0][12] != Global.invoiceFileName_csv{
            return nil
        }
        if csvRows[0][13] != Global.id_csv{
            return nil
        }
        return "ok"
    }
    func readDataFromCSV(fileName: String) -> String?{
        let docPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let pathURLcvs = docPath.appendingPathComponent(fileName)
        do {
            var contents = try String(contentsOfFile: pathURLcvs.path, encoding: .utf8)
            contents = cleanRows(file: contents)
            return contents
        } catch {
            print("File import Read Error for cvs file \(pathURLcvs.absoluteString)", error)
            os_log("ImportExportViewController readDataFromCSV", log: Log.viewcontroller, type: .error)
            return nil
        }
    }
    func cleanRows(file: String) -> String{
        var cleanFile = file
        cleanFile = cleanFile.replacingOccurrences(of: "\r", with: "\n")
        cleanFile = cleanFile.replacingOccurrences(of: "\n\n", with: "\n")
        cleanFile = cleanFile.replacingOccurrences(of: ";", with: ",")
        return cleanFile
    }
    func csvImportParser(data: String) -> [[String]] {
        var result: [[String]] = []
        let rows = data.components(separatedBy: "\n")
        for row in rows {
            if row.count > 0{
                let columns = row.components(separatedBy: ",")
                result.append(columns)
            }
        }
        return result
    }
    @IBAction func exportCVSButtonAction(_ sender: UIButton) {
        importedRowsLabel.isHidden = true
        importedRowsLabel.text = ""
        progressView.setProgress(0, animated: true)
        progressLabel.isHidden = false
        progressLabel.text = "0 %"
        exportCSVFile()
    }
    @IBAction func shareButtonAction(_ sender: Any) {
        importedRowsLabel.isHidden = true
        importedRowsLabel.text = ""
        progressView.setProgress(0, animated: true)
        progressLabel.isHidden = false
        progressLabel.text = "0 %"
        exportCSVFile()
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: self.url!.path) {
            let text = NSLocalizedString("Shared by Inventory App", comment: "Shared by Inventory App")
            let activityViewController: UIActivityViewController = UIActivityViewController(activityItems: [text, self.url!], applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = self.view
            self.present(activityViewController, animated: true, completion: nil)
        } else {
            let alertController = UIAlertController(title: Global.error, message: Global.documentNotFound, preferredStyle: .alert)
            let defaultAction = UIAlertAction.init(title: Global.ok, style: UIAlertAction.Style.default, handler: nil)
            alertController.addAction(defaultAction)
            navigationController!.present(alertController, animated: true, completion: nil)
        }
    }
    @IBAction func importFromCVSFileButton(_ sender: Any) {
        openFilesApp()
    }
    func sendCSVEmail(path: URL?){
        self.view.endEditing(true)
        let mailComposeViewController = configuredMailComposeViewController(url: path)
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
        mailComposerVC.setSubject(NSLocalizedString("My CSV file", comment: "My CSV file"))
        let msg = NSLocalizedString("My CSV file", comment: "My CSV file")
        mailComposerVC.setMessageBody(msg, isHTML: false)
        if url != nil{
            do{
                let attachmentData = try Data(contentsOf: url!)
                mailComposerVC.addAttachmentData(attachmentData, mimeType: "text/csv", fileName: Global.csvFile)
            }
            catch let error {
                os_log("ImportExportViewController email attachement error: %s", log: Log.viewcontroller, type: .error, error.localizedDescription)
            }
        }
        return mailComposerVC
    }
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?)
    {
        controller.dismiss(animated: true, completion: nil)
    }
    func openFilesApp(){
        let controller = UIDocumentPickerViewController(
            documentTypes: [String(kUTTypeCommaSeparatedText)], 
            in: .import 
        )
        controller.delegate = self
        if #available(iOS 11.0, *) {
            controller.allowsMultipleSelection = false
        }
        present(
            controller,
            animated: true,
            completion: nil
        )
    }
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        importedRowsLabel.isHidden = true
        importedRowsLabel.text = ""
        progressView.setProgress(0, animated: true)
        progressLabel.isHidden = false
        progressLabel.text = "0 %"
        importCVSFile(file: url.lastPathComponent)
    }
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        importedRowsLabel.isHidden = false
        importedRowsLabel.text = NSLocalizedString("No file selected for importing", comment: "No file selected for importing")
    }
}
