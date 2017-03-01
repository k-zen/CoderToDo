import UIKit
import UserNotifications

class AKListProjectsViewController: AKCustomViewController, UITableViewDataSource, UITableViewDelegate
{
    // MARK: Constants
    struct LocalConstants {
        static let AKHeaderHeight: CGFloat = 34.0
        static let AKRowHeight: CGFloat = 52.0
        static let AKDisplaceDownAnimation = "displaceDown"
        static let AKDisplaceUpAnimation = "displaceUp"
        static let AKDisplaceHeight: CGFloat = 40.0
    }
    
    // MARK: Properties
    let displaceDownProjectsTable = CABasicAnimation(keyPath: LocalConstants.AKDisplaceDownAnimation)
    let displaceUpProjectsTable = CABasicAnimation(keyPath: LocalConstants.AKDisplaceUpAnimation)
    var sortProjectsBy: ProjectSorting = ProjectSorting.creationDate
    var order: SortingOrder = SortingOrder.descending
    
    // MARK: Outlets
    @IBOutlet weak var projectsTable: UITableView!
    @IBOutlet weak var menu: UIBarButtonItem!
    
    // MARK: Actions
    @IBAction func toggleMenu(_ sender: Any)
    {
        if self.projectsTable.frame.origin.y == 0.0 {
            self.showTopMenu()
            
            UIView.beginAnimations(LocalConstants.AKDisplaceDownAnimation, context: nil)
            self.projectsTable.frame = CGRect(
                x: self.projectsTable.frame.origin.x,
                y: self.projectsTable.frame.origin.y + LocalConstants.AKDisplaceHeight,
                width: self.projectsTable.frame.width,
                height: self.projectsTable.frame.height - LocalConstants.AKDisplaceHeight
            )
            UIView.commitAnimations()
        }
        else {
            self.hideTopMenu()
            
            UIView.beginAnimations(LocalConstants.AKDisplaceUpAnimation, context: nil)
            self.projectsTable.frame = CGRect(
                x: self.projectsTable.frame.origin.x,
                y: self.projectsTable.frame.origin.y - LocalConstants.AKDisplaceHeight,
                width: self.projectsTable.frame.width,
                height: self.projectsTable.frame.height + LocalConstants.AKDisplaceHeight
            )
            UIView.commitAnimations()
        }
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
        // If it's the first time the user uses the App.
        // 1. Show Intro view.
        // 2. Cancel all local notifications, that the App might had previously created.
        if DataInterface.getUser()?.username == nil {
            // 1. Present Intro view.
            self.presentView(controller: AKIntroductoryViewController(nibName: "AKIntroductoryView", bundle: nil),
                             taskBeforePresenting: { (presenterController, presentedController) -> Void in },
                             dismissViewCompletionTask: { (presenterController, presentedController) -> Void in
                                NSLog("=> INFO: \(type(of: presentedController)) MODAL PRESENTATION HAS BEEN DISMISSED...") }
            )
            // 2. Clear all notifications from previous installs.
            Func.AKGetNotificationCenter().removeAllDeliveredNotifications()
            Func.AKGetNotificationCenter().removeAllPendingNotificationRequests()
            
            return
        }
        
        // Always reload the table!
        self.projectsTable?.reloadData()
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
        cell.osrValue.text = String(format: "%.2f", DataInterface.computeOSR(project: project))
        // Running Days
        let runningDays = DataInterface.getProjectRunningDays(project: project)
        cell.runningDaysValue.text = String(format: "%i running %@", runningDays, runningDays > 1 ? "days" : "day")
        // Add Tomorrow Task
        if DataInterface.getProjectStatus(project: project) == ProjectStatus.ACEPTING_TASKS || DataInterface.getProjectStatus(project: project) == ProjectStatus.FIRST_DAY {
            cell.addTomorrowTask.isHidden = false
        }
        else {
            cell.addTomorrowTask.isHidden = true
        }
        // Project State
        cell.statusValue.text = DataInterface.getProjectStatus(project: project).rawValue
        switch DataInterface.getProjectStatus(project: project) {
        case ProjectStatus.ACEPTING_TASKS:
            Func.AKAddBorderDeco(
                cell.statusValue,
                color: GlobalConstants.AKBlueForWhiteFg.cgColor,
                thickness: GlobalConstants.AKDefaultBorderThickness,
                position: .bottom
            )
            break
        case ProjectStatus.OPEN:
            Func.AKAddBorderDeco(
                cell.statusValue,
                color: GlobalConstants.AKGreenForWhiteFg.cgColor,
                thickness: GlobalConstants.AKDefaultBorderThickness,
                position: .bottom
            )
            break
        case ProjectStatus.CLOSED:
            Func.AKAddBorderDeco(
                cell.statusValue,
                color: GlobalConstants.AKRedForWhiteFg.cgColor,
                thickness: GlobalConstants.AKDefaultBorderThickness,
                position: .bottom
            )
            break
        case ProjectStatus.FIRST_DAY:
            Func.AKAddBorderDeco(
                cell.statusValue,
                color: GlobalConstants.AKOrangeForWhiteFg.cgColor,
                thickness: GlobalConstants.AKDefaultBorderThickness,
                position: .bottom
            )
            break
        }
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
        cell.addTomorrowTask.layer.cornerRadius = GlobalConstants.AKButtonCornerRadius
        Func.AKAddBorderDeco(
            cell.infoContainer,
            color: GlobalConstants.AKTableCellBorderBg.cgColor,
            thickness: GlobalConstants.AKDefaultBorderThickness * 4.0,
            position: .left
        )
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        let project = DataInterface.getProjects(sortBy: self.sortProjectsBy, order: self.order)[section]
        
        let tableWidth = tableView.bounds.width
        let padding = CGFloat(8.0)
        let badgeSizeWidth = CGFloat(130.0)
        let badgeSizeHeight = CGFloat(21.0)
        
        let headerCell = UIView(frame: CGRect(x: 0, y: 0, width: tableWidth, height: LocalConstants.AKHeaderHeight))
        headerCell.backgroundColor = GlobalConstants.AKTableHeaderCellBg
        Func.AKAddBorderDeco(
            headerCell,
            color: GlobalConstants.AKTableHeaderCellBorderBg.cgColor,
            thickness: GlobalConstants.AKDefaultBorderThickness * 4.0,
            position: .left
        )
        
        let title = UILabel(frame: CGRect(
            x: padding * 2,
            y: 0,
            width: tableWidth - (padding * 3) - badgeSizeWidth,
            height: LocalConstants.AKHeaderHeight)
        )
        title.font = UIFont(name: GlobalConstants.AKSecondaryFont, size: 18.0)
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
            x: pendingTasksBadgeContainer.bounds.width - badgeSizeWidth,
            y: (LocalConstants.AKHeaderHeight - badgeSizeHeight) / 2.0,
            width: badgeSizeWidth,
            height: badgeSizeHeight)
        )
        pendingTasksBadge.font = UIFont(name: GlobalConstants.AKDefaultFont, size: 14.0)
        pendingTasksBadge.textColor = GlobalConstants.AKBadgeColorFg
        pendingTasksBadge.backgroundColor = GlobalConstants.AKBadgeColorBg
        pendingTasksBadge.text = String(format: "Pending Tasks: %i", DataInterface.countProjectPendingTasks(project: project))
        pendingTasksBadge.textAlignment = .right
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
            
            // Remove data structure.
            DataInterface.getUser()?.removeFromProject(project)
            // Invalidate notifications.
            Func.AKGetNotificationCenter().removePendingNotificationRequests(withIdentifiers:
                [
                    String(format: "%@:%@", GlobalConstants.AKStartingTimeNotificationName, project.name!),
                    String(format: "%@:%@", GlobalConstants.AKClosingTimeNotificationName, project.name!)
                ]
            )
            
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
        super.inhibitLocalNotificationMessage = false
        super.inhibitTapGesture = true
        super.setup()
        
        // Custom Components
        self.projectsTable.register(UINib(nibName: "AKProjectsTableViewCell", bundle: nil), forCellReuseIdentifier: "ProjectsTableCell")
        
        // Add UITableView's DataSource & Delegate.
        self.projectsTable?.dataSource = self
        self.projectsTable?.delegate = self
        
        // Animations
        self.displaceDownProjectsTable.fromValue = 0.0
        self.displaceDownProjectsTable.toValue = LocalConstants.AKDisplaceHeight
        self.displaceDownProjectsTable.duration = 1.0
        self.displaceDownProjectsTable.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        self.displaceDownProjectsTable.autoreverses = false
        self.view.layer.add(self.displaceDownProjectsTable, forKey: LocalConstants.AKDisplaceDownAnimation)
        
        self.displaceUpProjectsTable.fromValue = LocalConstants.AKDisplaceHeight
        self.displaceUpProjectsTable.toValue = 0.0
        self.displaceUpProjectsTable.duration = 1.0
        self.displaceUpProjectsTable.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        self.displaceUpProjectsTable.autoreverses = false
        self.view.layer.add(self.displaceUpProjectsTable, forKey: LocalConstants.AKDisplaceUpAnimation)
        
        // Custom Actions
        self.topMenuOverlayController.addAction = { (presenterController) -> Void in
            if let presenterController = presenterController {
                presenterController.presentView(controller: AKNewProjectViewController(nibName: "AKNewProjectView", bundle: nil),
                                                taskBeforePresenting: { (presenterController, presentedController) -> Void in },
                                                dismissViewCompletionTask: { (presenterController, presentedController) -> Void in
                                                    NSLog("=> INFO: \(type(of: presentedController)) MODAL PRESENTATION HAS BEEN DISMISSED...")
                                                    
                                                    if let presenterController = presenterController as? AKListProjectsViewController {
                                                        presenterController.projectsTable.reloadData()
                                                    } }
                )
            }
        }
        self.topMenuOverlayController.sortAction = { (presenterController) -> Void in
            if let presenterController = presenterController {
                presenterController.presentView(controller: AKSortProjectSelectorViewController(nibName: "AKSortProjectSelectorView", bundle: nil),
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
        }
        
        // Custom L&F.
        self.menu.setTitleTextAttributes(
            [
                NSFontAttributeName: UIFont(name: GlobalConstants.AKDefaultFont, size: GlobalConstants.AKNavBarFontSize) ?? UIFont.systemFont(ofSize: GlobalConstants.AKNavBarFontSize),
                NSForegroundColorAttributeName: GlobalConstants.AKDefaultFg
            ], for: .normal
        )
    }
}
