import UIKit

class AKViewProjectViewController: AKCustomViewController, UITableViewDataSource, UITableViewDelegate
{
    // MARK: Constants
    struct LocalConstants {
        static let AKHeaderHeight: CGFloat = 34
        static let AKEmptyRowHeight: CGFloat = 40
    }
    
    // MARK: Properties
    let customCell = AKTasksTableView()
    var customCellView: UIView!
    var project: Project!
    
    // MARK: Outlets
    @IBOutlet weak var daysTable: UITableView!
    
    // MARK: Actions
    @IBAction func add(_ sender: Any)
    {
        self.presentView(controller: AKAddViewController(nibName: "AKAddView", bundle: nil),
                         dismissViewCompletionTask: { (presenterController, presentedController) -> Void in
                            NSLog("=> INFO: \(type(of: presentedController)) MODAL PRESENTATION HAS BEEN DISMISSED...") }
        )
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
        let day = DataInterface.getDays(project: self.project)[(indexPath as NSIndexPath).section]
        if DataInterface.countTasks(day: day) > 0 {
            // Calculate given the number of tasks. Each task has a cell of ~44 points height.
            let cellHeight = 40 + (CGFloat(DataInterface.countTasks(day: day)) * AKTasksTableView.LocalConstants.AKHeaderHeight)
            
            let cell = self.daysTable.dequeueReusableCell(withIdentifier: "DaysTableCell") as! AKDaysTableViewCell
            cell.mainContainer.backgroundColor = GlobalConstants.AKTableCellBg
            cell.title.removeFromSuperview()
            
            customCellView = customCell.customView
            customCell.controller = self
            customCell.day = day
            customCellView.frame = CGRect(
                x: 0,
                y: 0,
                width: tableView.bounds.width,
                height: cellHeight
            )
            customCellView.translatesAutoresizingMaskIntoConstraints = true
            customCellView.clipsToBounds = true
            cell.mainContainer.addSubview(customCellView)
            
            // Custom L&F.
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            
            return cell
        }
        else {
            let cell = self.daysTable.dequeueReusableCell(withIdentifier: "DaysTableCell") as! AKDaysTableViewCell
            cell.mainContainer.backgroundColor = GlobalConstants.AKTableCellBg
            
            // Custom L&F.
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        let day = DataInterface.getDays(project: self.project)[section]
        
        let tableWidth = tableView.bounds.width
        let padding = CGFloat(8.0)
        let badgeSizeWidth = CGFloat(60.0)
        let badgeSizeHeight = CGFloat(21.0)
        
        let headerCell = UIView(frame: CGRect(x: 0, y: 0, width: tableWidth, height: LocalConstants.AKHeaderHeight))
        headerCell.backgroundColor = GlobalConstants.AKTableHeaderCellBg
        
        let title = UILabel(frame: CGRect(
            x: padding,
            y: 0,
            width: tableWidth - (padding * 3) - badgeSizeWidth,
            height: LocalConstants.AKHeaderHeight)
        )
        title.font = UIFont(name: GlobalConstants.AKDefaultFont, size: 18.0)
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
        srBadge.font = UIFont(name: GlobalConstants.AKSecondaryFont, size: 12.0)
        srBadge.textColor = GlobalConstants.AKBadgeColorFg
        srBadge.backgroundColor = GlobalConstants.AKBadgeColorBg
        srBadge.text = String(format: "SR %.2f%%", day.sr)
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
        if DataInterface.countTasks(day: day) <= 0 {
            return LocalConstants.AKEmptyRowHeight
        }
        else {
            // Calculate given the number of tasks. Each task has a cell of ~44 points height.
            return 40 + (CGFloat(DataInterface.countTasks(day: day)) * AKTasksTableView.LocalConstants.AKHeaderHeight)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat { return LocalConstants.AKHeaderHeight }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat { return CGFloat.leastNormalMagnitude }
    
    // MARK: Miscellaneous
    func customSetup()
    {
        super.inhibitTapGesture = true
        super.setup()
        
        // Allways add today to the table.
        DataInterface.addToday(project: self.project)
        
        // Custom Components
        self.daysTable.register(UINib(nibName: "AKDaysTableViewCell", bundle: nil), forCellReuseIdentifier: "DaysTableCell")
        
        // Add UITableView's DataSource & Delegate.
        self.daysTable?.dataSource = self
        self.daysTable?.delegate = self
    }
}
