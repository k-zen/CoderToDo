import UIKit

class AKBrainstormingBucketViewController: AKCustomViewController, UITableViewDataSource, UITableViewDelegate
{
    // MARK: Constants
    private struct LocalConstants {
        static let AKProjectListTableHeaderHeight: CGFloat = 4
        static let AKProjectListTableRowHeight: CGFloat = 40
        static let AKProjectListTableFooterHeight: CGFloat = 4
        
        static let AKBucketTableHeaderHeight: CGFloat = 4
        static let AKBucketTableRowHeight: CGFloat = 45
        static let AKBucketTableFooterHeight: CGFloat = 4
        
        static let AKProjectListTableTag = 1
        static let AKBucketTableTag = 2
    }
    
    // MARK: Properties
    var projectFilter = Filter(projectFilter: FilterProject())
    var selectedProject: Project?
    
    // MARK: Outlets
    @IBOutlet var mainContainer: UIView!
    @IBOutlet weak var projectListContainer: UIView!
    @IBOutlet weak var bucketContainer: UIView!
    @IBOutlet weak var messageContainer: UIView!
    @IBOutlet weak var projectListTable: UITableView!
    @IBOutlet weak var addEntry: UIButton!
    @IBOutlet weak var bucketTable: UITableView!
    
    // MARK: Actions
    @IBAction func addEntry(_ sender: Any)
    {
        self.showAddBucketEntry(animate: true, completionTask: nil)
    }
    
    // MARK: AKCustomViewController Overriding
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.customSetup()
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        Func.AKReloadTableWithAnimation(tableView: self.projectListTable)
        
        // Automatic select the most loaded bucket.
        self.selectedProject = DataInterface.mostLoadedBucket()
        // Hide the second table.
        if self.selectedProject == nil {
            self.bucketContainer.isHidden = true
            self.messageContainer.isHidden = false
        }
        else {
            self.bucketContainer.isHidden = false
            self.messageContainer.isHidden = true
        }
    }
    
    override func viewDidLayoutSubviews()
    {
        super.viewDidLayoutSubviews()
        
        // Custom L&F.
        self.addEntry.layer.cornerRadius = GlobalConstants.AKButtonCornerRadius
    }
    
    // MARK: UITableViewDataSource Implementation
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let project = DataInterface.getProjects(filter: self.projectFilter)[(indexPath as NSIndexPath).section]
        
        switch tableView.tag {
        case LocalConstants.AKProjectListTableTag:
            let cell = self.projectListTable.dequeueReusableCell(withIdentifier: "ConfigurationsTableCell") as! AKConfigurationsTableViewCell
            cell.title.text = project.name
            cell.arrowWidth.constant = 0
            cell.badgeWidth.constant = 70
            cell.badge.text = String(format: "Count: %i", DataInterface.countBucketEntries(project: project))
            
            // Custom L&F.
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            Func.AKAddBorderDeco(
                cell,
                color: GlobalConstants.AKTableHeaderCellBorderBg.cgColor,
                thickness: GlobalConstants.AKDefaultBorderThickness * 4.0,
                position: .left
            )
            
            return cell
        case LocalConstants.AKBucketTableTag:
            if let selectedProject = selectedProject {
                let bucketEntry = DataInterface.getBucketEntries(project: selectedProject)[(indexPath as NSIndexPath).row]
                
                let cell = self.bucketTable.dequeueReusableCell(withIdentifier: "BucketTableCell") as! AKBucketTableViewCell
                cell.nameValue.text = bucketEntry.name
                cell.dateValue.text = Func.AKGetFormattedDate(date: bucketEntry.creationDate as? Date)
                
                // Custom L&F.
                cell.selectionStyle = UITableViewCellSelectionStyle.none
                Func.AKAddBorderDeco(
                    cell.infoContainer,
                    color: GlobalConstants.AKTableHeaderCellBorderBg.cgColor,
                    thickness: GlobalConstants.AKDefaultBorderThickness * 4.0,
                    position: .left
                )
                
                return cell
            }
        default:
            break
        }
        
        let defaultCell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "Cell")
        defaultCell.selectionStyle = UITableViewCellSelectionStyle.none
        
        return defaultCell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        switch tableView.tag {
        case LocalConstants.AKProjectListTableTag:
            let headerCell = UIView(frame: CGRect(x: 0.0, y: 0.0, width: tableView.frame.width, height: LocalConstants.AKProjectListTableHeaderHeight))
            headerCell.backgroundColor = UIColor.clear
            
            return headerCell
        case LocalConstants.AKBucketTableTag:
            if let _ = selectedProject {
                let headerCell = UIView(frame: CGRect(x: 0.0, y: 0.0, width: tableView.frame.width, height: LocalConstants.AKBucketTableHeaderHeight))
                headerCell.backgroundColor = UIColor.clear
                
                return headerCell
            }
        default:
            break
        }
        
        let headerCell = UIView(frame: CGRect(x: 0.0, y: 0.0, width: tableView.frame.width, height: 0.0))
        headerCell.backgroundColor = UIColor.clear
        
        return headerCell
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView?
    {
        switch tableView.tag {
        case LocalConstants.AKProjectListTableTag:
            let footerCell = UIView(frame: CGRect(x: 0.0, y: 0.0, width: tableView.frame.width, height: LocalConstants.AKProjectListTableFooterHeight))
            footerCell.backgroundColor = UIColor.clear
            
            return footerCell
        case LocalConstants.AKBucketTableTag:
            if let _ = selectedProject {
                let footerCell = UIView(frame: CGRect(x: 0.0, y: 0.0, width: tableView.frame.width, height: LocalConstants.AKBucketTableFooterHeight))
                footerCell.backgroundColor = UIColor.clear
                
                return footerCell
            }
        default:
            break
        }
        
        let footerCell = UIView(frame: CGRect(x: 0.0, y: 0.0, width: tableView.frame.width, height: 0.0))
        footerCell.backgroundColor = UIColor.clear
        
        return footerCell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        switch tableView.tag {
        case LocalConstants.AKProjectListTableTag:
            return DataInterface.getProjects(filter: self.projectFilter).count
        case LocalConstants.AKBucketTableTag:
            return 1
        default:
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        switch tableView.tag {
        case LocalConstants.AKProjectListTableTag:
            return 1
        case LocalConstants.AKBucketTableTag:
            if let selectedProject = selectedProject {
                return DataInterface.countBucketEntries(project: selectedProject)
            }
            else {
                return 0
            }
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool
    {
        switch tableView.tag {
        case LocalConstants.AKBucketTableTag:
            return true
        default:
            break
        }
        
        return false
    }
    
    // MARK: UITableViewDelegate Implementation
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]?
    {
        // Delete Action
        let delete = UITableViewRowAction(style: .default, title: "Delete", handler: { (action, indexpath) -> Void in
            let bucketEntry = DataInterface.getBucketEntries(project: self.selectedProject!)[(indexPath as NSIndexPath).row]
            DataInterface.removeBucketEntry(project: self.selectedProject!, entry: bucketEntry)
            
            Func.AKReloadTableWithAnimation(tableView: self.bucketTable)
        })
        delete.backgroundColor = GlobalConstants.AKRedForWhiteFg
        
        return [delete];
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        switch tableView.tag {
        case LocalConstants.AKProjectListTableTag:
            return LocalConstants.AKProjectListTableRowHeight
        case LocalConstants.AKBucketTableTag:
            return LocalConstants.AKBucketTableRowHeight
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        switch tableView.tag {
        case LocalConstants.AKProjectListTableTag:
            return LocalConstants.AKProjectListTableHeaderHeight
        case LocalConstants.AKBucketTableTag:
            return LocalConstants.AKBucketTableHeaderHeight
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat { return CGFloat.leastNormalMagnitude }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        switch tableView.tag {
        case LocalConstants.AKProjectListTableTag:
            self.selectedProject = DataInterface.getProjects(filter: self.projectFilter)[(indexPath as NSIndexPath).section]
            // Show the second table.
            self.bucketContainer.isHidden = false
            self.messageContainer.isHidden = true
            // Load bucket table.
            Func.AKReloadTableWithAnimation(tableView: self.bucketTable)
            break
        default:
            break
        }
    }
    
    // MARK: Miscellaneous
    func customSetup()
    {
        super.inhibitTapGesture = true
        super.setup()
        
        // Custom Components
        self.projectListTable.register(UINib(nibName: "AKConfigurationsTableViewCell", bundle: nil), forCellReuseIdentifier: "ConfigurationsTableCell")
        self.bucketTable.register(UINib(nibName: "AKBucketTableViewCell", bundle: nil), forCellReuseIdentifier: "BucketTableCell")
        
        // Delegate & DataSource
        self.projectListTable.dataSource = self
        self.projectListTable.delegate = self
        self.projectListTable.tag = LocalConstants.AKProjectListTableTag
        self.bucketTable.dataSource = self
        self.bucketTable.delegate = self
        self.bucketTable.tag = LocalConstants.AKBucketTableTag
    }
}
