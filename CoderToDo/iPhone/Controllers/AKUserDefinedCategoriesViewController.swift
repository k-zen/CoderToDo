import UIKit

class AKUserDefinedCategoriesViewController: AKCustomViewController, UITableViewDataSource, UITableViewDelegate
{
    // MARK: Constants
    private struct LocalConstants {
        static let AKHeaderHeight: CGFloat = 0.5
        static let AKRowHeight: CGFloat = 40
        static let AKFooterHeight: CGFloat = 0.5
    }
    
    // MARK: Properties
    var project: Project!
    
    // MARK: Outlets
    @IBOutlet weak var userDefinedCategoriesTable: UITableView!
    
    // MARK: AKCustomViewController Overriding
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.customSetup()
    }
    
    // MARK: UITableViewDataSource Implementation
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = self.userDefinedCategoriesTable.dequeueReusableCell(withIdentifier: "ConfigurationsTableCell") as! AKConfigurationsTableViewCell
        cell.title.text = DataInterface.listProjectCategories(project: self.project)[(indexPath as NSIndexPath).section]
        cell.arrowWidth.constant = 0
        
        // Custom L&F.
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        cell.mainContainer.backgroundColor = GlobalConstants.AKTableCellBg
        Func.AKAddBorderDeco(
            cell,
            color: GlobalConstants.AKTableCellBorderBg.cgColor,
            thickness: GlobalConstants.AKDefaultBorderThickness * 4.0,
            position: .left
        )
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        let headerCell = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: LocalConstants.AKHeaderHeight))
        headerCell.backgroundColor = UIColor.clear
        
        return headerCell
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView?
    {
        let footerCell = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: LocalConstants.AKFooterHeight))
        footerCell.backgroundColor = UIColor.clear
        
        return footerCell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int { return DataInterface.listProjectCategories(project: self.project).count }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return 1 }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool { return true }
    
    // MARK: UITableViewDelegate Implementation
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]?
    {
        // Delete Action
        let delete = UITableViewRowAction(style: .default, title: "Delete", handler: { (action, indexpath) -> Void in
            do {
                try DataInterface.removeProjectCategory(project: self.project, name: DataInterface.listProjectCategories(project: self.project)[(indexPath as NSIndexPath).section])
            }
            catch {
                Func.AKPresentMessageFromError(controller: self, message: "\(error)", autoDismiss: true)
            }
            
            Func.AKReloadTableWithAnimation(tableView: self.userDefinedCategoriesTable)
        })
        delete.backgroundColor = GlobalConstants.AKRedForWhiteFg
        
        return [delete];
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { return LocalConstants.AKRowHeight }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat { return LocalConstants.AKHeaderHeight }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat { return LocalConstants.AKFooterHeight }
    
    // MARK: Miscellaneous
    func customSetup()
    {
        self.inhibitTapGesture = true
        self.setup()
        
        // Custom Components
        self.userDefinedCategoriesTable.register(UINib(nibName: "AKConfigurationsTableViewCell", bundle: nil), forCellReuseIdentifier: "ConfigurationsTableCell")
        
        // Delegate & DataSource
        self.userDefinedCategoriesTable?.dataSource = self
        self.userDefinedCategoriesTable?.delegate = self
    }
}
