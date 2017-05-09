import UIKit

class AKBrainstormingBucketViewController: AKCustomViewController, UITableViewDataSource, UITableViewDelegate {
    // MARK: Constants
    private struct LocalConstants {
        static let AKProjectListTableHeaderHeight: CGFloat = 1.0
        static let AKProjectListTableRowHeight: CGFloat = 40.0
        static let AKProjectListTableFooterHeight: CGFloat = 1.0
        
        static let AKBucketTableHeaderHeight: CGFloat = 34
        static let AKBucketTableRowHeight: CGFloat = 45.0
        static let AKBucketTableFooterHeight: CGFloat = CGFloat.leastNormalMagnitude
        
        static let AKProjectListTableTag = 1
        static let AKBucketTableTag = 2
    }
    
    // MARK: Properties
    var projectFilter = Filter(projectFilter: FilterProject())
    var selectedProject: Project?
    var selectedBucketEntry: BucketEntry?
    var addBucketEntryOverlay: AKAddBucketEntryView?
    
    // MARK: Outlets
    @IBOutlet var mainContainer: UIView!
    @IBOutlet weak var projectListContainer: UIView!
    @IBOutlet weak var bucketContainer: UIView!
    @IBOutlet weak var projectListTable: UITableView!
    @IBOutlet weak var addEntry: UIBarButtonItem!
    @IBOutlet weak var bucketListTitle: UILabel!
    @IBOutlet weak var bucketTable: UITableView!
    
    // MARK: Actions
    @IBAction func addEntry(_ sender: Any) {
        if let _ = self.selectedProject {
            self.addBucketEntryOverlay = showAddBucketEntry(
                origin: CGPoint.zero,
                animate: true,
                completionTask: { (presenterController) -> Void in
                    if let presenterController = presenterController as? AKBrainstormingBucketViewController {
                        presenterController.addBucketEntryOverlay?.name.text = ""
                    } }
            )
        }
        else {
            self.showMessage(
                origin: CGPoint.zero,
                type: .info,
                message: "Select a project first.",
                animate: true,
                completionTask: nil
            )
        }
    }
    
    // MARK: AKCustomViewController Overriding
    override func viewDidLoad() {
        super.viewDidLoad()
        self.customSetup()
    }
    
    // MARK: UITableViewDataSource Implementation
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let project = DataInterface.getProjects(filter: self.projectFilter)[indexPath.section]
        
        switch tableView.tag {
        case LocalConstants.AKProjectListTableTag:
            let cell = self.projectListTable.dequeueReusableCell(withIdentifier: "ConfigurationsTableCell") as! AKConfigurationsTableViewCell
            cell.title.text = project.name
            cell.arrowWidth.constant = 0
            cell.badgeWidth.constant = 70
            cell.badge.text = String(format: "Count: %i", DataInterface.countBucketEntries(project: project, forDate: ""))
            
            // Custom L&F.
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            Func.AKAddBorderDeco(
                cell,
                color: Cons.AKTableHeaderCellBorderBg.cgColor,
                thickness: Cons.AKDefaultBorderThickness * 4.0,
                position: .left
            )
            
            return cell
        case LocalConstants.AKBucketTableTag:
            if let selectedProject = self.selectedProject {
                let date = DataInterface.getEntryDates(project: selectedProject)[indexPath.section]
                let bucketEntry = DataInterface.getBucketEntries(project: selectedProject, forDate: date)[indexPath.row]
                
                let cell = self.bucketTable.dequeueReusableCell(withIdentifier: "BucketTableCell") as! AKBucketTableViewCell
                cell.controller = self
                cell.nameValue.text = bucketEntry.name
                cell.priorityValue.text = Func.AKGetPriorityAsName(priority: bucketEntry.priority)
                cell.priorityValue.backgroundColor = bucketEntry.priority == 0 ? UIColor.clear : Func.AKGetColorForPriority(priority: Priority(rawValue: bucketEntry.priority)!)
                
                // Custom L&F.
                Func.AKAddBorderDeco(
                    cell.infoContainer,
                    color: bucketEntry.priority == 0 ? UIColor.clear.cgColor : Func.AKGetColorForPriority(priority: Priority(rawValue: bucketEntry.priority)!).cgColor,
                    thickness: Cons.AKDefaultBorderThickness * 4.0,
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
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch tableView.tag {
        case LocalConstants.AKProjectListTableTag:
            let headerCell = UIView(frame: CGRect(x: 0.0, y: 0.0, width: tableView.frame.width, height: LocalConstants.AKProjectListTableHeaderHeight))
            headerCell.backgroundColor = UIColor.clear
            
            return headerCell
        case LocalConstants.AKBucketTableTag:
            if let selectedProject = self.selectedProject {
                let date = DataInterface.getEntryDates(project: selectedProject)[section]
                
                let tableWidth = tableView.frame.width
                let padding = CGFloat(8.0)
                let badgeSizeWidth = CGFloat(60.0)
                let badgeSizeHeight = CGFloat(21.0)
                
                let headerCell = UIView(frame: CGRect(x: 0, y: 0, width: tableWidth, height: LocalConstants.AKBucketTableHeaderHeight))
                headerCell.backgroundColor = Cons.AKTableCellBg
                
                let title = UILabel(frame: CGRect(
                    x: 0.0,
                    y: 0.0,
                    width: tableWidth - (padding * 2.0) - badgeSizeWidth,
                    height: LocalConstants.AKBucketTableHeaderHeight)
                )
                title.font = UIFont(name: Cons.AKSecondaryFont, size: 19.0)
                title.textColor = Cons.AKDefaultFg
                title.text = date
                title.textAlignment = .left
                // ### DEBUG
                // title.layer.borderColor = UIColor.white.cgColor
                // title.layer.borderWidth = 1.0
                
                Func.AKAddBorderDeco(
                    title,
                    color: Cons.AKDefaultViewBorderBg.cgColor,
                    thickness: Cons.AKDefaultBorderThickness / 1.5,
                    position: .through
                )
                
                let tasksCountBadgeContainer = UIView(frame: CGRect(
                    x: tableWidth - padding - (badgeSizeWidth),
                    y: 0,
                    width: badgeSizeWidth,
                    height: LocalConstants.AKBucketTableHeaderHeight)
                )
                // ### DEBUG
                // tasksCountBadgeContainer.layer.borderColor = UIColor.white.cgColor
                // tasksCountBadgeContainer.layer.borderWidth = 1.0
                
                let tasksCountBadge = UILabel(frame: CGRect(
                    x: tasksCountBadgeContainer.frame.width - badgeSizeWidth,
                    y: (LocalConstants.AKBucketTableHeaderHeight - badgeSizeHeight) / 2.0,
                    width: badgeSizeWidth,
                    height: badgeSizeHeight)
                )
                tasksCountBadge.font = UIFont(name: Cons.AKDefaultFont, size: 12.0)
                tasksCountBadge.textColor = Cons.AKBadgeColorFg
                tasksCountBadge.backgroundColor = Cons.AKBadgeColorBg
                tasksCountBadge.text = String(format: "Entries: %i", DataInterface.countBucketEntries(project: selectedProject, forDate: date))
                tasksCountBadge.textAlignment = .center
                tasksCountBadge.layer.cornerRadius = Cons.AKButtonCornerRadius
                tasksCountBadge.layer.masksToBounds = true
                // ### DEBUG
                // tasksCountBadge.layer.borderColor = UIColor.white.cgColor
                // tasksCountBadge.layer.borderWidth = 1.0
                
                tasksCountBadgeContainer.addSubview(tasksCountBadge)
                
                headerCell.addSubview(title)
                headerCell.addSubview(tasksCountBadgeContainer)
                
                return headerCell
            }
        default:
            break
        }
        
        let headerCell = UIView(frame: CGRect(x: 0.0, y: 0.0, width: tableView.frame.width, height: 0.0))
        headerCell.backgroundColor = UIColor.clear
        
        return headerCell
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        switch tableView.tag {
        case LocalConstants.AKProjectListTableTag:
            let footerCell = UIView(frame: CGRect(x: 0.0, y: 0.0, width: tableView.frame.width, height: LocalConstants.AKProjectListTableFooterHeight))
            footerCell.backgroundColor = UIColor.clear
            
            return footerCell
        case LocalConstants.AKBucketTableTag:
            if let _ = self.selectedProject {
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
    
    func numberOfSections(in tableView: UITableView) -> Int {
        switch tableView.tag {
        case LocalConstants.AKProjectListTableTag:
            return DataInterface.getProjects(filter: self.projectFilter).count
        case LocalConstants.AKBucketTableTag:
            if let selectedProject = self.selectedProject {
                return DataInterface.getEntryDates(project: selectedProject).count
            }
            else {
                return 0
            }
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch tableView.tag {
        case LocalConstants.AKProjectListTableTag:
            return 1
        case LocalConstants.AKBucketTableTag:
            if let selectedProject = self.selectedProject {
                let date = DataInterface.getEntryDates(project: selectedProject)[section]
                
                return DataInterface.countBucketEntries(project: selectedProject, forDate: date)
            }
            else {
                return 0
            }
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool { return false }
    
    // MARK: UITableViewDelegate Implementation
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch tableView.tag {
        case LocalConstants.AKProjectListTableTag:
            return LocalConstants.AKProjectListTableRowHeight
        case LocalConstants.AKBucketTableTag:
            return LocalConstants.AKBucketTableRowHeight
        default:
            return 0.0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch tableView.tag {
        case LocalConstants.AKProjectListTableTag:
            return LocalConstants.AKProjectListTableHeaderHeight
        case LocalConstants.AKBucketTableTag:
            return LocalConstants.AKBucketTableHeaderHeight
        default:
            return 0.0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        switch tableView.tag {
        case LocalConstants.AKProjectListTableTag:
            return LocalConstants.AKProjectListTableFooterHeight
        case LocalConstants.AKBucketTableTag:
            return LocalConstants.AKBucketTableFooterHeight
        default:
            return 0.0
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch tableView.tag {
        case LocalConstants.AKProjectListTableTag:
            self.selectedProject = DataInterface.getProjects(filter: self.projectFilter)[indexPath.section]
            // Show the second table.
            self.bucketContainer.isHidden = false
            self.bucketListTitle.text = String(format: "Bucket list for: %@", self.selectedProject?.name ?? "")
            // Load bucket table.
            Func.AKReloadTable(tableView: self.bucketTable)
            break
        case LocalConstants.AKBucketTableTag:
            if let selectedProject = self.selectedProject {
                let date = DataInterface.getEntryDates(project: selectedProject)[indexPath.section]
                self.selectedBucketEntry = DataInterface.getBucketEntries(project: selectedProject, forDate: date)[indexPath.row]
                if let _ = self.selectedBucketEntry {
                    do {
                        try AKChecks.canAddTask(project: selectedProject)
                        self.showMigrateBucketEntry(
                            origin: CGPoint.zero,
                            animate: true,
                            completionTask: { (presenterController) -> Void in
                                if let presenterController = presenterController as? AKBrainstormingBucketViewController {
                                    presenterController.migrateBucketEntryOverlay.taskNameValue.text = presenterController.selectedBucketEntry?.name
                                } }
                        )
                    }
                    catch {
                        Func.AKPresentMessageFromError(controller: self, message: "\(error)")
                    }
                }
            }
            break
        default:
            break
        }
    }
    
    // MARK: Miscellaneous
    func customSetup() {
        self.inhibitTapGesture = true
        self.loadData = { (controller) -> Void in
            if let controller = controller as? AKBrainstormingBucketViewController {
                // Automatic select the most loaded bucket.
                controller.selectedProject = DataInterface.mostLoadedBucket()
                // Hide the second table.
                if controller.selectedProject == nil {
                    controller.bucketContainer.isHidden = true
                }
                else {
                    controller.bucketContainer.isHidden = false
                    controller.bucketListTitle.text = String(format: "Bucket list for: %@", controller.selectedProject?.name ?? "")
                }
                
                Func.AKReloadTable(tableView: controller.projectListTable)
                Func.AKReloadTable(tableView: controller.bucketTable)
                
                // Show message if the are no projects.
                if DataInterface.getProjects(filter: controller.projectFilter).count > 0 {
                    controller.hideInitialMessage(animate: true, completionTask: nil)
                }
                else {
                    var origin = Func.AKCenterScreenCoordinate(
                        container: controller.view,
                        width: AKInitialMessageView.LocalConstants.AKViewWidth,
                        height: AKInitialMessageView.LocalConstants.AKViewHeight
                    )
                    origin.y -= 0.0
                    
                    controller.showInitialMessage(
                        origin: origin,
                        title: "Hello..!",
                        message: "Add a project first in order to start adding entries to the bucket.",
                        animate: false,
                        completionTask: nil
                    )
                }
            }
        }
        self.setup()
        
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
