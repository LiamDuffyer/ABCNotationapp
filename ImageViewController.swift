import UIKit
import os
class ImageViewController: UIViewController {
    var image : UIImage?
    var titleForImage: String?
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 11.0, *) {
            self.navigationItem.largeTitleDisplayMode = .never
            self.navigationItem.largeTitleDisplayMode = .always
        }
        navigationController?.navigationBar.prefersLargeTitles = true
        self.title = titleForImage 
        imageView.image = image
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }
    fileprivate func updateMinZoomScaleForSize(_ size: CGSize) {
        let widthScale = size.width / imageView.bounds.width
        let heightScale = size.height / imageView.bounds.height
        let minScale = min(widthScale, heightScale)
        scrollView.minimumZoomScale = minScale
        scrollView.zoomScale = minScale
    }
}
