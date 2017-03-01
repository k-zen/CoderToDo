import UIKit
import UserNotifications

class AKNewProjectViewController: AKCustomViewController, UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate
{
    // MARK: Local Enums
    private enum LocalEnums: Int {
        case projectName = 1
        case tolerance = 2
        case startingTime = 3
        case closingTime = 4
    }
    
    // MARK: Properties
    var toleranceData = [Int]()
    var workingDayTimeData = [String]()
    
    // MARK: Outlets
    @IBOutlet weak var controlsContainer: UIView!
    @IBOutlet weak var notifyClosingTime: UISwitch!
    @IBOutlet weak var projectName: UITextField!
    @IBOutlet weak var startingTime: UIPickerView!
    @IBOutlet weak var closingTime: UIPickerView!
    @IBOutlet weak var tolerance: UIPickerView!
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
            
            try projectName.validate()
            try projectName.process()
            
            if let mr = Func.AKObtainMasterReference() {
                let now = NSDate()
                
                let project = Project(context: mr.getMOC())
                project.notifyClosingTime = notifyClosingTime
                project.name = projectName.outputData
                project.startingTime = startingTime
                project.closingTime = closingTime
                project.closingTimeTolerance = Int16(tolerance)
                project.creationDate = now
                project.pendingQueue = PendingQueue(context: mr.getMOC())
                project.dilateQueue = DilateQueue(context: mr.getMOC())
                DataInterface.getUser()?.addToProject(project)
                
                // Schedule local notifications.
                if notifyClosingTime {
                    let startingTimeContent = UNMutableNotificationContent()
                    startingTimeContent.title = String(format: "Project: %@", projectName.outputData)
                    startingTimeContent.body = String(format: "Hey %@, starting time is up for your project.", DataInterface.getUsername())
                    startingTimeContent.sound = UNNotificationSound.default()
                    Func.AKGetNotificationCenter().add(
                        UNNotificationRequest(
                            identifier: String(format: "%@:%@", GlobalConstants.AKStartingTimeNotificationName, projectName.outputData),
                            content: startingTimeContent,
                            trigger: UNCalendarNotificationTrigger(
                                dateMatching: Func.AKGetCalendarForLoading().dateComponents([.hour,.minute,.second,], from: startingTime as Date),
                                repeats: true
                            )
                        ),
                        withCompletionHandler: { (error) in
                            if let _ = error {
                                self.showMessage(message: "Error setting up starting time notification.")
                            } }
                    )
                    
                    let closingTimeContent = UNMutableNotificationContent()
                    closingTimeContent.title = String(format: "Project: %@", projectName.outputData)
                    closingTimeContent.body = String(format: "Hey %@, closing time is due for your project.", DataInterface.getUsername())
                    closingTimeContent.sound = UNNotificationSound.default()
                    Func.AKGetNotificationCenter().add(
                        UNNotificationRequest(
                            identifier: String(format: "%@:%@", GlobalConstants.AKClosingTimeNotificationName, projectName.outputData),
                            content: closingTimeContent,
                            trigger: UNCalendarNotificationTrigger(
                                dateMatching: Func.AKGetCalendarForLoading().dateComponents([.hour,.minute,.second,], from: closingTime as Date),
                                repeats: true
                            )
                        ),
                        withCompletionHandler: { (error) in
                            if let _ = error {
                                self.showMessage(message: "Error setting up closing time notification.")
                            } }
                    )
                }
                
                self.dismissView(executeDismissTask: true)
            }
        }
        catch {
            Func.AKPresentMessageFromError(controller: self, message: "\(error)")
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
        
        if let data = self.localize(key: "WorkingDayTime") as? [Date] {
            for element in data {
                var components = Func.AKGetCalendarForLoading().dateComponents([.hour, .minute], from: element)
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
        case LocalEnums.startingTime.rawValue, LocalEnums.closingTime.rawValue:
            pickerLabel.text = self.workingDayTimeData[row]
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
        case LocalEnums.tolerance.rawValue:
            return self.toleranceData.count
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
        super.setup()
        
        // Set Delegator.
        self.projectName.delegate = self
        self.projectName.tag = LocalEnums.projectName.rawValue
        self.tolerance.delegate = self
        self.tolerance.dataSource = self
        self.tolerance.tag = LocalEnums.tolerance.rawValue
        self.startingTime.delegate = self
        self.startingTime.dataSource = self
        self.startingTime.tag = LocalEnums.startingTime.rawValue
        self.closingTime.delegate = self
        self.closingTime.dataSource = self
        self.closingTime.tag = LocalEnums.closingTime.rawValue
        
        // Custom L&F.
        self.projectName.layer.cornerRadius = GlobalConstants.AKButtonCornerRadius
        self.startingTime.layer.cornerRadius = GlobalConstants.AKButtonCornerRadius
        self.closingTime.layer.cornerRadius = GlobalConstants.AKButtonCornerRadius
        self.tolerance.layer.cornerRadius = GlobalConstants.AKButtonCornerRadius
        self.save.layer.cornerRadius = GlobalConstants.AKButtonCornerRadius
        self.close.layer.cornerRadius = GlobalConstants.AKButtonCornerRadius
    }
}
