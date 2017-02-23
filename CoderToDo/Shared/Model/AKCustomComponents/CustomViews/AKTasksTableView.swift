import UIKit

class AKTasksTableView: AKCustomView, UITableViewDataSource, UITableViewDelegate
{
    // MARK: Constants
    struct LocalConstants {
        static let AKHeaderHeight: CGFloat = 34
        static let AKRowHeight: CGFloat = 40
        static let AKFooterHeight: CGFloat = 6
    }
    
    // MARK: Properties
    let animation: CABasicAnimation = CABasicAnimation(keyPath: "opacity")
    var controller: AKCustomViewController?
    var day: Day?
    
    // MARK: Outlets
    @IBOutlet var tasksTable: UITableView!
    
    // MARK: UIView Overriding
    convenience init()
    {
        NSLog("=> DEFAULT init()")
        self.init(frame: CGRect.zero)
    }
    
    override init(frame: CGRect)
    {
        NSLog("=> FRAME init()")
        super.init(frame: frame)
        setup()
    }
    
    required init(coder aDecoder: NSCoder)
    {
        NSLog("=> CODER init()")
        super.init(coder: aDecoder)!
    }
    
    // MARK: UITableViewDataSource Implementation
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let category = DataInterface.getCategories(day: self.day!)[(indexPath as NSIndexPath).section]
        let task = DataInterface.getTasks(category: category)[(indexPath as NSIndexPath).row]
        
        let cell = self.tasksTable.dequeueReusableCell(withIdentifier: "TasksTableCell") as! AKTasksTableViewCell
        cell.taskNameValue.text = String(format: "• %@", task.name ?? "Some Name...")
        // Completion Percentage.
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
        // Status
        cell.taskStateValue.text = task.state ?? TaskStates.PENDING.rawValue
        Func.AKAddBorderDeco(
            cell.taskStateValue,
            color: Func.AKGetColorForTaskState(taskState: task.state ?? "").cgColor,
            thickness: GlobalConstants.AKDefaultBorderThickness,
            position: .bottom
        )
        
        // Custom L&F.
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        cell.mainContainer.backgroundColor = GlobalConstants.AKDefaultBg
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        let category = DataInterface.getCategories(day: self.day!)[section]
        
        let tableWidth = tableView.bounds.width
        let padding = CGFloat(8.0)
        
        let headerCell = UIView(frame: CGRect(x: 0, y: 0, width: tableWidth, height: LocalConstants.AKHeaderHeight))
        headerCell.backgroundColor = GlobalConstants.AKDefaultBg
        
        let title = UILabel(frame: CGRect(
            x: padding * 2,
            y: 0,
            width: tableWidth - (padding * 2),
            height: LocalConstants.AKHeaderHeight - 4.0)
        )
        title.font = UIFont(name: GlobalConstants.AKDefaultFont, size: 16.0)
        title.textColor = GlobalConstants.AKDefaultFg
        title.text = category.name ?? "N\\A"
        title.textAlignment = .left
        // ### DEBUG
        // title.layer.borderColor = UIColor.white.cgColor
        // title.layer.borderWidth = 1.0
        
        Func.AKAddBorderDeco(
            title,
            color: GlobalConstants.AKDefaultViewBorderBg.cgColor,
            thickness: GlobalConstants.AKDefaultBorderThickness,
            position: .bottom
        )
        
        headerCell.addSubview(title)
        
        return headerCell
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView?
    {
        let footerCell = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: LocalConstants.AKFooterHeight))
        footerCell.backgroundColor = UIColor.clear
        
        return footerCell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        if let day = self.day {
            return DataInterface.getCategories(day: day).count
        }
        else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if let day = self.day {
            let category = DataInterface.getCategories(day: day)[section]
            
            return DataInterface.countTasks(category: category)
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
        if let day = self.day {
            let category = DataInterface.getCategories(day: day)[(indexPath as NSIndexPath).section]
            let task = DataInterface.getTasks(category: category)[(indexPath as NSIndexPath).row]
            controller?.performSegue(withIdentifier: GlobalConstants.AKViewTaskSegue, sender: task)
        }
    }
    
    // MARK: Miscellaneous
    func setup()
    {
        NSLog("=> ENTERING SETUP ON FRAME: \(type(of:self))")
        
        self.animation.fromValue = 0.85
        self.animation.toValue = 0.65
        self.animation.duration = 2.0
        self.animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        self.animation.autoreverses = true
        self.animation.repeatCount = 20000
        
        // Custom Components
        self.tasksTable.register(UINib(nibName: "AKTasksTableViewCell", bundle: nil), forCellReuseIdentifier: "TasksTableCell")
        
        // Add UITableView's DataSource & Delegate.
        self.tasksTable?.dataSource = self
        self.tasksTable?.delegate = self
    }
    
    func startAnimation()
    {
        self.customView.layer.add(animation, forKey: "opacity")
    }
    
    func stopAnimation()
    {
        self.customView.layer.removeAllAnimations()
    }
}
