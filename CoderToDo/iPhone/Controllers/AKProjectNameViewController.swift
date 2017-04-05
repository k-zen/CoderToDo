import UIKit

class AKProjectNameViewController: AKCustomViewController, UITextFieldDelegate
{
    // MARK: Local Enums
    private enum LocalEnums: Int {
        case projectName = 1
    }
    
    // MARK: Properties
    var project: Project!
    
    // MARK: Outlets
    @IBOutlet weak var scrollContainer: UIScrollView!
    @IBOutlet weak var controlsContainer: UIView!
    @IBOutlet weak var projectNameValue: UITextField!
    @IBOutlet weak var save: UIButton!
    
    // MARK: Actions
    @IBAction func save(_ sender: Any)
    {
        // Check name.
        let projectName = AKProjectName(inputData: self.projectNameValue.text!)
        do {
            try projectName.validate()
            try projectName.process()
        }
        catch {
            Func.AKPresentMessageFromError(controller: self, message: "\(error)")
            return
        }
        
        var project = AKProjectBuilder.from(project: self.project)
        project.name = projectName.outputData
        AKProjectBuilder.to(project: self.project, from: project)
        
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
        case LocalEnums.projectName.rawValue:
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
        self.loadData = { (controller) -> Void in
            if let controller = controller as? AKProjectNameViewController {
                controller.projectNameValue.text = controller.project.name
            }
        }
        self.configureLookAndFeel = { (controller) -> Void in
            if let controller = controller as? AKProjectNameViewController {
                controller.projectNameValue.layer.cornerRadius = GlobalConstants.AKButtonCornerRadius
                controller.save.layer.cornerRadius = GlobalConstants.AKButtonCornerRadius
            }
        }
        self.setup()
        
        // Delegate & DataSource
        self.projectNameValue.delegate = self
        self.projectNameValue.tag = LocalEnums.projectName.rawValue
    }
}
