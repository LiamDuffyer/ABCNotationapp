import UIKit
import CoreData
import os
private let store = CoreDataStorage.shared
class OwnerTableViewController: UITableViewController {
    fileprivate let cellIdentifier = "ownerCell"
    lazy var fetchedResultsController: NSFetchedResultsController<Owner> = {
        let fetchRequest: NSFetchRequest<Owner> = Owner.fetchRequest()
        let nameSort = NSSortDescriptor(key: #keyPath(Owner.ownerName), ascending: true)
        fetchRequest.sortDescriptors = [nameSort]
        let fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: store.getContext(),
            sectionNameKeyPath: nil,
            cacheName: nil)
        fetchedResultsController.delegate = self
        return fetchedResultsController
    }()
    @IBOutlet weak var doneButtonLabel: UIBarButtonItem!
    @IBOutlet weak var addButtonLabel: UIBarButtonItem!
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = true
        }
        navigationItem.leftBarButtonItem?.tintColor = themeColorUIControls
        navigationItem.rightBarButtonItem?.tintColor = themeColorUIControls
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        self.title = NSLocalizedString("My Owners", comment: "My Owners")
        self.tableView.scrollToNearestSelectedRow(at: UITableView.ScrollPosition.bottom, animated: true)
        do {
            try fetchedResultsController.performFetch()
        } catch let error as NSError {
            print("Fetching error: \(error), \(error.userInfo)")
            os_log("OwnerTableViewController viewDidLoad", log: Log.viewcontroller, type: .error)
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        let destination =  segue.destination as! OwnerEditViewController
        if segue.identifier == "editSegueOwner"  {
            let owner = fetchedResultsController.object(at: self.tableView.indexPathForSelectedRow!)
            destination.currentOwner = owner
        }
        if segue.identifier == "addSegueOwner"  {
            destination.currentOwner = nil
        }
    }
    func showAlertDialog() -> Bool{
        var result : Bool = false
        let message = NSLocalizedString("Are you sure you want to delete? All inventory objects depending will be deleted as well...", comment: "Are you sure you want to delete? All inventory objects depending will be deleted as well...")
        let dialogMessage = UIAlertController(title: Global.confirm, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: Global.ok, style: .destructive, handler: { (action) -> Void in
            result = true
        })
        let cancel = UIAlertAction(title: Global.cancel, style: .cancel) { (action) -> Void in
            result = false
        }
        dialogMessage.addAction(ok)
        dialogMessage.addAction(cancel)
        self.present(dialogMessage, animated: true, completion: nil)
        return result
    }
    func confirmDelete(owner: Owner) {
        let title = NSLocalizedString("Delete owner", comment: "Delete owner")
        let message = NSLocalizedString("Are you sure you really want to delete? Any related inventory will be deleted as well!", comment: "Are you sure you really want to delete")
        let myActionSheet = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        let DeleteAction = UIAlertAction(title: Global.delete + " \(owner.ownerName!)", style: .destructive){ (ACTION) in
            _ = store.deleteOwner(owner: owner)
        }
        let CancelAction = UIAlertAction(title: Global.cancel, style: UIAlertAction.Style.cancel) { (ACTION) in
        }
        myActionSheet.addAction(DeleteAction)
        myActionSheet.addAction(CancelAction)
        addActionSheetForiPad(actionSheet: myActionSheet)
        present(myActionSheet, animated: true, completion: nil)
    }
    @IBAction func doneButton(_ sender: Any) {
        navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func addButton(_ sender: Any) {
    }
}
extension OwnerTableViewController {
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath)
    {
        let idx = IndexPath(row: indexPath.row, section: 0)
        tableView.selectRow(at: idx, animated: true, scrollPosition: .middle)
        performSegue(withIdentifier: "editSegueOwner", sender: self)
    }
    func configure(cell: UITableViewCell, for indexPath: IndexPath) {
        let owner = fetchedResultsController.object(at: indexPath)
        cell.textLabel?.text = owner.ownerName
        cell.textLabel?.font = UIFont(name: "HelveticaNeue", size:20)
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        guard let sections = fetchedResultsController.sections else {
            return 0
        }
        return sections.count
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sectionInfo = fetchedResultsController.sections?[section] else {
            return 0
        }
        return sectionInfo.numberOfObjects
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        configure(cell: cell, for: indexPath)
        return cell
    }
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let sectionInfo = fetchedResultsController.sections?[section]
        return sectionInfo?.name
    }
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath)
    {
        if editingStyle == .delete{
            let owner = fetchedResultsController.object(at: indexPath)
            confirmDelete(owner: owner)
        }
    }
}
extension OwnerTableViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .automatic)
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .automatic)
        case .update:
            let cell = tableView.cellForRow(at: indexPath!)
            configure(cell: cell!, for: indexPath!)
        case .move:
            tableView.deleteRows(at: [indexPath!], with: .automatic)
            tableView.insertRows(at: [newIndexPath!], with: .automatic)
        @unknown default:
            os_log("OwnerTableViewController controller", log: Log.viewcontroller, type: .error)
        }
    }
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        let indexSet = IndexSet(integer: sectionIndex)
        switch type {
        case .insert:
            tableView.insertSections(indexSet, with: .automatic)
        case .delete:
            tableView.deleteSections(indexSet, with: .automatic)
        default: break
        }
    }
}
