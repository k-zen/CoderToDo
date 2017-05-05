import UIKit

class AKContinueMessageView: AKCustomView, AKCustomViewProtocol {
    // MARK: Constants
    struct LocalConstants {
        static let AKViewWidth: CGFloat = 300.0
        static let AKViewHeight: CGFloat = 162.0
    }
    
    // MARK: Properties
    var yesAction: ((AKCustomViewController?) -> Void)? = nil
    var noAction: ((AKCustomViewController?) -> Void)? = nil
    
    // MARK: Outlets
    @IBOutlet var mainContainer: UIView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var message: UILabel!
    @IBOutlet weak var yes: UIButton!
    @IBOutlet weak var no: UIButton!
    
    // MARK: Actions
    @IBAction func yes(_ sender: Any) {
        // Default Action!
        self.controller?.hideContinueMessage(animate: true, completionTask: nil)
        // Custom Action.
        if self.yesAction != nil {
            self.yesAction!(self.controller)
        }
    }
    
    @IBAction func no(_ sender: Any) {
        // Default Action!
        self.controller?.hideContinueMessage(animate: true, completionTask: nil)
        // Custom Action.
        if self.noAction != nil {
            self.noAction!(self.controller)
        }
    }
    
    // MARK: UIView Overriding
    convenience init() { self.init(frame: CGRect.zero) }
    
    // MARK: Miscellaneous
    override func setup() {
        super.shouldAddBlurView = true
        super.setup()
        
        self.getView().translatesAutoresizingMaskIntoConstraints = true
        self.getView().clipsToBounds = true
        
        self.loadComponents()
        self.applyLookAndFeel()
        self.addAnimations(expandCollapseHeight: LocalConstants.AKViewHeight)
    }
    
    func loadComponents() {}
    
    func applyLookAndFeel() {
        self.getView().layer.cornerRadius = GlobalConstants.AKViewCornerRadius
        self.getView().layer.masksToBounds = true
        self.getView().layer.borderColor = GlobalConstants.AKCoderToDoGray3.cgColor
        self.getView().layer.borderWidth = 2.0
        self.mainContainer.backgroundColor = UIColor.clear
        
        Func.AKStyleButton(button: self.yes)
        Func.AKStyleButton(button: self.no)
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
