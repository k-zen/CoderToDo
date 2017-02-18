import UIKit

class AKUsernameInputViewController: AKCustomViewController, UITextFieldDelegate
{
    // MARK: Properties
    var presenterController: AKCustomViewController?
    
    // MARK: Local Enums
    enum LocalTextField: Int {
        case username = 1
    }
    
    // MARK: Outlets
    @IBOutlet weak var controlsContainer: UIView!
    @IBOutlet weak var mainTitle: UILabel!
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
            Func.AKPresentMessageFromError(message: "\(error)")
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
        case LocalTextField.username.rawValue:
            return newLen > GlobalConstants.AKMaxUsernameLength ? false : true
        default:
            return newLen > GlobalConstants.AKMaxUsernameLength ? false : true
        }
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool
    {
        Func.AKAddDoneButtonKeyboard(textField, controller: self)
        
        switch textField.tag {
        default:
            return true
        }
    }
    
    // MARK: Miscellaneous
    func customSetup()
    {
        super.shouldAddBlurView = true
        super.setup()
        
        // Set Delegator.
        self.usernameValue.delegate = self
        self.usernameValue.tag = LocalTextField.username.rawValue
        
        // Custom L&F.
        self.usernameValue.layer.cornerRadius = GlobalConstants.AKButtonCornerRadius
        self.done.layer.cornerRadius = GlobalConstants.AKButtonCornerRadius
    }
}
