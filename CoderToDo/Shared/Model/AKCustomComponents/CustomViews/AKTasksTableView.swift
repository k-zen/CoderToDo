import UIKit

class AKTasksTableView: AKCustomView, AKCustomViewProtocol, UITableViewDataSource, UITableViewDelegate
{
    // MARK: Constants
    struct LocalConstants {
        static let AKHeaderHeight: CGFloat = 30
        static let AKRowHeight: CGFloat = 45
        static let AKFooterHeight: CGFloat = 1.0
    }
    
    // MARK: Properties
    var controller: AKCustomViewController?
    var day: Day?
    
    // MARK: Outlets
    @IBOutlet var tasksTable: UITableView!
    
    // MARK: UIView Overriding
    convenience init() { self.init(frame: CGRect.zero) }
    
    // MARK: UITableViewDataSource Implementation
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        if let controller = self.controller as? AKViewProjectViewController {
            let category = DataInterface.getCategories(day: self.day!, filterEmpty: true, filter: controller.taskFilter)[(indexPath as NSIndexPath).section]
            let task = DataInterface.getTasks(category: category, filter: controller.taskFilter)[(indexPath as NSIndexPath).row]
            
            // Sanity Checks
            AKChecks.workingDayCloseSanityChecks(controller: controller, task: task)
            
            let cell = self.tasksTable.dequeueReusableCell(withIdentifier: "TasksTableCell") as! AKTasksTableViewCell
            
            // Task Name
            cell.taskNameValue.text = String(format: "%@", task.name ?? "Some Name...")
            
            // Task Completion Percentage
            cell.taskCompletionPercentageValue.text = String(format: "%.1f%%", task.completionPercentage)
            switch task.completionPercentage {
            case 1.0 ..< 33.0:
                Func.AKAddBorderDeco(
                    cell.taskCompletionPercentageValue,
                    color: GlobalConstants.AKRedForWhiteFg.cgColor,
                    thickness: GlobalConstants.AKDefaultBorderThickness,
                    position: .bottom
                )
                break
            case 33.0 ..< 66.0:
                Func.AKAddBorderDeco(
                    cell.taskCompletionPercentageValue,
                    color: GlobalConstants.AKYellowForWhiteFg.cgColor,
                    thickness: GlobalConstants.AKDefaultBorderThickness,
                    position: .bottom
                )
                break
            case 66.0 ..< 100.1:
                Func.AKAddBorderDeco(
                    cell.taskCompletionPercentageValue,
                    color: GlobalConstants.AKGreenForWhiteFg.cgColor,
                    thickness: GlobalConstants.AKDefaultBorderThickness,
                    position: .bottom
                )
                break
            default:
                Func.AKAddBorderDeco(
                    cell.taskCompletionPercentageValue,
                    color: GlobalConstants.AKRedForWhiteFg.cgColor,
                    thickness: GlobalConstants.AKDefaultBorderThickness,
                    position: .bottom
                )
                break
            }
            
            // Task State
            cell.taskStateValue.text = task.state
            Func.AKAddBorderDeco(
                cell.taskStateValue,
                color: Func.AKGetColorForTaskState(taskState: task.state!).cgColor,
                thickness: GlobalConstants.AKDefaultBorderThickness,
                position: .bottom
            )
            
            // Custom L&F.
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            cell.mainContainer.backgroundColor = GlobalConstants.AKTableCellBg
            // Func.AKAddBorderDeco(
            //     cell.infoContainer,
            //     color: Func.AKGetColorForTaskState(taskState: task.state!).cgColor,
            //     thickness: GlobalConstants.AKDefaultBorderThickness * 4.0,
            //     position: .left
            // )
            
            return cell
        }
        else {
            let cell = self.tasksTable.dequeueReusableCell(withIdentifier: "TasksTableCell") as! AKTasksTableViewCell
            
            // Custom L&F.
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            cell.mainContainer.backgroundColor = GlobalConstants.AKTableCellBg
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        if let controller = self.controller as? AKViewProjectViewController {
            let category = DataInterface.getCategories(day: self.day!, filterEmpty: true, filter: controller.taskFilter)[section]
            
            let tableWidth = tableView.frame.width
            let padding = CGFloat(8.0)
            let badgeSizeWidth = CGFloat(60.0)
            let badgeSizeHeight = CGFloat(21.0)
            
            let headerCell = UIView(frame: CGRect(x: 0, y: 0, width: tableWidth, height: LocalConstants.AKHeaderHeight))
            headerCell.backgroundColor = GlobalConstants.AKDefaultBg
            
            let title = UILabel(frame: CGRect(
                x: padding * 2,
                y: 0,
                width: tableWidth - (padding * 2), // Overlap badge!
                height: LocalConstants.AKHeaderHeight)
            )
            title.font = UIFont(name: GlobalConstants.AKSecondaryFont, size: 19.0)
            title.textColor = GlobalConstants.AKCoderToDoGray1
            title.text = category.name ?? "N\\A"
            title.textAlignment = .left
            // ### DEBUG
            // title.layer.borderColor = UIColor.white.cgColor
            // title.layer.borderWidth = 1.0
            
            Func.AKAddBorderDeco(
                title,
                color: GlobalConstants.AKDefaultViewBorderBg.cgColor,
                thickness: GlobalConstants.AKDefaultBorderThickness / 1.5,
                position: .through
            )
            
            let tasksCountBadgeContainer = UIView(frame: CGRect(
                x: tableWidth - padding - (badgeSizeWidth),
                y: 0,
                width: badgeSizeWidth,
                height: LocalConstants.AKHeaderHeight)
            )
            // ### DEBUG
            // tasksCountBadgeContainer.layer.borderColor = UIColor.white.cgColor
            // tasksCountBadgeContainer.layer.borderWidth = 1.0
            
            let tasksCountBadge = UILabel(frame: CGRect(
                x: tasksCountBadgeContainer.frame.width - (badgeSizeWidth),
                y: (LocalConstants.AKHeaderHeight - badgeSizeHeight) / 2.0,
                width: badgeSizeWidth,
                height: badgeSizeHeight)
            )
            tasksCountBadge.font = UIFont(name: GlobalConstants.AKDefaultFont, size: 12.0)
            tasksCountBadge.textColor = GlobalConstants.AKCoderToDoWhite2
            tasksCountBadge.backgroundColor = GlobalConstants.AKCoderToDoGray2
            if let controller = self.controller as? AKViewProjectViewController {
                tasksCountBadge.text = String(format: "Tasks: %i", DataInterface.getTasks(category: category, filter: controller.taskFilter).count)
            }
            else {
                tasksCountBadge.text = String(format: "Tasks: %i", 0)
            }
            tasksCountBadge.textAlignment = .center
            tasksCountBadge.layer.cornerRadius = GlobalConstants.AKButtonCornerRadius
            tasksCountBadge.layer.masksToBounds = true
            // ### DEBUG
            // tasksCountBadge.layer.borderColor = UIColor.white.cgColor
            // tasksCountBadge.layer.borderWidth = 1.0
            
            tasksCountBadgeContainer.addSubview(tasksCountBadge)
            
            headerCell.addSubview(title)
            headerCell.addSubview(tasksCountBadgeContainer)
            
            return headerCell
        }
        else {
            let tableWidth = tableView.frame.width
            
            let headerCell = UIView(frame: CGRect(x: 0, y: 0, width: tableWidth, height: LocalConstants.AKHeaderHeight))
            headerCell.backgroundColor = GlobalConstants.AKDefaultBg
            
            return headerCell
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView?
    {
        let footerCell = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: LocalConstants.AKFooterHeight))
        footerCell.backgroundColor = UIColor.clear
        
        return footerCell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        if let day = self.day {
            if let controller = self.controller as? AKViewProjectViewController {
                return DataInterface.getCategories(day: day, filterEmpty: true, filter: controller.taskFilter).count
            }
            else {
                return 0
            }
        }
        else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if let day = self.day, let controller = self.controller as? AKViewProjectViewController {
            let category = DataInterface.getCategories(day: day, filterEmpty: true, filter: controller.taskFilter)[section]
            
            return DataInterface.getTasks(category: category, filter: controller.taskFilter).count
        }
        else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool { return false }
    
    // MARK: UITableViewDelegate Implementation
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { return LocalConstants.AKRowHeight }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat { return LocalConstants.AKHeaderHeight }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat { return LocalConstants.AKFooterHeight }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        if let day = self.day, let controller = self.controller as? AKViewProjectViewController {
            let category = DataInterface.getCategories(day: day, filterEmpty: true, filter: controller.taskFilter)[(indexPath as NSIndexPath).section]
            let task = DataInterface.getTasks(category: category, filter: controller.taskFilter)[(indexPath as NSIndexPath).row]
            controller.performSegue(withIdentifier: GlobalConstants.AKViewTaskSegue, sender: task)
        }
    }
    
    // MARK: Miscellaneous
    func setup()
    {
        NSLog("=> ENTERING SETUP ON FRAME: \(type(of:self))")
        
        // Delegate & DataSource
        self.tasksTable?.dataSource = self
        self.tasksTable?.delegate = self
        
        self.getView().translatesAutoresizingMaskIntoConstraints = true
        self.getView().clipsToBounds = true
        
        self.loadComponents()
        self.applyLookAndFeel()
        self.addAnimations(expandCollapseHeight: 0.0)
    }
    
    func loadComponents()
    {
        self.tasksTable.register(UINib(nibName: "AKTasksTableViewCell", bundle: nil), forCellReuseIdentifier: "TasksTableCell")
    }
    
    func applyLookAndFeel() {}
    
    func draw(container: UIView, coordinates: CGPoint, size: CGSize)
    {
        self.getView().frame = CGRect(
            x: coordinates.x,
            y: coordinates.y,
            width: size.width,
            height: size.height
        )
        container.addSubview(self.getView())
    }
}
