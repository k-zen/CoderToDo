import UIKit

class AKAddCategoryViewController: AKCustomViewController, UITextFieldDelegate {
    // MARK: Local Enums
    private enum LocalEnums: Int {
        case category = 1
    }
    
    // MARK: Properties
    var project: Project!
    
    // MARK: Outlets
    @IBOutlet weak var scrollContainer: UIScrollView!
    @IBOutlet weak var controlsContainer: UIView!
    @IBOutlet weak var projectName: UILabel!
    @IBOutlet weak var mainTitle: UILabel!
    @IBOutlet weak var categoryValue: UITextField!
    @IBOutlet weak var add: UIButton!
    @IBOutlet weak var close: UIButton!
    
    // MARK: Actions
    @IBAction func add(_ sender: Any) {
        do {
            let categoryName = AKCategoryName(inputData: self.categoryValue.text!)
            
            try categoryName.validate()
            try categoryName.process()
            
            try DataInterface.addProjectCategory(
                toProject: self.project,
                categoryName: categoryName.outputData
            )
            
            self.dismissView(executeDismissTask: true)
        }
        catch {
            Func.AKPresentMessageFromError(controller: self, message: "\(error)")
        }
    }
    
    @IBAction func close(_ sender: Any) { self.dismissView(executeDismissTask: true) }
    
    // MARK: AKCustomViewController Overriding
    override func viewDidLoad() {
        super.viewDidLoad()
        self.customSetup()
    }
    
    // MARK: UITextFieldDelegate Implementation
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if range.length + range.location > (textField.text?.characters.count)! {
            return false
        }
        
        let newLen = (textField.text?.characters.count)! + string.characters.count - range.length
        
        switch textField.tag {
        case LocalEnums.category.rawValue:
            return newLen > GlobalConstants.AKMaxCategoryNameLength ? false : true
        default:
            return newLen > GlobalConstants.AKMaxCategoryNameLength ? false : true
        }
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        Func.AKAddDoneButtonKeyboard(textField, controller: self)
        self.currentEditableComponent = textField
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        self.currentEditableComponent = nil
        return true
    }
    
    // MARK: Miscellaneous
    func customSetup() {
        self.loadData = { (controller) -> Void in
            if let controller = controller as? AKAddCategoryViewController {
                controller.projectName.text = controller.project.name
            }
        }
        self.configureLookAndFeel = { (controller) -> Void in
            if let controller = controller as? AKAddCategoryViewController {
                Func.AKAddBlurView(view: controller.controlsContainer, effect: .dark, addClearColorBgToView: true)
                controller.controlsContainer.layer.cornerRadius = GlobalConstants.AKViewCornerRadius
                controller.controlsContainer.layer.masksToBounds = true
                controller.controlsContainer.layer.borderColor = GlobalConstants.AKCoderToDoGray3.cgColor
                controller.controlsContainer.layer.borderWidth = 2.0
                
                Func.AKStyleTextField(textField: controller.categoryValue)
                
                Func.AKStyleButton(button: controller.add)
                Func.AKStyleButton(button: controller.close)
            }
        }
        self.currentScrollContainer = self.scrollContainer
        self.setup()
        
        // Delegate & DataSource
        self.categoryValue.delegate = self
        self.categoryValue.tag = LocalEnums.category.rawValue
    }
}
