import UIKit

class AKListProjectsViewController: AKCustomViewController, UITableViewDataSource, UITableViewDelegate
{
    // MARK: Constants
    struct LocalConstants {
        static let AKHeaderHeight: CGFloat = 34
        static let AKRowHeight: CGFloat = 52
    }
    
    // MARK: Properties
    var sortProjectsBy: ProjectSorting = ProjectSorting.creationDate
    var order: SortingOrder = SortingOrder.descending
    
    // MARK: Outlets
    @IBOutlet weak var projectsTable: UITableView!
    
    // MARK: Actions
    @IBAction func organizeProjects(_ sender: Any)
    {
        self.presentView(controller: AKSortProjectSelectorViewController(nibName: "AKSortProjectSelectorView", bundle: nil),
                         taskBeforePresenting: { (presenterController, presentedController) -> Void in },
                         dismissViewCompletionTask: { (presenterController, presentedController) -> Void in
                            NSLog("=> INFO: \(type(of: presentedController)) MODAL PRESENTATION HAS BEEN DISMISSED...")
                            
                            if let presenterController = presenterController as? AKListProjectsViewController, let presentedController = presentedController as? AKSortProjectSelectorViewController {
                                presenterController.sortProjectsBy = presentedController.filtersData[presentedController.filters.selectedRow(inComponent: 0)]
                                presenterController.order = presentedController.orderData[presentedController.order.selectedRow(inComponent: 0)]
                                presenterController.projectsTable.reloadData()
                            } }
        )
    }
    
    @IBAction func addNewProject(_ sender: Any)
    {
        self.presentView(controller: AKNewProjectViewController(nibName: "AKNewProjectView", bundle: nil),
                         taskBeforePresenting: { (presenterController, presentedController) -> Void in },
                         dismissViewCompletionTask: { (presenterController, presentedController) -> Void in
                            NSLog("=> INFO: \(type(of: presentedController)) MODAL PRESENTATION HAS BEEN DISMISSED...")
                            
                            if let presenterController = presenterController as? AKListProjectsViewController {
                                presenterController.projectsTable.reloadData()
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
                             taskBeforePresenting: { (presenterController, presentedController) -> Void in },
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
                        destination.navController.title = project.name ?? "View Project"
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
        cell.controller = self
        cell.project = project
        // OSR
        cell.osrValue.text = String(format: "%.1f", project.osr)
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
        // Times
        if let startingTime = project.startingTime as? Date {
            cell.startValue.text = String(
                format: "From: %.2i:%.2ih",
                Func.AKGetCalendarForLoading().dateComponents([.hour], from: startingTime).hour ?? 0,
                Func.AKGetCalendarForLoading().dateComponents([.minute], from: startingTime).minute ?? 0
            )
        }
        else {
            cell.startValue.isHidden = true
        }
        if let closingTime = project.closingTime as? Date {
            cell.closeValue.text = String(
                format: "To: %.2i:%.2ih",
                Func.AKGetCalendarForLoading().dateComponents([.hour], from: closingTime).hour ?? 0,
                Func.AKGetCalendarForLoading().dateComponents([.minute], from: closingTime).minute ?? 0
            )
        }
        else {
            cell.closeValue.isHidden = true
        }
        
        // Custom L&F.
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        cell.mainContainer.backgroundColor = GlobalConstants.AKTableCellBg
        
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
