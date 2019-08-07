import UIKit
import os
private let store = CoreDataStorage.shared
class BrandEditViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var cancelButtonOutlet: UIBarButtonItem!
    @IBOutlet weak var saveButtonOutlet: UIBarButtonItem!
    @IBOutlet weak var textfieldBrand: UITextField!
    weak var currentBrand : Brand?
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = true
        }
        navigationItem.leftBarButtonItem?.tintColor = themeColorUIControls
        navigationItem.rightBarButtonItem?.tintColor = themeColorUIControls
        if currentBrand != nil{
            self.title = NSLocalizedString("Edit Brand", comment: "Edit Brand")
            textfieldBrand.text = currentBrand!.brandName
        }
        else{
            self.title = NSLocalizedString("Add Brand", comment: "Add Brand")
            textfieldBrand.text = ""
            saveButtonOutlet.isEnabled = false
        }
        textfieldBrand.becomeFirstResponder()
        textfieldBrand.delegate = self
        textfieldBrand.addTarget(self, action: #selector(textDidChange(_:)), for: UIControl.Event.editingDidEnd)
        textfieldBrand.addTarget(self, action: #selector(textIsChanging(_:)), for: UIControl.Event.editingChanged)
        textfieldBrand.placeholder = Global.brand
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if (textField == textfieldBrand)
        {
            self.view.endEditing(true)
        }
        return false
    }
    @objc func textDidChange(_ textField:UITextField) {
    }
    @objc func textIsChanging(_ textField:UITextField) {
        let text = textfieldBrand.text?.trimmingCharacters(in: .whitespaces)
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
        if (currentBrand == nil)
        {
            if store.fetchBrand(brandName: textfieldBrand.text!)
            {
                showAlertDialog()
                self.view.endEditing(false)
                textfieldBrand.becomeFirstResponder()
            }
            else{
                let brand = Brand(context: store.getContext())
                brand.brandName = (textfieldBrand.text!.capitalized).trimmingCharacters(in: .whitespaces)
                currentBrand = brand
                _ = store.saveBrand(brand: currentBrand!)
                navigationController?.popViewController(animated: true)
                self.dismiss(animated: true, completion: nil)
            }
        }
        else{
            currentBrand?.brandName = textfieldBrand.text
            _ = store.saveBrand(brand: currentBrand!)
            navigationController?.popViewController(animated: true)
            self.dismiss(animated: true, completion: nil)
        }
    }
    func showAlertDialog(){
        let title = NSLocalizedString("Brand already exists", comment: "Brand already exists")
        displayAlert(title: title, message: Global.chooseDifferentName, buttonText: Global.ok)
    }
}
