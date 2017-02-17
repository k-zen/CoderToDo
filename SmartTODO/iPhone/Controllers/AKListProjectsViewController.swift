import UIKit

class AKListProjectsViewController: AKCustomViewController, UITableViewDataSource, UITableViewDelegate
{
    // MARK: Constants
    struct LocalConstants {
        static let AKHeaderHeight: CGFloat = 34
        static let AKRowHeight: CGFloat = 52
    }
    
    var sortProjectsBy: ProjectSorting = ProjectSorting.creationDate
    var order: SortingOrder = SortingOrder.descending
    
    // MARK: Outlets
    @IBOutlet weak var projectsTable: UITableView!
    
    // MARK: Actions
    @IBAction func organizeProjects(_ sender: Any)
    {
        self.presentView(controller: AKSortProjectSelectorViewController(nibName: "AKSortProjectSelectorView", bundle: nil),
                         dismissViewCompletionTask: { (presenterController, presentedController) -> Void in
                            NSLog("=> INFO: \(type(of: presentedController)) MODAL PRESENTATION HAS BEEN DISMISSED...")
                            
                            if let controller1 = presenterController as? AKListProjectsViewController, let controller2 = presentedController as? AKSortProjectSelectorViewController {
                                controller1.sortProjectsBy = controller2.filtersData[controller2.filters.selectedRow(inComponent: 0)]
                                controller1.order = controller2.orderData[controller2.order.selectedRow(inComponent: 0)]
                                controller1.projectsTable.reloadData()
                            } }
        )
    }
    
    @IBAction func addNewProject(_ sender: Any)
    {
        self.presentView(controller: AKNewProjectViewController(nibName: "AKNewProjectView", bundle: nil),
                         dismissViewCompletionTask: { (presenterController, presentedController) -> Void in
                            NSLog("=> INFO: \(type(of: presentedController)) MODAL PRESENTATION HAS BEEN DISMISSED...")
                            
                            if let controller = presenterController as? AKListProjectsViewController {
                                controller.projectsTable.reloadData()
                            } }
        )
    }
    
    // MARK: AKCustomViewController Overriding
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.customSetup()
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        
        // Checks
        if DataInterface.getUser()?.username == nil {
            self.presentView(controller: AKIntroductoryViewController(nibName: "AKIntroductoryView", bundle: nil),
                             dismissViewCompletionTask: { (presenterController, presentedController) -> Void in
                                NSLog("=> INFO: \(type(of: presentedController)) MODAL PRESENTATION HAS BEEN DISMISSED...") }
            )
            return
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if let identifier = segue.identifier {
            switch identifier {
            case GlobalConstants.AKViewProjectSegue:
                if let destination = segue.destination as? AKViewProjectViewController {
                    if let project = sender as? Project {
                        destination.project = project
                    }
                }
                break
            default:
                break
            }
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool
    {
        switch identifier {
        case GlobalConstants.AKViewProjectSegue:
            return true
        default:
            return false
        }
    }
    
    // MARK: UITableViewDataSource Implementation
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let project = DataInterface.getProjects(sortBy: self.sortProjectsBy, order: self.order)[(indexPath as NSIndexPath).section]
        
        let cell = self.projectsTable.dequeueReusableCell(withIdentifier: "ProjectsTableCell") as! AKProjectsTableViewCell
        cell.mainContainer.backgroundColor = GlobalConstants.AKTableCellBg
        // OSR
        cell.osrValue.text = String(format: "%.2f", project.osr)
        // Running Days
        cell.runningDaysValue.text = String(format: "%i running days", DataInterface.getProjectRunningDays(project: project))
        // Add Tomorrow Task
        if DataInterface.getProjectStatus(project: project) == ProjectStatus.ACEPTING_TASKS {
            cell.addTomorrowTask.isHidden = false
        }
        else {
            cell.addTomorrowTask.isHidden = true
        }
        // Project State
        cell.statusValue.text = DataInterface.getProjectStatus(project: project).rawValue
        
        // Custom L&F.
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        let project = DataInterface.getProjects(sortBy: self.sortProjectsBy, order: self.order)[section]
        
        let tableWidth = tableView.bounds.width
        let padding = CGFloat(8.0)
        let badgeSizeWidth = CGFloat(110.0)
        let badgeSizeHeight = CGFloat(21.0)
        
        let headerCell = UIView(frame: CGRect(x: 0, y: 0, width: tableWidth, height: LocalConstants.AKHeaderHeight))
        headerCell.backgroundColor = GlobalConstants.AKTableHeaderCellBg
        
        let title = UILabel(frame: CGRect(
            x: padding,
            y: 0,
            width: tableWidth - (padding * 3) - badgeSizeWidth,
            height: LocalConstants.AKHeaderHeight)
        )
        title.font = UIFont(name: GlobalConstants.AKDefaultFont, size: 18.0)
        title.textColor = GlobalConstants.AKDefaultFg
        title.text = project.name ?? "N/A"
        title.textAlignment = .left
        // ### DEBUG
        // title.layer.borderColor = UIColor.white.cgColor
        // title.layer.borderWidth = 1.0
        
        let pendingTasksBadgeContainer = UIView(frame: CGRect(
            x: tableWidth - padding - badgeSizeWidth,
            y: 0,
            width: badgeSizeWidth,
            height: LocalConstants.AKHeaderHeight)
        )
        // ### DEBUG
        // pendingTasksBadgeContainer.layer.borderColor = UIColor.white.cgColor
        // pendingTasksBadgeContainer.layer.borderWidth = 1.0
        
        let pendingTasksBadge = UILabel(frame: CGRect(
            x: pendingTasksBadgeContainer.frame.width - badgeSizeWidth,
            y: (LocalConstants.AKHeaderHeight - badgeSizeHeight) / 2.0,
            width: badgeSizeWidth,
            height: badgeSizeHeight)
        )
        pendingTasksBadge.font = UIFont(name: GlobalConstants.AKSecondaryFont, size: 12.0)
        pendingTasksBadge.textColor = GlobalConstants.AKBadgeColorFg
        pendingTasksBadge.backgroundColor = GlobalConstants.AKBadgeColorBg
        pendingTasksBadge.text = String(format: "Pending Tasks: %i", DataInterface.countProjectPendingTasks(project: project))
        pendingTasksBadge.textAlignment = .center
        pendingTasksBadge.layer.cornerRadius = GlobalConstants.AKButtonCornerRadius
        pendingTasksBadge.layer.masksToBounds = true
        // ### DEBUG
        // pendingTasksBadge.layer.borderColor = UIColor.white.cgColor
        // pendingTasksBadge.layer.borderWidth = 1.0
        
        pendingTasksBadgeContainer.addSubview(pendingTasksBadge)
        
        headerCell.addSubview(title)
        headerCell.addSubview(pendingTasksBadgeContainer)
        
        return headerCell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return DataInterface.countProjects()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return 1 }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool { return true }
    
    // MARK: UITableViewDelegate Implementation
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String?
    {
        return "Delete"
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath)
    {
        if editingStyle == UITableViewCellEditingStyle.delete {
            let project = DataInterface.getProjects(sortBy: self.sortProjectsBy, order: self.order)[(indexPath as NSIndexPath).row]
            
            DataInterface.getUser()?.removeFromProject(project)
            self.projectsTable.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle { return UITableViewCellEditingStyle.delete }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { return LocalConstants.AKRowHeight }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat { return LocalConstants.AKHeaderHeight }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat { return CGFloat.leastNormalMagnitude }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let project = DataInterface.getProjects(sortBy: self.sortProjectsBy, order: self.order)[(indexPath as NSIndexPath).section]
        self.performSegue(withIdentifier: GlobalConstants.AKViewProjectSegue, sender: project)
    }
    
    // MARK: Miscellaneous
    func customSetup()
    {
        super.inhibitTapGesture = true
        super.setup()
        
        // Custom Components
        self.projectsTable.register(UINib(nibName: "AKProjectsTableViewCell", bundle: nil), forCellReuseIdentifier: "ProjectsTableCell")
        
        // Add UITableView's DataSource & Delegate.
        self.projectsTable?.dataSource = self
        self.projectsTable?.delegate = self
    }
}
