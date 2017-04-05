import UIKit

class AKInitialMessageView: AKCustomView, AKCustomViewProtocol
{
    // MARK: Constants
    struct LocalConstants {
        static let AKViewWidth: CGFloat = 300.0
        static let AKViewHeight: CGFloat = 196.0
    }
    
    // MARK: Outlets
    @IBOutlet var mainContainer: UIView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var message: UILabel!
    
    // MARK: UIView Overriding
    convenience init() { self.init(frame: CGRect.zero) }
    
    // MARK: Miscellaneous
    override func setup()
    {
        super.inhibitTapGesture = false
        super.setup()
        
        NSLog("=> ENTERING SETUP ON FRAME: \(type(of:self))")
        
        self.getView().translatesAutoresizingMaskIntoConstraints = true
        self.getView().clipsToBounds = true
        
        self.loadComponents()
        self.applyLookAndFeel()
        self.addAnimations(expandCollapseHeight: LocalConstants.AKViewHeight)
    }
    
    func loadComponents() {}
    
    func applyLookAndFeel()
    {
        self.getView().layer.cornerRadius = GlobalConstants.AKViewCornerRadius
    }
    
    func draw(container: UIView, coordinates: CGPoint, size: CGSize)
    {
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
}
