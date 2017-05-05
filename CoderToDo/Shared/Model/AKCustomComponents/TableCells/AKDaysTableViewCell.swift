import UIKit

class AKDaysTableViewCell: UITableViewCell {
    // MARK: Outlets
    @IBOutlet weak var mainContainer: UIView!
    @IBOutlet weak var title: UILabel!
    
    // MARK: UITableViewCell Overriding
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
