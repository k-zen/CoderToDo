import UIKit

class AKFilterView: AKCustomView, AKCustomViewProtocol, UIPickerViewDataSource, UIPickerViewDelegate
{
    // MARK: Constants
    struct LocalConstants {
        static let AKViewHeight: CGFloat = 70.0
    }
    
    // MARK: Local Enums
    private enum LocalEnums: Int {
        case filterType = 1
        case filterValue = 2
    }
    
    // MARK: Properties
    private var filterTypeData = [String]()
    private var filterValueData = [String]()
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
        case LocalEnums.filterType.rawValue:
            return self.filterTypeData[row]
        case LocalEnums.filterValue.rawValue:
            return self.filterValueData[row]
        default:
            return ""
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView
    {
        let pickerLabel = UILabel()
        pickerLabel.textColor = GlobalConstants.AKPickerViewFg
        
        switch pickerView.tag {
        case LocalEnums.filterType.rawValue:
            pickerLabel.text = self.filterTypeData[row]
            break
        case LocalEnums.filterValue.rawValue:
            pickerLabel.text = self.filterValueData[row]
            break
        default:
            pickerLabel.text = ""
            break
        }
        
        pickerLabel.textAlignment = .center
        pickerLabel.backgroundColor = GlobalConstants.AKDefaultBg
        pickerLabel.font = UIFont(name: GlobalConstants.AKSecondaryFont, size: GlobalConstants.AKPickerFontSize)
        
        return pickerLabel
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        if let controller = self.controller as? AKListProjectsViewController {
            let filterType = self.filterTypeData[self.type.selectedRow(inComponent: 0)]
            let filterValue = self.filterValueData[self.filters.selectedRow(inComponent: 0)]
            
            controller.filterType = ProjectFilter(rawValue: filterType)!
            switch controller.filterType {
            case ProjectFilter.status:
                controller.filterValue = ProjectFilterStatus(rawValue: filterValue)!.rawValue
                break
            }
            Func.AKReloadTableWithAnimation(tableView: controller.projectsTable)
        }
        else if let controller = self.controller as? AKViewProjectViewController {
            let filterType = self.filterTypeData[self.type.selectedRow(inComponent: 0)]
            let filterValue = self.filterValueData[self.filters.selectedRow(inComponent: 0)]
            
            controller.filterType = TaskFilter(rawValue: filterType)!
            switch controller.filterType {
            case TaskFilter.state:
                controller.filterValue = TaskFilterStates(rawValue: filterValue)!.rawValue
                break
            }
            Func.AKReloadTableWithAnimation(tableView: controller.daysTable)
            for customCell in controller.customCellArray {
                Func.AKReloadTableWithAnimation(tableView: customCell.tasksTable!)
            }
        }
    }
    
    // MARK: UIPickerViewDataSource Implementation
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
    {
        switch pickerView.tag {
        case LocalEnums.filterType.rawValue:
            return self.filterTypeData.count
        case LocalEnums.filterValue.rawValue:
            return self.filterValueData.count
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
        self.type.tag = LocalEnums.filterType.rawValue
        self.filters.delegate = self
        self.filters.dataSource = self
        self.filters.tag = LocalEnums.filterValue.rawValue
        
        self.getView().translatesAutoresizingMaskIntoConstraints = true
        self.getView().clipsToBounds = true
        
        self.loadComponents()
        self.applyLookAndFeel()
        self.addAnimations(expandCollapseHeight: LocalConstants.AKViewHeight)
    }
    
    func loadComponents()
    {
        self.filterTypeData.removeAll()
        self.filterValueData.removeAll()
        if let _ = self.controller as? AKListProjectsViewController {
            for type in Func.AKIterateEnum(ProjectFilter.self) {
                self.filterTypeData.append(type.rawValue)
                if type == ProjectFilter.status {
                    for filter in Func.AKIterateEnum(ProjectFilterStatus.self) {
                        self.filterValueData.append(filter.rawValue)
                    }
                }
            }
        }
        else if let _ = self.controller as? AKViewProjectViewController {
            for type in Func.AKIterateEnum(TaskFilter.self) {
                self.filterTypeData.append(type.rawValue)
                if type == TaskFilter.state {
                    for filter in Func.AKIterateEnum(TaskFilterStates.self) {
                        self.filterValueData.append(filter.rawValue)
                    }
                }
            }
        }
    }
    
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
