import UIKit
import os
class RoomNavigationViewController: UINavigationController {
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 11.0, *) {
            navigationItem.largeTitleDisplayMode = .always
        }
    }
}
