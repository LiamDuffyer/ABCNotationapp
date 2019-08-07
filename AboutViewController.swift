import UIKit
import MessageUI
import os
import AudioToolbox
import WatchConnectivity
class AboutViewController: UIViewController, MFMailComposeViewControllerDelegate, UIPopoverPresentationControllerDelegate  {
    @IBOutlet weak var appVersionNumberLabel: UILabel!
    @IBOutlet weak var copyrightLabel: UILabel!
    @IBOutlet weak var iosversionLabel: UILabel!
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var appInformationButton: UIButton!
    @IBOutlet weak var feedbackButton: UIButton!
    @IBOutlet weak var privacyButton: UIButton!
    @IBOutlet weak var userManualButton: UIButton!
    @IBOutlet weak var openSourceLabel: UILabel!
    @IBOutlet weak var appSettingsButton: UIButton!
    @IBOutlet weak var helpButton: UIButton!
    let kvStore = NSUbiquitousKeyValueStore()
    var counter = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        appInformationButton.tintColor = themeColorUIControls
        feedbackButton.tintColor = themeColorUIControls
        privacyButton.tintColor = themeColorUIControls
        userManualButton.tintColor = themeColorUIControls
        appSettingsButton.tintColor = themeColorUIControls
        appVersionNumberLabel.text = UIApplication.appName! + " " + UIApplication.appVersion! + " (" + UIApplication.appBuild! + ")"
        appVersionNumberLabel.textColor = themeColorText
        copyrightLabel.text = NSLocalizedString("(c) 2019 by M. Deuß", comment: "(c) 2019 by M. Deuß")
        iosversionLabel.text = NSLocalizedString("Running on iOS ", comment: "Running on iOS") + DeviceInfo.getOSVersion()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        useiCloudSettingsStorage()
        self.hideKeyboardWhenTappedAround()
    }
    func useiCloudSettingsStorage(){
            userNameTextField.text = UserInfo.userName
            addressTextField.text = UserInfo.addressName
        NotificationCenter.default.addObserver(self, selector: #selector(AboutViewController.kvHasChanged(notification:)), name: NSUbiquitousKeyValueStore.didChangeExternallyNotification, object: kvStore)
    }
    @objc func kvHasChanged(notification: NSNotification){
        userNameTextField.text = kvStore.string(forKey: Global.keyUserName)
        UserInfo.userName = userNameTextField.text!
        addressTextField.text = kvStore.string(forKey: Global.keyHouseName)
        UserInfo.addressName = addressTextField.text!
    }
    func popOver(text: NSAttributedString, sender: UIButton){
        let myVC = storyboard?
            .instantiateViewController(withIdentifier: "PopupViewController")   
            as! PopupViewController
        myVC.myText = text
        myVC.aboutVC = self
        myVC.modalPresentationStyle = .popover
        let popPC = myVC.popoverPresentationController!
        popPC.sourceView = sender
        popPC.sourceRect = sender.bounds
        popPC.permittedArrowDirections = .up
        popPC.delegate = self
        present(myVC, animated:true, completion: nil)
        let _ = Statistics.shared.allInventory(elementsCount: 10)
        let watchSessionManager = WatchSessionManager.sharedManager
        let returnMessage: [String : Any] = [
            DataKey.AmountMoney : Statistics.shared.itemPricesSum(),
            DataKey.ItemCount : Statistics.shared.getInventoryItemCount()
        ]
        watchSessionManager.sendMessage(message: returnMessage)
        watchSessionManager.sendTopPricesListToWatch(count: 10)
        let _ = watchSessionManager.transferUserInfo(userInfo: returnMessage)
        watchSessionManager.sendItemsByRoomListToWatch()
        watchSessionManager.sendItemsByCategoryListToWatch()
        watchSessionManager.sendItemsByBrandListToWatch()
        watchSessionManager.sendItemsByOwnerListToWatch()
        let image = #imageLiteral(resourceName: "Owner Icon")
        let data = image.jpegData(compressionQuality: 0.9)
        watchSessionManager.sendMessageData(data: data!)
    }
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    @IBAction func userNameEditingChanged(_ sender: UITextField) {
        if (userNameTextField.text!.count > 0){
            kvStore.set(userNameTextField.text!, forKey: Global.keyUserName)
            kvStore.synchronize()
            UserInfo.userName = userNameTextField.text!
        }
    }
    @IBAction func addressEditingChanged(_ sender: UITextField) {
        if (addressTextField.text!.count > 0){
            kvStore.set(addressTextField.text!, forKey: Global.keyHouseName)
            kvStore.synchronize()
            UserInfo.addressName = addressTextField.text!
        }
    }
    @IBAction func appSettingsAction(_ sender: UIButton) {
        Global.callAppSettings()
    }
    @IBAction func feedbackButton(_ sender: Any) {
        self.view.endEditing(true)
        let mailComposeViewController = configuredMailComposeViewController()
        if MFMailComposeViewController.canSendMail()
        {
            self.present(mailComposeViewController, animated: true, completion: nil)
        }
        else
        {
            displayAlert(title: Global.emailNotSent, message: Global.emailDevice, buttonText: Global.emailConfig)
        }
    }
    @IBAction func informationButton(_ sender: Any) {
        self.view.endEditing(true)
        if let url = URL(string: Global.website) {
            UIApplication.shared.open(url, options: [:])
        }
    }
    @IBAction func helpButton(_ sender: UIButton) {
        var fileName : String
        switch Local.currentLocaleForDate(){
        case "de_DE", "de_AT", "de_CH", "de":
            fileName = "Aboutview Help German"
            break
        default: 
            fileName = "Aboutview Help English"
            break
        }
        popOver(text: Global.getRTFFileFromBundle(fileName: fileName), sender: sender)
    }
    func configuredMailComposeViewController() -> MFMailComposeViewController
    {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self
        mailComposerVC.setToRecipients([Global.emailAdr])
        mailComposerVC.setSubject(UIApplication.appName! + " " + (UIApplication.appVersion!) + " " + Global.support)
        let msg = NSLocalizedString("I have some suggestions: ", comment: "I have some suggestions: ")
        mailComposerVC.setMessageBody(msg, isHTML: false)
        return mailComposerVC
    }
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?)
    {
        controller.dismiss(animated: true, completion: nil)
    }
}
