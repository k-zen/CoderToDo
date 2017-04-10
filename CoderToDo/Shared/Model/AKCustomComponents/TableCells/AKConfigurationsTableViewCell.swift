import UIKit

class AKConfigurationsTableViewCell: UITableViewCell
{
    // MARK: Properties
    let displaceableMenuOverlay = AKDisplaceableTableMenuView()
    var swipeLeftGesture: UISwipeGestureRecognizer?
    var swipeRightGesture: UISwipeGestureRecognizer?
    var controller: AKCustomViewController?
    
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
        
        // Manage gestures.
        self.swipeLeftGesture = UISwipeGestureRecognizer(target: self, action: #selector(AKProjectsTableViewCell.swipeLeft(_:)))
        self.swipeLeftGesture?.delegate = self
        self.swipeLeftGesture?.direction = .left
        self.addGestureRecognizer(self.swipeLeftGesture!)
        self.swipeRightGesture = UISwipeGestureRecognizer(target: self, action: #selector(AKProjectsTableViewCell.swipeRight(_:)))
        self.swipeRightGesture?.delegate = self
        self.swipeRightGesture?.direction = .right
        self.addGestureRecognizer(self.swipeRightGesture!)
        
        // Initial States.
        self.badgeWidth.constant = 0
        
        // Custom L&F.
        self.badge.layer.cornerRadius = GlobalConstants.AKButtonCornerRadius
        self.badge.layer.masksToBounds = true
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
        if self.controller == nil || !(self.controller?.isKind(of: AKUserDefinedCategoriesViewController.self))! {
            return // Disable editing for all except UserDefinedCategoriesViewController. TODO: Improve.
        }
        
        switch state {
        case .visible:
            // The origin never changes so fix it to the controller's view.
            var origin = CGPoint.zero
            origin.x = self.frame.width - AKDisplaceableTableMenuView.LocalConstants.AKViewWidth
            
            // Configure the overlay.
            self.displaceableMenuOverlay.controller = self.controller
            self.displaceableMenuOverlay.tableCell = self
            self.displaceableMenuOverlay.showEditButton = false
            self.displaceableMenuOverlay.customHeight = 40.0
            self.displaceableMenuOverlay.setup()
            self.displaceableMenuOverlay.draw(container: self, coordinates: origin, size: CGSize.zero)
            self.displaceableMenuOverlay.deleteAction = { (overlay, controller) -> Void in
                if let overlay = overlay as? AKDisplaceableTableMenuView, let controller = self.controller as? AKUserDefinedCategoriesViewController {
                    if let cell = overlay.tableCell {
                        if let indexPath = controller.userDefinedCategoriesTable.indexPath(for: cell) {
                            do {
                                try DataInterface.removeProjectCategory(project: controller.project, name: DataInterface.listProjectCategories(project: controller.project)[indexPath.section])
                                Func.AKReloadTable(tableView: controller.userDefinedCategoriesTable)
                            }
                            catch {
                                Func.AKPresentMessageFromError(controller: controller, message: "\(error)")
                            }
                        }
                    }
                }
            }
            
            // Expand/Show the overlay.
            self.displaceableMenuOverlay.expand(
                controller: self.controller,
                expandHeight: 40.0,
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
