import UIKit

class AKFilterView: AKCustomView, AKCustomViewProtocol, UIPickerViewDataSource, UIPickerViewDelegate {
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
    
    // MARK: Outlets
    @IBOutlet weak var mainContainer: UIView!
    @IBOutlet weak var type: UIPickerView!
    @IBOutlet weak var filters: UIPickerView!
    
    // MARK: UIView Overriding
    convenience init() { self.init(frame: CGRect.zero) }
    
    // MARK: UIPickerViewDelegate Implementation
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch pickerView.tag {
        case LocalEnums.filterType.rawValue:
            return self.filterTypeData[row]
        case LocalEnums.filterValue.rawValue:
            return self.filterValueData[row]
        default:
            return ""
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let pickerLabel = UILabel()
        pickerLabel.textColor = Cons.AKPickerViewFg
        
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
        pickerLabel.backgroundColor = Cons.AKPickerViewBg
        pickerLabel.font = UIFont(name: Cons.AKSecondaryFont, size: Cons.AKPickerFontSize)
        
        return pickerLabel
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if let controller = self.controller as? AKListProjectsViewController {
            let filterType = self.filterTypeData[self.type.selectedRow(inComponent: 0)]
            let filterValue = self.filterValueData[self.filters.selectedRow(inComponent: 0)]
            
            controller.projectFilter.projectFilter?.filterType = ProjectFilter(rawValue: filterType)!
            switch (controller.projectFilter.projectFilter?.filterType)! {
            case .status:
                controller.projectFilter.projectFilter?.filterValue = ProjectFilterStatus(rawValue: filterValue)!
                break
            }
            Func.AKReloadTable(tableView: controller.projectsTable)
        }
        else if let controller = self.controller as? AKViewProjectViewController {
            let filterType = self.filterTypeData[self.type.selectedRow(inComponent: 0)]
            let filterValue = self.filterValueData[self.filters.selectedRow(inComponent: 0)]
            
            controller.taskFilter.taskFilter?.filterType = TaskFilter(rawValue: filterType)!
            switch (controller.taskFilter.taskFilter?.filterType)! {
            case .state:
                controller.taskFilter.taskFilter?.filterValue = TaskFilterStates(rawValue: filterValue)!
                break
            }
            
            // Trigger caching recomputation, and reloading.
            controller.cachingSystem.triggerHeightRecomputation(controller: controller)
            controller.completeReload()
        }
    }
    
    // MARK: UIPickerViewDataSource Implementation
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
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
    override func setup() {
        super.setup()
        
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
    
    func loadComponents() {
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
            for (index, row) in controller.filterMenuItemOverlay.filterTypeData.enumerated() {
                if row.caseInsensitiveCompare(Cons.AKDefaultProjectFilterType.rawValue) == .orderedSame {
                    controller.filterMenuItemOverlay.type.selectRow(index, inComponent: 0, animated: true)
                }
            }
            for (index, row) in controller.filterMenuItemOverlay.filterValueData.enumerated() {
                if row.caseInsensitiveCompare(Cons.AKDefaultProjectFilterValue.rawValue) == .orderedSame {
                    controller.filterMenuItemOverlay.filters.selectRow(index, inComponent: 0, animated: true)
                }
            }
        }
        else if let controller = self.controller as? AKViewProjectViewController {
            for (index, row) in controller.filterMenuItemOverlay.filterTypeData.enumerated() {
                if row.caseInsensitiveCompare(Cons.AKDefaultTaskFilterType.rawValue) == .orderedSame {
                    controller.filterMenuItemOverlay.type.selectRow(index, inComponent: 0, animated: true)
                }
            }
            for (index, row) in controller.filterMenuItemOverlay.filterValueData.enumerated() {
                if row.caseInsensitiveCompare(Cons.AKDefaultTaskFilterValue.rawValue) == .orderedSame {
                    controller.filterMenuItemOverlay.filters.selectRow(index, inComponent: 0, animated: true)
                }
            }
        }
    }
}
