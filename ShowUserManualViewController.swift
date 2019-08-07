import UIKit
import PDFKit
import os
class ShowUserManualViewController: UIViewController {
    @IBOutlet weak var pdfView: PDFView!
    @IBOutlet weak var doneAction: UIButton!
    @IBOutlet weak var navigationBar: UINavigationBar!
    override func viewDidLoad() {
        super.viewDidLoad()
        os_log("ShowUserManualViewController viewDidLoad", log: Log.viewcontroller, type: .info)
        doneAction.tintColor = themeColorUIControls
        navigationBar.topItem?.title = NSLocalizedString("Inventory User Manual", comment: "Inventory User Manual")
        doneAction.setTitle(Global.done, for: .normal)
        if #available(iOS 11.0, *) {
            self.navigationItem.largeTitleDisplayMode = .never
            self.navigationItem.largeTitleDisplayMode = .always
        }
        navigationController?.navigationBar.prefersLargeTitles = true
        var fileURL : URL?
        switch Local.currentLocaleForDate(){
        case "de_DE", "de_AT", "de_CH", "de":
            fileURL = Bundle.main.url(forResource: "Inventory App Handbuch", withExtension: "pdf")
            break
        default: 
            fileURL = Bundle.main.url(forResource: "Inventory App Handbuch", withExtension: "pdf")
            break
        }
        DispatchQueue.main.async{
                self.pdfView.autoScales = true
                self.pdfView.displayMode = .singlePageContinuous
                self.pdfView.displayDirection = .vertical
                guard let firstPage = self.pdfView.document?.page(at: 0) else { return }
                self.pdfView.go(to: CGRect(x: 0, y: Int.max, width: 0, height: 0), on: firstPage)
        }
        self.pdfView.document = PDFDocument(url: fileURL!)
    }
    @IBAction func doneAction(_ sender: UIButton) {
        os_log("ShowUserManualViewController doneAction", log: Log.viewcontroller, type: .info)
        dismiss(animated: true, completion: nil)
    }
}
