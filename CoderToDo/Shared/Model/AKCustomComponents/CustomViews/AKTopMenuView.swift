import UIKit

class AKTopMenuView: AKCustomView, AKCustomViewProtocol
{
    // MARK: Constants
    struct LocalConstants {
        static let AKViewHeight: CGFloat = 41.5
        static let AKExpandHeightAnimation = "expandHeight"
        static let AKCollapseHeightAnimation = "collapseHeight"
    }
    
    // MARK: Properties
    private let expandHeight = CABasicAnimation(keyPath: LocalConstants.AKExpandHeightAnimation)
    private let collapseHeight = CABasicAnimation(keyPath: LocalConstants.AKCollapseHeightAnimation)
    var defaultOperationsExpand: (AKCustomView) -> Void = { (view) -> Void in }
    var defaultOperationsCollapse: (AKCustomView) -> Void = { (view) -> Void in }
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
    @IBAction func add(_ sender: Any) { self.controller?.hideMessage(); self.addAction(self.controller) }
    
    @IBAction func sort(_ sender: Any) { self.controller?.hideMessage(); self.sortAction(self.controller) }
    
    @IBAction func filter(_ sender: Any) { self.controller?.hideMessage(); self.filterAction(self.controller) }
    
    @IBAction func search(_ sender: Any) { self.controller?.hideMessage(); self.searchAction(self.controller) }
    
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
        self.addAnimations()
    }
    
    func loadComponents() {}
    
    func applyLookAndFeel()
    {
        Func.AKAddBorderDeco(self.add.titleLabel!, color: GlobalConstants.AKCoderToDoBlue.cgColor, thickness: GlobalConstants.AKDefaultBorderThickness, position: .bottom)
        Func.AKAddBorderDeco(self.sort.titleLabel!, color: GlobalConstants.AKCoderToDoBlue.cgColor, thickness: GlobalConstants.AKDefaultBorderThickness, position: .bottom)
        Func.AKAddBorderDeco(self.filter.titleLabel!, color: GlobalConstants.AKCoderToDoBlue.cgColor, thickness: GlobalConstants.AKDefaultBorderThickness, position: .bottom)
        Func.AKAddBorderDeco(self.search.titleLabel!, color: GlobalConstants.AKCoderToDoBlue.cgColor, thickness: GlobalConstants.AKDefaultBorderThickness, position: .bottom)
    }
    
    func addAnimations()
    {
        self.expandHeight.fromValue = 0.0
        self.expandHeight.toValue = LocalConstants.AKViewHeight
        self.expandHeight.duration = 1.0
        self.expandHeight.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        self.expandHeight.autoreverses = false
        self.getView().layer.add(self.expandHeight, forKey: LocalConstants.AKExpandHeightAnimation)
        
        self.collapseHeight.fromValue = LocalConstants.AKViewHeight
        self.collapseHeight.toValue = 0.0
        self.collapseHeight.duration = 1.0
        self.collapseHeight.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        self.collapseHeight.autoreverses = false
        self.getView().layer.add(self.collapseHeight, forKey: LocalConstants.AKCollapseHeightAnimation)
    }
    
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
    
    func expand(completionTask: ((_ presenterController: AKCustomViewController?) -> Void)?)
    {
        self.defaultOperationsExpand(self)
        
        UIView.beginAnimations(LocalConstants.AKExpandHeightAnimation, context: nil)
        Func.AKChangeComponentHeight(component: self.getView(), newHeight: LocalConstants.AKViewHeight)
        CATransaction.setCompletionBlock {
            if completionTask != nil {
                completionTask!(self.controller)
            }
        }
        UIView.commitAnimations()
    }
    
    func collapse(completionTask: ((_ presenterController: AKCustomViewController?) -> Void)?)
    {
        self.defaultOperationsCollapse(self)
        
        UIView.beginAnimations(LocalConstants.AKCollapseHeightAnimation, context: nil)
        Func.AKChangeComponentHeight(component: self.getView(), newHeight: 0.0)
        CATransaction.setCompletionBlock {
            if completionTask != nil {
                completionTask!(self.controller)
            }
        }
        UIView.commitAnimations()
    }
}
