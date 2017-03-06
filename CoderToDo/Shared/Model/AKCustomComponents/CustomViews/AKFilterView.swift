import UIKit

class AKFilterView: AKCustomView, AKCustomViewProtocol, UIPickerViewDataSource, UIPickerViewDelegate
{
    // MARK: Constants
    struct LocalConstants {
        static let AKViewHeight: CGFloat = 70.0
        static let AKExpandHeightAnimation = "expandHeight"
        static let AKCollapseHeightAnimation = "collapseHeight"
    }
    
    // MARK: Local Enums
    private enum LocalEnums: Int {
        case type = 1
        case filters = 2
    }
    
    // MARK: Properties
    private var typeData = [String]()
    private var filtersData = [String]()
    private let expandHeight = CABasicAnimation(keyPath: LocalConstants.AKExpandHeightAnimation)
    private let collapseHeight = CABasicAnimation(keyPath: LocalConstants.AKCollapseHeightAnimation)
    var controller: AKCustomViewController?
    
    // MARK: Outlets
    @IBOutlet weak var mainContainer: UIView!
    @IBOutlet weak var type: UIPickerView!
    @IBOutlet weak var filters: UIPickerView!
    
    // MARK: UIView Overriding
    convenience init() { self.init(frame: CGRect.zero) }
    
    // MARK: UIPickerViewDelegate Implementation
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?
    {
        switch pickerView.tag {
        case LocalEnums.type.rawValue:
            return self.typeData[row]
        case LocalEnums.filters.rawValue:
            return self.filtersData[row]
        default:
            return ""
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView
    {
        let pickerLabel = UILabel()
        pickerLabel.textColor = GlobalConstants.AKPickerViewFg
        
        switch pickerView.tag {
        case LocalEnums.type.rawValue:
            pickerLabel.text = self.typeData[row]
            pickerLabel.textAlignment = .center
            pickerLabel.backgroundColor = GlobalConstants.AKCoderToDoGray3
            break
        case LocalEnums.filters.rawValue:
            pickerLabel.text = self.filtersData[row]
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
            let filterType = self.typeData[self.type.selectedRow(inComponent: 0)]
            let filterValue = self.filtersData[self.filters.selectedRow(inComponent: 0)]
            
            controller.filterType = ProjectFilter(rawValue: filterType)!
            switch controller.filterType {
            case ProjectFilter.status:
                controller.filterValue = ProjectFilterStatus(rawValue: filterValue)!.rawValue
                break
            }
            controller.projectsTable.reloadData()
        }
        else if let controller = self.controller as? AKViewProjectViewController {
            // controller.sortTasksBy = TaskSorting(rawValue: self.filtersData[self.filters.selectedRow(inComponent: 0)])!
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
        case LocalEnums.type.rawValue:
            return self.typeData.count
        case LocalEnums.filters.rawValue:
            return self.filtersData.count
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
        self.type.delegate = self
        self.type.dataSource = self
        self.type.tag = LocalEnums.type.rawValue
        self.filters.delegate = self
        self.filters.dataSource = self
        self.filters.tag = LocalEnums.filters.rawValue
        
        self.getView().translatesAutoresizingMaskIntoConstraints = true
        self.getView().clipsToBounds = true
        
        self.loadComponents()
        self.applyLookAndFeel()
        self.addAnimations()
    }
    
    func loadComponents()
    {
        self.typeData.removeAll()
        self.filtersData.removeAll()
        if let _ = self.controller as? AKListProjectsViewController {
            for type in Func.AKIterateEnum(ProjectFilter.self) {
                self.typeData.append(type.rawValue)
                if type == ProjectFilter.status {
                    for filter in Func.AKIterateEnum(ProjectFilterStatus.self) {
                        self.filtersData.append(filter.rawValue)
                    }
                }
            }
            
            self.filters.selectRow(0, inComponent: 0, animated: true)
        }
        else if let _ = self.controller as? AKViewProjectViewController {
            // TODO
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
