import UIKit

class AKViewProjectViewController: AKCustomViewController, UITableViewDataSource, UITableViewDelegate
{
    // MARK: Constants
    struct LocalConstants {
        static let AKHeaderHeight: CGFloat = 40
    }
    
    // MARK: Properties
    var project: Project!
    
    // MARK: Outlets
    @IBOutlet weak var daysTable: UITableView!
    
    // MARK: Actions
    @IBAction func addTask(_ sender: Any)
    {
        NSLog("=> INFO: NEW TASK BUTTON PRESSED!")
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
    }
    
    // MARK: UITableViewDataSource Implementation
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        var element: Day!
        if (indexPath as NSIndexPath).section > 0 {
            element = DataInterface.getDays(project: self.project)[(indexPath as NSIndexPath).section]
        }
        
        let cell = self.daysTable.dequeueReusableCell(withIdentifier: "DaysTableCell") as! AKDaysTableViewCell
        cell.mainContainer.backgroundColor = GlobalConstants.AKTableCellBg
        
        // Custom L&F.
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        var element: Day!
        if section <= 0 {
            if let mr = Func.AKObtainMasterReference() {
                let now = NSDate()
                
                element = Day(context: mr.getMOC())
                element.date = now
            }
            
        }
        else {
            element = DataInterface.getDays(project: self.project)[section]
        }
        
        let tableWidth = tableView.bounds.width
        let padding = CGFloat(8.0)
        let badgeSize = CGFloat(31.0)
        
        let headerCell = UIView(frame: CGRect(x: 0, y: 0, width: tableWidth, height: LocalConstants.AKHeaderHeight))
        headerCell.backgroundColor = GlobalConstants.AKTableHeaderCellBg
        
        let title = UILabel(frame: CGRect(
            x: padding,
            y: 0,
            width: tableWidth - (padding * 3) - badgeSize,
            height: LocalConstants.AKHeaderHeight)
        )
        title.font = UIFont(name: GlobalConstants.AKDefaultFont, size: 20.0)
        title.textColor = GlobalConstants.AKDefaultFg
        title.text = DataInterface.getDayTitle(day: element)
        title.textAlignment = .left
        // ### DEBUG
        // title.layer.borderColor = UIColor.white.cgColor
        // title.layer.borderWidth = 1.0
        
        let srBadgeContainer = UIView(frame: CGRect(
            x: tableWidth - padding - (badgeSize * 2.0),
            y: 0,
            width: badgeSize * 2.0,
            height: LocalConstants.AKHeaderHeight)
        )
        // ### DEBUG
        // runningDaysBadgeContainer.layer.borderColor = UIColor.white.cgColor
        // runningDaysBadgeContainer.layer.borderWidth = 1.0
        
        let srBadge = UILabel(frame: CGRect(
            x: srBadgeContainer.frame.width - (badgeSize * 2.0),
            y: (LocalConstants.AKHeaderHeight - badgeSize) / 2.0,
            width: badgeSize * 2.0,
            height: badgeSize)
        )
        srBadge.font = UIFont(name: GlobalConstants.AKSecondaryFont, size: 12.0)
        srBadge.textColor = GlobalConstants.AKDefaultFg
        srBadge.backgroundColor = GlobalConstants.AKEnabledButtonBg
        srBadge.text = String(format: "SR %.2f%%", element.sr)
        srBadge.textAlignment = .center
        srBadge.layer.cornerRadius = GlobalConstants.AKButtonCornerRadius
        srBadge.layer.masksToBounds = true
        // ### DEBUG
        // runningDaysBadge.layer.borderColor = UIColor.white.cgColor
        // runningDaysBadge.layer.borderWidth = 1.0
        
        srBadgeContainer.addSubview(srBadge)
        
        headerCell.addSubview(title)
        headerCell.addSubview(srBadgeContainer)
        
        return headerCell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int { return 1 + DataInterface.countDays(project: self.project) }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return 1 }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool { return false }
    
    // MARK: UITableViewDelegate Implementation
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        if (indexPath as NSIndexPath).section <= 0 {
            return 40
        }
        else {
            return 140
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat { return LocalConstants.AKHeaderHeight }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat { return CGFloat.leastNormalMagnitude }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        // let element = DataInterface.getDays(project: self.project)[(indexPath as NSIndexPath).section]
        // self.performSegue(withIdentifier: "ViewTaskSegue", sender: element)
    }
    
    // MARK: Miscellaneous
    func customSetup()
    {
        super.inhibitTapGesture = true
        super.setup()
        
        // Custom Components
        self.daysTable.register(UINib(nibName: "AKDaysTableViewCell", bundle: nil), forCellReuseIdentifier: "DaysTableCell")
        
        // Add UITableView's DataSource & Delegate.
        self.daysTable?.dataSource = self
        self.daysTable?.delegate = self
    }
}
