import UIKit

class AKSearchView: AKCustomView, AKCustomViewProtocol, UISearchBarDelegate
{
    // MARK: Constants
    struct LocalConstants {
        static let AKViewHeight: CGFloat = 44.0
    }
    
    // MARK: Properties
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
        self.addAnimations(expandCollapseHeight: LocalConstants.AKViewHeight)
    }
    
    func loadComponents() {}
    
    func applyLookAndFeel()
    {
        self.searchBar.keyboardAppearance = .dark
        self.searchBar.autocapitalizationType = .none
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
}
