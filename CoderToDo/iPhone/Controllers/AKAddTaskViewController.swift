import UIKit

class AKAddTaskViewController: AKCustomViewController, UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate
{
    // MARK: Local Enums
    enum LocalEnums: Int {
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
                    let now = NSDate()
                    let task = Task(context: mr.getMOC())
                    task.creationDate = now
                    task.name = taskName.outputData
                    task.state = TaskStates.PENDING.rawValue
                    
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
                else {
                    NSLog("=> ERROR: NO CURRENT DAY!")
                    // TODO: Add error handling here and dismiss view!
                    self.dismissView(executeDismissTask: true)
                }
            }
        }
        catch {
            Func.AKPresentMessageFromError(message: "\(error)")
        }
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
        self.loadLocalizedText()
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        
        // Set default values.
        self.categoryValue.selectRow(0, inComponent: 0, animated: true)
    }
    
    override func loadLocalizedText() {
        super.loadLocalizedText()
        
        // Load pickers.
        for categoryName in DataInterface.listCategoriesInProject(project: self.project) {
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
            if textField.spellCheckingType == UITextSpellCheckingType.yes || textField.spellCheckingType == UITextSpellCheckingType.default {
                keyboardHeight += GlobalConstants.AKSpellCheckerToolbarHeight
            }
            
            let height = Func.AKGetComponentAbsoluteHeightPosition(container: self.view, component: self.add)
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
        default:
            pickerLabel.text = ""
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
        
        // Set Delegator.
        self.taskNameValue.delegate = self
        self.taskNameValue.tag = LocalEnums.taskName.rawValue
        self.categoryValue.delegate = self
        self.categoryValue.dataSource = self
        self.categoryValue.tag = LocalEnums.category.rawValue
        
        // Custom L&F.
        self.taskNameValue.layer.cornerRadius = GlobalConstants.AKButtonCornerRadius
        self.categoryValue.layer.cornerRadius = GlobalConstants.AKButtonCornerRadius
        self.add.layer.cornerRadius = GlobalConstants.AKButtonCornerRadius
        self.close.layer.cornerRadius = GlobalConstants.AKButtonCornerRadius
    }
}
