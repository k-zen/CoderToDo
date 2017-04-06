import UIKit

class AKUsernameInputViewController: AKCustomViewController, UITextFieldDelegate
{
    // MARK: Local Enums
    private enum LocalEnums: Int {
        case username = 1
    }
    
    // MARK: Properties
    var presenterController: AKCustomViewController?
    
    // MARK: Outlets
    @IBOutlet weak var scrollContainer: UIScrollView!
    @IBOutlet weak var controlsContainer: UIView!
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var usernameValue: UITextField!
    @IBOutlet weak var done: UIButton!
    
    // MARK: Actions
    @IBAction func done(_ sender: Any)
    {
        let username = AKUsername(inputData: self.usernameValue.text!)
        do {
            try username.validate()
            try username.process()
        }
        catch {
            Func.AKPresentMessageFromError(controller: self, message: "\(error)")
            return
        }
        
        var newUser = AKUserInterface(username: username.outputData)
        newUser.gmtOffset = Int16(Func.AKGetOffsetFromGMT())
        do {
            try newUser.validate()
        }
        catch {
            Func.AKPresentMessageFromError(controller: self, message: "\(error)")
            return
        }
        
        AKUserBuilder.to(user: DataInterface.getUser()!, from: newUser)
        self.presenterController?.dismissView(executeDismissTask: true)
    }
    
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
        case LocalEnums.username.rawValue:
            return newLen > GlobalConstants.AKMaxUsernameLength ? false : true
        default:
            return newLen > GlobalConstants.AKMaxUsernameLength ? false : true
        }
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool
    {
        Func.AKAddDoneButtonKeyboard(textField, controller: self)
        
        switch textField.tag {
        case LocalEnums.username.rawValue:
            var offset = textField.convert(textField.frame, to: self.scrollContainer).origin
            offset.x = 0
            
            var keyboardHeight = GlobalConstants.AKKeyboardHeight
            if textField.autocorrectionType == UITextAutocorrectionType.no {
                keyboardHeight -= GlobalConstants.AKAutoCorrectionToolbarHeight
            }
            
            let height = Func.AKGetComponentAbsoluteHeightPosition(container: self.controlsContainer, component: self.done)
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
            if let controller = controller as? AKUsernameInputViewController {
                controller.icon.layer.cornerRadius = GlobalConstants.AKButtonCornerRadius * 2.0
                controller.icon.layer.masksToBounds = true
                controller.usernameValue.layer.cornerRadius = GlobalConstants.AKButtonCornerRadius
                controller.done.layer.cornerRadius = GlobalConstants.AKButtonCornerRadius
            }
        }
        self.setup()
        
        // Delegate & DataSource
        self.usernameValue.delegate = self
        self.usernameValue.tag = LocalEnums.username.rawValue
    }
}
