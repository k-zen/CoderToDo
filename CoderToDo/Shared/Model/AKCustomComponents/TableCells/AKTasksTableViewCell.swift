import UIKit

class AKTasksTableViewCell: UITableViewCell {
    // MARK: Outlets
    @IBOutlet weak var mainContainer: UIView!
    @IBOutlet weak var infoContainer: UIView!
    @IBOutlet weak var stateContainer: UIView!
    @IBOutlet weak var taskNameValue: UILabel!
    @IBOutlet weak var taskStateValue: UILabel!
    @IBOutlet weak var taskCompletionPercentageValue: UILabel!
    
    // MARK: UITableViewCell Overriding
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
