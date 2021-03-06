import UIKit

class AKSortView: AKCustomView, AKCustomViewProtocol, UIPickerViewDataSource, UIPickerViewDelegate {
    // MARK: Constants
    struct LocalConstants {
        static let AKViewHeight: CGFloat = 70.0
    }
    
    // MARK: Local Enums
    private enum LocalEnums: Int {
        case order = 1
        case filters = 2
    }
    
    // MARK: Properties
    private var sortOrderData = [SortingOrder]()
    private var sortFilterData = [String]()
    
    // MARK: Outlets
    @IBOutlet weak var mainContainer: UIView!
    @IBOutlet weak var order: UIPickerView!
    @IBOutlet weak var filters: UIPickerView!
    
    // MARK: UIView Overriding
    convenience init() { self.init(frame: CGRect.zero) }
    
    // MARK: UIPickerViewDelegate Implementation
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch pickerView.tag {
        case LocalEnums.filters.rawValue:
            return self.sortFilterData[row]
        case LocalEnums.order.rawValue:
            return self.sortOrderData[row].rawValue
        default:
            return ""
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let pickerLabel = UILabel()
        pickerLabel.textColor = Cons.AKPickerViewFg
        
        switch pickerView.tag {
        case LocalEnums.filters.rawValue:
            pickerLabel.text = self.sortFilterData[row]
            break
        case LocalEnums.order.rawValue:
            pickerLabel.text = self.sortOrderData[row].rawValue
            break
        default:
            pickerLabel.text = ""
            break
        }
        
        pickerLabel.textAlignment = .center
        pickerLabel.backgroundColor = Cons.AKPickerViewBg
        pickerLabel.font = UIFont(name: Cons.AKSecondaryFont, size: Cons.AKPickerFontSize)
        
        return pickerLabel
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if let controller = self.controller as? AKListProjectsViewController {
            controller.projectFilter.projectFilter?.sortType = ProjectSorting(rawValue: self.sortFilterData[self.filters.selectedRow(inComponent: 0)])!
            controller.projectFilter.projectFilter?.sortOrder = self.sortOrderData[self.order.selectedRow(inComponent: 0)]
            
            Func.AKReloadTable(tableView: controller.projectsTable)
        }
        else if let controller = self.controller as? AKViewProjectViewController {
            controller.taskFilter.taskFilter?.sortType = TaskSorting(rawValue: self.sortFilterData[self.filters.selectedRow(inComponent: 0)])!
            controller.taskFilter.taskFilter?.sortOrder = self.sortOrderData[self.order.selectedRow(inComponent: 0)]
            
            controller.completeReload()
        }
    }
    
    // MARK: UIPickerViewDataSource Implementation
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView.tag {
        case LocalEnums.filters.rawValue:
            return self.sortFilterData.count
        case LocalEnums.order.rawValue:
            return self.sortOrderData.count
        default:
            return 0
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int { return 1 }
    
    // MARK: Miscellaneous
    override func setup() {
        super.setup()
        
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
        self.addAnimations(expandCollapseHeight: LocalConstants.AKViewHeight)
    }
    
    func loadComponents() {
        self.sortFilterData.removeAll()
        self.sortOrderData.removeAll()
        if let _ = self.controller as? AKListProjectsViewController {
            for filter in ProjectSorting.allCases {
                self.sortFilterData.append(filter.rawValue)
            }
            for order in SortingOrder.allCases {
                self.sortOrderData.append(order)
            }
        }
        else if let _ = self.controller as? AKViewProjectViewController {
            for filter in TaskSorting.allCases {
                self.sortFilterData.append(filter.rawValue)
            }
            for order in SortingOrder.allCases {
                self.sortOrderData.append(order)
            }
        }
    }
    
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
    
    func resetViewDefaults(controller: AKCustomViewController) {
        if let controller = self.controller as? AKListProjectsViewController {
            for (index, row) in controller.sortMenuItemOverlay.sortOrderData.enumerated() {
                if row.rawValue.caseInsensitiveCompare(Cons.AKDefaultProjectSortOrder.rawValue) == .orderedSame {
                    controller.sortMenuItemOverlay.order.selectRow(index, inComponent: 0, animated: true)
                }
            }
            for (index, row) in controller.sortMenuItemOverlay.sortFilterData.enumerated() {
                if row.caseInsensitiveCompare(Cons.AKDefaultProjectSortType.rawValue) == .orderedSame {
                    controller.sortMenuItemOverlay.filters.selectRow(index, inComponent: 0, animated: true)
                }
            }
        }
        else if let controller = self.controller as? AKViewProjectViewController {
            for (index, row) in controller.sortMenuItemOverlay.sortOrderData.enumerated() {
                if row.rawValue.caseInsensitiveCompare(Cons.AKDefaultTaskSortOrder.rawValue) == .orderedSame {
                    controller.sortMenuItemOverlay.order.selectRow(index, inComponent: 0, animated: true)
                }
            }
            for (index, row) in controller.sortMenuItemOverlay.sortFilterData.enumerated() {
                if row.caseInsensitiveCompare(Cons.AKDefaultTaskSortType.rawValue) == .orderedSame {
                    controller.sortMenuItemOverlay.filters.selectRow(index, inComponent: 0, animated: true)
                }
            }
        }
    }
}
