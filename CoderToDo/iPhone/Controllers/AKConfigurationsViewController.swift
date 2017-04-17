import UIKit

class AKConfigurationsViewController: AKCustomViewController, UITableViewDataSource, UITableViewDelegate
{
    // MARK: Constants
    private struct LocalConstants {
        static let AKHeaderHeight: CGFloat = 0.5
        static let AKRowHeight: CGFloat = 40.0
        static let AKFooterHeight: CGFloat = CGFloat.leastNormalMagnitude
    }
    
    // MARK: Properties
    var configurationsTableHeaders = ["Backup", "Goodies"]
    
    // MARK: Outlets
    @IBOutlet weak var configurationsTable: UITableView!
    
    // MARK: AKCustomViewController Overriding
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.customSetup()
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool
    {
        switch identifier {
        case GlobalConstants.AKViewBackupSegue,
             GlobalConstants.AKViewGoodiesSegue:
            return true
        default:
            return false
        }
    }
    
    // MARK: UITableViewDataSource Implementation
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
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
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        let headerCell = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: LocalConstants.AKHeaderHeight))
        headerCell.backgroundColor = UIColor.clear
        
        return headerCell
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView?
    {
        let footerCell = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: LocalConstants.AKFooterHeight))
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        switch indexPath.section {
        case 0:
            self.performSegue(withIdentifier: GlobalConstants.AKViewBackupSegue, sender: self)
            break
        case 1:
            self.performSegue(withIdentifier: GlobalConstants.AKViewGoodiesSegue, sender: self)
            break
        default:
            break
        }
    }
    
    // MARK: Miscellaneous
    func customSetup()
    {
        self.inhibitTapGesture = true
        self.setup()
        
        // Custom Components
        self.configurationsTable.register(UINib(nibName: "AKConfigurationsTableViewCell", bundle: nil), forCellReuseIdentifier: "ConfigurationsTableCell")
        
        // Delegate & DataSource
        self.configurationsTable?.dataSource = self
        self.configurationsTable?.delegate = self
    }
}
