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
    @IBOutlet var migrate: UISwitch!
    @IBOutlet weak var add: UIButton!
    @IBOutlet weak var close: UIButton!
    
    // MARK: Actions
    @IBAction func add(_ sender: Any)
    {
        let selectedCategory = self.categoryData[self.categoryValue.selectedRow(inComponent: 0)]
        let taskName = AKTaskName(inputData: self.taskNameValue.text!)
        do {
            try taskName.validate()
            try taskName.process()
        }
        catch Exceptions.emptyData(let error) {
            if self.migrate.isOn {
                self.showContinueMessage(
                    message: "Would you like to \"only\" migrate tasks...?",
                    yesButtonTitle: "Yes",
                    noButtonTitle: "No",
                    yesAction: { (presenterController) -> Void in
                        if let presenterController = presenterController as? AKAddTaskViewController {
                            do {
                                if try DataInterface.migrateTasksFromQueues(toProject: presenterController.project) {
                                    presenterController.dismissView(executeDismissTask: true)
                                }
                                else {
                                    presenterController.showMessage(
                                        message: String(
                                            format: "%@, an error has occur while migrating the tasks.",
                                            DataInterface.getUsername()
                                        ),
                                        animate: true,
                                        completionTask: nil
                                    )
                                }
                            }
                            catch {
                                Func.AKPresentMessageFromError(controller: presenterController, message: "\(error)")
                                return
                            }
                        } },
                    noAction: { (presenterController) -> Void in
                        presenterController?.dismissView(executeDismissTask: true) },
                    animate: true,
                    completionTask: nil
                )
            }
            else {
                Func.AKPresentMessage(controller: self, message: "\(error)")
            }
            return
        }
        catch {
            Func.AKPresentMessageFromError(controller: self, message: "\(error)")
            return
        }
        
        if self.migrate.isOn {
            do {
                if try DataInterface.migrateTasksFromQueues(toProject: self.project) {
                    self.dismissView(executeDismissTask: true)
                }
                else {
                    self.showMessage(
                        message: String(
                            format: "%@, an error has occur while migrating the tasks.",
                            DataInterface.getUsername()
                        ),
                        animate: true,
                        completionTask: nil
                    )
                }
            }
            catch {
                Func.AKPresentMessageFromError(controller: self, message: "\(error)")
                return
            }
        }
        
        // Add the new task.
        do {
            if let mr = Func.AKObtainMasterReference() {
                let now = NSDate()
                let task = Task(context: mr.getMOC())
                task.creationDate = now
                task.name = taskName.outputData
                task.state = self.initialStateValue.titleForSegment(at: self.initialStateValue.selectedSegmentIndex)
                if try DataInterface.addTask(toProject: self.project, toCategoryNamed: selectedCategory, task: task) {
                    self.dismissView(executeDismissTask: true)
                }
                else {
                    self.showMessage(
                        message: String(
                            format: "%@, an error has occur while creating the new task.",
                            DataInterface.getUsername()
                        ),
                        animate: true,
                        completionTask: nil
                    )
                }
            }
        }
        catch {
            Func.AKPresentMessageFromError(controller: self, message: "\(error)")
            return
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
        
        if DataInterface.getProjectStatus(project: self.project) == .firstDay {
            self.showMessage(
                message: String(
                    format: "%@, since this is your first day, we've made an exception to our basic rule, and all tasks you add now up to closing time are going to be added for today.",
                    DataInterface.getUsername()
                ),
                animate: true,
                completionTask: nil
            )
        }
    }
    
    override func viewDidLayoutSubviews()
    {
        super.viewDidLayoutSubviews()
        
        // Custom L&F.
        self.taskNameValue.layer.cornerRadius = GlobalConstants.AKButtonCornerRadius
        self.categoryValue.layer.cornerRadius = GlobalConstants.AKButtonCornerRadius
        self.initialStateValue.subviews[1].tintColor = Func.AKGetColorForTaskState(taskState: TaskStates.pending.rawValue)
        self.initialStateValue.subviews[0].tintColor = Func.AKGetColorForTaskState(taskState: TaskStates.dilate.rawValue)
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
            if textField.autocorrectionType == UITextAutocorrectionType.no {
                keyboardHeight -= GlobalConstants.AKAutoCorrectionToolbarHeight
            }
            
            let height = Func.AKGetComponentAbsoluteHeightPosition(container: self.controlsContainer, component: self.categoryValue)
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
            break
        default:
            pickerLabel.text = ""
            break
        }
        
        pickerLabel.backgroundColor = GlobalConstants.AKDefaultBg
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
