import UIKit

class AKBucketTableViewCell: UITableViewCell
{
    // MARK: Properties
    let displaceableMenuOverlay = AKDisplaceableTableMenuView()
    var swipeLeftGesture: UISwipeGestureRecognizer?
    var swipeRightGesture: UISwipeGestureRecognizer?
    var controller: AKCustomViewController?
    
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
        
        // Manage gestures.
        self.swipeLeftGesture = UISwipeGestureRecognizer(target: self, action: #selector(AKProjectsTableViewCell.swipeLeft(_:)))
        self.swipeLeftGesture?.delegate = self
        self.swipeLeftGesture?.direction = .left
        self.addGestureRecognizer(self.swipeLeftGesture!)
        self.swipeRightGesture = UISwipeGestureRecognizer(target: self, action: #selector(AKProjectsTableViewCell.swipeRight(_:)))
        self.swipeRightGesture?.delegate = self
        self.swipeRightGesture?.direction = .right
        self.addGestureRecognizer(self.swipeRightGesture!)
        
        // Custom L&F.
        self.priorityValue.layer.cornerRadius = GlobalConstants.AKButtonCornerRadius
        self.priorityValue.layer.masksToBounds = true
        self.selectionStyle = UITableViewCellSelectionStyle.none
    }
    
    override func setSelected(_ selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)
        
        self.toggleDisplaceableMenu(state: .notVisible)
    }
    
    // MARK: UIGestureRecognizerDelegate Implementation
    override func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool
    {
        if gestureRecognizer.isKind(of: UISwipeGestureRecognizer.self) {
            return true
        }
        else {
            return false // By default disable all gestures!
        }
    }
    
    // MARK: Gesture Handling
    @objc internal func swipeLeft(_ gesture: UIGestureRecognizer?) { self.toggleDisplaceableMenu(state: .visible) }
    
    @objc internal func swipeRight(_ gesture: UIGestureRecognizer?) { self.toggleDisplaceableMenu(state: .notVisible) }
    
    // MARK: Menu Handling
    func toggleDisplaceableMenu(state: DisplaceableMenuStates)
    {
        switch state {
        case .visible:
            // The origin never changes so fix it to the controller's view.
            var origin = CGPoint.zero
            origin.x = self.frame.width - AKDisplaceableTableMenuView.LocalConstants.AKViewWidth
            
            // Configure the overlay.
            self.displaceableMenuOverlay.controller = self.controller
            self.displaceableMenuOverlay.tableCell = self
            self.displaceableMenuOverlay.showEditButton = false
            self.displaceableMenuOverlay.customHeight = 45.0
            self.displaceableMenuOverlay.mainContainer.backgroundColor = GlobalConstants.AKCoderToDoGray2
            self.displaceableMenuOverlay.setup()
            self.displaceableMenuOverlay.draw(container: self, coordinates: origin, size: CGSize.zero)
            self.displaceableMenuOverlay.deleteAction = { (overlay, controller) -> Void in
                if let overlay = overlay as? AKDisplaceableTableMenuView, let controller = self.controller as? AKBrainstormingBucketViewController {
                    if let cell = overlay.tableCell {
                        if let selectedProject = controller.selectedProject {
                            if let indexPath = controller.bucketTable.indexPath(for: cell) {
                                let date = DataInterface.getEntryDates(project: selectedProject)[indexPath.section]
                                let bucketEntry = DataInterface.getBucketEntries(project: selectedProject, forDate: date)[indexPath.row]
                                DataInterface.removeBucketEntry(project: selectedProject, entry: bucketEntry)
                                
                                Func.AKReloadTableWithAnimation(tableView: controller.projectListTable)
                                Func.AKReloadTableWithAnimation(tableView: controller.bucketTable)
                            }
                        }
                    }
                }
            }
            
            // Expand/Show the overlay.
            self.displaceableMenuOverlay.expand(
                controller: self.controller,
                expandHeight: 45.0,
                animate: true,
                completionTask: nil
            )
            break
        case .notVisible:
            self.displaceableMenuOverlay.collapse(
                controller: self.controller,
                animate: true,
                completionTask: nil
            )
            break
        }
    }
}
