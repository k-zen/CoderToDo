import UIKit

class AKDisplaceableTableMenuView: AKCustomView, AKCustomViewProtocol {
    // MARK: Constants
    struct LocalConstants {
        static let AKViewWidth: CGFloat = 120.0
        static let AKViewHeight: CGFloat = 72.0
    }
    
    // MARK: Properties
    var showEditButton = true
    var showDeleteButton = true
    var tableCell: UITableViewCell?
    var swipeLeftGesture: UISwipeGestureRecognizer?
    var swipeRightGesture: UISwipeGestureRecognizer?
    var editAction: ((AKCustomView?, AKCustomViewController?) -> Void)? = nil
    var deleteAction: ((AKCustomView?, AKCustomViewController?) -> Void)? = nil
    var customHeight: CGFloat = 0.0
    
    // MARK: Outlets
    @IBOutlet var mainContainer: UIView!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    
    // MARK: Constraints
    @IBOutlet weak var editButtonWidth: NSLayoutConstraint!
    @IBOutlet weak var editButtonX: NSLayoutConstraint!
    @IBOutlet weak var deleteButtonWidth: NSLayoutConstraint!
    @IBOutlet weak var deleteButtonX: NSLayoutConstraint!
    @IBOutlet weak var editButtonTop: NSLayoutConstraint!
    @IBOutlet weak var editButtonBottom: NSLayoutConstraint!
    @IBOutlet weak var deleteButtonTop: NSLayoutConstraint!
    @IBOutlet weak var deleteButtonBottom: NSLayoutConstraint!
    
    // MARK: Actions
    @IBAction func action(_ sender: Any) {
        if let button = sender as? UIButton {
            switch button.tag {
            case 1:
                if editAction != nil {
                    editAction!(self, self.controller)
                }
                break
            case 2:
                if deleteAction != nil {
                    deleteAction!(self, self.controller)
                }
                break
            default:
                break
            }
        }
    }
    
    // MARK: UIView Overriding
    convenience init() { self.init(frame: CGRect.zero) }
    
    // MARK: Miscellaneous
    override func setup() {
        super.setup()
        
        self.getView().translatesAutoresizingMaskIntoConstraints = true
        self.getView().clipsToBounds = true
        
        self.loadComponents()
        self.applyLookAndFeel()
        self.addAnimations(expandCollapseHeight: self.customHeight == 0.0 ? LocalConstants.AKViewHeight : self.customHeight)
    }
    
    func loadComponents() {
        if !self.showEditButton {
            self.editButtonWidth.constant = 0.0
            self.deleteButtonWidth.constant = 104.0
            self.deleteButtonX.constant = 0.0
        }
        if !self.showDeleteButton {
            self.editButtonWidth.constant = 104.0
            self.editButtonX.constant = 0.0
            self.deleteButtonWidth.constant = 0.0
        }
    }
    
    func applyLookAndFeel() {
        self.editButton.layer.cornerRadius = GlobalConstants.AKButtonCornerRadius
        self.deleteButton.layer.cornerRadius = GlobalConstants.AKButtonCornerRadius
    }
    
    func draw(container: UIView, coordinates: CGPoint, size: CGSize) {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        self.getView().frame = CGRect(
            x: coordinates.x,
            y: coordinates.y,
            width: LocalConstants.AKViewWidth,
            height: size.height
        )
        container.addSubview(self.getView())
        CATransaction.commit()
    }
    
    func resetViewDefaults(controller: AKCustomViewController) {}
}
