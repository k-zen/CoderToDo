import UIKit

class AKViewProjectViewController: AKCustomViewController, UITableViewDataSource, UITableViewDelegate
{
    // MARK: Constants
    private struct LocalConstants {
        static let AKHeaderHeight: CGFloat = 34
        static let AKEmptyRowHeight: CGFloat = 40
        static let AKDisplaceDownAnimation = "displaceDown"
        static let AKDisplaceUpAnimation = "displaceUp"
        static let AKDisplaceHeight: CGFloat = 40.0
    }
    
    // MARK: Properties
    let displaceDownProjectsTable = CABasicAnimation(keyPath: LocalConstants.AKDisplaceDownAnimation)
    let displaceUpProjectsTable = CABasicAnimation(keyPath: LocalConstants.AKDisplaceUpAnimation)
    var customCellArray = [AKTasksTableView]()
    var project: Project!
    var sortType: TaskSorting = TaskSorting.creationDate
    var sortOrder: SortingOrder = SortingOrder.descending
    var filterType: TaskFilter = TaskFilter.state
    var filterValue: String = TaskFilterStates.none.rawValue
    var searchTerm: String = Search.showAll.rawValue
    var selectedMenuItem: MenuItems = .none
    var isMenuVisible: Bool = false
    var isMenuItemVisible: Bool = false
    
    // MARK: Outlets
    @IBOutlet weak var navController: UINavigationItem!
    @IBOutlet weak var daysTable: UITableView!
    
    // MARK: Actions
    @IBAction func toggleMenu(_ sender: Any)
    {
        if !self.isMenuVisible {
            self.displaceDownTable(offset: LocalConstants.AKDisplaceHeight)
        }
        else {
            self.displaceUpTable(offset: LocalConstants.AKDisplaceHeight)
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
        
        // Always reload the table!
        self.daysTable?.reloadData()
        for customCell in self.customCellArray {
            customCell.tasksTable?.reloadData()
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
                (CGFloat(DataInterface.countAllTasksInDay(
                    day: day,
                    sortBy: self.sortType,
                    sortOrder: self.sortOrder,
                    filterType: self.filterType,
                    filterValue: self.filterValue,
                    searchTerm: self.searchTerm)) * AKTasksTableView.LocalConstants.AKRowHeight)
            
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
        
        let tableWidth = tableView.frame.width
        let padding = CGFloat(8.0)
        let badgeSizeWidth = CGFloat(60.0)
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
        title.text = DataInterface.getDayTitle(day: day)
        title.textAlignment = .left
        // ### DEBUG
        // title.layer.borderColor = UIColor.white.cgColor
        // title.layer.borderWidth = 1.0
        
        let srBadgeContainer = UIView(frame: CGRect(
            x: tableWidth - padding - (badgeSizeWidth),
            y: 0,
            width: badgeSizeWidth,
            height: LocalConstants.AKHeaderHeight)
        )
        // ### DEBUG
        // srBadgeContainer.layer.borderColor = UIColor.white.cgColor
        // srBadgeContainer.layer.borderWidth = 1.0
        
        let srBadge = UILabel(frame: CGRect(
            x: srBadgeContainer.frame.width - (badgeSizeWidth),
            y: (LocalConstants.AKHeaderHeight - badgeSizeHeight) / 2.0,
            width: badgeSizeWidth,
            height: badgeSizeHeight)
        )
        srBadge.font = UIFont(name: GlobalConstants.AKDefaultFont, size: 12.0)
        srBadge.textColor = GlobalConstants.AKBadgeColorFg
        srBadge.backgroundColor = GlobalConstants.AKBadgeColorBg
        srBadge.text = String(format: "SR: %.2f%%", DataInterface.computeSRForDay(day: day))
        srBadge.textAlignment = .center
        srBadge.layer.cornerRadius = GlobalConstants.AKButtonCornerRadius
        srBadge.layer.masksToBounds = true
        // ### DEBUG
        // srBadge.layer.borderColor = UIColor.white.cgColor
        // srBadge.layer.borderWidth = 1.0
        
        srBadgeContainer.addSubview(srBadge)
        
        headerCell.addSubview(title)
        headerCell.addSubview(srBadgeContainer)
        
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
                (CGFloat(DataInterface.countAllTasksInDay(
                    day: day,
                    sortBy: self.sortType,
                    sortOrder: self.sortOrder,
                    filterType: self.filterType,
                    filterValue: self.filterValue,
                    searchTerm: self.searchTerm)) * AKTasksTableView.LocalConstants.AKRowHeight)
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
                                    presenterController.daysTable.reloadData()
                                    for customCell in presenterController.customCellArray {
                                        customCell.tasksTable?.reloadData()
                                    }
                                } }
            )
        }
        super.setup()
        
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
                                                        presenterController.daysTable.reloadData()
                                                        for customCell in presenterController.customCellArray {
                                                            customCell.tasksTable?.reloadData()
                                                        }
                                                    } }
                )
            }
        }
        self.topMenuOverlay.sortAction = { (presenterController) -> Void in
            if let presenterController = presenterController as? AKViewProjectViewController {
                presenterController.toggleMenuItem(menuItem: .sort)
            }
        }
        self.topMenuOverlay.filterAction = { (presenterController) -> Void in
            if let presenterController = presenterController as? AKViewProjectViewController {
                presenterController.toggleMenuItem(menuItem: .filter)
            }
        }
        self.topMenuOverlay.searchAction = { (presenterController) -> Void in
            if let presenterController = presenterController as? AKViewProjectViewController {
                presenterController.toggleMenuItem(menuItem: .search)
            }
        }
    }
    
    // MARK: Animations
    func displaceDownTable(offset: CGFloat)
    {
        self.isMenuVisible = true
        self.showTopMenu()
        
        UIView.beginAnimations(LocalConstants.AKDisplaceDownAnimation, context: nil)
        Func.AKChangeComponentYPosition(component: self.daysTable, newY: self.daysTable.frame.origin.y + offset)
        Func.AKChangeComponentHeight(component: self.daysTable, newHeight: self.daysTable.frame.height - offset)
        UIView.commitAnimations()
    }
    
    func displaceUpTable(offset: CGFloat)
    {
        self.isMenuVisible = false
        self.hideTopMenu()
        
        var newOffset = offset
        if self.isMenuItemVisible {
            switch self.selectedMenuItem {
            case .sort:
                newOffset += AKSortView.LocalConstants.AKViewHeight
                self.isMenuItemVisible = false
                self.hideSortMenuItem()
                break
            case .filter:
                newOffset += AKFilterView.LocalConstants.AKViewHeight
                self.isMenuItemVisible = false
                self.hideFilterMenuItem()
                break
            case .search:
                newOffset += AKSearchView.LocalConstants.AKViewHeight
                self.isMenuItemVisible = false
                self.hideSearchMenuItem()
                break
            default:
                break
            }
        }
        
        UIView.beginAnimations(LocalConstants.AKDisplaceUpAnimation, context: nil)
        Func.AKChangeComponentYPosition(component: self.daysTable, newY: self.daysTable.frame.origin.y - newOffset)
        Func.AKChangeComponentHeight(component: self.daysTable, newHeight: self.daysTable.frame.height + newOffset)
        UIView.commitAnimations()
    }
    
    func toggleMenuItem(menuItem: MenuItems)
    {
        var offset: CGFloat = 0.0
        let direction: Displacement = !self.isMenuItemVisible ? .down : .up
        
        switch menuItem {
        case .sort:
            self.selectedMenuItem = .sort
            offset += AKSortView.LocalConstants.AKViewHeight
            if direction == Displacement.down {
                self.isMenuItemVisible = true
                self.showSortMenuItem()
            }
            else {
                self.isMenuItemVisible = false
                self.hideSortMenuItem()
            }
            break
        case .filter:
            self.selectedMenuItem = .filter
            offset += AKFilterView.LocalConstants.AKViewHeight
            if direction == Displacement.down {
                self.isMenuItemVisible = true
                self.showFilterMenuItem()
            }
            else {
                self.isMenuItemVisible = false
                self.hideFilterMenuItem()
            }
            break
        case .search:
            self.selectedMenuItem = .search
            offset += AKSearchView.LocalConstants.AKViewHeight
            if direction == Displacement.down {
                self.isMenuItemVisible = true
                self.showSearchMenuItem()
            }
            else {
                self.isMenuItemVisible = false
                self.hideSearchMenuItem()
            }
            break
        default:
            break
        }
        
        if direction == Displacement.down {
            UIView.beginAnimations(LocalConstants.AKDisplaceDownAnimation, context: nil)
            Func.AKChangeComponentYPosition(component: self.daysTable, newY: self.daysTable.frame.origin.y + offset)
            Func.AKChangeComponentHeight(component: self.daysTable, newHeight: self.daysTable.frame.height - offset)
            UIView.commitAnimations()
        }
        else {
            UIView.beginAnimations(LocalConstants.AKDisplaceUpAnimation, context: nil)
            Func.AKChangeComponentYPosition(component: self.daysTable, newY: self.daysTable.frame.origin.y - offset)
            Func.AKChangeComponentHeight(component: self.daysTable, newHeight: self.daysTable.frame.height + offset)
            UIView.commitAnimations()
        }
    }
}
