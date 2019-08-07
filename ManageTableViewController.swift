import UIKit
import os
class ManageTableViewController: UITableViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = true
        }
        self.title = NSLocalizedString("Manage items", comment: "Manage items table view title")
        self.tableView.scrollToNearestSelectedRow(at: UITableView.ScrollPosition.bottom, animated: true)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.scrollToNearestSelectedRow(at: UITableView.ScrollPosition.bottom, animated: true)
    }
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 61.0
    }
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int)
    {
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.font = UIFont(name: "HelveticaNeue", size: 20)!
        header.textLabel?.textColor = UIColor.lightGray
        header.backgroundView?.backgroundColor = themeColorUIControls
    }
}
