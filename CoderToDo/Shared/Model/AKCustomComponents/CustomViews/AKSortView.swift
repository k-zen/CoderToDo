import UIKit

class AKSortView: AKCustomView, AKCustomViewProtocol, UIPickerViewDataSource, UIPickerViewDelegate
{
    // MARK: Constants
    struct LocalConstants {
        static let AKViewHeight: CGFloat = 70.0
        static let AKExpandHeightAnimation = "expandHeight"
        static let AKCollapseHeightAnimation = "collapseHeight"
    }
    
    // MARK: Local Enums
    private enum LocalEnums: Int {
        case filters = 1
        case order = 2
    }
    
    // MARK: Properties
    private let expandHeight = CABasicAnimation(keyPath: LocalConstants.AKExpandHeightAnimation)
    private let collapseHeight = CABasicAnimation(keyPath: LocalConstants.AKCollapseHeightAnimation)
    private var filtersData = [String]()
    private var orderData = [SortingOrder]()
    var defaultOperationsExpand: (AKCustomView) -> Void = { (view) -> Void in }
    var defaultOperationsCollapse: (AKCustomView) -> Void = { (view) -> Void in }
    var controller: AKCustomViewController?
    
    // MARK: Outlets
    @IBOutlet weak var mainContainer: UIView!
    @IBOutlet weak var filters: UIPickerView!
    @IBOutlet weak var order: UIPickerView!
    
    // MARK: UIView Overriding
    convenience init() { self.init(frame: CGRect.zero) }
    
    // MARK: UIPickerViewDelegate Implementation
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?
    {
        switch pickerView.tag {
        case LocalEnums.filters.rawValue:
            return self.filtersData[row]
        case LocalEnums.order.rawValue:
            return self.orderData[row].rawValue
        default:
            return ""
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView
    {
        let pickerLabel = UILabel()
        pickerLabel.textColor = GlobalConstants.AKPickerViewFg
        
        switch pickerView.tag {
        case LocalEnums.filters.rawValue:
            pickerLabel.text = self.filtersData[row]
            pickerLabel.textAlignment = .center
            pickerLabel.backgroundColor = GlobalConstants.AKCoderToDoGray3
            break
        case LocalEnums.order.rawValue:
            pickerLabel.text = self.orderData[row].rawValue
            pickerLabel.textAlignment = .center
            pickerLabel.backgroundColor = GlobalConstants.AKCoderToDoGray3
            break
        default:
            pickerLabel.text = ""
            break
        }
        
        pickerLabel.font = UIFont(name: GlobalConstants.AKSecondaryFont, size: GlobalConstants.AKPickerFontSize)
        
        return pickerLabel
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        if let controller = self.controller as? AKListProjectsViewController {
            controller.sortType = ProjectSorting(rawValue: self.filtersData[self.filters.selectedRow(inComponent: 0)])!
            controller.sortOrder = self.orderData[self.order.selectedRow(inComponent: 0)]
            controller.projectsTable.reloadData()
        }
        else if let controller = self.controller as? AKViewProjectViewController {
            controller.sortType = TaskSorting(rawValue: self.filtersData[self.filters.selectedRow(inComponent: 0)])!
            controller.sortOrder = self.orderData[self.order.selectedRow(inComponent: 0)]
            controller.daysTable.reloadData()
            for customCell in controller.customCellArray {
                customCell.tasksTable?.reloadData()
            }
        }
    }
    
    // MARK: UIPickerViewDataSource Implementation
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
    {
        switch pickerView.tag {
        case LocalEnums.filters.rawValue:
            return self.filtersData.count
        case LocalEnums.order.rawValue:
            return self.orderData.count
        default:
            return 0
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int { return 1 }
    
    // MARK: Miscellaneous
    func setup()
    {
        NSLog("=> ENTERING SETUP ON FRAME: \(type(of:self))")
        
        // Delegate & DataSource
        self.filters.delegate = self
        self.filters.dataSource = self
        self.filters.tag = LocalEnums.filters.rawValue
        self.order.delegate = self
        self.order.dataSource = self
        self.order.tag = LocalEnums.order.rawValue
        
        self.getView().translatesAutoresizingMaskIntoConstraints = true
        self.getView().clipsToBounds = true
        
        self.loadComponents()
        self.applyLookAndFeel()
        self.addAnimations()
    }
    
    func loadComponents()
    {
        self.filtersData.removeAll()
        self.orderData.removeAll()
        if let _ = self.controller as? AKListProjectsViewController {
            for filter in Func.AKIterateEnum(ProjectSorting.self) {
                self.filtersData.append(filter.rawValue)
            }
            for order in Func.AKIterateEnum(SortingOrder.self) {
                self.orderData.append(order)
            }
            
            self.filters.selectRow(2, inComponent: 0, animated: true)
        }
        else if let _ = self.controller as? AKViewProjectViewController {
            for filter in Func.AKIterateEnum(TaskSorting.self) {
                self.filtersData.append(filter.rawValue)
            }
            for order in Func.AKIterateEnum(SortingOrder.self) {
                self.orderData.append(order)
            }
            
            self.filters.selectRow(0, inComponent: 0, animated: true)
        }
    }
    
    func applyLookAndFeel() {}
    
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
