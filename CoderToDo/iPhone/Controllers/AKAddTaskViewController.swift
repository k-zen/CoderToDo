import UIKit

class AKAddTaskViewController: AKCustomViewController, UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate
{
    // MARK: Local Enums
    private enum LocalEnums: Int {
        case taskName = 1
        case category = 2
    }
    
    // MARK: Properties
    var categoryData = [String]()
    var project: Project!
    
    // MARK: Outlets
    @IBOutlet weak var scrollContainer: UIScrollView!
    @IBOutlet weak var controlsContainer: UIView!
    @IBOutlet weak var mainTitle: UILabel!
    @IBOutlet weak var taskNameValue: UITextField!
    @IBOutlet weak var categoryValue: UIPickerView!
    @IBOutlet weak var initialStateValue: UISegmentedControl!
    @IBOutlet weak var add: UIButton!
    @IBOutlet weak var close: UIButton!
    
    // MARK: Actions
    @IBAction func add(_ sender: Any)
    {
        do {
            let selectedCategory = self.categoryData[self.categoryValue.selectedRow(inComponent: 0)]
            let taskName = AKTaskName(inputData: self.taskNameValue.text!)
            
            try taskName.validate()
            try taskName.process()
            
            if let mr = Func.AKObtainMasterReference() {
                // Allways add today to the table if not present, if present return the last day.
                if let currentDay = DataInterface.addNewWorkingDay(project: self.project) {
                    let migratedPendingDay = (self.project.pendingQueue?.tasks?.allObjects.first as? Task)?.category?.day
                    let migratedDilateDay = (self.project.dilateQueue?.tasks?.allObjects.first as? Task)?.category?.day
                    
                    // Add task from PendingQueue.
                    if let tasks = self.project.pendingQueue?.tasks?.allObjects as? [Task] {
                        for task in tasks {
                            if let categoryName = task.category?.name {
                                // Here is the problem where tasks in queues where not added to the next day. If the next day
                                // doesn't have the category for which the task belongs, then it will return NIL and never execute
                                // this block of code.
                                // SOLUTION: If the new day doesn't have the category, then create a new one with the same name.
                                if let category = DataInterface.getCategoryByName(day: currentDay, name: categoryName) {
                                    category.addToTasks(task)
                                    currentDay.addToCategories(category)
                                    
                                    // Remove from queue.
                                    self.project.pendingQueue?.removeFromTasks(task)
                                    
                                    task.creationDate = currentDay.date
                                    task.initialCompletionPercentage = task.completionPercentage
                                }
                                else {
                                    let newCategory = Category(context: mr.getMOC())
                                    newCategory.name = categoryName
                                    newCategory.addToTasks(task)
                                    currentDay.addToCategories(newCategory)
                                    
                                    // Remove from queue.
                                    self.project.pendingQueue?.removeFromTasks(task)
                                    
                                    task.creationDate = currentDay.date
                                    task.initialCompletionPercentage = task.completionPercentage
                                }
                            }
                        }
                    }
                    
                    // Add task from DilateQueue.
                    if let tasks = self.project.dilateQueue?.tasks?.allObjects as? [Task] {
                        for task in tasks {
                            if let categoryName = task.category?.name {
                                // Here is the problem where tasks in queues where not added to the next day. If the next day
                                // doesn't have the category for which the task belongs, then it will return NIL and never execute
                                // this block of code.
                                // SOLUTION: If the new day doesn't have the category, then create a new one with the same name.
                                if let category = DataInterface.getCategoryByName(day: currentDay, name: categoryName) {
                                    category.addToTasks(task)
                                    currentDay.addToCategories(category)
                                    
                                    // Remove from queue.
                                    self.project.dilateQueue?.removeFromTasks(task)
                                    
                                    task.creationDate = currentDay.date
                                    task.initialCompletionPercentage = task.completionPercentage
                                }
                                else {
                                    let newCategory = Category(context: mr.getMOC())
                                    newCategory.name = categoryName
                                    newCategory.addToTasks(task)
                                    currentDay.addToCategories(newCategory)
                                    
                                    // Remove from queue.
                                    self.project.dilateQueue?.removeFromTasks(task)
                                    
                                    task.creationDate = currentDay.date
                                    task.initialCompletionPercentage = task.completionPercentage
                                }
                            }
                        }
                    }
                    
                    // To avoid having an empty day, because all tasks from one day have been moved, then check the day
                    // from which the pending or dilate tasks come from and if they are empty remove those days from the
                    // project.
                    if let day1 = migratedPendingDay, let day2 = migratedDilateDay {
                        // Count the task in both days.
                        let leftTasks = DataInterface.countAllTasksInDay(day: day1) + DataInterface.countAllTasksInDay(day: day2)
                        if leftTasks == 0 {
                            self.project.removeFromDays(day1)
                            self.project.removeFromDays(day2)
                        }
                    }
                    
                    // Add the new task.
                    let now = NSDate()
                    let task = Task(context: mr.getMOC())
                    task.creationDate = now
                    task.name = taskName.outputData
                    task.state = self.initialStateValue.titleForSegment(at: self.initialStateValue.selectedSegmentIndex)
                    
                    if let category = DataInterface.getCategoryByName(day: currentDay, name: selectedCategory) {
                        category.addToTasks(task)
                        currentDay.addToCategories(category)
                    }
                    else {
                        let newCategory = Category(context: mr.getMOC())
                        newCategory.name = selectedCategory
                        newCategory.addToTasks(task)
                        currentDay.addToCategories(newCategory)
                    }
                    
                    if DataInterface.updateDay(project: self.project, updatedDay: currentDay) {
                        self.dismissView(executeDismissTask: true)
                    }
                }
            }
        }
        catch {
            Func.AKPresentMessageFromError(controller: self, message: "\(error)")
        }
    }
    
    @IBAction func close(_ sender: Any) { self.dismissView(executeDismissTask: true) }
    
    // MARK: AKCustomViewController Overriding
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.customSetup()
        self.loadLocalizedText()
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        
        // Set default values.
        self.categoryValue.selectRow(0, inComponent: 0, animated: true)
        
        if DataInterface.getProjectStatus(project: self.project) == ProjectStatus.FIRST_DAY {
            self.showMessage(
                message: String(
                    format: "%@, since this is your first day, we've made an exception to our basic rule, and all tasks you add now up to closing time are going to be added for today.",
                    DataInterface.getUsername()
                )
            )
        }
    }
    
    override func viewDidLayoutSubviews()
    {
        super.viewDidLayoutSubviews()
        
        // Custom L&F.
        self.taskNameValue.layer.cornerRadius = GlobalConstants.AKButtonCornerRadius
        self.categoryValue.layer.cornerRadius = GlobalConstants.AKButtonCornerRadius
        self.initialStateValue.subviews[1].tintColor = Func.AKGetColorForTaskState(taskState: TaskStates.PENDING.rawValue)
        self.initialStateValue.subviews[0].tintColor = Func.AKGetColorForTaskState(taskState: TaskStates.DILATE.rawValue)
        self.add.layer.cornerRadius = GlobalConstants.AKButtonCornerRadius
        self.close.layer.cornerRadius = GlobalConstants.AKButtonCornerRadius
    }
    
    override func loadLocalizedText() {
        super.loadLocalizedText()
        
        // Load pickers.
        for categoryName in DataInterface.listProjectCategories(project: self.project) {
            self.categoryData.append(categoryName)
        }
    }
    
    // MARK: UITextFieldDelegate Implementation
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    {
        if range.length + range.location > (textField.text?.characters.count)! {
            return false
        }
        
        let newLen = (textField.text?.characters.count)! + string.characters.count - range.length
        
        switch textField.tag {
        case LocalEnums.taskName.rawValue:
            return newLen > GlobalConstants.AKMaxTaskNameLength ? false : true
        default:
            return newLen > GlobalConstants.AKMaxTaskNameLength ? false : true
        }
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool
    {
        Func.AKAddDoneButtonKeyboard(textField, controller: self)
        
        switch textField.tag {
        case LocalEnums.taskName.rawValue:
            var offset = textField.convert(textField.frame, to: self.scrollContainer).origin
            offset.x = 0
            
            var keyboardHeight = GlobalConstants.AKKeyboardHeight
            if textField.autocorrectionType == UITextAutocorrectionType.yes || textField.autocorrectionType == UITextAutocorrectionType.default {
                keyboardHeight += GlobalConstants.AKAutoCorrectionToolbarHeight
            }
            
            let height = Func.AKGetComponentAbsoluteHeightPosition(container: self.controlsContainer, component: self.add)
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
    
    // MARK: UIPickerViewDelegate Implementation
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?
    {
        switch pickerView.tag {
        case LocalEnums.category.rawValue:
            return self.categoryData[row]
        default:
            return ""
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView
    {
        let pickerLabel = UILabel()
        pickerLabel.textColor = GlobalConstants.AKPickerViewFg
        
        switch pickerView.tag {
        case LocalEnums.category.rawValue:
            pickerLabel.text = self.categoryData[row]
            pickerLabel.backgroundColor = GlobalConstants.AKCoderToDoGray3
            break
        default:
            pickerLabel.text = ""
            break
        }
        
        pickerLabel.font = UIFont(name: GlobalConstants.AKSecondaryFont, size: GlobalConstants.AKPickerFontSize)
        pickerLabel.textAlignment = NSTextAlignment.center
        
        return pickerLabel
    }
    
    // MARK: UIPickerViewDataSource Implementation
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
    {
        switch pickerView.tag {
        case LocalEnums.category.rawValue:
            return self.categoryData.count
        default:
            return 0
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int { return 1 }
    
    // MARK: Miscellaneous
    func customSetup()
    {
        super.setup()
        
        // Delegate & DataSource
        self.taskNameValue.delegate = self
        self.taskNameValue.tag = LocalEnums.taskName.rawValue
        self.categoryValue.delegate = self
        self.categoryValue.dataSource = self
        self.categoryValue.tag = LocalEnums.category.rawValue
    }
}
