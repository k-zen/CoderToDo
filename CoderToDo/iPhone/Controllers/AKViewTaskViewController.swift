import UIKit

class AKViewTaskViewController: AKCustomViewController, UITextViewDelegate
{
    // MARK: Local Enums
    enum LocalEnums: Int {
        case notes = 1
    }
    
    // MARK: Properties
    var task: Task!
    
    // MARK: Outlets
    @IBOutlet weak var navController: UINavigationItem!
    @IBOutlet weak var controlContainer: UIView!
    @IBOutlet weak var taskNameValue: UILabel!
    @IBOutlet weak var statusValue: UIButton!
    @IBOutlet weak var cpValue: UILabel!
    @IBOutlet weak var changeCP: UIStepper!
    @IBOutlet weak var notesValue: UITextView!
    @IBOutlet weak var stat1Value: UILabel!
    @IBOutlet weak var stat2Value: UILabel!
    
    // MARK: Actions
    @IBAction func changeStatus(_ sender: Any) {}
    
    @IBAction func changeCP(_ sender: Any)
    {
        self.cpValue.text = String(format: "%.1f%%", self.changeCP.value)
    }
    
    // MARK: AKCustomViewController Overriding
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.customSetup()
        
        // Load the task data.
        // Task name.
        self.taskNameValue.text = self.task.name ?? "N\\A"
        // Task Status.
        self.statusValue.setTitle(self.task.state ?? TaskStates.PENDING.rawValue, for: .normal)
        Func.AKAddBorderDeco(
            self.statusValue,
            color: Func.AKGetColorForTaskState(taskState: self.task.state ?? "").cgColor,
            thickness: GlobalConstants.AKDefaultBorderThickness,
            position: .bottom
        )
        // Task note.
        self.notesValue.text = self.task.note ?? ""
        // Completion Percentage.
        self.changeCP.value = Double(self.task.completionPercentage)
        self.cpValue.text = String(format: "%.1f%%", self.task.completionPercentage)
        
        // Enable editing only if day is open.
        if !DataInterface.isProjectOpen(project: (self.task.category?.day?.project)!) {
            // TODO: Show message to user and disable.
            // Disable:
            // 1. State Change
            // 2. Completion Percentage
            // 3. Notes
            self.statusValue.isEnabled = false
            self.changeCP.isEnabled = false
            self.notesValue.isEditable = false
        }
        else {
            self.statusValue.isEnabled = true
            self.changeCP.isEnabled = true
            self.notesValue.isEditable = true
        }
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillDisappear(animated)
        
        // Save the modifications.
        // If the CP is 100.0% then mark the task as completed no matter what.
        self.task.state = self.changeCP.value >= 100.0 ? TaskStates.DONE.rawValue : self.statusValue.titleLabel?.text
        self.task.completionPercentage = Float(self.changeCP.value)
        self.task.note = self.notesValue.text
    }
    
    // MARK: UITextViewDelegate Implementation
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool
    {
        if range.length + range.location > (textView.text?.characters.count)! {
            return false
        }
        
        let newLen = (textView.text?.characters.count)! + text.characters.count - range.length
        
        switch textView.tag {
        case LocalEnums.notes.rawValue:
            return newLen > GlobalConstants.AKMaxTaskNoteLength ? false : true
        default:
            return newLen > GlobalConstants.AKMaxTaskNoteLength ? false : true
        }
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool
    {
        Func.AKAddDoneButtonKeyboard(textView, controller: self)
        
        switch textView.tag {
        default:
            return true
        }
    }
    
    // MARK: Miscellaneous
    func customSetup()
    {
        super.setup()
        
        // Set Delegator.
        self.notesValue.delegate = self
        self.notesValue.tag = LocalEnums.notes.rawValue
        
        // Custom L&F.
        // self.notesValue.layer.cornerRadius = GlobalConstants.AKButtonCornerRadius
        self.notesValue.textContainerInset = UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0)
        Func.AKAddBorderDeco(
            self.notesValue,
            color: GlobalConstants.AKCoderToDoWhite2.cgColor,
            thickness: GlobalConstants.AKDefaultBorderThickness * 2.0,
            position: .left
        )
    }
}
