import UIKit

class AKViewTaskViewController: AKCustomViewController, UITextViewDelegate
{
    // MARK: Local Enums
    private enum LocalEnums: Int {
        case taskName = 1
        case notes = 2
    }
    
    // MARK: Properties
    var task: Task!
    var editMode: TaskMode = .editable
    
    // MARK: Outlets
    @IBOutlet weak var navController: UINavigationItem!
    @IBOutlet weak var scrollContainer: UIScrollView!
    @IBOutlet weak var controlContainer: UIView!
    @IBOutlet weak var taskDayValue: UILabel!
    @IBOutlet weak var taskState: UILabel!
    @IBOutlet weak var taskNameValue: UITextView!
    @IBOutlet weak var statusValue: UIButton!
    @IBOutlet weak var cpValue: UILabel!
    @IBOutlet weak var changeCP: UIStepper!
    @IBOutlet weak var categoryValue: UILabel!
    @IBOutlet weak var changeCategory: UIButton!
    @IBOutlet weak var notesValue: UITextView!
    @IBOutlet weak var dummyMarker: UILabel!
    
    // MARK: Actions
    @IBAction func changeStatus(_ sender: Any)
    {
        self.selectTaskStateOverlay.editMode = self.editMode
        
        var coordinates = self.view.convert(self.statusValue.frame, from: self.controlContainer)
        coordinates.origin.y += self.statusValue.frame.height
        self.showSelectTaskState(origin: coordinates.origin, animate: true, completionTask: nil)
    }
    
    @IBAction func changeCP(_ sender: Any) { self.cpValue.text = String(format: "%.1f%%", self.changeCP.value) }
    
    @IBAction func changeCategory(_ sender: Any) { self.showSelectCategory(origin: CGPoint.zero, animate: true, completionTask: nil) }
    
    // MARK: AKCustomViewController Overriding
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.customSetup()
    }
    
    // MARK: UITextViewDelegate Implementation
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool
    {
        if range.length + range.location > (textView.text?.characters.count)! {
            return false
        }
        
        let newLen = (textView.text?.characters.count)! + text.characters.count - range.length
        
        switch textView.tag {
        case LocalEnums.taskName.rawValue:
            return newLen > GlobalConstants.AKMaxTaskNameLength ? false : true
        case LocalEnums.notes.rawValue:
            return newLen > GlobalConstants.AKMaxTaskNoteLength ? false : true
        default:
            return newLen > GlobalConstants.AKMaxTaskNameLength ? false : true
        }
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool
    {
        Func.AKAddDoneButtonKeyboard(textView, controller: self)
        
        switch textView.tag {
        case LocalEnums.taskName.rawValue:
            return true
        case LocalEnums.notes.rawValue:
            var offset = textView.convert(textView.frame, to: self.scrollContainer).origin
            offset.x = 0
            
            var keyboardHeight = GlobalConstants.AKKeyboardHeight
            if textView.autocorrectionType == UITextAutocorrectionType.yes || textView.autocorrectionType == UITextAutocorrectionType.default {
                keyboardHeight += GlobalConstants.AKAutoCorrectionToolbarHeight
            }
            
            let height = Func.AKGetComponentAbsoluteHeightPosition(container: self.controlContainer, component: self.dummyMarker, isCentered: false)
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
        self.additionalOperationsWhenTaped = { (gesture) -> Void in self.hideSelectTaskState(animate: true, completionTask: nil); self.hideSelectCategory(animate: true, completionTask: nil) }
        self.loadData = { (controller) -> Void in
            if let controller = controller as? AKViewTaskViewController {
                // Load the task data.
                controller.taskDayValue.text = String(format: "Task set up for: %@", Func.AKGetFormattedDate(date: (controller.task.category?.day)!.date as Date?))
                // Task name.
                controller.taskNameValue.text = controller.task.name ?? "N\\A"
                // Task Status.
                controller.statusValue.setTitle(controller.task.state ?? TaskStates.pending.rawValue, for: .normal)
                Func.AKAddBorderDeco(
                    controller.statusValue,
                    color: Func.AKGetColorForTaskState(taskState: controller.task.state ?? "").cgColor,
                    thickness: GlobalConstants.AKDefaultBorderThickness,
                    position: .bottom
                )
                // Completion Percentage.
                controller.changeCP.value = Double(controller.task.completionPercentage)
                controller.cpValue.text = String(format: "%.1f%%", controller.task.completionPercentage)
                // Category
                controller.categoryValue.text = controller.task.category?.name ?? "N\\A"
                // Task note.
                controller.notesValue.text = controller.task.note ?? ""
                
                // By default mark the task as editable and then lower the flag.
                controller.markTask(mode: .editable)
                
                // Checks:
                var skipChecks = 0
                skipChecks += (DataInterface.getConfigurations()?.cleaningMode ?? false) ? 1 : 0
                
                if skipChecks == 0 {
                    let projectStatus = DataInterface.getProjectStatus(project: (controller.task.category?.day?.project)!)
                    if DataInterface.getDayStatus(day: (controller.task.category?.day)!) != DayStatus.current {
                        // Special case when we are allowed to change the status from DILATE to PENDING
                        // during the aceptance period for the next day ONLY!
                        if projectStatus == .accepting && DataInterface.isDayTomorrow(day: (controller.task.category?.day)!) {
                            NSLog("=> INFO: TASK CHECKS: DAY IS NOT CURRENT BUT PROJECT IS ACCEPTING AND IS TOMORROW.")
                            controller.markTask(mode: .limitedEditing)
                        }
                        else {
                            NSLog("=> INFO: TASK CHECKS: DAY IS NOT CURRENT AND PROJECT IS NOT ACCEPTING OR IS NOT TOMORROW.")
                            controller.markTask(mode: .notEditable)
                        }
                    }
                    else { // If the day is CURRENT but NOT open then always close.
                        if projectStatus != .open && projectStatus != .firstDay {
                            NSLog("=> INFO: TASK CHECKS: DAY IS CURRENT BUT PROJECT IS NOT OPEN.")
                            controller.markTask(mode: .notEditable)
                        }
                    }
                    
                    // Failsafe, tasks with these states will ALWAYS be marked as closed!
                    // + task marked as "DONE"
                    // + task marked as "NOT APPLICABLE".
                    switch controller.task.state! {
                    case TaskStates.done.rawValue, TaskStates.notApplicable.rawValue:
                        NSLog("=> INFO: TASK CHECKS: TASK MARKED AS DONE OR NOT APPLICABLE.")
                        controller.markTask(mode: .notEditable)
                        break
                    default:
                        // Ignore
                        break
                    }
                }
            }
        }
        self.saveData = { (controller) -> Void in
            if let controller = controller as? AKViewTaskViewController {
                do {
                    let taskName = AKTaskName(inputData: controller.taskNameValue.text!)
                    try taskName.validate()
                    try taskName.process()
                    controller.task.name = taskName.outputData
                }
                catch {
                    // Do nothing, just don't save the name.
                }
                // If the CP is 100.0% then mark the task as "DONE", only if not marked as "NOT APPLICABLE".
                if controller.changeCP.value >= 100.0 && controller.statusValue.titleLabel?.text != TaskStates.notApplicable.rawValue {
                    controller.task.state = TaskStates.done.rawValue
                }
                else {
                    controller.task.state = controller.statusValue.titleLabel?.text
                }
                // Task's Completion Percentage.
                controller.task.completionPercentage = Float(controller.changeCP.value)
                // Note.
                controller.task.note = controller.notesValue.text
                // Recompute the day's SR.
                _ = DataInterface.computeSRForDay(day: (controller.task.category?.day)!)
            }
        }
        self.configureLookAndFeel = { (controller) -> Void in
            if let controller = controller as? AKViewTaskViewController {
                controller.taskNameValue.layer.cornerRadius = GlobalConstants.AKButtonCornerRadius
                controller.taskNameValue.textContainerInset = UIEdgeInsets(top: 5.0, left: 5.0, bottom: 5.0, right: 5.0)
                controller.taskState.layer.cornerRadius = GlobalConstants.AKButtonCornerRadius
                controller.taskState.layer.masksToBounds = true
                controller.changeCategory.layer.cornerRadius = GlobalConstants.AKButtonCornerRadius
                controller.notesValue.layer.cornerRadius = GlobalConstants.AKButtonCornerRadius
                controller.notesValue.textContainerInset = UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0)
            }
        }
        self.setup()
        
        // Delegate & DataSource
        self.taskNameValue.delegate = self
        self.taskNameValue.tag = LocalEnums.taskName.rawValue
        self.notesValue.delegate = self
        self.notesValue.tag = LocalEnums.notes.rawValue
    }
    
    private func toggleEditMode(mode: TaskMode)
    {
        switch mode {
        case .editable:
            self.taskNameValue.isEditable = true
            self.statusValue.isEnabled = true
            self.changeCP.isEnabled = true
            self.changeCategory.isEnabled = true
            break
        case .notEditable:
            self.taskNameValue.isEditable = false
            self.statusValue.isEnabled = false
            self.changeCP.isEnabled = false
            self.changeCategory.isEnabled = false
            break
        case .limitedEditing:
            self.taskNameValue.isEditable = true
            self.statusValue.isEnabled = true
            self.changeCP.isEnabled = false
            self.changeCategory.isEnabled = true
            break
        }
    }
    
    func markTask(mode: TaskMode)
    {
        self.taskState.text = mode.rawValue
        switch mode {
        case .editable:
            self.taskState.backgroundColor = GlobalConstants.AKGreenForWhiteFg
            break
        case .notEditable:
            self.taskState.backgroundColor = GlobalConstants.AKRedForWhiteFg
            break
        case .limitedEditing:
            self.taskState.backgroundColor = GlobalConstants.AKBlueForWhiteFg
            break
        }
        
        self.editMode = mode
        self.toggleEditMode(mode: mode)
    }
}
