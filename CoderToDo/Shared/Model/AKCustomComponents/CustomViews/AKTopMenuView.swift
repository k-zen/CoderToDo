import UIKit

class AKTopMenuView: AKCustomView, AKCustomViewProtocol {
    // MARK: Constants
    struct LocalConstants {
        static let AKViewHeight: CGFloat = 42.0
    }
    
    // MARK: Properties
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
    @IBAction func add(_ sender: Any) { self.addAction(self.controller) }
    
    @IBAction func sort(_ sender: Any) { self.sortAction(self.controller) }
    
    @IBAction func filter(_ sender: Any) { self.filterAction(self.controller) }
    
    @IBAction func search(_ sender: Any) { self.searchAction(self.controller) }
    
    // MARK: UIView Overriding
    convenience init() { self.init(frame: CGRect.zero) }
    
    // MARK: Miscellaneous
    override func setup() {
        super.setup()
        
        self.getView().translatesAutoresizingMaskIntoConstraints = true
        self.getView().clipsToBounds = true
        
        self.loadComponents()
        self.applyLookAndFeel()
        self.addAnimations(expandCollapseHeight: LocalConstants.AKViewHeight)
    }
    
    func loadComponents() {}
    
    func applyLookAndFeel() {}
    
    func draw(container: UIView, coordinates: CGPoint, size: CGSize) {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        self.getView().frame = CGRect(
            x: coordinates.x,
            y: coordinates.y,
            width: size.width,
            height: size.height
        )
        container.addSubview(self.getView())
        CATransaction.commit()
    }
    
    func resetViewDefaults(controller: AKCustomViewController) {}
}
