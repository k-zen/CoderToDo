import UIKit

class AKNewProjectViewController: AKCustomViewController, UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate
{
    // MARK: Local Enums
    enum LocalEnums: Int {
        case projectName = 1
        case tolerance = 2
        case maxCategories = 3
        case maxTasks = 4
        case startingTime = 5
        case closingTime = 6
    }
    
    // MARK: Properties
    var toleranceData: [Int] = []
    var limitsData: [Int] = []
    var workingDayTimeData: [String] = []
    
    // MARK: Outlets
    @IBOutlet weak var scrollContainer: UIScrollView!
    @IBOutlet weak var controlsContainer: UIView!
    @IBOutlet weak var notifyClosingTime: UISwitch!
    @IBOutlet weak var projectName: UITextField!
    @IBOutlet weak var startingTime: UIPickerView!
    @IBOutlet weak var closingTime: UIPickerView!
    @IBOutlet weak var tolerance: UIPickerView!
    @IBOutlet weak var maxCategories: UIPickerView!
    @IBOutlet weak var maxTasks: UIPickerView!
    @IBOutlet weak var save: UIButton!
    @IBOutlet weak var close: UIButton!
    
    // MARK: Actions
    @IBAction func save(_ sender: Any)
    {
        do {
            let notifyClosingTime = self.notifyClosingTime.isOn
            let projectName = AKProjectName(inputData: self.projectName.text!)
            let startingTime = try Func.AKProcessDate(dateAsString: self.workingDayTimeData[self.startingTime.selectedRow(inComponent: 0)], format: GlobalConstants.AKWorkingDayTimeDateFormat) as NSDate
            let closingTime = try Func.AKProcessDate(dateAsString: self.workingDayTimeData[self.closingTime.selectedRow(inComponent: 0)], format: GlobalConstants.AKWorkingDayTimeDateFormat) as NSDate
            let tolerance = self.toleranceData[self.tolerance.selectedRow(inComponent: 0)]
            let maxCategories = self.limitsData[self.maxCategories.selectedRow(inComponent: 0)]
            let maxTasks = self.limitsData[self.maxTasks.selectedRow(inComponent: 0)]
            
            try projectName.validate()
            try projectName.process()
            
            if let mr = Func.AKObtainMasterReference() {
                let project = Project(context: mr.getMOC())
                
                project.notifyClosingTime = notifyClosingTime
                project.name = projectName.outputData
                project.startingTime = startingTime
                project.closingTime = closingTime
                project.closingTimeTolerance = Int16(tolerance)
                project.maxCategories = Int16(maxCategories)
                project.maxTasks = Int16(maxTasks)
                project.creationDate = NSDate()
                
                DataInterface.getUser()?.addToProject(project)
                self.dismissView(executeDismissTask: true)
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
        self.tolerance.selectRow(1, inComponent: 0, animated: true)
        self.maxCategories.selectRow(0, inComponent: 0, animated: true)
        self.maxTasks.selectRow(0, inComponent: 0, animated: true)
        self.startingTime.selectRow(8, inComponent: 0, animated: true)
        self.closingTime.selectRow(16, inComponent: 0, animated: true)
    }
    
    override func loadLocalizedText() {
        super.loadLocalizedText()
        
        // Load pickers.
        if let data = self.localize(key: "Tolerance") as? [NSNumber] {
            for case let element as Int in data {
                self.toleranceData.append(element)
            }
        }
        
        if let data = self.localize(key: "Limits") as? [NSNumber] {
            for case let element as Int in data {
                self.limitsData.append(element)
            }
        }
        
        if let data = self.localize(key: "WorkingDayTime") as? [Date] {
            for element in data {
                var components = Calendar.current.dateComponents([.hour, .minute], from: element)
                self.workingDayTimeData.append(String(format: "%.2i:%.2i", components.hour ?? 0, components.minute ?? 0))
            }
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
    
    // MARK: UIPickerViewDelegate Implementation
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?
    {
        switch pickerView.tag {
        case LocalEnums.tolerance.rawValue:
            return String(format: "%i minutes", self.toleranceData[row])
        case LocalEnums.maxCategories.rawValue, LocalEnums.maxTasks.rawValue:
            return self.limitsData[row] == -1 ? "No Limit" : String(format: "%i", self.limitsData[row])
        case LocalEnums.startingTime.rawValue, LocalEnums.closingTime.rawValue:
            return self.workingDayTimeData[row]
        default:
            return ""
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView
    {
        let pickerLabel = UILabel()
        pickerLabel.textColor = GlobalConstants.AKPickerViewFg
        
        switch pickerView.tag {
        case LocalEnums.tolerance.rawValue:
            pickerLabel.text = String(format: "%i minutes", self.toleranceData[row])
        case LocalEnums.maxCategories.rawValue, LocalEnums.maxTasks.rawValue:
            pickerLabel.text = self.limitsData[row] == -1 ? "No Limit" : String(format: "%i", self.limitsData[row])
        case LocalEnums.startingTime.rawValue, LocalEnums.closingTime.rawValue:
            pickerLabel.text = self.workingDayTimeData[row]
        default:
            pickerLabel.text = ""
        }
        
        pickerLabel.font = UIFont(name: GlobalConstants.AKDefaultFont, size: 18)
        pickerLabel.textAlignment = NSTextAlignment.center
        
        return pickerLabel
    }
    
    // MARK: UIPickerViewDataSource Implementation
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
    {
        switch pickerView.tag {
        case LocalEnums.tolerance.rawValue:
            return self.toleranceData.count
        case LocalEnums.maxCategories.rawValue, LocalEnums.maxTasks.rawValue:
            return self.limitsData.count
        case LocalEnums.startingTime.rawValue, LocalEnums.closingTime.rawValue:
            return self.workingDayTimeData.count
        default:
            return 0
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int { return 1 }
    
    // MARK: Miscellaneous
    func customSetup()
    {
        super.inhibitTapGesture = true
        super.setup()
        
        // Set Delegator.
        self.projectName.delegate = self
        self.projectName.tag = LocalEnums.projectName.rawValue
        self.tolerance.delegate = self
        self.tolerance.dataSource = self
        self.tolerance.tag = LocalEnums.tolerance.rawValue
        self.maxCategories.delegate = self
        self.maxCategories.dataSource = self
        self.maxCategories.tag = LocalEnums.maxCategories.rawValue
        self.maxTasks.delegate = self
        self.maxTasks.dataSource = self
        self.maxTasks.tag = LocalEnums.maxTasks.rawValue
        self.startingTime.delegate = self
        self.startingTime.dataSource = self
        self.startingTime.tag = LocalEnums.startingTime.rawValue
        self.closingTime.delegate = self
        self.closingTime.dataSource = self
        self.closingTime.tag = LocalEnums.closingTime.rawValue
        
        // Custom L&F.
        self.controlsContainer.backgroundColor = UIColor.clear
        self.projectName.layer.cornerRadius = GlobalConstants.AKButtonCornerRadius
        self.startingTime.layer.cornerRadius = GlobalConstants.AKButtonCornerRadius
        self.closingTime.layer.cornerRadius = GlobalConstants.AKButtonCornerRadius
        self.tolerance.layer.cornerRadius = GlobalConstants.AKButtonCornerRadius
        self.maxCategories.layer.cornerRadius = GlobalConstants.AKButtonCornerRadius
        self.maxTasks.layer.cornerRadius = GlobalConstants.AKButtonCornerRadius
        self.save.layer.cornerRadius = GlobalConstants.AKButtonCornerRadius
        self.close.layer.cornerRadius = GlobalConstants.AKButtonCornerRadius
    }
}
