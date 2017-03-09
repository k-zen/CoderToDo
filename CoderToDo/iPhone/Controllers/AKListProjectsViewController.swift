import UIKit
import UserNotifications

class AKListProjectsViewController: AKCustomViewController, UITableViewDataSource, UITableViewDelegate
{
    // MARK: Constants
    private struct LocalConstants {
        static let AKHeaderHeight: CGFloat = 34.0
        static let AKRowHeight: CGFloat = 52.0
        static let AKDisplaceHeight: CGFloat = 40.0
    }
    
    // MARK: Properties
    var sortType = ProjectSorting.creationDate
    var sortOrder = SortingOrder.descending
    var filterType = ProjectFilter.status
    var filterValue = ProjectFilterStatus.none.rawValue
    var searchTerm = Search.showAll.rawValue
    
    // MARK: Outlets
    @IBOutlet weak var projectsTable: UITableView!
    @IBOutlet weak var menu: UIBarButtonItem!
    
    // MARK: Actions
    @IBAction func toggleMenu(_ sender: Any)
    {
        if !self.isMenuVisible {
            self.displaceDownTable(
                tableView: self.projectsTable,
                offset: LocalConstants.AKDisplaceHeight,
                animate: true,
                completionTask: { (controller) -> Void in
                    if let controller = controller as? AKListProjectsViewController {
                        controller.resetFilters(controller: controller)
                    } }
            )
        }
        else {
            self.displaceUpTable(
                tableView: self.projectsTable,
                offset: LocalConstants.AKDisplaceHeight,
                animate: true,
                completionTask: { (controller) -> Void in
                    if let controller = controller as? AKListProjectsViewController {
                        controller.resetFilters(controller: controller)
                        Func.AKReloadTableWithAnimation(tableView: controller.projectsTable)
                    } }
            )
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
    }
    
    override func viewDidLayoutSubviews()
    {
        super.viewDidLayoutSubviews()
        
        // Custom L&F.
        self.menu.setTitleTextAttributes(
            [
                NSFontAttributeName: UIFont(name: GlobalConstants.AKDefaultFont, size: GlobalConstants.AKNavBarFontSize) ?? UIFont.systemFont(ofSize: GlobalConstants.AKNavBarFontSize),
                NSForegroundColorAttributeName: GlobalConstants.AKDefaultFg
            ], for: .normal
        )
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
            case GlobalConstants.AKProjectConfigurationsSegue:
                if let destination = segue.destination as? AKProjectConfigurationsViewController {
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
        case GlobalConstants.AKProjectConfigurationsSegue:
            return true
        default:
            return false
        }
    }
    
    // MARK: UITableViewDataSource Implementation
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let project = DataInterface.getProjects(
            sortBy: self.sortType,
            sortOrder: self.sortOrder,
            filterType: self.filterType,
            filterValue: self.filterValue,
            searchTerm: self.searchTerm)[(indexPath as NSIndexPath).section]
        
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
        let project = DataInterface.getProjects(
            sortBy: self.sortType,
            sortOrder: self.sortOrder,
            filterType: self.filterType,
            filterValue: self.filterValue,
            searchTerm: self.searchTerm)[section]
        
        let tableWidth = tableView.frame.width
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
            x: pendingTasksBadgeContainer.frame.width - badgeSizeWidth,
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
        return DataInterface.getProjects(
            sortBy: self.sortType,
            sortOrder: self.sortOrder,
            filterType: self.filterType,
            filterValue: self.filterValue,
            searchTerm: self.searchTerm).count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return 1 }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool { return true }
    
    // MARK: UITableViewDelegate Implementation
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]?
    {
        // Edit Action
        let edit = UITableViewRowAction(style: .default, title: "Edit", handler: { (action, indexpath) -> Void in
            let project = DataInterface.getProjects(
                sortBy: self.sortType,
                sortOrder: self.sortOrder,
                filterType: self.filterType,
                filterValue: self.filterValue,
                searchTerm: self.searchTerm)[(indexPath as NSIndexPath).section]
            self.performSegue(withIdentifier: GlobalConstants.AKProjectConfigurationsSegue, sender: project)
        })
        edit.backgroundColor = GlobalConstants.AKCoderToDoBlue
        
        // Delete Action
        let delete = UITableViewRowAction(style: .default, title: "Delete", handler: { (action, indexpath) -> Void in
            self.showContinueMessage(
                message: "This action can't be undone. Continue...?",
                yesAction: { (presenterController) -> Void in
                    if let presenterController = presenterController as? AKListProjectsViewController {
                        let project = DataInterface.getProjects(
                            sortBy: presenterController.sortType,
                            sortOrder: presenterController.sortOrder,
                            filterType: presenterController.filterType,
                            filterValue: presenterController.filterValue,
                            searchTerm: presenterController.searchTerm)[(indexPath as NSIndexPath).row]
                        
                        // Remove data structure.
                        DataInterface.getUser()?.removeFromProject(project)
                        // Invalidate notifications.
                        Func.AKGetNotificationCenter().removePendingNotificationRequests(withIdentifiers:
                            [
                                String(format: "%@:%@", GlobalConstants.AKStartingTimeNotificationName, project.name!),
                                String(format: "%@:%@", GlobalConstants.AKClosingTimeNotificationName, project.name!)
                            ]
                        )
                        
                        Func.AKReloadTableWithAnimation(tableView: presenterController.projectsTable)
                    }
                    
                    presenterController?.hideContinueMessage(animate: true, completionTask: { (presenterController) -> Void in }) },
                noAction: { (presenterController) -> Void in
                    if let presenterController = presenterController as? AKListProjectsViewController {
                        Func.AKReloadTableWithAnimation(tableView: presenterController.projectsTable)
                    }
                    
                    presenterController?.hideContinueMessage(animate: true, completionTask: { (presenterController) -> Void in }) },
                animate: true,
                completionTask: nil
            )
        })
        delete.backgroundColor = GlobalConstants.AKRedForWhiteFg
        
        return [delete, edit];
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle { return UITableViewCellEditingStyle.delete }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { return LocalConstants.AKRowHeight }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat { return LocalConstants.AKHeaderHeight }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat { return CGFloat.leastNormalMagnitude }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let project = DataInterface.getProjects(
            sortBy: self.sortType,
            sortOrder: self.sortOrder,
            filterType: self.filterType,
            filterValue: self.filterValue,
            searchTerm: self.searchTerm)[(indexPath as NSIndexPath).section]
        self.performSegue(withIdentifier: GlobalConstants.AKViewProjectSegue, sender: project)
    }
    
    // MARK: Miscellaneous
    func customSetup()
    {
        super.inhibitLocalNotificationMessage = false
        super.inhibitTapGesture = true
        super.inhibitLongPressGesture = false
        super.additionalOperationsWhenLongPressed = { (gesture) -> Void in
            self.presentView(controller: AKNewProjectViewController(nibName: "AKNewProjectView", bundle: nil),
                             taskBeforePresenting: { _,_ in },
                             dismissViewCompletionTask: { (presenterController, presentedController) -> Void in
                                if let presenterController = presenterController as? AKListProjectsViewController {
                                    Func.AKReloadTableWithAnimation(tableView: presenterController.projectsTable)
                                } }
            )
        }
        super.setup()
        super.configureAnimations(displacementHeight: LocalConstants.AKDisplaceHeight)
        
        // Custom Components
        self.projectsTable.register(UINib(nibName: "AKProjectsTableViewCell", bundle: nil), forCellReuseIdentifier: "ProjectsTableCell")
        
        // Delegate & DataSource
        self.projectsTable?.dataSource = self
        self.projectsTable?.delegate = self
        
        // Custom Actions
        self.topMenuOverlay.addAction = { (presenterController) -> Void in
            if let presenterController = presenterController {
                presenterController.presentView(controller: AKNewProjectViewController(nibName: "AKNewProjectView", bundle: nil),
                                                taskBeforePresenting: { _,_ in },
                                                dismissViewCompletionTask: { (presenterController, presentedController) -> Void in
                                                    if let presenterController = presenterController as? AKListProjectsViewController {
                                                        Func.AKReloadTableWithAnimation(tableView: presenterController.projectsTable)
                                                    } }
                )
            }
        }
        self.topMenuOverlay.sortAction = { (presenterController) -> Void in
            if let presenterController = presenterController as? AKListProjectsViewController {
                if presenterController.isMenuItemVisible && presenterController.selectedMenuItem != .sort {
                    presenterController.toggleMenuItem(
                        tableView: presenterController.projectsTable,
                        menuItem: presenterController.selectedMenuItem,
                        animate: false,
                        completionTask: { (controller) -> Void in
                            if let controller = controller as? AKListProjectsViewController {
                                controller.resetFilters(controller: controller)
                            } }
                    )
                }
                
                presenterController.toggleMenuItem(
                    tableView: presenterController.projectsTable,
                    menuItem: .sort,
                    animate: true,
                    completionTask: { (controller) -> Void in
                        if let controller = controller as? AKListProjectsViewController {
                            controller.resetFilters(controller: controller)
                        } }
                )
            }
        }
        self.topMenuOverlay.filterAction = { (presenterController) -> Void in
            if let presenterController = presenterController as? AKListProjectsViewController {
                if presenterController.isMenuItemVisible && presenterController.selectedMenuItem != .filter {
                    presenterController.toggleMenuItem(
                        tableView: presenterController.projectsTable,
                        menuItem: presenterController.selectedMenuItem,
                        animate: false,
                        completionTask: { (controller) -> Void in
                            if let controller = controller as? AKListProjectsViewController {
                                controller.resetFilters(controller: controller)
                            } }
                    )
                }
                
                presenterController.toggleMenuItem(
                    tableView: presenterController.projectsTable,
                    menuItem: .filter,
                    animate: true,
                    completionTask: { (controller) -> Void in
                        if let controller = controller as? AKListProjectsViewController {
                            controller.resetFilters(controller: controller)
                        } }
                )
            }
        }
        self.topMenuOverlay.searchAction = { (presenterController) -> Void in
            if let presenterController = presenterController as? AKListProjectsViewController {
                if presenterController.isMenuItemVisible && presenterController.selectedMenuItem != .search {
                    presenterController.toggleMenuItem(
                        tableView: presenterController.projectsTable,
                        menuItem: presenterController.selectedMenuItem,
                        animate: false,
                        completionTask: { (controller) -> Void in
                            if let controller = controller as? AKListProjectsViewController {
                                controller.resetFilters(controller: controller)
                            } }
                    )
                }
                
                presenterController.toggleMenuItem(
                    tableView: presenterController.projectsTable,
                    menuItem: .search,
                    animate: true,
                    completionTask: { (controller) -> Void in
                        if let controller = controller as? AKListProjectsViewController {
                            controller.resetFilters(controller: controller)
                        } }
                )
            }
        }
    }
    
    func resetFilters(controller: AKCustomViewController) {
        self.sortType = ProjectSorting.creationDate
        self.sortOrder = SortingOrder.descending
        self.filterType = ProjectFilter.status
        self.filterValue = ProjectFilterStatus.none.rawValue
        self.searchTerm = Search.showAll.rawValue
        
        controller.sortMenuItemOverlay.order.selectRow(1, inComponent: 0, animated: true)
        controller.sortMenuItemOverlay.filters.selectRow(1, inComponent: 0, animated: true)
        
        controller.filterMenuItemOverlay.type.selectRow(0, inComponent: 0, animated: true)
        controller.filterMenuItemOverlay.filters.selectRow(0, inComponent: 0, animated: true)
        
        controller.searchMenuItemOverlay.searchBarCancelButtonClicked(controller.searchMenuItemOverlay.searchBar)
    }
}
