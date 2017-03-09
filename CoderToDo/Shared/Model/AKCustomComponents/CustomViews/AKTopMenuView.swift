import UIKit

class AKTopMenuView: AKCustomView, AKCustomViewProtocol
{
    // MARK: Constants
    struct LocalConstants {
        static let AKViewHeight: CGFloat = 41.5
    }
    
    // MARK: Properties
    var controller: AKCustomViewController?
    var addAction: (AKCustomViewController?) -> Void = { _ in NSLog("=> INFO: ADD HAS BEEN PRESSED!") }
    var sortAction: (AKCustomViewController?) -> Void = { _ in NSLog("=> INFO: SORT HAS BEEN PRESSED!") }
    var filterAction: (AKCustomViewController?) -> Void = { _ in NSLog("=> INFO: FILTER HAS BEEN PRESSED!") }
    var searchAction: (AKCustomViewController?) -> Void = { _ in NSLog("=> INFO: SEARCH HAS BEEN PRESSED!") }
    
    // MARK: Outlets
    @IBOutlet var mainContainer: UIView!
    @IBOutlet weak var add: UIButton!
    @IBOutlet weak var sort: UIButton!
    @IBOutlet weak var filter: UIButton!
    @IBOutlet weak var search: UIButton!
    
    // MARK: Actions
    @IBAction func add(_ sender: Any) { self.controller?.hideMessage(animate: true, completionTask: nil); self.addAction(self.controller) }
    
    @IBAction func sort(_ sender: Any) { self.controller?.hideMessage(animate: true, completionTask: nil); self.sortAction(self.controller) }
    
    @IBAction func filter(_ sender: Any) { self.controller?.hideMessage(animate: true, completionTask: nil); self.filterAction(self.controller) }
    
    @IBAction func search(_ sender: Any) { self.controller?.hideMessage(animate: true, completionTask: nil); self.searchAction(self.controller) }
    
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
    
    func applyLookAndFeel() {}
    
    func draw(container: UIView, coordinates: CGPoint, size: CGSize)
    {
        self.getView().frame = CGRect(
            x: coordinates.x,
            y: coordinates.y,
            width: size.width,
            height: size.height
        )
        container.addSubview(self.getView())
    }
}
