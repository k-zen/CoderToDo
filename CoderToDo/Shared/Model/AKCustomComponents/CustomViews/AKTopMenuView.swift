import UIKit

class AKTopMenuView: AKCustomView
{
    // MARK: Constants
    struct LocalConstants {
        static let AKViewHeight: CGFloat = 41.5
        static let AKExpandHeightAnimation = "expandHeight"
        static let AKCollapseHeightAnimation = "collapseHeight"
    }
    
    // MARK: Properties
    let expandHeight = CABasicAnimation(keyPath: LocalConstants.AKExpandHeightAnimation)
    let collapseHeight = CABasicAnimation(keyPath: LocalConstants.AKCollapseHeightAnimation)
    var controller: AKCustomViewController?
    var addAction: (AKCustomViewController?) -> Void = { _ in NSLog("=> INFO: ADD HAS BEEN PRESSED!") }
    var sortAction: (AKCustomViewController?) -> Void = { _ in NSLog("=> INFO: SORT HAS BEEN PRESSED!") }
    var filterAction: (AKCustomViewController?) -> Void = { _ in NSLog("=> INFO: FILTER HAS BEEN PRESSED!") }
    var searchAction: (AKCustomViewController?) -> Void = { _ in NSLog("=> INFO: SEARCH HAS BEEN PRESSED!") }
    
    // MARK: Properties
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
    convenience init()
    {
        NSLog("=> DEFAULT init()")
        self.init(frame: CGRect.zero)
    }
    
    override init(frame: CGRect)
    {
        NSLog("=> FRAME init()")
        super.init(frame: frame)
        setup()
    }
    
    required init(coder aDecoder: NSCoder)
    {
        NSLog("=> CODER init()")
        super.init(coder: aDecoder)!
    }
    
    // MARK: Miscellaneous
    func setup()
    {
        NSLog("=> ENTERING SETUP ON FRAME: \(type(of:self))")
        
        self.expandHeight.fromValue = 0.0
        self.expandHeight.toValue = LocalConstants.AKViewHeight
        self.expandHeight.duration = 1.0
        self.expandHeight.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        self.expandHeight.autoreverses = false
        self.customView.layer.add(self.expandHeight, forKey: LocalConstants.AKExpandHeightAnimation)
        
        self.collapseHeight.fromValue = LocalConstants.AKViewHeight
        self.collapseHeight.toValue = 0.0
        self.collapseHeight.duration = 1.0
        self.collapseHeight.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        self.collapseHeight.autoreverses = false
        self.customView.layer.add(self.collapseHeight, forKey: LocalConstants.AKCollapseHeightAnimation)
    }
}
