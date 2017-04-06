import UIKit

class AKUserConfigurationViewController: AKCustomViewController, UITextFieldDelegate
{
    // MARK: Local Enums
    private enum LocalEnums: Int {
        case username = 1
    }
    
    // MARK: Outlets
    @IBOutlet weak var scrollContainer: UIScrollView!
    @IBOutlet weak var controlsContainer: UIView!
    @IBOutlet weak var usernameValue: UITextField!
    @IBOutlet weak var save: UIButton!
    
    // MARK: Actions
    @IBAction func save(_ sender: Any)
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
        self.navigationController?.popViewController(animated: true)
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
        default:
            return true
        }
    }
    
    // MARK: Miscellaneous
    func customSetup()
    {
        self.loadData = { (controller) -> Void in
            if let controller = controller as? AKUserConfigurationViewController {
                controller.usernameValue.text = DataInterface.getUsername()
            }
        }
        self.configureLookAndFeel = { (controller) -> Void in
            if let controller = controller as? AKUserConfigurationViewController {
                controller.usernameValue.layer.cornerRadius = GlobalConstants.AKButtonCornerRadius
                controller.save.layer.cornerRadius = GlobalConstants.AKButtonCornerRadius
            }
        }
        self.setup()
        
        // Delegate & DataSource
        self.usernameValue.delegate = self
        self.usernameValue.tag = LocalEnums.username.rawValue
    }
}
