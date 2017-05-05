import UIKit

class AKAboutViewController: AKCustomViewController, UITableViewDataSource, UITableViewDelegate {
    // MARK: Constants
    private struct LocalConstants {
        static let AKHeaderHeight: CGFloat = 1.0
        static let AKRowHeight: CGFloat = 40.0
        static let AKFooterHeight: CGFloat = 1.0
    }
    
    // MARK: Properties
    var pagesTableHeaders = ["Rules", "Contact Us", "Changes"]
    
    // MARK: Outlets
    @IBOutlet var mainContainer: UIView!
    @IBOutlet weak var scrollContainer: UIScrollView!
    @IBOutlet weak var controlsContainer: UIView!
    @IBOutlet weak var versionValue: UILabel!
    @IBOutlet weak var pagesTable: UITableView!
    
    // MARK: AKCustomViewController Overriding
    override func viewDidLoad() {
        super.viewDidLoad()
        self.customSetup()
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        switch identifier {
        case GlobalConstants.AKViewRulesSegue,
             GlobalConstants.AKViewChangesSegue:
            return true
        default:
            return false
        }
    }
    
    // MARK: UITableViewDataSource Implementation
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.pagesTable.dequeueReusableCell(withIdentifier: "ConfigurationsTableCell") as! AKConfigurationsTableViewCell
        cell.title.text = self.pagesTableHeaders[indexPath.section]
        
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
        let headerCell = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: LocalConstants.AKHeaderHeight))
        headerCell.backgroundColor = UIColor.clear
        
        return headerCell
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerCell = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: LocalConstants.AKFooterHeight))
        footerCell.backgroundColor = UIColor.clear
        
        return footerCell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int { return self.pagesTableHeaders.count }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return 1 }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool { return false }
    
    // MARK: UITableViewDelegate Implementation
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { return LocalConstants.AKRowHeight }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat { return LocalConstants.AKHeaderHeight }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat { return LocalConstants.AKFooterHeight }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            self.performSegue(withIdentifier: GlobalConstants.AKViewRulesSegue, sender: self)
            break
        case 1:
            let subject = "Support"
            let body = ""
            let coded = "mailto:support@codertodo.com?subject=\(subject)&body=\(body)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            
            if let url = URL(string: coded!) {
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }
            break
        case 2:
            self.performSegue(withIdentifier: GlobalConstants.AKViewChangesSegue, sender: self)
            break
        default:
            break
        }
    }
    
    // MARK: Miscellaneous
    func customSetup() {
        self.inhibitTapGesture = true
        self.loadData = { (controller) -> Void in
            if let controller = controller as? AKAboutViewController {
                controller.versionValue.text = String(format: "Version %@ Build %@", Func.AKAppVersion(), Func.AKAppBuild())
            }
        }
        self.setup()
        
        // Custom Components
        self.pagesTable.register(UINib(nibName: "AKConfigurationsTableViewCell", bundle: nil), forCellReuseIdentifier: "ConfigurationsTableCell")
        
        // Delegate & DataSource
        self.pagesTable?.dataSource = self
        self.pagesTable?.delegate = self
    }
}
