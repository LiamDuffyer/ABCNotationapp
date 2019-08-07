import UIKit
import CoreData
import os
private let store = CoreDataStorage.shared
class CategoryTableViewController: UITableViewController {
    fileprivate let cellIdentifier = "categoryCell"
    lazy var fetchedResultsController: NSFetchedResultsController<Category> = {
        let fetchRequest: NSFetchRequest<Category> = Category.fetchRequest()
        let nameSort = NSSortDescriptor(key: #keyPath(Category.categoryName), ascending: true)
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
        self.title = NSLocalizedString("My Categories", comment: "My Categories")
        self.tableView.scrollToNearestSelectedRow(at: UITableView.ScrollPosition.bottom, animated: true)
        do {
            try fetchedResultsController.performFetch()
        } catch let error as NSError {
            print("Fetching error: \(error), \(error.userInfo)")
            os_log("CategoryTableViewController viewDidLoad", log: Log.viewcontroller, type: .info)
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        let destination =  segue.destination as! CategoryEditViewController
        if segue.identifier == "editSegueCategory"  {
            let category = fetchedResultsController.object(at: self.tableView.indexPathForSelectedRow!)
            destination.currentCategory = category
        }
        if segue.identifier == "addSegueCategory"  {
            destination.currentCategory = nil
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
    func confirmDelete(category: Category) {
        let title = NSLocalizedString("Delete category", comment: "Delete category")
        let message = NSLocalizedString("Are you sure you really want to delete? Any related inventory will be deleted as well!", comment: "Are you sure you really want to delete")
        let myActionSheet = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        let DeleteAction = UIAlertAction(title: Global.delete + " \(category.categoryName!)", style: UIAlertAction.Style.destructive){ (ACTION) in
            _ = store.deleteCategory(category: category)
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
extension CategoryTableViewController {
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath)
    {
        let idx = IndexPath(row: indexPath.row, section: 0)
        tableView.selectRow(at: idx, animated: true, scrollPosition: .middle)
        performSegue(withIdentifier: "editSegueCategory", sender: self)
    }
    func configure(cell: UITableViewCell, for indexPath: IndexPath) {
        let category = fetchedResultsController.object(at: indexPath)
        cell.textLabel?.text = category.categoryName
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
            let category = fetchedResultsController.object(at: indexPath)
            confirmDelete(category: category)
        }
    }
}
extension CategoryTableViewController: NSFetchedResultsControllerDelegate {
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
            os_log("CategoryTableViewController controller", log: Log.viewcontroller, type: .error)
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
