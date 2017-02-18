import UIKit

class AKTasksTableView: AKCustomView, UITableViewDataSource, UITableViewDelegate
{
    // MARK: Constants
    struct LocalConstants {
        static let AKHeaderHeight: CGFloat = 44
    }
    
    // MARK: Properties
    let animation: CABasicAnimation = CABasicAnimation(keyPath: "opacity")
    var controller: AKCustomViewController?
    var day: Day!
    
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
        let task = DataInterface.getTasks(day: self.day)[(indexPath as NSIndexPath).row]
        
        let cell = self.tasksTable.dequeueReusableCell(withIdentifier: "TasksTableCell") as! AKTasksTableViewCell
        cell.taskNameValue.text = String(format: "• %@", task.name ?? "Some Name...")
        
        // Custom L&F.
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        // let task = DataInterface.getTasks(day: self.day)[section]
        
        let tableWidth = tableView.bounds.width
        let padding = CGFloat(12.0)
        
        let headerCell = UIView(frame: CGRect(x: 0, y: 0, width: tableWidth, height: LocalConstants.AKHeaderHeight))
        headerCell.backgroundColor = GlobalConstants.AKTableCellBg
        
        let title = UILabel(frame: CGRect(
            x: padding,
            y: 0,
            width: tableWidth - (padding * 2),
            height: LocalConstants.AKHeaderHeight)
        )
        title.font = UIFont(name: GlobalConstants.AKDefaultFont, size: 16.0)
        title.textColor = GlobalConstants.AKDefaultFg
        title.text = "Some Category"
        title.textAlignment = .left
        // ### DEBUG
        // title.layer.borderColor = UIColor.white.cgColor
        // title.layer.borderWidth = 1.0
        
        Func.AKAddBorderDeco(title, color: GlobalConstants.AKDefaultViewBorderBg.cgColor, thickness: GlobalConstants.AKDefaultBorderThickness, position: .bottom)
        
        headerCell.addSubview(title)
        
        return headerCell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int { return 1 }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return DataInterface.countTasks(day: self.day) }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool { return false }
    
    // MARK: UITableViewDelegate Implementation
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 40
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat { return LocalConstants.AKHeaderHeight }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat { return CGFloat.leastNormalMagnitude }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let task = DataInterface.getTasks(day: self.day)[(indexPath as NSIndexPath).row]
        controller?.performSegue(withIdentifier: GlobalConstants.AKViewTaskSegue, sender: task)
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
