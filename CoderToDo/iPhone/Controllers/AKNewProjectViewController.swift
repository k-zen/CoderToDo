import UIKit

class AKNewProjectViewController: AKCustomViewController, UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate {
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
    @IBOutlet weak var scrollContainer: UIScrollView!
    @IBOutlet weak var controlsContainer: UIView!
    @IBOutlet weak var notifyClosingTime: UISwitch!
    @IBOutlet weak var projectName: UITextField!
    @IBOutlet weak var startingTime: UIPickerView!
    @IBOutlet weak var closingTime: UIPickerView!
    @IBOutlet weak var tolerance: UIPickerView!
    @IBOutlet weak var save: UIButton!
    @IBOutlet weak var close: UIButton!
    
    // MARK: Actions
    @IBAction func save(_ sender: Any) {
        // Check name.
        let name = AKProjectName(inputData: self.projectName.text!)
        do {
            try name.validate()
            try name.process()
        }
        catch {
            Func.AKPresentMessageFromError(controller: self, message: "\(error)")
            return
        }
        
        // Check other data.
        let cti = self.workingDayTimeData[self.closingTime.selectedRow(inComponent: 0)]
        let ctt = self.toleranceData[self.tolerance.selectedRow(inComponent: 0)]
        let nct = self.notifyClosingTime.isOn
        let sti = self.workingDayTimeData[self.startingTime.selectedRow(inComponent: 0)]
        
        var newProject = AKProjectInterface(name: name.outputData)
        // Custom Setters.
        newProject.setClosingTime(cti, format: Cons.AKWorkingDayTimeDateFormat, timeZone: Func.AKGetCalendarForLoading().timeZone)
        newProject.setStartingTime(sti, format: Cons.AKWorkingDayTimeDateFormat, timeZone: Func.AKGetCalendarForLoading().timeZone)
        // Normal Setters.
        newProject.gmtOffset = Int16(Func.AKGetOffsetFromGMT())
        newProject.closingTimeTolerance = Int16(ctt)
        newProject.notifyClosingTime = nct
        do {
            try newProject.validate()
        }
        catch {
            Func.AKPresentMessageFromError(controller: self, message: "\(error)")
            return
        }
        
        if let project = AKProjectBuilder.mirror(interface: newProject) {
            if DataInterface.addProject(project: project) {
                self.dismissView(executeDismissTask: true)
            }
            else {
                self.showMessage(
                    origin: CGPoint.zero,
                    type: .error,
                    message: "Could not add the new project. The error has been reported.",
                    animate: true,
                    completionTask: nil
                )
            }
        }
    }
    
    @IBAction func close(_ sender: Any) { self.dismissView(executeDismissTask: true) }
    
    // MARK: AKCustomViewController Overriding
    override func viewDidLoad() {
        super.viewDidLoad()
        self.customSetup()
        self.loadLocalizedText()
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
                let components = Func.AKGetCalendarForLoading().dateComponents([.hour, .minute], from: element)
                self.workingDayTimeData.append(String(format: "%.2i:%.2i", components.hour ?? 0, components.minute ?? 0))
            }
        }
    }
    
    // MARK: UITextFieldDelegate Implementation
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if range.length + range.location > (textField.text?.count)! {
            return false
        }
        
        let newLen = (textField.text?.count)! + string.count - range.length
        
        switch textField.tag {
        case LocalEnums.projectName.rawValue:
            return newLen > Cons.AKMaxProjectNameLength ? false : true
        default:
            return newLen > Cons.AKMaxProjectNameLength ? false : true
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
    
    // MARK: UIPickerViewDelegate Implementation
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch pickerView.tag {
        case LocalEnums.tolerance.rawValue:
            return String(format: "%i minutes", self.toleranceData[row])
        case LocalEnums.startingTime.rawValue, LocalEnums.closingTime.rawValue:
            return self.workingDayTimeData[row]
        default:
            return ""
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let pickerLabel = UILabel()
        pickerLabel.textColor = Cons.AKPickerViewFg
        
        switch pickerView.tag {
        case LocalEnums.tolerance.rawValue:
            pickerLabel.text = String(format: "%i minutes", self.toleranceData[row])
            break
        case LocalEnums.startingTime.rawValue, LocalEnums.closingTime.rawValue:
            pickerLabel.text = self.workingDayTimeData[row]
            break
        default:
            pickerLabel.text = ""
            break
        }
        
        pickerLabel.backgroundColor = Cons.AKPickerViewBg
        pickerLabel.font = UIFont(name: Cons.AKSecondaryFont, size: Cons.AKPickerFontSize)
        pickerLabel.textAlignment = NSTextAlignment.center
        
        return pickerLabel
    }
    
    // MARK: UIPickerViewDataSource Implementation
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
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
    func customSetup() {
        self.loadData = { (controller) -> Void in
            if let controller = controller as? AKNewProjectViewController {
                controller.tolerance.selectRow(1, inComponent: 0, animated: true)
                controller.startingTime.selectRow(8, inComponent: 0, animated: true)
                controller.closingTime.selectRow(16, inComponent: 0, animated: true)
            }
        }
        self.configureLookAndFeel = { (controller) -> Void in
            if let controller = controller as? AKNewProjectViewController {
                Func.AKAddBlurView(view: controller.controlsContainer, effect: .dark, addClearColorBgToView: true)
                controller.controlsContainer.layer.cornerRadius = Cons.AKViewCornerRadius
                controller.controlsContainer.layer.masksToBounds = true
                controller.controlsContainer.layer.borderColor = Cons.AKCoderToDoGray3.cgColor
                controller.controlsContainer.layer.borderWidth = Cons.AKViewBorderWidth
                
                Func.AKStyleTextField(textField: controller.projectName)
                
                Func.AKStylePicker(picker: controller.tolerance)
                Func.AKStylePicker(picker: controller.startingTime)
                Func.AKStylePicker(picker: controller.closingTime)
                
                Func.AKStyleButton(button: controller.save)
                Func.AKStyleButton(button: controller.close)
            }
        }
        self.currentScrollContainer = self.scrollContainer
        self.setup()
        
        // Delegate & DataSource
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
    }
}
