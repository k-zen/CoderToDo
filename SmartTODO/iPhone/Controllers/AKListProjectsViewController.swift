import UIKit

class AKListProjectsViewController: AKCustomViewController, UITableViewDataSource, UITableViewDelegate
{
    // MARK: Constants
    struct LocalConstants {
        static let AKHeaderHeight: CGFloat = 40
        static let AKRowHeight: CGFloat = 86
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
    
    // MARK: UITableViewDataSource Implementation
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let element = DataInterface.getProjects(sortBy: self.sortProjectsBy, order: self.order)[(indexPath as NSIndexPath).section]
        
        let cell = self.projectsTable.dequeueReusableCell(withIdentifier: "ProjectsTableCell") as! AKProjectsTableViewCell
        cell.mainContainer.backgroundColor = GlobalConstants.AKTableCellBg
        // OSR
        cell.osrValue.text = String(format: "%.2f", element.osr)
        // Running Days
        cell.runningDaysValue.text = String(format: "%i running days", DataInterface.getProjectRunningDays(element: element))
        // Add Tomorrow Task
        if DataInterface.getProjectStatus(element: element) == ProjectStatus.ACEPTING_TASKS {
            cell.addTomorrowTask.isEnabled = true
            cell.addTomorrowTask.backgroundColor = GlobalConstants.AKEnabledButtonBg
        }
        else {
            cell.addTomorrowTask.isEnabled = false
            cell.addTomorrowTask.backgroundColor = GlobalConstants.AKDisabledButtonBg
        }
        // Project State
        cell.statusValue.text = DataInterface.getProjectStatus(element: element).rawValue
        
        // Custom L&F.
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        // cell.osrValue.layer.cornerRadius = GlobalConstants.AKButtonCornerRadius
        // cell.osrValue.layer.masksToBounds = true
        // cell.stateContainer.layer.cornerRadius = GlobalConstants.AKButtonCornerRadius
        // cell.stateContainer.layer.masksToBounds = true
        // cell.addTomorrowTask.layer.cornerRadius = GlobalConstants.AKButtonCornerRadius
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        let element = DataInterface.getProjects(sortBy: self.sortProjectsBy, order: self.order)[section]
        
        let tableWidth = tableView.bounds.width
        let padding = CGFloat(8.0)
        let badgeSize = CGFloat(31.0)
        
        let headerCell = UIView(frame: CGRect(x: 0, y: 0, width: tableWidth, height: LocalConstants.AKHeaderHeight))
        headerCell.backgroundColor = GlobalConstants.AKTableHeaderCellBg
        
        let title = UILabel(frame: CGRect(
            x: padding,
            y: 0,
            width: tableWidth - (padding * 3) - badgeSize,
            height: LocalConstants.AKHeaderHeight)
        )
        title.font = UIFont(name: GlobalConstants.AKDefaultFont, size: 20.0)
        title.textColor = GlobalConstants.AKDefaultFg
        title.text = element.name ?? "N/A"
        title.textAlignment = .left
        // ### DEBUG
        // title.layer.borderColor = UIColor.white.cgColor
        // title.layer.borderWidth = 1.0
        
        let runningDaysBadgeContainer = UIView(frame: CGRect(
            x: tableWidth - padding - badgeSize,
            y: 0,
            width: badgeSize,
            height: LocalConstants.AKHeaderHeight)
        )
        // ### DEBUG
        // runningDaysBadgeContainer.layer.borderColor = UIColor.white.cgColor
        // runningDaysBadgeContainer.layer.borderWidth = 1.0
        
        let runningDaysBadge = UILabel(frame: CGRect(
            x: runningDaysBadgeContainer.frame.width - badgeSize,
            y: (LocalConstants.AKHeaderHeight - badgeSize) / 2.0,
            width: badgeSize,
            height: badgeSize)
        )
        runningDaysBadge.font = UIFont(name: GlobalConstants.AKSecondaryFont, size: 12.0)
        runningDaysBadge.textColor = GlobalConstants.AKDefaultFg
        runningDaysBadge.backgroundColor = GlobalConstants.AKEnabledButtonBg
        runningDaysBadge.text = String(format: "%i", DataInterface.countProjectPendingTasks(element: element))
        runningDaysBadge.textAlignment = .center
        runningDaysBadge.layer.cornerRadius = badgeSize / 2.0
        runningDaysBadge.layer.masksToBounds = true
        // ### DEBUG
        // runningDaysBadge.layer.borderColor = UIColor.white.cgColor
        // runningDaysBadge.layer.borderWidth = 1.0
        
        runningDaysBadgeContainer.addSubview(runningDaysBadge)
        
        headerCell.addSubview(title)
        headerCell.addSubview(runningDaysBadgeContainer)
        
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
            let element = DataInterface.getProjects(sortBy: self.sortProjectsBy, order: self.order)[(indexPath as NSIndexPath).row]
            
            DataInterface.getUser()?.removeFromProject(element)
            self.projectsTable.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle { return UITableViewCellEditingStyle.delete }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { return LocalConstants.AKRowHeight }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat { return LocalConstants.AKHeaderHeight }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat { return CGFloat.leastNormalMagnitude }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let element = DataInterface.getProjects(sortBy: self.sortProjectsBy, order: self.order)[(indexPath as NSIndexPath).section]
        
        self.performSegue(withIdentifier: "ViewProjectSegue", sender: element)
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
