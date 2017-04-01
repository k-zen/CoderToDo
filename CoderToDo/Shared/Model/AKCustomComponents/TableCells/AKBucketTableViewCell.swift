import UIKit

class AKBucketTableViewCell: UITableViewCell
{
    // MARK: Outlets
    @IBOutlet weak var mainContainer: UIView!
    @IBOutlet weak var infoContainer: UIView!
    @IBOutlet weak var dateContainer: UIView!
    @IBOutlet weak var nameValue: UILabel!
    @IBOutlet weak var priorityValue: UILabel!
    
    // MARK: UITableViewCell Overriding
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        // Custom L&F.
        self.priorityValue.layer.cornerRadius = GlobalConstants.AKButtonCornerRadius
        self.priorityValue.layer.masksToBounds = true
    }
    
    override func setSelected(_ selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)
    }
}
