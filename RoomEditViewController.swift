import UIKit
import os
private let store = CoreDataStorage.shared
class RoomEditViewController: UIViewController, UITextFieldDelegate{
    weak var currentRoom : Room?
    @IBOutlet weak var textfieldRoomName: UITextField!
    @IBOutlet weak var cancelButtonOutlet: UIBarButtonItem!
    @IBOutlet weak var saveButtonOutlet: UIBarButtonItem!
    @IBOutlet weak var chosenImage: UIImageView!
    @IBOutlet weak var bedroomIcon: UIButton!
    @IBOutlet weak var diningIcon: UIButton!
    @IBOutlet weak var kidsIcon: UIButton!
    @IBOutlet weak var gardenIcon: UIButton!
    @IBOutlet weak var bathIcon: UIButton!
    @IBOutlet weak var cellarIcon: UIButton!
    @IBOutlet weak var kitchenIcon: UIButton!
    @IBOutlet weak var livingIcon: UIButton!
    @IBOutlet weak var garageIcon: UIButton!
    @IBOutlet weak var homeIcon: UIButton!
    @IBOutlet weak var defaultIcon: UIButton!
    @IBOutlet weak var living2Icon: UIButton!
    @IBOutlet weak var officeIcon: UIButton!
    @IBOutlet weak var office2Icon: UIButton!
    @IBOutlet weak var office3Icon: UIButton!
    @IBOutlet weak var girlIcon: UIButton!
    @IBOutlet weak var boyIcon: UIButton!
    @IBOutlet weak var kidsbedIcon: UIButton!
    @IBOutlet weak var girlAndBoyIcon: UIButton!
    @IBOutlet weak var office4Icon: UIButton!
    @IBOutlet weak var bedroom2Icon: UIButton!
    @IBOutlet weak var generalRoomIcon: UIButton!
    @IBOutlet weak var toasterIcon: UIButton!
    @IBOutlet weak var showerIcon: UIButton!
    @IBOutlet weak var garage2Icon: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = true
        }
        navigationItem.leftBarButtonItem?.tintColor = themeColorUIControls
        navigationItem.rightBarButtonItem?.tintColor = themeColorUIControls
        hideKeyboardWhenTappedAround()
        if currentRoom != nil{
            self.title = NSLocalizedString("Edit Room", comment: "Edit Room")
            textfieldRoomName.text = currentRoom!.roomName
            let imageData = currentRoom!.roomImage! as Data
            let image = UIImage(data: imageData, scale:1.0)
            chosenImage.image = image
        }
        else{
            self.title = NSLocalizedString("Add Room", comment: "Add Room")
            textfieldRoomName.text = ""
            saveButtonOutlet.isEnabled = false
        }
        textfieldRoomName.becomeFirstResponder()
        textfieldRoomName.delegate = self
        textfieldRoomName.addTarget(self, action: #selector(textDidChange(_:)), for: UIControl.Event.editingDidEnd)
        textfieldRoomName.addTarget(self, action: #selector(textIsChanging(_:)), for: UIControl.Event.editingChanged)
        textfieldRoomName.placeholder = Global.room
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if (textField == textfieldRoomName)
        {
            self.view.endEditing(true)
        }
        return false
    }
    @objc func textDidChange(_ textField:UITextField) {
    }
    @objc func textIsChanging(_ textField:UITextField) {
        let text = textfieldRoomName.text?.trimmingCharacters(in: .whitespaces)
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
        if (currentRoom == nil)
        {
            if store.fetchRoom(roomName: textfieldRoomName.text!)
            {
                showAlertDialog()
                self.view.endEditing(false)
                textfieldRoomName.becomeFirstResponder()
            }
            else{
                let room = Room(context: store.getContext())
                room.roomName = (textfieldRoomName.text!.capitalized).trimmingCharacters(in: .whitespaces)
                let imageData = chosenImage.image!.jpegData(compressionQuality: 1.0)
                room.roomImage = imageData! as NSData
                currentRoom = room
                _ = store.saveRoom(room: currentRoom!)
                navigationController?.popViewController(animated: true)
                self.dismiss(animated: true, completion: nil)
            }
        }
        else{ 
                currentRoom?.roomName = textfieldRoomName.text
                let imageData = chosenImage.image!.jpegData(compressionQuality: 1.0)
                currentRoom?.roomImage = imageData! as NSData
                _ = store.saveRoom(room: currentRoom!)
                navigationController?.popViewController(animated: true)
                self.dismiss(animated: true, completion: nil)
        }
    }
    func showAlertDialog(){
        let title = NSLocalizedString("Room already exists", comment: "Room already exists")
        displayAlert(title: title, message: Global.chooseDifferentName, buttonText: Global.ok)
    }
    @IBAction func iconButton(_ sender: UIButton) {
        switch sender {
        case bedroomIcon:
            chosenImage.image = #imageLiteral(resourceName: "icons8-bett-50")
            break
        case diningIcon:
            chosenImage.image = #imageLiteral(resourceName: "icons8-geschirr-50")
            break
        case kidsIcon:
            chosenImage.image = #imageLiteral(resourceName: "icons8-teddy-50")
            break
        case gardenIcon:
            chosenImage.image = #imageLiteral(resourceName: "icons8-haus-mit-garten-50")
            break
        case garageIcon:
            chosenImage.image = #imageLiteral(resourceName: "icons8-garage-50")
            break
        case bathIcon:
            chosenImage.image = #imageLiteral(resourceName: "icons8-dusche-und-badewanne-96")
            break
        case cellarIcon:
            chosenImage.image = #imageLiteral(resourceName: "icons8-keller-filled-50")
            break
        case livingIcon:
            chosenImage.image = #imageLiteral(resourceName: "icons8-wohnzimmer-50")
            break
        case kitchenIcon:
            chosenImage.image = #imageLiteral(resourceName: "icons8-kochtopf-50")
            break
        case homeIcon:
            chosenImage.image = #imageLiteral(resourceName: "icons8-wohnung-filled-50")
            break
        case defaultIcon:
            chosenImage.image = #imageLiteral(resourceName: "icons8-home-filled-50")
            break
        case living2Icon:
            chosenImage.image = #imageLiteral(resourceName: "icons8-retro-tv-filled-50")
            break
        case officeIcon:
            chosenImage.image = #imageLiteral(resourceName: "icons8-arbeitsplatz-50")
            break
        case office2Icon:
            chosenImage.image = #imageLiteral(resourceName: "icons8-home-office-filled-50")
            break
        case office3Icon:
            chosenImage.image = #imageLiteral(resourceName: "icons8-schreibtischlampe-filled-50")
            break
        case office4Icon:
            chosenImage.image = #imageLiteral(resourceName: "icons8-buchhaltung-96")
            break
        case girlIcon:
            chosenImage.image = #imageLiteral(resourceName: "icons8-maedchen-96")
            break
        case boyIcon:
            chosenImage.image = #imageLiteral(resourceName: "icons8-junge-96")
            break
        case girlAndBoyIcon:
            chosenImage.image = #imageLiteral(resourceName: "icons8-kinder-90")
            break
        case kidsbedIcon:
            chosenImage.image = #imageLiteral(resourceName: "icons8-krippe-96")
            break
        case bedroom2Icon:
            chosenImage.image = #imageLiteral(resourceName: "icons8-schlafen-96")
            break
        case generalRoomIcon:
            chosenImage.image = #imageLiteral(resourceName: "icons8-zimmer-96")
            break
        case toasterIcon:
            chosenImage.image = #imageLiteral(resourceName: "icons8-toaster-96")
            break
        case showerIcon:
            chosenImage.image = #imageLiteral(resourceName: "icons8-dusche-96")
            break
        case garage2Icon:
            chosenImage.image = #imageLiteral(resourceName: "icons8-garage-96")
            break
        default:
            chosenImage.image = #imageLiteral(resourceName: "icons8-home-filled-50")
            break
        }
    }
}
