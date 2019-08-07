import UIKit
class PopupViewController: UIViewController {
    @IBOutlet weak var infotxt: UITextView!
    var myText : NSAttributedString?
    weak var aboutVC: AboutViewController!  
    override var preferredContentSize: CGSize{
        get{
            if infotxt != nil, let pvc = presentingViewController{
                return infotxt.sizeThatFits(pvc.view.bounds.size)
            }
            return super.preferredContentSize
        }
        set { super.preferredContentSize = newValue}
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        if myText != nil{
            infotxt.attributedText = myText
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DispatchQueue.main.async{
            let desiredOffset = CGPoint(x: 0, y: -self.infotxt.contentInset.top)
            self.infotxt.setContentOffset(desiredOffset, animated: false)
        }
    }
}
