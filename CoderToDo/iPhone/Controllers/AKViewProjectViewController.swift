import UIKit

class AKViewProjectViewController: AKCustomViewController, UITableViewDataSource, UITableViewDelegate
{
    // MARK: Constants
    private struct LocalConstants {
        static let AKHeaderHeight: CGFloat = 34
        static let AKEmptyRowHeight: CGFloat = 40
        static let AKDisplaceHeight: CGFloat = 40.0
    }
    
    // MARK: Properties
    var customCellArray = [AKTasksTableView]()
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
                completionTask: { (controller) -> Void in
                    if let controller = controller as? AKViewProjectViewController {
                        controller.resetFilters(controller: controller)
                    } }
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
                        Func.AKReloadTableWithAnimation(tableView: controller.daysTable)
                        for customCell in controller.customCellArray {
                            Func.AKReloadTableWithAnimation(tableView: customCell.tasksTable!)
                        }
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
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        Func.AKReloadTableWithAnimation(tableView: self.daysTable)
        for customCell in self.customCellArray {
            Func.AKReloadTableWithAnimation(tableView: customCell.tasksTable!)
        }
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
        // First we check which section we are. That means which day we are referencing.
        let day = DataInterface.getDays(project: self.project)[(indexPath as NSIndexPath).section]
        
        // If the count of categories is bigger than 0, it means there are tasks. Else show empty day cell.
        if DataInterface.countCategories(day: day) > 0 {
            // Calculate cell height.
            let cellHeight = (CGFloat(DataInterface.countCategories(day: day)) * (AKTasksTableView.LocalConstants.AKHeaderHeight + AKTasksTableView.LocalConstants.AKFooterHeight)) +
                (CGFloat(DataInterface.countTasksInDay(day: day, filter: self.taskFilter)) * AKTasksTableView.LocalConstants.AKRowHeight)
            
            if let cell = UINib(nibName: "AKDaysTableViewCell", bundle: nil).instantiate(withOwner: self, options: nil).first as? AKDaysTableViewCell {
                let customCell = AKTasksTableView()
                customCell.controller = self
                customCell.day = day
                customCell.setup()
                customCell.draw(
                    container: cell.mainContainer,
                    coordinates: CGPoint.zero,
                    size: CGSize(width: tableView.frame.width, height: cellHeight)
                )
                
                // Custom L&F.
                cell.selectionStyle = UITableViewCellSelectionStyle.none
                cell.mainContainer.backgroundColor = GlobalConstants.AKTableCellBg
                
                self.customCellArray.insert(customCell, at: (indexPath as NSIndexPath).section)
                
                return cell
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
        let day = DataInterface.getDays(project: self.project)[section]
        let isToday = DataInterface.isDayToday(day: day)
        let projectStatus = DataInterface.getProjectStatus(project: day.project!)
        
        let tableWidth = tableView.frame.width
        let padding = CGFloat(8.0)
        let firstBadgeSizeWidth = CGFloat(70.0)
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
        title.font = UIFont(name: GlobalConstants.AKSecondaryFont, size: 18.0)
        title.textColor = GlobalConstants.AKDefaultFg
        title.text = DataInterface.getDayTitle(day: day)
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
        firstBadge.font = UIFont(name: GlobalConstants.AKDefaultFont, size: 12.0)
        firstBadge.textColor = GlobalConstants.AKBadgeColorFg
        firstBadge.backgroundColor = GlobalConstants.AKBadgeColorBg
        firstBadge.text = String(format: "SR: %.2f%%", DataInterface.computeSRForDay(day: day))
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
        if isToday {
            secondBadge.backgroundColor = Func.AKGetColorForProjectStatus(projectStatus: projectStatus)
            secondBadge.text = String(format: "%@", projectStatus.rawValue)
        }
        else {
            secondBadge.backgroundColor = Func.AKGetColorForProjectStatus(projectStatus: .closed)
            secondBadge.text = String(format: "%@", ProjectStatus.closed.rawValue)
        }
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
    
    func numberOfSections(in tableView: UITableView) -> Int { return DataInterface.countDays(project: self.project) }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return 1 }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool { return false }
    
    // MARK: UITableViewDelegate Implementation
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        let day = DataInterface.getDays(project: self.project)[(indexPath as NSIndexPath).section]
        if DataInterface.countCategories(day: day) <= 0 {
            return LocalConstants.AKEmptyRowHeight
        }
        else {
            return (CGFloat(DataInterface.countCategories(day: day)) * (AKTasksTableView.LocalConstants.AKHeaderHeight + AKTasksTableView.LocalConstants.AKFooterHeight)) +
                (CGFloat(DataInterface.countTasksInDay(day: day, filter: self.taskFilter)) * AKTasksTableView.LocalConstants.AKRowHeight)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat { return LocalConstants.AKHeaderHeight }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat { return CGFloat.leastNormalMagnitude }
    
    // MARK: Miscellaneous
    func customSetup()
    {
        super.inhibitTapGesture = true
        super.inhibitLongPressGesture = false
        super.additionalOperationsWhenLongPressed = { (gesture) -> Void in
            self.presentView(controller: AKAddViewController(nibName: "AKAddView", bundle: nil),
                             taskBeforePresenting: { (presenterController, presentedController) -> Void in
                                if
                                    let presenterController = presenterController as? AKViewProjectViewController,
                                    let presentedController = presentedController as? AKAddViewController {
                                    presentedController.project = presenterController.project
                                } },
                             dismissViewCompletionTask: { (presenterController, presentedController) -> Void in
                                // Always reload the days table!
                                if let presenterController = presenterController as? AKViewProjectViewController {
                                    Func.AKReloadTableWithAnimation(tableView: presenterController.daysTable)
                                    for customCell in presenterController.customCellArray {
                                        Func.AKReloadTableWithAnimation(tableView: customCell.tasksTable!)
                                    }
                                } }
            )
        }
        super.setup()
        super.configureAnimations(displacementHeight: LocalConstants.AKDisplaceHeight)
        
        // Delegate & DataSource
        self.daysTable?.dataSource = self
        self.daysTable?.delegate = self
        
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
        self.topMenuOverlay.addAction = { (presenterController) -> Void in
            if let presenterController = presenterController {
                presenterController.presentView(controller: AKAddViewController(nibName: "AKAddView", bundle: nil),
                                                taskBeforePresenting: { (presenterController, presentedController) -> Void in
                                                    if
                                                        let presenterController = presenterController as? AKViewProjectViewController,
                                                        let presentedController = presentedController as? AKAddViewController {
                                                        presentedController.project = presenterController.project
                                                    } },
                                                dismissViewCompletionTask: { (presenterController, presentedController) -> Void in
                                                    // Always reload the days table!
                                                    if let presenterController = presenterController as? AKViewProjectViewController {
                                                        Func.AKReloadTableWithAnimation(tableView: presenterController.daysTable)
                                                        for customCell in presenterController.customCellArray {
                                                            Func.AKReloadTableWithAnimation(tableView: customCell.tasksTable!)
                                                        }
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
                        animate: false,
                        completionTask: { (controller) -> Void in
                            if let controller = controller as? AKViewProjectViewController {
                                controller.resetFilters(controller: controller)
                            } }
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
                        animate: false,
                        completionTask: { (controller) -> Void in
                            if let controller = controller as? AKViewProjectViewController {
                                controller.resetFilters(controller: controller)
                            } }
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
                        animate: false,
                        completionTask: { (controller) -> Void in
                            if let controller = controller as? AKViewProjectViewController {
                                controller.resetFilters(controller: controller)
                            } }
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
    }
    
    func resetFilters(controller: AKCustomViewController) {
        self.taskFilter = Filter(taskFilter: FilterTask())
        
        controller.sortMenuItemOverlay.order.selectRow(1, inComponent: 0, animated: true)
        controller.sortMenuItemOverlay.filters.selectRow(1, inComponent: 0, animated: true)
        
        controller.filterMenuItemOverlay.type.selectRow(0, inComponent: 0, animated: true)
        controller.filterMenuItemOverlay.filters.selectRow(0, inComponent: 0, animated: true)
        
        controller.searchMenuItemOverlay.searchBarCancelButtonClicked(controller.searchMenuItemOverlay.searchBar)
    }
}
