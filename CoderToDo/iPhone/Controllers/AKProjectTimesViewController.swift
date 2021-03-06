import UIKit
import UserNotifications

class AKProjectTimesViewController: AKCustomViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    // MARK: Local Enums
    private enum LocalEnums: Int {
        case tolerance = 1
        case startingTime = 2
        case closingTime = 3
    }
    
    // MARK: Properties
    var toleranceData = [Int]()
    var workingDayTimeData = [String]()
    var project: Project!
    var lastSelectedRowClosingTime: Int = -1
    var lastSelectedRowStartingTime: Int = -1
    
    // MARK: Outlets
    @IBOutlet weak var controlsContainer: UIView!
    @IBOutlet weak var startingTime: UIPickerView!
    @IBOutlet weak var closingTime: UIPickerView!
    @IBOutlet weak var tolerance: UIPickerView!
    
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
    
    // MARK: UIPickerViewDelegate Implementation
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        var cti: String = ""
        var sti: String = ""
        
        switch pickerView.tag {
        case LocalEnums.closingTime.rawValue:
            cti = self.workingDayTimeData[row]
            sti = self.workingDayTimeData[self.startingTime.selectedRow(inComponent: 0)]
            break
        case LocalEnums.startingTime.rawValue:
            cti = self.workingDayTimeData[self.closingTime.selectedRow(inComponent: 0)]
            sti = self.workingDayTimeData[row]
            break
        default:
            break
        }
        
        var newProject = AKProjectInterface(name: "Dummy Project")
        // Custom Setters.
        newProject.setClosingTime(cti, format: Cons.AKWorkingDayTimeDateFormat, timeZone: Func.AKGetCalendarForLoading().timeZone)
        newProject.setStartingTime(sti, format: Cons.AKWorkingDayTimeDateFormat, timeZone: Func.AKGetCalendarForLoading().timeZone)
        do {
            try newProject.validate()
        }
        catch {
            Func.AKPresentMessageFromError(controller: self, message: "\(error)")
            
            // Undo last selection.
            switch pickerView.tag {
            case LocalEnums.closingTime.rawValue:
                self.closingTime.selectRow(self.lastSelectedRowClosingTime, inComponent: 0, animated: true)
                break
            case LocalEnums.startingTime.rawValue:
                self.startingTime.selectRow(self.lastSelectedRowStartingTime, inComponent: 0, animated: true)
                break
            default:
                break
            }
            
            return
        }
        
        switch pickerView.tag {
        case LocalEnums.closingTime.rawValue:
            self.lastSelectedRowClosingTime = row
            break
        case LocalEnums.startingTime.rawValue:
            self.lastSelectedRowStartingTime = row
            break
        default:
            break
        }
    }
    
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
            if let controller = controller as? AKProjectTimesViewController {
                // Set default values.
                let cttIndex = controller.toleranceData.firstIndex(of: Int(controller.project.closingTimeTolerance))!
                let stiIndex = controller.workingDayTimeData.firstIndex(of: Func.AKProcessDateToString(
                    date: controller.project.startingTime! as Date,
                    format: Cons.AKWorkingDayTimeDateFormat,
                    timeZone: Func.AKGetCalendarForLoading().timeZone
                ))!
                let ctiIndex = controller.workingDayTimeData.firstIndex(of: Func.AKProcessDateToString(
                    date: controller.project.closingTime! as Date,
                    format: Cons.AKWorkingDayTimeDateFormat,
                    timeZone: Func.AKGetCalendarForLoading().timeZone
                ))!
                
                controller.lastSelectedRowStartingTime = stiIndex
                controller.lastSelectedRowClosingTime = ctiIndex
                
                controller.tolerance.selectRow(cttIndex, inComponent: 0, animated: true)
                controller.startingTime.selectRow(stiIndex, inComponent: 0, animated: true)
                controller.closingTime.selectRow(ctiIndex, inComponent: 0, animated: true)
            }
        }
        self.saveData = { (controller) -> Void in
            if let controller = controller as? AKProjectTimesViewController {
                // Save the modifications.
                let ctt = controller.toleranceData[controller.tolerance.selectedRow(inComponent: 0)]
                let sti = controller.workingDayTimeData[controller.startingTime.selectedRow(inComponent: 0)]
                let cti = controller.workingDayTimeData[controller.closingTime.selectedRow(inComponent: 0)]
                
                var project = AKProjectBuilder.from(project: controller.project)
                // Custom Setters.
                project.setClosingTime(cti, format: Cons.AKWorkingDayTimeDateFormat, timeZone: Func.AKGetCalendarForLoading().timeZone)
                project.setStartingTime(sti, format: Cons.AKWorkingDayTimeDateFormat, timeZone: Func.AKGetCalendarForLoading().timeZone)
                // Normal Setters.
                project.closingTimeTolerance = Int16(ctt)
                AKProjectBuilder.to(project: controller.project, from: project)
                
                // Re-schedule the notifications.
                if controller.project.notifyClosingTime {
                    // 1. Invalidate the current ones.
                    Func.AKInvalidateLocalNotification(controller: controller, project: controller.project)
                    // 2. Re-schedule.
                    Func.AKScheduleLocalNotification(
                        controller: controller,
                        project: controller.project,
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
            }
        }
        self.configureLookAndFeel = { (controller) -> Void in
            if let controller = controller as? AKProjectTimesViewController {
                Func.AKStylePicker(picker: controller.tolerance)
                Func.AKStylePicker(picker: controller.startingTime)
                Func.AKStylePicker(picker: controller.closingTime)
            }
        }
        self.setup()
        
        // Delegate & DataSource
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
