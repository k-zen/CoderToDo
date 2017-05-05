import UIKit

class AKProjectConfigurationsViewController: AKCustomViewController, UITableViewDataSource, UITableViewDelegate {
    // MARK: Constants
    private struct LocalConstants {
        static let AKHeaderHeight: CGFloat = 34.0
        static let AKRowHeight: CGFloat = 40.0
        static let AKFooterHeight: CGFloat = 10.0
    }
    
    // MARK: Properties
    var configurationsTableHeaders = ["Name", "Times", "Notifications", "User Defined Categories"]
    var project: Project!
    
    // MARK: Outlets
    @IBOutlet weak var configurationsTable: UITableView!
    
    // MARK: AKCustomViewController Overriding
    override func viewDidLoad() {
        super.viewDidLoad()
        self.customSetup()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            switch identifier {
            case GlobalConstants.AKViewProjectNameSegue:
                if let destination = segue.destination as? AKProjectNameViewController {
                    if let project = sender as? Project {
                        destination.project = project
                    }
                }
                break
            case GlobalConstants.AKViewProjectTimesSegue:
                if let destination = segue.destination as? AKProjectTimesViewController {
                    if let project = sender as? Project {
                        destination.project = project
                    }
                }
                break
            case GlobalConstants.AKViewProjectNotificationsSegue:
                if let destination = segue.destination as? AKProjectNotificationsViewController {
                    if let project = sender as? Project {
                        destination.project = project
                    }
                }
                break
            case GlobalConstants.AKViewUserDefinedCategoriesSegue:
                if let destination = segue.destination as? AKUserDefinedCategoriesViewController {
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
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        switch identifier {
        case GlobalConstants.AKViewProjectNameSegue,
             GlobalConstants.AKViewProjectTimesSegue,
             GlobalConstants.AKViewProjectNotificationsSegue,
             GlobalConstants.AKViewUserDefinedCategoriesSegue:
            return true
        default:
            return false
        }
    }
    
    // MARK: UITableViewDataSource Implementation
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.configurationsTable.dequeueReusableCell(withIdentifier: "ConfigurationsTableCell") as! AKConfigurationsTableViewCell
        cell.title.text = self.configurationsTableHeaders[indexPath.section]
        
        // Custom L&F.
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        Func.AKAddBorderDeco(
            cell,
            color: GlobalConstants.AKTableHeaderCellBorderBg.cgColor,
            thickness: GlobalConstants.AKDefaultBorderThickness * 4.0,
            position: .left
        )
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerCell = UIView(frame: CGRect(x: 0.0, y: 0.0, width: tableView.frame.width, height: LocalConstants.AKHeaderHeight))
        headerCell.backgroundColor = UIColor.clear
        
        let title = UILabel(frame: CGRect(
            x: 0.0,
            y: 0.0,
            width: tableView.frame.width,
            height: LocalConstants.AKHeaderHeight)
        )
        title.font = UIFont(name: GlobalConstants.AKSecondaryFont, size: 16.0)
        title.textColor = GlobalConstants.AKDefaultFg
        switch section {
        case 0:
            title.text = "Project Name"
            break
        case 1:
            title.text = "Working Day Times"
            break
        case 2:
            title.text = "Local Notification System"
            break
        case 3:
            title.text = "Your Categories"
            break
        default:
            break
        }
        title.textAlignment = .left
        // ### DEBUG
        // title.layer.borderColor = UIColor.white.cgColor
        // title.layer.borderWidth = 1.0
        
        headerCell.addSubview(title)
        
        return headerCell
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerCell = UIView(frame: CGRect(x: 0.0, y: 0.0, width: tableView.frame.width, height: LocalConstants.AKFooterHeight))
        footerCell.backgroundColor = UIColor.clear
        
        return footerCell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int { return self.configurationsTableHeaders.count }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return 1 }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool { return false }
    
    // MARK: UITableViewDelegate Implementation
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { return LocalConstants.AKRowHeight }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat { return LocalConstants.AKHeaderHeight }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat { return LocalConstants.AKFooterHeight }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            self.performSegue(withIdentifier: GlobalConstants.AKViewProjectNameSegue, sender: self.project)
            break
        case 1:
            self.performSegue(withIdentifier: GlobalConstants.AKViewProjectTimesSegue, sender: self.project)
            break
        case 2:
            self.performSegue(withIdentifier: GlobalConstants.AKViewProjectNotificationsSegue, sender: self.project)
            break
        case 3:
            self.performSegue(withIdentifier: GlobalConstants.AKViewUserDefinedCategoriesSegue, sender: self.project)
            break
        default:
            break
        }
    }
    
    // MARK: Miscellaneous
    func customSetup() {
        self.inhibitTapGesture = true
        self.setup()
        
        // Custom Components
        self.configurationsTable.register(UINib(nibName: "AKConfigurationsTableViewCell", bundle: nil), forCellReuseIdentifier: "ConfigurationsTableCell")
        
        // Delegate & DataSource
        self.configurationsTable?.dataSource = self
        self.configurationsTable?.delegate = self
    }
}
