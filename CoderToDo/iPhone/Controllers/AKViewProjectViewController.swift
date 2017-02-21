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
    @IBOutlet weak var navController: UINavigationItem!
    @IBOutlet weak var daysTable: UITableView!
    
    // MARK: Actions
    @IBAction func add(_ sender: Any)
    {
        self.presentView(controller: AKAddViewController(nibName: "AKAddView", bundle: nil),
                         taskBeforePresenting: { (presenterController, presentedController) -> Void in
                            if let presenterController = presenterController as? AKViewProjectViewController, let presentedController = presentedController as? AKAddViewController {
                                presentedController.project = presenterController.project
                            } },
                         dismissViewCompletionTask: { (presenterController, presentedController) -> Void in
                            NSLog("=> INFO: \(type(of: presentedController)) MODAL PRESENTATION HAS BEEN DISMISSED...")
                            
                            // Always reload the days table!
                            if let presenterController = presenterController as? AKViewProjectViewController {
                                presenterController.daysTable.reloadData()
                                presenterController.customCell.tasksTable?.reloadData()
                            } }
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
        
        // Always reload the table!
        self.daysTable?.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if let identifier = segue.identifier {
            switch identifier {
            case GlobalConstants.AKViewTaskSegue:
                if let destination = segue.destination as? AKViewTaskViewController {
                    if let task = sender as? Task {
                        // destination.project = project
                        destination.navController.title = task.name ?? "View Task"
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
            let cellHeight = (CGFloat(DataInterface.countCategories(day: day)) * AKTasksTableView.LocalConstants.AKHeaderHeight) + (CGFloat(DataInterface.countAllTasksInDay(day: day)) * AKTasksTableView.LocalConstants.AKRowHeight)
            
            let cell = self.daysTable.dequeueReusableCell(withIdentifier: "DaysTableCell") as! AKDaysTableViewCell
            cell.title.isHidden = true
            
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
            cell.mainContainer.backgroundColor = GlobalConstants.AKTableCellBg
            // Func.AKAddBorderDeco(
            //     cell.mainContainer,
            //     color: GlobalConstants.AKTableCellBorderBg.cgColor,
            //     thickness: GlobalConstants.AKDefaultBorderThickness * 4.0,
            //     position: .left
            // )
            
            return cell
        }
        else {
            let cell = self.daysTable.dequeueReusableCell(withIdentifier: "DaysTableCell") as! AKDaysTableViewCell
            
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
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        let day = DataInterface.getDays(project: self.project)[section]
        
        let tableWidth = tableView.bounds.width
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
        if DataInterface.countCategories(day: day) <= 0 {
            return LocalConstants.AKEmptyRowHeight
        }
        else {
            return (CGFloat(DataInterface.countCategories(day: day)) * AKTasksTableView.LocalConstants.AKHeaderHeight) + (CGFloat(DataInterface.countAllTasksInDay(day: day)) * AKTasksTableView.LocalConstants.AKRowHeight)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat { return LocalConstants.AKHeaderHeight }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat { return CGFloat.leastNormalMagnitude }
    
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
