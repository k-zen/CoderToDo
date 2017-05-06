import UIKit

class AKSelectCategoryView: AKCustomView, AKCustomViewProtocol, UIPickerViewDataSource, UIPickerViewDelegate {
    // MARK: Constants
    struct LocalConstants {
        static let AKViewWidth: CGFloat = 300.0
        static let AKViewHeight: CGFloat = 166.0
    }
    
    // MARK: Local Enums
    private enum LocalEnums: Int {
        case category = 1
    }
    
    // MARK: Properties
    private var categoryData = [String]()
    
    // MARK: Outlets
    @IBOutlet var mainContainer: UIView!
    @IBOutlet weak var categoryValue: UIPickerView!
    @IBOutlet weak var change: UIButton!
    
    // MARK: Actions
    @IBAction func change(_ sender: Any) {
        if let controller = controller as? AKViewTaskViewController {
            let selectedCategory = self.categoryData[self.categoryValue.selectedRow(inComponent: 0)]
            
            if DataInterface.migrateTaskToCategory(toCategoryNamed: selectedCategory, task: controller.task) {
                controller.dismissView(executeDismissTask: true)
            }
            else {
                // TODO: Do something.
            }
            
            // Collapse this view.
            controller.tap(nil)
            // Reload the view.
            controller.categoryValue.text = selectedCategory
        }
    }
    
    // MARK: UIView Overriding
    convenience init() { self.init(frame: CGRect.zero) }
    
    // MARK: UIPickerViewDelegate Implementation
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch pickerView.tag {
        case LocalEnums.category.rawValue:
            return self.categoryData[row]
        default:
            return ""
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let pickerLabel = UILabel()
        pickerLabel.textColor = Cons.AKPickerViewFg
        
        switch pickerView.tag {
        case LocalEnums.category.rawValue:
            pickerLabel.text = self.categoryData[row]
            break
        default:
            pickerLabel.text = ""
            break
        }
        
        pickerLabel.backgroundColor = Cons.AKPickerViewBg
        pickerLabel.font = UIFont(name: Cons.AKSecondaryFont, size: Cons.AKPickerFontSize)
        pickerLabel.textAlignment = NSTextAlignment.center
        
        return pickerLabel
    }
    
    // MARK: UIPickerViewDataSource Implementation
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView.tag {
        case LocalEnums.category.rawValue:
            return self.categoryData.count
        default:
            return 0
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int { return 1 }
    
    // MARK: Miscellaneous
    override func setup() {
        super.shouldAddBlurView = true
        super.setup()
        
        // Delegate & DataSource
        self.categoryValue.delegate = self
        self.categoryValue.dataSource = self
        self.categoryValue.tag = LocalEnums.category.rawValue
        
        self.getView().translatesAutoresizingMaskIntoConstraints = true
        self.getView().clipsToBounds = true
        
        self.loadComponents()
        self.applyLookAndFeel()
        self.addAnimations(expandCollapseHeight: LocalConstants.AKViewHeight)
    }
    
    func loadComponents() {
        self.categoryData.removeAll()
        if let controller = self.controller as? AKViewTaskViewController {
            if let project = controller.task.category?.day?.project {
                for categoryName in DataInterface.listProjectCategories(project: project) {
                    self.categoryData.append(categoryName)
                }
            }
        }
        
        // Set default values.
        self.categoryValue.selectRow(0, inComponent: 0, animated: true)
    }
    
    func applyLookAndFeel() {
        self.getView().layer.cornerRadius = Cons.AKViewCornerRadius
        self.getView().layer.masksToBounds = true
        self.getView().layer.borderColor = Cons.AKCoderToDoGray3.cgColor
        self.getView().layer.borderWidth = 2.0
        self.mainContainer.backgroundColor = UIColor.clear
        
        Func.AKStylePicker(picker: self.categoryValue)
        
        Func.AKStyleButton(button: self.change)
    }
    
    func draw(container: UIView, coordinates: CGPoint, size: CGSize) {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        self.getView().frame = CGRect(
            x: coordinates.x,
            y: coordinates.y,
            width: LocalConstants.AKViewWidth,
            height: size.height
        )
        container.addSubview(self.getView())
        CATransaction.commit()
    }
    
    func resetViewDefaults(controller: AKCustomViewController) {}
}
