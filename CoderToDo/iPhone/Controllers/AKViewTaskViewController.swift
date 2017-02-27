import UIKit

class AKViewTaskViewController: AKCustomViewController, UITextViewDelegate
{
    // MARK: Local Enums
    enum LocalEnums: Int {
        case notes = 1
    }
    
    // MARK: Properties
    // Overlay Controllers
    let selectTaskStateOverlayController = AKSelectTaskStateView()
    var selectTaskStateOverlayView: UIView!
    var task: Task!
    
    // MARK: Outlets
    @IBOutlet weak var navController: UINavigationItem!
    @IBOutlet weak var scrollContainer: UIScrollView!
    @IBOutlet weak var controlContainer: UIView!
    @IBOutlet weak var taskState: UILabel!
    @IBOutlet weak var taskNameValue: UILabel!
    @IBOutlet weak var statusValue: UIButton!
    @IBOutlet weak var cpValue: UILabel!
    @IBOutlet weak var changeCP: UIStepper!
    @IBOutlet weak var notesValue: UITextView!
    
    // MARK: Actions
    @IBAction func changeStatus(_ sender: Any)
    {
        UIView.beginAnimations(AKSelectTaskStateView.LocalConstants.AKExpandHeightAnimation, context: nil)
        let coordinates = self.view.convert(self.statusValue.frame, from: self.controlContainer)
        self.selectTaskStateOverlayView.frame = CGRect(
            x: coordinates.origin.x,
            y: coordinates.origin.y + self.statusValue.bounds.height,
            width: self.selectTaskStateOverlayView.bounds.width,
            height: AKSelectTaskStateView.LocalConstants.AKViewHeight
        )
        UIView.commitAnimations()
    }
    
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
    }
    
    override func viewDidLayoutSubviews()
    {
        super.viewDidLayoutSubviews()
        
        // Setup the overlays.
        let coordinates = self.view.convert(self.statusValue.frame, from: self.controlContainer)
        self.selectTaskStateOverlayView = self.selectTaskStateOverlayController.customView
        self.selectTaskStateOverlayController.controller = self
        self.selectTaskStateOverlayView.frame = CGRect(
            x: coordinates.origin.x,
            y: coordinates.origin.y + self.statusValue.bounds.height,
            width: self.selectTaskStateOverlayView.bounds.width,
            height: 0
        )
        self.selectTaskStateOverlayView.translatesAutoresizingMaskIntoConstraints = true
        self.selectTaskStateOverlayView.clipsToBounds = true
        self.view.addSubview(self.selectTaskStateOverlayView)
        
        // Custom L&F.
        self.taskState.layer.cornerRadius = GlobalConstants.AKButtonCornerRadius
        self.taskState.layer.masksToBounds = true
        self.notesValue.textContainerInset = UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0)
        Func.AKAddBorderDeco(
            self.notesValue,
            color: GlobalConstants.AKCoderToDoWhite2.cgColor,
            thickness: GlobalConstants.AKDefaultBorderThickness * 2.0,
            position: .left
        )
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        // Checks:
        // Close Task if:
        //  day is not current.
        if DataInterface.getDayStatus(day: (self.task.category?.day)!) != DayStatus.current {
            self.markTask(mode: TaskMode.NOT_EDITABLE)
        }
        //  project not open.
        if !DataInterface.isProjectOpen(project: (self.task.category?.day?.project)!) {
            self.markTask(mode: TaskMode.NOT_EDITABLE)
        }
        //  task marked as "DONE".
        if self.task.state == TaskStates.DONE.rawValue {
            self.markTask(mode: TaskMode.NOT_EDITABLE)
        }
        //  task marked as "NOT APPLICABLE".
        if self.task.state == TaskStates.NOT_APPLICABLE.rawValue {
            self.markTask(mode: TaskMode.NOT_EDITABLE)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillDisappear(animated)
        
        // Save the modifications.
        // If the CP is 100.0% then mark the task as "DONE", only if not marked as "NOT APPLICABLE".
        if self.changeCP.value >= 100.0 && self.statusValue.titleLabel?.text != TaskStates.NOT_APPLICABLE.rawValue {
            self.task.state = TaskStates.DONE.rawValue
        }
        else {
            self.task.state = self.statusValue.titleLabel?.text
        }
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
        case LocalEnums.notes.rawValue:
            var offset = textView.convert(textView.frame, to: self.scrollContainer).origin
            offset.x = 0
            
            var keyboardHeight = GlobalConstants.AKKeyboardHeight
            if textView.spellCheckingType == UITextSpellCheckingType.yes || textView.spellCheckingType == UITextSpellCheckingType.default {
                keyboardHeight += GlobalConstants.AKSpellCheckerToolbarHeight
            }
            
            let height = Func.AKGetComponentAbsoluteHeightPosition(container: self.controlContainer, component: self.notesValue)
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
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool
    {
        switch textView.tag {
        default:
            var offset = textView.convert(textView.frame, to: self.scrollContainer).origin
            offset.x = 0
            offset.y = 0
            
            self.scrollContainer.setContentOffset(offset, animated: true)
            
            return true
        }
    }
    
    // MARK: Miscellaneous
    func customSetup()
    {
        super.additionalOperationsWhenTaped = { (gesture) -> Void in
            UIView.beginAnimations(AKSelectTaskStateView.LocalConstants.AKCollapseHeightAnimation, context: nil)
            let coordinates = self.view.convert(self.statusValue.frame, from: self.controlContainer)
            self.selectTaskStateOverlayView.frame = CGRect(
                x: coordinates.origin.x,
                y: coordinates.origin.y + self.statusValue.bounds.height,
                width: self.selectTaskStateOverlayView.bounds.width,
                height: 0.0
            )
            UIView.commitAnimations()
        }
        super.setup()
        
        // Set Delegator.
        self.notesValue.delegate = self
        self.notesValue.tag = LocalEnums.notes.rawValue
    }
    
    func toggleEditMode(mode: TaskMode)
    {
        switch mode {
        case TaskMode.EDITABLE:
            self.statusValue.isEnabled = true
            self.changeCP.isEnabled = true
            break
        case TaskMode.NOT_EDITABLE:
            self.statusValue.isEnabled = false
            self.changeCP.isEnabled = false
            break
        }
    }
    
    func markTask(mode: TaskMode)
    {
        self.taskState.text = mode.rawValue
        self.taskState.backgroundColor = GlobalConstants.AKRedForWhiteFg
        self.toggleEditMode(mode: mode)
    }
}
