import Charts
import UIKit
import UserNotifications

class AKListProjectsViewController: AKCustomViewController, UITableViewDataSource, UITableViewDelegate
{
    // MARK: Constants
    private struct LocalConstants {
        static let AKHeaderHeight: CGFloat = 34.0
        static let AKRowHeight: CGFloat = 52.0
        static let AKFooterHeight: CGFloat = 1.0
        static let AKDisplaceHeight: CGFloat = 40.0
    }
    
    // MARK: Properties
    var projectFilter = Filter(projectFilter: FilterProject())
    
    // MARK: Outlets
    @IBOutlet weak var projectsTable: UITableView!
    @IBOutlet weak var chartContainer: UIView!
    @IBOutlet weak var mostProductiveDay: UILabel!
    @IBOutlet weak var osrChartContainer: BarChartView!
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
            case GlobalConstants.AKViewProjectConfigurationsSegue:
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
        case GlobalConstants.AKViewProjectConfigurationsSegue:
            return true
        default:
            return false
        }
    }
    
    // MARK: UITableViewDataSource Implementation
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let project = DataInterface.getProjects(filter: self.projectFilter)[(indexPath as NSIndexPath).section]
        
        let cell = self.projectsTable.dequeueReusableCell(withIdentifier: "ProjectsTableCell") as! AKProjectsTableViewCell
        cell.controller = self
        cell.project = project
        // OSR
        cell.osrValue.text = String(format: "%.2f", DataInterface.computeOSR(project: project))
        // Running Days
        let runningDays = DataInterface.getProjectRunningDays(project: project)
        cell.runningDaysValue.text = String(format: "%i running %@", runningDays, runningDays > 1 ? "days" : "day")
        // Add Tomorrow Task
        if DataInterface.getProjectStatus(project: project) == .accepting || DataInterface.getProjectStatus(project: project) == .firstDay {
            cell.addTomorrowTask.isHidden = false
        }
        else {
            cell.addTomorrowTask.isHidden = true
        }
        // Times
        if let startingTime = project.startingTime as Date? {
            cell.startValue.text = String(
                format: "From: %.2i:%.2ih",
                Func.AKGetCalendarForLoading().dateComponents([.hour], from: startingTime).hour ?? 0,
                Func.AKGetCalendarForLoading().dateComponents([.minute], from: startingTime).minute ?? 0
            )
        }
        else {
            cell.startValue.isHidden = true
        }
        if let closingTime = project.closingTime as Date? {
            cell.closeValue.text = String(
                format: "To: %.2i:%.2ih (%i min)",
                Func.AKGetCalendarForLoading().dateComponents([.hour], from: closingTime).hour ?? 0,
                Func.AKGetCalendarForLoading().dateComponents([.minute], from: closingTime).minute ?? 0,
                project.closingTimeTolerance
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
        let project = DataInterface.getProjects(filter: self.projectFilter)[section]
        let projectStatus = DataInterface.getProjectStatus(project: project)
        
        let tableWidth = tableView.frame.width
        let padding = CGFloat(8.0)
        let firstBadgeSizeWidth = CGFloat(100.0)
        let firstBadgeSizeHeight = CGFloat(21.0)
        let secondBadgeSizeWidth = CGFloat(60.0)
        let secondBadgeSizeHeight = CGFloat(21.0)
        let paddingBetweenBadges = CGFloat(4.0)
        
        let headerCell = UIView(frame: CGRect(x: 0, y: 0, width: tableWidth, height: LocalConstants.AKHeaderHeight))
        headerCell.backgroundColor = GlobalConstants.AKTableHeaderCellBg
        Func.AKAddBorderDeco(
            headerCell,
            color: GlobalConstants.AKTableHeaderCellBorderBg.cgColor,
            thickness: GlobalConstants.AKDefaultBorderThickness * 4.0,
            position: .left
        )
        
        let title = UILabel(frame: CGRect(
            x: padding * 2.0,
            y: 0.0,
            width: tableWidth - (padding * 3) - firstBadgeSizeWidth - secondBadgeSizeWidth - paddingBetweenBadges,
            height: LocalConstants.AKHeaderHeight)
        )
        title.font = UIFont(name: GlobalConstants.AKSecondaryFont, size: 19.0)
        title.textColor = GlobalConstants.AKDefaultFg
        title.text = project.name ?? "N/A"
        title.textAlignment = .left
        // ### DEBUG
        // title.layer.borderColor = UIColor.white.cgColor
        // title.layer.borderWidth = 1.0
        
        let firstBadgeContainer = UIView(frame: CGRect(
            x: tableWidth - padding - firstBadgeSizeWidth - secondBadgeSizeWidth - paddingBetweenBadges,
            y: 0.0,
            width: firstBadgeSizeWidth,
            height: LocalConstants.AKHeaderHeight)
        )
        // ### DEBUG
        // firstBadgeContainer.layer.borderColor = UIColor.white.cgColor
        // firstBadgeContainer.layer.borderWidth = 1.0
        
        let firstBadge = UILabel(frame: CGRect(
            x: firstBadgeContainer.frame.width - firstBadgeSizeWidth,
            y: (LocalConstants.AKHeaderHeight - firstBadgeSizeHeight) / 2.0,
            width: firstBadgeSizeWidth,
            height: firstBadgeSizeHeight)
        )
        firstBadge.font = UIFont(name: GlobalConstants.AKDefaultFont, size: 14.0)
        firstBadge.textColor = GlobalConstants.AKBadgeColorFg
        firstBadge.backgroundColor = GlobalConstants.AKBadgeColorBg
        firstBadge.text = String(format: "Pending Tasks: %i", DataInterface.countProjectPendingTasks(project: project))
        firstBadge.textAlignment = .center
        firstBadge.layer.cornerRadius = GlobalConstants.AKButtonCornerRadius
        firstBadge.layer.masksToBounds = true
        // ### DEBUG
        // firstBadge.layer.borderColor = UIColor.white.cgColor
        // firstBadge.layer.borderWidth = 1.0
        
        firstBadgeContainer.addSubview(firstBadge)
        
        let secondBadgeContainer = UIView(frame: CGRect(
            x: tableWidth - padding - secondBadgeSizeWidth,
            y: 0.0,
            width: secondBadgeSizeWidth,
            height: LocalConstants.AKHeaderHeight)
        )
        // ### DEBUG
        // secondBadgeContainer.layer.borderColor = UIColor.white.cgColor
        // secondBadgeContainer.layer.borderWidth = 1.0
        
        let secondBadge = UILabel(frame: CGRect(
            x: secondBadgeContainer.frame.width - secondBadgeSizeWidth,
            y: (LocalConstants.AKHeaderHeight - secondBadgeSizeHeight) / 2.0,
            width: secondBadgeSizeWidth,
            height: secondBadgeSizeHeight)
        )
        secondBadge.font = UIFont(name: GlobalConstants.AKDefaultFont, size: 12.0)
        secondBadge.textColor = GlobalConstants.AKBadgeColorFg
        secondBadge.backgroundColor = Func.AKGetColorForProjectStatus(projectStatus: projectStatus)
        secondBadge.text = String(format: "%@", projectStatus.rawValue)
        secondBadge.textAlignment = .center
        secondBadge.layer.cornerRadius = GlobalConstants.AKButtonCornerRadius
        secondBadge.layer.masksToBounds = true
        // ### DEBUG
        // secondBadge.layer.borderColor = UIColor.white.cgColor
        // secondBadge.layer.borderWidth = 1.0
        
        secondBadgeContainer.addSubview(secondBadge)
        
        headerCell.addSubview(title)
        headerCell.addSubview(firstBadgeContainer)
        headerCell.addSubview(secondBadgeContainer)
        
        return headerCell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int { return DataInterface.getProjects(filter: self.projectFilter).count }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return 1 }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool { return true }
    
    // MARK: UITableViewDelegate Implementation
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]?
    {
        // Edit Action
        let edit = UITableViewRowAction(style: .default, title: "Edit", handler: { (action, indexpath) -> Void in
            let project = DataInterface.getProjects(filter: self.projectFilter)[(indexPath as NSIndexPath).section]
            self.performSegue(withIdentifier: GlobalConstants.AKViewProjectConfigurationsSegue, sender: project)
        })
        edit.backgroundColor = GlobalConstants.AKCoderToDoBlue
        
        // Delete Action
        let delete = UITableViewRowAction(style: .default, title: "Delete", handler: { (action, indexpath) -> Void in
            self.showContinueMessage(
                origin: CGPoint.zero,
                message: "This action can't be undone. Continue...?",
                yesAction: { (presenterController) -> Void in
                    if let presenterController = presenterController as? AKListProjectsViewController {
                        let project = DataInterface.getProjects(filter: presenterController.projectFilter)[(indexPath as NSIndexPath).row]
                        
                        // Remove data structure.
                        DataInterface.getUser()?.removeFromProject(project)
                        // Invalidate notifications.
                        Func.AKInvalidateLocalNotification(controller: self, project: project)
                        
                        Func.AKReloadTableWithAnimation(tableView: presenterController.projectsTable)
                        // Hide the chart if there are not data.
                        presenterController.chartContainer.isHidden = DataInterface.computeAverageSRGroupedByDay().isEmpty ? true : false
                    } },
                noAction: { (presenterController) -> Void in
                    if let presenterController = presenterController as? AKListProjectsViewController {
                        Func.AKReloadTableWithAnimation(tableView: presenterController.projectsTable)
                    } },
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
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat { return LocalConstants.AKFooterHeight }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let project = DataInterface.getProjects(filter: self.projectFilter)[(indexPath as NSIndexPath).section]
        self.performSegue(withIdentifier: GlobalConstants.AKViewProjectSegue, sender: project)
    }
    
    // MARK: Miscellaneous
    func customSetup()
    {
        self.inhibitLocalNotificationMessage = false
        self.inhibitTapGesture = true
        self.inhibitLongPressGesture = false
        self.additionalOperationsWhenLongPressed = { (gesture) -> Void in
            self.presentView(controller: AKNewProjectViewController(nibName: "AKNewProjectView", bundle: nil),
                             taskBeforePresenting: { _,_ in },
                             dismissViewCompletionTask: { (presenterController, presentedController) -> Void in
                                if let presenterController = presenterController as? AKListProjectsViewController {
                                    Func.AKReloadTableWithAnimation(tableView: presenterController.projectsTable)
                                } }
            )
        }
        self.loadData = { (controller) -> Void in
            if let controller = controller as? AKListProjectsViewController {
                Func.AKReloadTableWithAnimation(tableView: controller.projectsTable)
                // Hide the chart if there are not data.
                controller.loadChart()
                controller.chartContainer.isHidden = DataInterface.computeAverageSRGroupedByDay().isEmpty ? true : false // TODO: Improve!
                
                // Checks
                // If it's the first time the user uses the App.
                // 1. Show Intro view.
                // 2. Cancel all local notifications, that the App might had previously created.
                // 3. Set default values for Configurations.
                if DataInterface.firstTime() {
                    // 1. Present Intro view.
                    controller.presentView(controller: AKIntroductoryViewController(nibName: "AKIntroductoryView", bundle: nil),
                                           taskBeforePresenting: { (presenterController, presentedController) -> Void in },
                                           dismissViewCompletionTask: { (presenterController, presentedController) -> Void in
                                            NSLog("=> INFO: \(type(of: presentedController)) MODAL PRESENTATION HAS BEEN DISMISSED...") }
                    )
                    
                    // 2. Clear all notifications from previous installs.
                    Func.AKInvalidateLocalNotification(controller: controller, project: nil)
                    
                    // 3. Default values for Configurations.
                    let newConfigurations = AKConfigurationsInterface()
                    do {
                        try newConfigurations.validate()
                    }
                    catch {
                        Func.AKPresentMessageFromError(controller: controller, message: "\(error)")
                        return
                    }
                    
                    if let configurations = AKConfigurationsBuilder.mirror(interface: newConfigurations) {
                        DataInterface.addConfigurations(configurations: configurations)
                    }
                    
                    return
                }
                
                // Show message if the are no projects.
                if DataInterface.getProjects(filter: controller.projectFilter).count > 0 {
                    controller.hideInitialMessage(animate: false, completionTask: nil)
                }
                else {
                    var origin = Func.AKCenterScreenCoordinate(
                        container: controller.view,
                        width: AKInitialMessageView.LocalConstants.AKViewWidth,
                        height: AKInitialMessageView.LocalConstants.AKViewHeight
                    )
                    origin.y -= 60.0
                    
                    controller.showInitialMessage(
                        origin: origin,
                        title: "Hello..!",
                        message: "Use the menu button above to start adding coding projects.",
                        animate: false,
                        completionTask: nil
                    )
                }
            }
        }
        self.configureLookAndFeel = { (controller) -> Void in
            if let controller = controller as? AKListProjectsViewController {
                controller.menu.setTitleTextAttributes(
                    [
                        NSFontAttributeName: UIFont(name: GlobalConstants.AKSecondaryFont, size: GlobalConstants.AKNavBarFontSize) ?? UIFont.systemFont(ofSize: GlobalConstants.AKNavBarFontSize),
                        NSForegroundColorAttributeName: GlobalConstants.AKTabBarTintSelected
                    ], for: .normal
                )
            }
        }
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
        self.setup()
        self.configureAnimations(displacementHeight: LocalConstants.AKDisplaceHeight)
        
        // Custom Components
        self.projectsTable.register(UINib(nibName: "AKProjectsTableViewCell", bundle: nil), forCellReuseIdentifier: "ProjectsTableCell")
        
        // Delegate & DataSource
        self.projectsTable?.dataSource = self
        self.projectsTable?.delegate = self
    }
    
    func resetFilters(controller: AKCustomViewController) {
        self.projectFilter = Filter(projectFilter: FilterProject())
        
        controller.sortMenuItemOverlay.order.selectRow(1, inComponent: 0, animated: true)
        controller.sortMenuItemOverlay.filters.selectRow(1, inComponent: 0, animated: true)
        
        controller.filterMenuItemOverlay.type.selectRow(0, inComponent: 0, animated: true)
        controller.filterMenuItemOverlay.filters.selectRow(0, inComponent: 0, animated: true)
        
        controller.searchMenuItemOverlay.searchBarCancelButtonClicked(controller.searchMenuItemOverlay.searchBar)
    }
    
    
    func loadChart() {
        let formato: BarChartFormatter = BarChartFormatter()
        
        var dataEntries: [BarChartDataEntry] = []
        for (key, value) in DataInterface.computeAverageSRGroupedByDay() {
            let dataEntry = BarChartDataEntry(x: Double(key), y: Double(value))
            dataEntries.append(dataEntry)
        }
        
        let chartDataSet = BarChartDataSet(values: dataEntries, label: "Success Ratio Grouped by Day (%)")
        chartDataSet.valueFont = UIFont(name: GlobalConstants.AKDefaultFont, size: 12)!
        chartDataSet.valueTextColor = GlobalConstants.AKDefaultFg
        chartDataSet.drawValuesEnabled = true
        chartDataSet.setColors([GlobalConstants.AKCoderToDoWhite], alpha: 0.5)
        
        // Configure the chart.
        self.osrChartContainer.xAxis.labelPosition = .bottom
        self.osrChartContainer.xAxis.labelFont = UIFont(name: GlobalConstants.AKDefaultFont, size: 12)!
        self.osrChartContainer.xAxis.labelTextColor = GlobalConstants.AKDefaultFg
        self.osrChartContainer.xAxis.gridColor = GlobalConstants.AKDefaultFg
        self.osrChartContainer.xAxis.gridLineCap = .square
        self.osrChartContainer.xAxis.gridLineDashLengths = [2, 2]
        self.osrChartContainer.xAxis.valueFormatter = formato
        
        self.osrChartContainer.leftAxis.labelFont = UIFont(name: GlobalConstants.AKDefaultFont, size: 12)!
        self.osrChartContainer.leftAxis.labelTextColor = GlobalConstants.AKDefaultFg
        self.osrChartContainer.leftAxis.gridLineCap = .square
        self.osrChartContainer.leftAxis.gridLineDashLengths = [2, 2]
        self.osrChartContainer.leftAxis.axisMaximum = 100
        self.osrChartContainer.leftAxis.axisMinimum = 0
        
        self.osrChartContainer.rightAxis.labelFont = UIFont(name: GlobalConstants.AKDefaultFont, size: 12)!
        self.osrChartContainer.rightAxis.labelTextColor = GlobalConstants.AKDefaultFg
        self.osrChartContainer.rightAxis.gridLineCap = .square
        self.osrChartContainer.rightAxis.gridLineDashLengths = [2, 2]
        self.osrChartContainer.rightAxis.axisMaximum = 100
        self.osrChartContainer.rightAxis.axisMinimum = 0
        
        self.osrChartContainer.legend.textColor = GlobalConstants.AKDefaultFg
        self.osrChartContainer.legend.font = UIFont(name: GlobalConstants.AKDefaultFont, size: 16)!
        self.osrChartContainer.legend.horizontalAlignment = .center
        
        self.osrChartContainer.backgroundColor = GlobalConstants.AKDefaultBg
        self.osrChartContainer.gridBackgroundColor = GlobalConstants.AKDefaultBg
        self.osrChartContainer.noDataText = ""
        self.osrChartContainer.chartDescription?.text = ""
        self.osrChartContainer.animate(xAxisDuration: 1.0, yAxisDuration: 1.0, easingOption: .linear)
        self.osrChartContainer.isUserInteractionEnabled = false
        
        // Load chart.
        let chartData = BarChartData(dataSet: chartDataSet)
        
        self.osrChartContainer.data = chartData
        
        let mostProductiveDay = DataInterface.mostProductiveDay()
        if mostProductiveDay != .invalid {
            self.mostProductiveDay.text = String(
                format: "%@ is your most productive day!",
                Func.AKGetDayOfWeekAsName(dayOfWeek: mostProductiveDay.rawValue)!
            )
        }
        else {
            self.mostProductiveDay.text = ""
        }
    }
}

@objc(BarChartFormatter)
class BarChartFormatter: NSObject, IAxisValueFormatter
{
    func stringForValue(_ value: Double, axis: AxisBase?) -> String { return Func.AKGetDayOfWeekAsName(dayOfWeek: Int16(value), short: true)! }
}
