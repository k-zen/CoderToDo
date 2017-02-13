import UIKit

class AKNewProjectViewController: AKCustomViewController, UITextFieldDelegate
{
    // MARK: Local Enums
    enum LocalTextField: Int {
        case projectName = 1
    }
    
    // MARK: Outlets
    @IBOutlet weak var controlsContainer: UIView!
    @IBOutlet weak var projectNameValue: UITextField!
    @IBOutlet weak var save: UIButton!
    @IBOutlet weak var close: UIButton!
    
    // MARK: Actions
    @IBAction func save(_ sender: Any)
    {
        Func.AKDelay(0.0, isMain: false, task: { Void -> Void in
            let projectName = AKProjectName(inputData: self.projectNameValue.text!)
            do {
                try projectName.validate()
                try projectName.process()
            }
            catch {
                Func.AKPresentMessageFromError(message: "\(error)")
                return
            }
            
            if let mr = Func.AKObtainMasterReference() {
                let project = Project(context: mr.getMOC())
                project.name = projectName.outputData
                
                DataInterface.getUser()?.addToProject(project)
                self.dismissView(executeDismissTask: true)
            }
        })
    }
    
    @IBAction func close(_ sender: Any)
    {
        self.dismissView(executeDismissTask: true)
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
        case LocalTextField.projectName.rawValue:
            return newLen > GlobalConstants.AKMaxProjectNameLength ? false : true
        default:
            return newLen > GlobalConstants.AKMaxProjectNameLength ? false : true
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
        super.setup()
        
        // Set Delegator.
        self.projectNameValue.delegate = self
        self.projectNameValue.tag = LocalTextField.projectName.rawValue
        
        // Custom L&F.
        self.controlsContainer.backgroundColor = UIColor.clear
        self.projectNameValue.layer.cornerRadius = GlobalConstants.AKButtonCornerRadius
        self.save.layer.cornerRadius = GlobalConstants.AKButtonCornerRadius
        self.close.layer.cornerRadius = GlobalConstants.AKButtonCornerRadius
    }
}
