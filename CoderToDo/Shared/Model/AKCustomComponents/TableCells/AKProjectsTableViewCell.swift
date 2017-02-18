import UIKit

class AKProjectsTableViewCell: UITableViewCell
{
    // MARK: Outlets
    @IBOutlet weak var mainContainer: UIView!
    @IBOutlet weak var infoContainer: UIView!
    @IBOutlet weak var osrValue: UILabel!
    @IBOutlet weak var stateContainer: UIView!
    @IBOutlet weak var runningDaysValue: UILabel!
    @IBOutlet weak var addTomorrowTask: UIButton!
    @IBOutlet weak var statusValue: UILabel!
    @IBOutlet weak var startValue: UILabel!
    @IBOutlet weak var closeValue: UILabel!
    
    // MARK: Actions
    @IBAction func addTomorrowTask(_ sender: Any)
    {
        NSLog("=> INFO: PRESSED BUTTON TO ADD TASK FOR TOMORROW!")
    }
    
    // MARK: UITableViewCell Overriding
    override func awakeFromNib()
    {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)
    }
}
