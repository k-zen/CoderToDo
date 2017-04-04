import UIKit
import UserNotifications

class AKProjectTimesViewController: AKCustomViewController, UIPickerViewDataSource, UIPickerViewDelegate
{
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
    
    // MARK: Outlets
    @IBOutlet weak var controlsContainer: UIView!
    @IBOutlet weak var startingTime: UIPickerView!
    @IBOutlet weak var closingTime: UIPickerView!
    @IBOutlet weak var tolerance: UIPickerView!
    
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
        let cttIndex = self.toleranceData.index(of: Int(project.closingTimeTolerance))!
        let stiIndex = self.workingDayTimeData.index(of: Func.AKProcessDateToString(
            date: project.startingTime! as Date,
            format: GlobalConstants.AKWorkingDayTimeDateFormat,
            timeZone: TimeZone.current
        ))!
        let ctiIndex = self.workingDayTimeData.index(of: Func.AKProcessDateToString(
            date: project.closingTime! as Date,
            format: GlobalConstants.AKWorkingDayTimeDateFormat,
            timeZone: TimeZone.current
        ))!
        
        self.tolerance.selectRow(cttIndex, inComponent: 0, animated: true)
        self.startingTime.selectRow(stiIndex, inComponent: 0, animated: true)
        self.closingTime.selectRow(ctiIndex, inComponent: 0, animated: true)
    }
    
    override func viewDidLayoutSubviews()
    {
        super.viewDidLayoutSubviews()
        
        // Custom L&F.
        self.startingTime.layer.cornerRadius = GlobalConstants.AKButtonCornerRadius
        self.closingTime.layer.cornerRadius = GlobalConstants.AKButtonCornerRadius
        self.tolerance.layer.cornerRadius = GlobalConstants.AKButtonCornerRadius
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillDisappear(animated)
        
        // Save the modifications.
        let ctt = self.toleranceData[self.tolerance.selectedRow(inComponent: 0)]
        let sti = self.workingDayTimeData[self.startingTime.selectedRow(inComponent: 0)]
        let cti = self.workingDayTimeData[self.closingTime.selectedRow(inComponent: 0)]
        
        var project = AKProjectBuilder.from(project: self.project)
        // Custom Setters.
        project.setClosingTime(cti, format: GlobalConstants.AKWorkingDayTimeDateFormat, timeZone: TimeZone.current)
        project.setStartingTime(sti, format: GlobalConstants.AKWorkingDayTimeDateFormat, timeZone: TimeZone.current)
        // Normal Setters.
        project.closingTimeTolerance = Int16(ctt)
        AKProjectBuilder.to(project: self.project, from: project)
        
        // Re-schedule the notifications.
        // 1. Invalidate the current ones.
        Func.AKInvalidateLocalNotification(controller: self, project: self.project)
        // 2. Re-schedule.
        Func.AKScheduleLocalNotification(
            controller: self,
            project: self.project,
            completionTask: { (presenterController) -> Void in
                presenterController?.showMessage(
                    message: "Ooops, there was a problem scheduling the notification.",
                    animate: true,
                    completionTask: nil
                ) }
        )
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
            break
        case LocalEnums.startingTime.rawValue, LocalEnums.closingTime.rawValue:
            pickerLabel.text = self.workingDayTimeData[row]
            break
        default:
            pickerLabel.text = ""
            break
        }
        
        pickerLabel.backgroundColor = GlobalConstants.AKPickerViewBg
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
