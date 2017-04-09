import UIKit

class AKSearchView: AKCustomView, AKCustomViewProtocol, UISearchBarDelegate
{
    // MARK: Constants
    struct LocalConstants {
        static let AKViewHeight: CGFloat = 44.0
    }
    
    // MARK: Outlets
    @IBOutlet weak var mainContainer: UIView!
    @IBOutlet var searchBar: UISearchBar!
    
    // MARK: UIView Overriding
    convenience init() { self.init(frame: CGRect.zero) }
    
    // MARK: UISearchBarDelegate Implementation
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String)
    {
        if let controller = self.controller as? AKListProjectsViewController {
            controller.projectFilter.projectFilter?.searchTerm = SearchTerm(term: searchText.compare("") == .orderedSame ? Search.showAll.rawValue : searchText)
            Func.AKReloadTableWithAnimation(tableView: controller.projectsTable)
        }
        else if let controller = self.controller as? AKViewProjectViewController {
            controller.taskFilter.taskFilter?.searchTerm = SearchTerm(term: searchText.compare("") == .orderedSame ? Search.showAll.rawValue : searchText)
            Func.AKReloadTableWithAnimation(tableView: controller.daysTable)
            for customCell in controller.customCellArray {
                Func.AKReloadTableWithAnimation(tableView: customCell.tasksTable!)
            }
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar)
    {
        if let controller = self.controller as? AKListProjectsViewController {
            controller.projectFilter.projectFilter?.searchTerm = SearchTerm(term: Search.showAll.rawValue)
            Func.AKReloadTableWithAnimation(tableView: controller.projectsTable)
        }
        else if let controller = self.controller as? AKViewProjectViewController {
            controller.taskFilter.taskFilter?.searchTerm = SearchTerm(term: Search.showAll.rawValue)
            Func.AKReloadTableWithAnimation(tableView: controller.daysTable)
            for customCell in controller.customCellArray {
                Func.AKReloadTableWithAnimation(tableView: customCell.tasksTable!)
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
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool
    {
        self.searchBar.showsScopeBar = true
        self.searchBar.sizeToFit()
        
        self.searchBar.setShowsCancelButton(true, animated: true)
        return true
    }
    
    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool
    {
        self.searchBar.showsScopeBar = false
        self.searchBar.sizeToFit()
        
        self.searchBar.setShowsCancelButton(false, animated: true)
        return true
    }
    
    // MARK: Miscellaneous
    override func setup()
    {
        super.setup()
        
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
        self.searchBar.showsCancelButton = false
    }
    
    func draw(container: UIView, coordinates: CGPoint, size: CGSize)
    {
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
}
