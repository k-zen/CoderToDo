import UIKit

class AKSelectCategoryView: AKCustomView, AKCustomViewProtocol, UIPickerViewDataSource, UIPickerViewDelegate
{
    // MARK: Constants
    private struct LocalConstants {
        static let AKViewWidth: CGFloat = 300.0
        static let AKViewHeight: CGFloat = 166.0
        static let AKExpandHeightAnimation = "expandHeight"
        static let AKCollapseHeightAnimation = "collapseHeight"
    }
    
    // MARK: Local Enums
    private enum LocalEnums: Int {
        case category = 1
    }
    
    // MARK: Properties
    private let expandHeight = CABasicAnimation(keyPath: LocalConstants.AKExpandHeightAnimation)
    private let collapseHeight = CABasicAnimation(keyPath: LocalConstants.AKCollapseHeightAnimation)
    private var categoryData = [String]()
    var defaultOperationsExpand: (AKCustomView) -> Void = { (view) -> Void in }
    var defaultOperationsCollapse: (AKCustomView) -> Void = { (view) -> Void in }
    var controller: AKCustomViewController?
    
    // MARK: Outlets
    @IBOutlet var mainContainer: UIView!
    @IBOutlet weak var categoryValue: UIPickerView!
    @IBOutlet weak var change: UIButton!
    
    // MARK: Actions
    @IBAction func change(_ sender: Any)
    {
        if let controller = controller as? AKViewTaskViewController {
            let selectedCategory = self.categoryData[self.categoryValue.selectedRow(inComponent: 0)]
            
            if let day = controller.task.category?.day {
                if let category = DataInterface.getCategoryByName(day: day, name: selectedCategory) {
                    category.addToTasks(controller.task)
                }
                else {
                    if let mr = Func.AKObtainMasterReference() {
                        let newCategory = Category(context: mr.getMOC())
                        newCategory.name = selectedCategory
                        newCategory.addToTasks(controller.task)
                        day.addToCategories(newCategory)
                    }
                }
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
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?
    {
        switch pickerView.tag {
        case LocalEnums.category.rawValue:
            return self.categoryData[row]
        default:
            return ""
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView
    {
        let pickerLabel = UILabel()
        pickerLabel.textColor = GlobalConstants.AKPickerViewFg
        
        switch pickerView.tag {
        case LocalEnums.category.rawValue:
            pickerLabel.text = self.categoryData[row]
            pickerLabel.backgroundColor = GlobalConstants.AKCoderToDoGray3
            break
        default:
            pickerLabel.text = ""
            pickerLabel.backgroundColor = GlobalConstants.AKCoderToDoGray3
            break
        }
        
        pickerLabel.font = UIFont(name: GlobalConstants.AKSecondaryFont, size: GlobalConstants.AKPickerFontSize)
        pickerLabel.textAlignment = NSTextAlignment.center
        
        return pickerLabel
    }
    
    // MARK: UIPickerViewDataSource Implementation
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
    {
        switch pickerView.tag {
        case LocalEnums.category.rawValue:
            return self.categoryData.count
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
        self.categoryValue.delegate = self
        self.categoryValue.dataSource = self
        self.categoryValue.tag = LocalEnums.category.rawValue
        
        self.getView().translatesAutoresizingMaskIntoConstraints = true
        self.getView().clipsToBounds = true
        
        self.loadComponents()
        self.applyLookAndFeel()
        self.addAnimations()
    }
    
    func loadComponents()
    {
        self.categoryData.removeAll()
        if let controller = controller as? AKViewTaskViewController {
            if let project = controller.task.category?.day?.project {
                for categoryName in DataInterface.listProjectCategories(project: project) {
                    self.categoryData.append(categoryName)
                }
            }
        }
        
        // Set default values.
        self.categoryValue.selectRow(0, inComponent: 0, animated: true)
    }
    
    func applyLookAndFeel()
    {
        self.getView().layer.cornerRadius = GlobalConstants.AKViewCornerRadius
        self.getView().layer.borderWidth = CGFloat(GlobalConstants.AKDefaultBorderThickness)
        self.getView().layer.borderColor = GlobalConstants.AKDefaultViewBorderBg.cgColor
        self.change.layer.cornerRadius = GlobalConstants.AKButtonCornerRadius
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
            x: Func.AKCenterScreenCoordinate(container, LocalConstants.AKViewWidth, LocalConstants.AKViewHeight).x,
            y: Func.AKCenterScreenCoordinate(container, LocalConstants.AKViewWidth, LocalConstants.AKViewHeight).y,
            width: LocalConstants.AKViewWidth,
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
