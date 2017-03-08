import UIKit

class AKSearchView: AKCustomView, AKCustomViewProtocol, UISearchBarDelegate
{
    // MARK: Constants
    struct LocalConstants {
        static let AKViewHeight: CGFloat = 44.0
        static let AKExpandHeightAnimation = "expandHeight"
        static let AKCollapseHeightAnimation = "collapseHeight"
    }
    
    // MARK: Properties
    private let expandHeight = CABasicAnimation(keyPath: LocalConstants.AKExpandHeightAnimation)
    private let collapseHeight = CABasicAnimation(keyPath: LocalConstants.AKCollapseHeightAnimation)
    var controller: AKCustomViewController?
    
    // MARK: Outlets
    @IBOutlet weak var mainContainer: UIView!
    @IBOutlet var searchBar: UISearchBar!
    
    // MARK: UIView Overriding
    convenience init() { self.init(frame: CGRect.zero) }
    
    // MARK: UISearchBarDelegate Implementation
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String)
    {
        if let controller = self.controller as? AKListProjectsViewController {
            controller.searchTerm = searchText.compare("") == .orderedSame ? Search.showAll.rawValue : searchText
            controller.projectsTable.reloadData()
        }
        else if let controller = self.controller as? AKViewProjectViewController {
            controller.searchTerm = searchText.compare("") == .orderedSame ? Search.showAll.rawValue : searchText
            controller.daysTable?.reloadData()
            for customCell in controller.customCellArray {
                customCell.tasksTable?.reloadData()
            }
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar)
    {
        if let controller = self.controller as? AKListProjectsViewController {
            controller.searchTerm = Search.showAll.rawValue
            controller.projectsTable.reloadData()
        }
        else if let controller = self.controller as? AKViewProjectViewController {
            controller.searchTerm = Search.showAll.rawValue
            controller.daysTable?.reloadData()
            for customCell in controller.customCellArray {
                customCell.tasksTable?.reloadData()
            }
        }
        
        // Always execute this.
        controller?.tap(nil)
        self.searchBar.text = ""
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar)
    {
        controller?.tap(nil)
    }
    
    // MARK: Miscellaneous
    func setup()
    {
        NSLog("=> ENTERING SETUP ON FRAME: \(type(of:self))")
        
        // Delegate & DataSource
        self.searchBar.delegate = self
        
        self.getView().translatesAutoresizingMaskIntoConstraints = true
        self.getView().clipsToBounds = true
        
        self.loadComponents()
        self.applyLookAndFeel()
        self.addAnimations()
    }
    
    func loadComponents() {}
    
    func applyLookAndFeel()
    {
        self.searchBar.keyboardAppearance = .dark
        self.searchBar.autocapitalizationType = .none
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
