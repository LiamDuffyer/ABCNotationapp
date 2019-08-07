import UIKit
import PDFKit
import os
class PDFViewController: UIViewController {
    @IBOutlet weak var shareButton: UIBarButtonItem!
    var currentPDF: PDFView!
    var currentTitle: String?
    var currentPath: URL?
    @IBOutlet weak var pdfView: PDFView!
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 11.0, *) {
            self.navigationItem.largeTitleDisplayMode = .never
            self.navigationItem.largeTitleDisplayMode = .always
        }
        navigationController?.navigationBar.prefersLargeTitles = true
        shareButton.tintColor =  themeColorUIControls
        self.title = currentTitle
        pdfView.autoScales = true
        pdfView.displayMode = .singlePageContinuous
        pdfView.displayDirection = .vertical
        DispatchQueue.main.async
            {
                guard let firstPage = self.pdfView.document?.page(at: 0) else { return }
                self.pdfView.go(to: CGRect(x: 0, y: Int.max, width: 0, height: 0), on: firstPage)
        }
        pdfView.document = currentPDF?.document
        let lastPageStr = NSLocalizedString("Last Page", comment: "Last page")
        let firstPageStr = NSLocalizedString("First Page", comment: "First page")
        let lastPageBtn = UIBarButtonItem(title: lastPageStr, style: .plain, target: self, action: #selector(lastPage))
        let firstPageBtn = UIBarButtonItem(title: firstPageStr, style: .plain, target: self, action: #selector(firstPage))
        let arr = navigationItem.rightBarButtonItems
        navigationItem.rightBarButtonItems = arr! + [lastPageBtn, firstPageBtn]
        lastPageBtn.tintColor = themeColorUIControls
        firstPageBtn.tintColor = themeColorUIControls
    }
    @objc func firstPage() {
        pdfView.goToFirstPage(nil)
    }
    @objc func lastPage() {
        pdfView.goToLastPage(nil)
    }
    @IBAction func shareButtonAction(_ sender: Any) {
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: currentPath!.path) {
            let activityViewController: UIActivityViewController = UIActivityViewController(activityItems: [currentPath!], applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = self.view
            self.present(activityViewController, animated: true, completion: nil)
        } else {
            let alertController = UIAlertController(title: Global.error, message: Global.documentNotFound, preferredStyle: .alert)
            let defaultAction = UIAlertAction.init(title: Global.ok, style: UIAlertAction.Style.default, handler: nil)
            alertController.addAction(defaultAction)
            navigationController!.present(alertController, animated: true, completion: nil)
        }
    }
}
