import UIKit

class AKUsernameInputViewController: AKCustomViewController, UITextFieldDelegate
{
    // MARK: Properties
    var presenterController: AKCustomViewController?
    
    // MARK: Local Enums
    enum LocalEnums: Int {
        case username = 1
    }
    
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
        
        DataInterface.getUser()?.username = username.outputData
        presenterController?.dismissView(executeDismissTask: true)
    }
    
    // MARK: AKCustomViewController Overriding
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.customSetup()
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
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
            if textField.spellCheckingType == UITextSpellCheckingType.yes || textField.spellCheckingType == UITextSpellCheckingType.default {
                keyboardHeight += GlobalConstants.AKSpellCheckerToolbarHeight
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
        super.setup()
        
        // Set Delegator.
        self.usernameValue.delegate = self
        self.usernameValue.tag = LocalEnums.username.rawValue
        
        // Custom L&F.
        self.icon.layer.cornerRadius = GlobalConstants.AKButtonCornerRadius * 2.0
        self.icon.layer.masksToBounds = true
        self.usernameValue.layer.cornerRadius = GlobalConstants.AKButtonCornerRadius
        self.done.layer.cornerRadius = GlobalConstants.AKButtonCornerRadius
    }
}
