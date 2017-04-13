import Charts
import UIKit
import UserNotifications

class AKListProjectsViewController: AKCustomViewController, UITableViewDataSource, UITableViewDelegate
{
    // MARK: Constants
    private struct LocalConstants {
        static let AKHeaderHeight: CGFloat = 34.0
        static let AKRowHeight: CGFloat = 72.0
        static let AKFooterHeight: CGFloat = 1.0
        static let AKDisplaceHeight: CGFloat = AKTopMenuView.LocalConstants.AKViewHeight
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
                        Func.AKReloadTable(tableView: controller.projectsTable)
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
                        destination.cachingSystem = AKTableCachingSystem(projectName: project.name!)
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
        let project = DataInterface.getProjects(filter: self.projectFilter)[indexPath.section]
        
        let cell = self.projectsTable.dequeueReusableCell(withIdentifier: "ProjectsTableCell") as! AKProjectsTableViewCell
        cell.controller = self
        cell.project = project
        // OSR
        cell.osrValue.text = String(format: "%.2f", DataInterface.computeOSR(project: project))
        // Running Days
        let runningDays = DataInterface.getProjectRunningDays(project: project)
        cell.runningDaysValue.text = String(format: "%i running %@", runningDays, runningDays > 1 ? "days" : "day")
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
        // New day state.
        if DataInterface.getProjectStatus(project: project) == .accepting {
            if DataInterface.isTomorrowSetUp(project: project) {
                cell.newDayStateValue.text = "Tomorrow is set."
                cell.newDayStateValue.textColor = GlobalConstants.AKGreenForBlackFg
            }
            else {
                cell.newDayStateValue.text = "Tomorrow is not set."
                cell.newDayStateValue.textColor = GlobalConstants.AKRedForBlackFg
            }
        }
        else {
            cell.newDayStateValue.text = "N\\A"
            cell.newDayStateValue.textColor = GlobalConstants.AKTableCellBg
            cell.newDayStateValueHeight.constant = 0.0
        }
        // Add task button.
        cell.toggleAddTaskButton()
        
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
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool { return false }
    
    // MARK: UITableViewDelegate Implementation
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle { return UITableViewCellEditingStyle.delete }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        let project = DataInterface.getProjects(filter: self.projectFilter)[indexPath.section]
        
        var cellHeight = LocalConstants.AKRowHeight
        if DataInterface.getProjectStatus(project: project) != .accepting {
            cellHeight -= 23.5
        }
        
        return cellHeight
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat { return LocalConstants.AKHeaderHeight }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat { return LocalConstants.AKFooterHeight }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let project = DataInterface.getProjects(filter: self.projectFilter)[indexPath.section]
        self.performSegue(withIdentifier: GlobalConstants.AKViewProjectSegue, sender: project)
    }
    
    // MARK: Miscellaneous
    func customSetup()
    {
        self.inhibitLocalNotificationMessage = false
        self.inhibitTapGesture = true
        self.loadData = { (controller) -> Void in
            if let controller = controller as? AKListProjectsViewController {
                Func.AKReloadTable(tableView: controller.projectsTable)
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
                                           dismissViewCompletionTask: { (presenterController, presentedController) -> Void in }
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
                }
                
                // Show message if the are no projects.
                if DataInterface.getProjects(filter: controller.projectFilter).count == 0 {
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
                        animate: true,
                        completionTask: nil
                    )
                }
                else {
                    controller.hideInitialMessage(animate: true, completionTask: nil)
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
                                                        Func.AKReloadTable(tableView: presenterController.projectsTable)
                                                        
                                                        // Check that at least one project was added.
                                                        if DataInterface.getProjects(filter: presenterController.projectFilter).count > 0 {
                                                            presenterController.hideInitialMessage(animate: true, completionTask: nil)
                                                        }
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
        
        controller.sortMenuItemOverlay.resetViewDefaults(controller: self)
        controller.filterMenuItemOverlay.resetViewDefaults(controller: self)
        
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
        chartDataSet.setColors([GlobalConstants.AKCoderToDoWhite], alpha: 0.75)
        
        // Configure the chart.
        self.osrChartContainer.xAxis.labelPosition = .bottom
        self.osrChartContainer.xAxis.labelFont = UIFont(name: GlobalConstants.AKDefaultFont, size: 12)!
        self.osrChartContainer.xAxis.labelTextColor = GlobalConstants.AKDefaultFg
        self.osrChartContainer.xAxis.gridColor = GlobalConstants.AKDefaultBg
        self.osrChartContainer.xAxis.gridLineCap = .square
        self.osrChartContainer.xAxis.gridLineDashLengths = [2, 2]
        self.osrChartContainer.xAxis.valueFormatter = formato
        self.osrChartContainer.xAxis.drawAxisLineEnabled = false
        
        self.osrChartContainer.leftAxis.labelFont = UIFont(name: GlobalConstants.AKDefaultFont, size: 12)!
        self.osrChartContainer.leftAxis.labelTextColor = GlobalConstants.AKDefaultFg
        self.osrChartContainer.leftAxis.gridColor = GlobalConstants.AKDefaultBg
        self.osrChartContainer.leftAxis.gridLineCap = .square
        self.osrChartContainer.leftAxis.gridLineDashLengths = [2, 2]
        self.osrChartContainer.leftAxis.axisMaximum = 100
        self.osrChartContainer.leftAxis.axisMinimum = 0
        self.osrChartContainer.leftAxis.drawAxisLineEnabled = false
        self.osrChartContainer.leftAxis.drawLabelsEnabled = false
        
        self.osrChartContainer.rightAxis.labelFont = UIFont(name: GlobalConstants.AKDefaultFont, size: 12)!
        self.osrChartContainer.rightAxis.labelTextColor = GlobalConstants.AKDefaultFg
        self.osrChartContainer.rightAxis.gridColor = GlobalConstants.AKDefaultBg
        self.osrChartContainer.rightAxis.gridLineCap = .square
        self.osrChartContainer.rightAxis.gridLineDashLengths = [2, 2]
        self.osrChartContainer.rightAxis.axisMaximum = 100
        self.osrChartContainer.rightAxis.axisMinimum = 0
        self.osrChartContainer.rightAxis.drawAxisLineEnabled = false
        self.osrChartContainer.rightAxis.drawLabelsEnabled = false
        
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
