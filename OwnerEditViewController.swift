import UIKit
import os
private let store = CoreDataStorage.shared
class OwnerEditViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var cancelButtonOutlet: UIBarButtonItem!
    @IBOutlet weak var saveButtonOutlet: UIBarButtonItem!
    @IBOutlet weak var textfieldOwner: UITextField!
    weak var currentOwner : Owner?
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = true
        }
        navigationItem.leftBarButtonItem?.tintColor = themeColorUIControls
        navigationItem.rightBarButtonItem?.tintColor = themeColorUIControls
        if currentOwner != nil{
            self.title = NSLocalizedString("Edit Owner", comment: "Edit Owner")
            textfieldOwner.text = currentOwner!.ownerName
        }
        else{
            self.title = NSLocalizedString("Add Owner", comment: "Add Owner")
            textfieldOwner.text = ""
            saveButtonOutlet.isEnabled = false
        }
        textfieldOwner.becomeFirstResponder()
        textfieldOwner.delegate = self
        textfieldOwner.addTarget(self, action: #selector(textDidChange(_:)), for: UIControl.Event.editingDidEnd)
        textfieldOwner.addTarget(self, action: #selector(textIsChanging(_:)), for: UIControl.Event.editingChanged)
        textfieldOwner.placeholder = Global.owner
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if (textField == textfieldOwner)
        {
            self.view.endEditing(true)
        }
        return false
    }
    @objc func textDidChange(_ textField:UITextField) {
    }
    @objc func textIsChanging(_ textField:UITextField) {
        let text = textfieldOwner.text?.trimmingCharacters(in: .whitespaces)
        if text?.count == 0{
            saveButtonOutlet.isEnabled = false
        }
        else{
            saveButtonOutlet.isEnabled = true
        }
    }
    @IBAction func cancelButton(_ sender: Any) {
        navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func saveButton(_ sender: Any) {
        self.view.endEditing(true)
        if (currentOwner == nil)
        {
            if store.fetchOwner(ownerName: textfieldOwner.text!)
            {
                showAlertDialog()
                self.view.endEditing(false)
                textfieldOwner.becomeFirstResponder()
            }
            else{
                let owner = Owner(context: store.getContext())
                owner.ownerName = (textfieldOwner.text!.capitalized).trimmingCharacters(in: .whitespaces)
                currentOwner = owner
                _ = store.saveOwner(owner: currentOwner!)
                navigationController?.popViewController(animated: true)
                self.dismiss(animated: true, completion: nil)
            }
        }
        else{
            currentOwner?.ownerName = textfieldOwner.text
            _ = store.saveOwner(owner: currentOwner!)
            navigationController?.popViewController(animated: true)
            self.dismiss(animated: true, completion: nil)
        }
    }
    func showAlertDialog(){
        let title = NSLocalizedString("Owner already exists", comment: "Owner already exists")
        displayAlert(title: title, message: Global.chooseDifferentName, buttonText: Global.ok)
    }
}
