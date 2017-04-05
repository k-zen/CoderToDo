import UIKit

class AKAddCategoryViewController: AKCustomViewController, UITextFieldDelegate
{
    // MARK: Local Enums
    private enum LocalEnums: Int {
        case category = 1
    }
    
    // MARK: Properties
    var project: Project!
    
    // MARK: Outlets
    @IBOutlet weak var scrollContainer: UIScrollView!
    @IBOutlet weak var controlsContainer: UIView!
    @IBOutlet weak var mainTitle: UILabel!
    @IBOutlet weak var categoryValue: UITextField!
    @IBOutlet weak var add: UIButton!
    @IBOutlet weak var close: UIButton!
    
    // MARK: Actions
    @IBAction func add(_ sender: Any)
    {
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
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.customSetup()
    }
    
    // MARK: UITextFieldDelegate Implementation
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    {
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
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool
    {
        Func.AKAddDoneButtonKeyboard(textField, controller: self)
        
        switch textField.tag {
        case LocalEnums.category.rawValue:
            var offset = textField.convert(textField.frame, to: self.scrollContainer).origin
            offset.x = 0
            
            var keyboardHeight = GlobalConstants.AKKeyboardHeight
            if textField.autocorrectionType == UITextAutocorrectionType.no {
                keyboardHeight -= GlobalConstants.AKAutoCorrectionToolbarHeight
            }
            
            let height = Func.AKGetComponentAbsoluteHeightPosition(container: self.controlsContainer, component: self.add)
            if keyboardHeight > height {
                offset.y = abs(keyboardHeight - height)
            }
            else {
                offset.y = 0
            }
            
            self.scrollContainer.setContentOffset(offset, animated: true)
            
            return true
        default:
            return true
        }
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool
    {
        switch textField.tag {
        default:
            var offset = textField.convert(textField.frame, to: self.scrollContainer).origin
            offset.x = 0
            offset.y = 0
            
            self.scrollContainer.setContentOffset(offset, animated: true)
            
            return true
        }
    }
    
    // MARK: Miscellaneous
    func customSetup()
    {
        self.configureLookAndFeel = { (controller) -> Void in
            if let controller = controller as? AKAddCategoryViewController {
                controller.categoryValue.layer.cornerRadius = GlobalConstants.AKButtonCornerRadius
                controller.add.layer.cornerRadius = GlobalConstants.AKButtonCornerRadius
                controller.close.layer.cornerRadius = GlobalConstants.AKButtonCornerRadius
            }
        }
        self.setup()
        
        // Delegate & DataSource
        self.categoryValue.delegate = self
        self.categoryValue.tag = LocalEnums.category.rawValue
    }
}
