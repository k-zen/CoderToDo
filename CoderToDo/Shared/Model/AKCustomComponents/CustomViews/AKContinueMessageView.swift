import UIKit

class AKContinueMessageView: AKCustomView, AKCustomViewProtocol
{
    // MARK: Constants
    struct LocalConstants {
        static let AKViewWidth: CGFloat = 300.0
        static let AKViewHeight: CGFloat = 128.0
    }
    
    // MARK: Properties
    var controller: AKCustomViewController?
    var yesAction: (AKCustomViewController?) -> Void = { _ in NSLog("=> INFO: YES HAS BEEN PRESSED!") }
    var noAction: (AKCustomViewController?) -> Void = { _ in NSLog("=> INFO: NO HAS BEEN PRESSED!") }
    
    // MARK: Outlets
    @IBOutlet var mainContainer: UIView!
    @IBOutlet weak var message: UILabel!
    @IBOutlet weak var yes: UIButton!
    @IBOutlet weak var no: UIButton!
    
    // MARK: Actions
    @IBAction func yes(_ sender: Any)
    {
        self.controller?.hideMessage(
            animate: true,
            completionTask: nil
        )
        self.yesAction(self.controller)
    }
    
    @IBAction func no(_ sender: Any)
    {
        self.controller?.hideMessage(
            animate: true,
            completionTask: nil
        )
        self.noAction(self.controller)
    }
    
    // MARK: UIView Overriding
    convenience init() { self.init(frame: CGRect.zero) }
    
    // MARK: Miscellaneous
    func setup()
    {
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
        self.getView().layer.borderWidth = CGFloat(GlobalConstants.AKDefaultBorderThickness)
        self.getView().layer.borderColor = GlobalConstants.AKDefaultViewBorderBg.cgColor
        self.yes.layer.cornerRadius = GlobalConstants.AKButtonCornerRadius
        self.no.layer.cornerRadius = GlobalConstants.AKButtonCornerRadius
    }
    
    func draw(container: UIView, coordinates: CGPoint, size: CGSize)
    {
        self.getView().frame = CGRect(
            x: Func.AKCenterScreenCoordinate(container, LocalConstants.AKViewWidth, LocalConstants.AKViewHeight).x,
            y: Func.AKCenterScreenCoordinate(container, LocalConstants.AKViewWidth, LocalConstants.AKViewHeight).y,
            width: LocalConstants.AKViewWidth,
            height: size.height
        )
        container.addSubview(self.getView())
    }
}
