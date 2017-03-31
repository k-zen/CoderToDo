import UIKit

class AKConfigurationsTableViewCell: UITableViewCell
{
    // MARK: Outlets
    @IBOutlet weak var mainContainer: UIView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var arrow: UILabel!
    @IBOutlet weak var arrowWidth: NSLayoutConstraint!
    @IBOutlet weak var badge: UILabel!
    @IBOutlet weak var badgeWidth: NSLayoutConstraint!
    
    // MARK: UITableViewCell Overriding
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        self.badgeWidth.constant = 0
        
        // Custom L&F.
        self.badge.layer.cornerRadius = GlobalConstants.AKButtonCornerRadius
        self.badge.layer.masksToBounds = true
    }
    
    override func setSelected(_ selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)
    }
}
