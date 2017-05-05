import UIKit

class AKProjectNameViewController: AKCustomViewController, UITextFieldDelegate {
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
    @IBAction func save(_ sender: Any) {
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
        
        // Re-schedule the notifications. PART 1
        if self.project.notifyClosingTime {
            // 1. Invalidate the current ones.
            Func.AKInvalidateLocalNotification(controller: self, project: self.project)
        }
        
        var project = AKProjectBuilder.from(project: self.project)
        project.name = projectName.outputData
        AKProjectBuilder.to(project: self.project, from: project)
        
        // Re-schedule the notifications. PART 2
        if self.project.notifyClosingTime {
            // 2. Re-schedule.
            Func.AKScheduleLocalNotification(
                controller: self,
                project: self.project,
                completionTask: { (presenterController) -> Void in
                    presenterController?.showMessage(
                        origin: CGPoint.zero,
                        type: .error,
                        message: "Ooops, there was a problem scheduling the notification.",
                        animate: true,
                        completionTask: nil
                    ) }
            )
        }
        
        self.navigationController?.popViewController(animated: true)
    }
    
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
        case LocalEnums.projectName.rawValue:
            return newLen > GlobalConstants.AKMaxProjectNameLength ? false : true
        default:
            return newLen > GlobalConstants.AKMaxProjectNameLength ? false : true
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
            if let controller = controller as? AKProjectNameViewController {
                controller.projectNameValue.text = controller.project.name
            }
        }
        self.configureLookAndFeel = { (controller) -> Void in
            if let controller = controller as? AKProjectNameViewController {
                Func.AKStyleTextField(textField: controller.projectNameValue)
                Func.AKStyleButton(button: controller.save)
            }
        }
        self.currentScrollContainer = self.scrollContainer
        self.setup()
        
        // Delegate & DataSource
        self.projectNameValue.delegate = self
        self.projectNameValue.tag = LocalEnums.projectName.rawValue
    }
}
