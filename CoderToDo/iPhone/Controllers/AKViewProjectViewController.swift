import UIKit

class AKViewProjectViewController: AKCustomViewController, UITableViewDataSource, UITableViewDelegate
{
    // MARK: Constants
    private struct LocalConstants {
        static let AKHeaderHeight: CGFloat = 34.0
        static let AKEmptyRowHeight: CGFloat = 40.0
        static let AKDisplaceHeight: CGFloat = AKTopMenuView.LocalConstants.AKViewHeight
    }
    
    // MARK: Properties
    // Caching System
    var cachingSystem: AKTableCachingSystem!
    // Other
    var project: Project!
    var taskFilter = Filter(taskFilter: FilterTask())
    
    // MARK: Outlets
    @IBOutlet weak var navController: UINavigationItem!
    @IBOutlet weak var daysTable: UITableView!
    
    // MARK: Actions
    @IBAction func toggleMenu(_ sender: Any)
    {
        if !self.isMenuVisible {
            self.displaceDownTable(
                tableView: self.daysTable,
                offset: LocalConstants.AKDisplaceHeight,
                animate: true,
                completionTask: nil
            )
        }
        else {
            self.displaceUpTable(
                tableView: self.daysTable,
                offset: LocalConstants.AKDisplaceHeight,
                animate: true,
                completionTask: { (controller) -> Void in
                    if let controller = controller as? AKViewProjectViewController {
                        controller.resetFilters(controller: controller)
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
            case GlobalConstants.AKViewTaskSegue:
                if let destination = segue.destination as? AKViewTaskViewController {
                    if let task = sender as? Task {
                        destination.task = task
                        destination.navController.title = "Task Visualization"
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
        case GlobalConstants.AKViewTaskSegue:
            return true
        default:
            return false
        }
    }
    
    // MARK: UITableViewDataSource Implementation
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let section = indexPath.section
        
        // First we check which section we are. That means which day we are referencing.
        let day = DataInterface.getDays(project: self.project, filterEmpty: true, filter: self.taskFilter)[section]
        
        // If the count of categories is bigger than 0, it means there are tasks. Else show empty day cell.
        if DataInterface.countCategories(day: day, filterEmpty: true, filter: self.taskFilter) > 0 {
            // Caching System.
            let entry = self.cachingSystem.getEntry(controller: self, key: day.date!)
            
            if let entry = entry, let cell = entry.getParentCell() {
                if let view = entry.getChildView() {
                    // Re-draw the child's view.
                    Func.AKChangeComponentHeight(component: view.getView(), newHeight: entry.getChildViewHeight())
                }
                
                return cell
            }
            else {
                if let cell = UINib(nibName: "AKDaysTableViewCell", bundle: nil).instantiate(withOwner: self, options: nil).first as? AKDaysTableViewCell {
                    if let entry = self.cachingSystem.getEntry(controller: self, key: day.date!) {
                        entry.setChildViewHeightRecomputationRoutine(routine: { (controller) -> CGFloat in
                            if let controller = controller as? AKViewProjectViewController {
                                return
                                    (CGFloat(DataInterface.countCategories(day: day, filterEmpty: true, filter: controller.taskFilter)) * (AKTasksTableView.LocalConstants.AKHeaderHeight + AKTasksTableView.LocalConstants.AKFooterHeight)) +
                                        (CGFloat(DataInterface.countTasksInDay(day: day, filter: controller.taskFilter)) * AKTasksTableView.LocalConstants.AKRowHeight)
                            }
                            else {
                                return 0.0
                            }
                        })
                        entry.recomputeChildViewHeight(controller: self)
                        
                        let customView = AKTasksTableView()
                        customView.controller = self
                        customView.day = day
                        customView.setup()
                        customView.draw(
                            container: cell.mainContainer,
                            coordinates: CGPoint.zero,
                            size: CGSize(width: tableView.frame.width, height: entry.getChildViewHeight())
                        )
                        
                        // Custom L&F.
                        cell.selectionStyle = UITableViewCellSelectionStyle.none
                        cell.mainContainer.backgroundColor = GlobalConstants.AKTableCellBg
                        
                        entry.setParentCell(cell: cell)
                        entry.setChildView(view: customView)
                        
                        return cell
                    }
                }
            }
        }
        else {
            if let cell = UINib(nibName: "AKDaysTableViewCell", bundle: nil).instantiate(withOwner: self, options: nil).first as? AKDaysTableViewCell {
                // Custom L&F.
                cell.selectionStyle = UITableViewCellSelectionStyle.none
                cell.mainContainer.backgroundColor = GlobalConstants.AKTableCellBg
                Func.AKAddBorderDeco(
                    cell.mainContainer,
                    color: GlobalConstants.AKTableCellBorderBg.cgColor,
                    thickness: GlobalConstants.AKDefaultBorderThickness * 4.0,
                    position: .left
                )
                
                return cell
            }
        }
        
        // For all else return empty cell.
        let defaultCell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "Cell")
        defaultCell.selectionStyle = UITableViewCellSelectionStyle.none
        
        return defaultCell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        let day = DataInterface.getDays(project: self.project, filterEmpty: true, filter: self.taskFilter)[section]
        let isTomorrow = DataInterface.isDayTomorrow(day: day)
        let isToday = DataInterface.isDayToday(day: day)
        let projectStatus = DataInterface.getProjectStatus(project: day.project!)
        
        let tableWidth = tableView.frame.width
        let padding = CGFloat(8.0)
        let firstBadgeSizeWidth = CGFloat(70.0)
        let firstBadgeSizeHeight = CGFloat(21.0)
        let secondBadgeSizeWidth = CGFloat(70.0)
        let secondBadgeSizeHeight = CGFloat(21.0)
        let thirdBadgeSizeWidth = CGFloat(60.0)
        let thirdBadgeSizeHeight = CGFloat(21.0)
        let paddingBetweenBadges = CGFloat(4.0)
        
        let headerCell = UIView(frame: CGRect(x: 0, y: 0, width: tableWidth, height: LocalConstants.AKHeaderHeight))
        headerCell.backgroundColor = GlobalConstants.AKTableHeaderCellBg
        if isTomorrow {
            Func.AKAddBorderDeco(
                headerCell,
                color: Func.AKGetColorForProjectStatus(projectStatus: .accepting).cgColor,
                thickness: GlobalConstants.AKDefaultBorderThickness * 4.0,
                position: .left
            )
        }
        else if isToday {
            Func.AKAddBorderDeco(
                headerCell,
                color: Func.AKGetColorForProjectStatus(projectStatus: projectStatus == .accepting ? .closed : projectStatus).cgColor,
                thickness: GlobalConstants.AKDefaultBorderThickness * 4.0,
                position: .left
            )
        }
        else {
            Func.AKAddBorderDeco(
                headerCell,
                color: Func.AKGetColorForProjectStatus(projectStatus: .closed).cgColor,
                thickness: GlobalConstants.AKDefaultBorderThickness * 4.0,
                position: .left
            )
        }
        
        let title = UILabel(frame: CGRect(
            x: padding * 2.0,
            y: 0.0,
            width: tableWidth - (padding * 3) - firstBadgeSizeWidth - secondBadgeSizeWidth - thirdBadgeSizeWidth - paddingBetweenBadges,
            height: LocalConstants.AKHeaderHeight)
        )
        title.font = UIFont(name: GlobalConstants.AKSecondaryFont, size: 19.0)
        title.textColor = GlobalConstants.AKDefaultFg
        title.text = Func.AKGetFormattedDate(date: day.date as Date?)
        title.textAlignment = .left
        // ### DEBUG
        // title.layer.borderColor = UIColor.white.cgColor
        // title.layer.borderWidth = 1.0
        
        let firstBadgeContainer = UIView(frame: CGRect(
            x: tableWidth - padding - firstBadgeSizeWidth - secondBadgeSizeWidth - thirdBadgeSizeWidth - (paddingBetweenBadges * 2),
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
        firstBadge.font = UIFont(name: GlobalConstants.AKDefaultFont, size: 12.0)
        firstBadge.textColor = GlobalConstants.AKBadgeColorFg
        firstBadge.backgroundColor = GlobalConstants.AKBadgeColorBg
        firstBadge.text = String(format: "SR: %.2f%%", day.sr)
        firstBadge.textAlignment = .center
        firstBadge.layer.cornerRadius = GlobalConstants.AKButtonCornerRadius
        firstBadge.layer.masksToBounds = true
        // ### DEBUG
        // firstBadge.layer.borderColor = UIColor.white.cgColor
        // firstBadge.layer.borderWidth = 1.0
        
        firstBadgeContainer.addSubview(firstBadge)
        
        let secondBadgeContainer = UIView(frame: CGRect(
            x: tableWidth - padding - secondBadgeSizeWidth - thirdBadgeSizeWidth - paddingBetweenBadges,
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
        secondBadge.backgroundColor = GlobalConstants.AKBadgeColorBg
        secondBadge.text = String(format: "Pending: %i", DataInterface.countDayPendingTasks(day: day))
        secondBadge.textAlignment = .center
        secondBadge.layer.cornerRadius = GlobalConstants.AKButtonCornerRadius
        secondBadge.layer.masksToBounds = true
        // ### DEBUG
        // secondBadge.layer.borderColor = UIColor.white.cgColor
        // secondBadge.layer.borderWidth = 1.0
        
        secondBadgeContainer.addSubview(secondBadge)
        
        let thirdBadgeContainer = UIView(frame: CGRect(
            x: tableWidth - padding - thirdBadgeSizeWidth,
            y: 0.0,
            width: thirdBadgeSizeWidth,
            height: LocalConstants.AKHeaderHeight)
        )
        // ### DEBUG
        // thirdBadgeContainer.layer.borderColor = UIColor.white.cgColor
        // thirdBadgeContainer.layer.borderWidth = 1.0
        
        let thirdBadge = UILabel(frame: CGRect(
            x: thirdBadgeContainer.frame.width - thirdBadgeSizeWidth,
            y: (LocalConstants.AKHeaderHeight - thirdBadgeSizeHeight) / 2.0,
            width: thirdBadgeSizeWidth,
            height: thirdBadgeSizeHeight)
        )
        thirdBadge.font = UIFont(name: GlobalConstants.AKDefaultFont, size: 12.0)
        thirdBadge.textColor = GlobalConstants.AKBadgeColorFg
        if isTomorrow {
            thirdBadge.backgroundColor = Func.AKGetColorForProjectStatus(projectStatus: .accepting)
            thirdBadge.text = String(format: "%@", ProjectStatus.accepting.rawValue)
        }
        else if isToday {
            thirdBadge.backgroundColor = Func.AKGetColorForProjectStatus(projectStatus: projectStatus == .accepting ? .closed : projectStatus)
            thirdBadge.text = String(format: "%@", projectStatus == .accepting ? ProjectStatus.closed.rawValue : projectStatus.rawValue)
        }
        else {
            thirdBadge.backgroundColor = Func.AKGetColorForProjectStatus(projectStatus: .closed)
            thirdBadge.text = String(format: "%@", ProjectStatus.closed.rawValue)
        }
        thirdBadge.textAlignment = .center
        thirdBadge.layer.cornerRadius = GlobalConstants.AKButtonCornerRadius
        thirdBadge.layer.masksToBounds = true
        // ### DEBUG
        // thirdBadge.layer.borderColor = UIColor.white.cgColor
        // thirdBadge.layer.borderWidth = 1.0
        
        thirdBadgeContainer.addSubview(thirdBadge)
        
        headerCell.addSubview(title)
        headerCell.addSubview(firstBadgeContainer)
        headerCell.addSubview(secondBadgeContainer)
        headerCell.addSubview(thirdBadgeContainer)
        
        return headerCell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int { return DataInterface.countDays(project: self.project, filterEmpty: true, filter: self.taskFilter) }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return 1 }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool { return false }
    
    // MARK: UITableViewDelegate Implementation
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        let section = indexPath.section
        
        let day = DataInterface.getDays(
            project: self.project,
            filterEmpty: true,
            filter: self.taskFilter)[section]
        
        // Caching System.
        if let entry = self.cachingSystem.getEntry(controller: self, key: day.date!) {
            return entry.getParentCellHeight()
        }
        else {
            let newEntry = AKTableCachingEntry(key: day.date!, parentCell: nil, childView: nil)
            newEntry.setParentCellHeightRecomputationRoutine(routine: { (controller) -> CGFloat in
                if let controller = controller as? AKViewProjectViewController {
                    if DataInterface.countCategories(day: day, filterEmpty: true, filter: controller.taskFilter) <= 0 {
                        return LocalConstants.AKEmptyRowHeight
                    }
                    else {
                        return (CGFloat(DataInterface.countCategories(day: day, filterEmpty: true, filter: controller.taskFilter)) * (AKTasksTableView.LocalConstants.AKHeaderHeight + AKTasksTableView.LocalConstants.AKFooterHeight)) +
                            (CGFloat(DataInterface.countTasksInDay(day: day, filter: controller.taskFilter)) * AKTasksTableView.LocalConstants.AKRowHeight)
                    }
                }
                else {
                    return 0.0
                }
            })
            newEntry.recomputeParentCellHeight(controller: self)
            
            self.cachingSystem.addEntry(controller: self, key: day.date!, newEntry: newEntry)
            
            return newEntry.getParentCellHeight()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat { return LocalConstants.AKHeaderHeight }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat { return CGFloat.leastNormalMagnitude }
    
    // MARK: Miscellaneous
    func customSetup()
    {
        self.inhibitTapGesture = true
        self.loadData = { (controller) -> Void in
            if let controller = controller as? AKViewProjectViewController {
                // ALWAYS RESET ALL WHEN LOADING VIEW FOR THE FIRST TIME!
                self.resetFilters(controller: controller)
                
                // Show message if the are no tasks.
                if DataInterface.getAllTasksInProject(project: controller.project).count == 0 {
                    var origin = Func.AKCenterScreenCoordinate(
                        container: controller.view,
                        width: AKInitialMessageView.LocalConstants.AKViewWidth,
                        height: AKInitialMessageView.LocalConstants.AKViewHeight
                    )
                    origin.y -= 60.0
                    
                    controller.showInitialMessage(
                        origin: origin,
                        title: "Hello..!",
                        message: "Use the menu button above to start adding tasks to your project.",
                        animate: true,
                        completionTask: nil
                    )
                }
            }
        }
        self.topMenuOverlay.addAction = { (presenterController) -> Void in
            if let presenterController = presenterController as? AKViewProjectViewController {
                if presenterController.isMenuItemVisible && presenterController.selectedMenuItem != .add {
                    presenterController.toggleMenuItem(
                        tableView: presenterController.daysTable,
                        menuItem: presenterController.selectedMenuItem,
                        animate: true,
                        completionTask: nil
                    )
                }
                
                presenterController.toggleMenuItem(
                    tableView: presenterController.daysTable,
                    menuItem: .add,
                    animate: true,
                    completionTask: { (controller) -> Void in
                        if let controller = controller as? AKViewProjectViewController {
                            controller.resetFilters(controller: controller)
                        } }
                )
            }
        }
        self.topMenuOverlay.sortAction = { (presenterController) -> Void in
            if let presenterController = presenterController as? AKViewProjectViewController {
                if presenterController.isMenuItemVisible && presenterController.selectedMenuItem != .sort {
                    presenterController.toggleMenuItem(
                        tableView: presenterController.daysTable,
                        menuItem: presenterController.selectedMenuItem,
                        animate: true,
                        completionTask: nil
                    )
                }
                
                presenterController.toggleMenuItem(
                    tableView: presenterController.daysTable,
                    menuItem: .sort,
                    animate: true,
                    completionTask: { (controller) -> Void in
                        if let controller = controller as? AKViewProjectViewController {
                            controller.resetFilters(controller: controller)
                        } }
                )
            }
        }
        self.topMenuOverlay.filterAction = { (presenterController) -> Void in
            if let presenterController = presenterController as? AKViewProjectViewController {
                if presenterController.isMenuItemVisible && presenterController.selectedMenuItem != .filter {
                    presenterController.toggleMenuItem(
                        tableView: presenterController.daysTable,
                        menuItem: presenterController.selectedMenuItem,
                        animate: true,
                        completionTask: nil
                    )
                }
                
                presenterController.toggleMenuItem(
                    tableView: presenterController.daysTable,
                    menuItem: .filter,
                    animate: true,
                    completionTask: { (controller) -> Void in
                        if let controller = controller as? AKViewProjectViewController {
                            controller.resetFilters(controller: controller)
                        } }
                )
            }
        }
        self.topMenuOverlay.searchAction = { (presenterController) -> Void in
            if let presenterController = presenterController as? AKViewProjectViewController {
                if presenterController.isMenuItemVisible && presenterController.selectedMenuItem != .search {
                    presenterController.toggleMenuItem(
                        tableView: presenterController.daysTable,
                        menuItem: presenterController.selectedMenuItem,
                        animate: true,
                        completionTask: nil
                    )
                }
                
                presenterController.toggleMenuItem(
                    tableView: presenterController.daysTable,
                    menuItem: .search,
                    animate: true,
                    completionTask: { (controller) -> Void in
                        if let controller = controller as? AKViewProjectViewController {
                            controller.resetFilters(controller: controller)
                        } }
                )
            }
        }
        self.setup()
        self.configureAnimations(displacementHeight: LocalConstants.AKDisplaceHeight)
        
        // Delegate & DataSource
        self.daysTable?.dataSource = self
        self.daysTable?.delegate = self
        
        // Animations
        self.displaceDownTable.fromValue = 0.0
        self.displaceDownTable.toValue = LocalConstants.AKDisplaceHeight
        self.displaceDownTable.duration = 0.5
        self.displaceDownTable.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        self.displaceDownTable.autoreverses = false
        self.view.layer.add(self.displaceDownTable, forKey: LocalConstants.AKDisplaceDownAnimation)
        
        self.displaceUpTable.fromValue = LocalConstants.AKDisplaceHeight
        self.displaceUpTable.toValue = 0.0
        self.displaceUpTable.duration = 0.5
        self.displaceUpTable.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        self.displaceUpTable.autoreverses = false
        self.view.layer.add(self.displaceUpTable, forKey: LocalConstants.AKDisplaceUpAnimation)
    }
    
    func resetFilters(controller: AKCustomViewController)
    {
        if GlobalConstants.AKDebug {
            NSLog("=> \(type(of: self)): RESETTING FILTERS")
        }
        
        self.taskFilter = Filter(taskFilter: FilterTask())
        
        controller.sortMenuItemOverlay.resetViewDefaults(controller: self)
        controller.filterMenuItemOverlay.resetViewDefaults(controller: self)
        controller.searchMenuItemOverlay.resetViewDefaults(controller: self)
        
        // Trigger caching recomputation, and reloading.
        self.cachingSystem.triggerHeightRecomputation(controller: controller)
        self.completeReload()
    }
    
    func completeReload() -> Void
    {
        self.cachingSystem.triggerChildViewsReload(controller: self)
        Func.AKReloadTable(tableView: self.daysTable)
    }
}
