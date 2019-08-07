import UIKit
import os
private let store = CoreDataStorage.shared
class CategoryEditViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var cancelButtonOutlet: UIBarButtonItem!
    @IBOutlet weak var saveButtonOutlet: UIBarButtonItem!
    @IBOutlet weak var textfieldCategory: UITextField!
    weak var currentCategory : Category?
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = true
        }
        navigationItem.leftBarButtonItem?.tintColor = themeColorUIControls
        navigationItem.rightBarButtonItem?.tintColor = themeColorUIControls
        if currentCategory != nil{
            self.title = NSLocalizedString("Edit Category", comment: "Edit Category")
            textfieldCategory.text = currentCategory!.categoryName
        }
        else{
            self.title = NSLocalizedString("Add Category", comment: "Add Category")
            textfieldCategory.text = ""
            saveButtonOutlet.isEnabled = false
        }
        textfieldCategory.becomeFirstResponder()
        textfieldCategory.delegate = self
        textfieldCategory.addTarget(self, action: #selector(textDidChange(_:)), for: UIControl.Event.editingDidEnd)
        textfieldCategory.addTarget(self, action: #selector(textIsChanging(_:)), for: UIControl.Event.editingChanged)
        textfieldCategory.placeholder = Global.category
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if (textField == textfieldCategory)
        {
            self.view.endEditing(true)
        }
        return false
    }
    @objc func textDidChange(_ textField:UITextField) {
    }
    @objc func textIsChanging(_ textField:UITextField) {
        let text = textfieldCategory.text?.trimmingCharacters(in: .whitespaces)
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
        if (currentCategory == nil)
        {
            if store.fetchCategory(categoryName: textfieldCategory.text!)
            {
                showAlertDialog()
                self.view.endEditing(false)
                textfieldCategory.becomeFirstResponder()
            }
            else{
                let category = Category(context: store.getContext())
                category.categoryName = (textfieldCategory.text!.capitalized).trimmingCharacters(in: .whitespaces)
                currentCategory = category
                _ = store.saveCategory(category: currentCategory!)
                navigationController?.popViewController(animated: true)
                self.dismiss(animated: true, completion: nil)
            }
        }
        else{ 
                currentCategory?.categoryName = textfieldCategory.text
                _ = store.saveCategory(category: currentCategory!)
                navigationController?.popViewController(animated: true)
                self.dismiss(animated: true, completion: nil)
        }
    }
    func showAlertDialog(){
        let title = NSLocalizedString("Category already exists", comment: "Category already exists")
        displayAlert(title: title, message: Global.chooseDifferentName, buttonText: Global.ok)
    }
}
