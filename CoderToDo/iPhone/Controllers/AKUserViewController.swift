import Charts
import UIKit

class AKUserViewController: AKCustomViewController, UITextFieldDelegate
{
    // MARK: Local Enums
    private enum LocalEnums: Int {
        case username = 1
    }
    
    // MARK: Outlets
    @IBOutlet weak var navController: UINavigationItem!
    @IBOutlet weak var scrollContainer: UIScrollView!
    @IBOutlet weak var controlsContainer: UIView!
    @IBOutlet weak var chartContainer: UIView!
    @IBOutlet weak var mostProductiveDay: UILabel!
    @IBOutlet weak var osrChartContainer: BarChartView!
    @IBOutlet weak var usernameValue: UITextField!
    @IBOutlet weak var save: UIButton!
    
    // MARK: Actions
    @IBAction func save(_ sender: Any)
    {
        let username = AKUsername(inputData: self.usernameValue.text!)
        do {
            try username.validate()
            try username.process()
        }
        catch {
            Func.AKPresentMessageFromError(controller: self, message: "\(error)")
            return
        }
        
        var newUser = AKUserInterface(username: username.outputData)
        newUser.gmtOffset = Int16(Func.AKGetOffsetFromGMT())
        do {
            try newUser.validate()
        }
        catch {
            Func.AKPresentMessageFromError(controller: self, message: "\(error)")
            return
        }
        
        AKUserBuilder.to(user: DataInterface.getUser()!, from: newUser)
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: AKCustomViewController Overriding
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.customSetup()
    }
    
    // MARK: UITextFieldDelegate Implementation
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    {
        if range.length + range.location > (textField.text?.characters.count)! {
            return false
        }
        
        let newLen = (textField.text?.characters.count)! + string.characters.count - range.length
        
        switch textField.tag {
        case LocalEnums.username.rawValue:
            return newLen > GlobalConstants.AKMaxUsernameLength ? false : true
        default:
            return newLen > GlobalConstants.AKMaxUsernameLength ? false : true
        }
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool
    {
        Func.AKAddDoneButtonKeyboard(textField, controller: self)
        
        switch textField.tag {
        case LocalEnums.username.rawValue:
            var offset = textField.convert(textField.frame, to: self.scrollContainer).origin
            offset.x = 0
            
            var keyboardHeight = GlobalConstants.AKKeyboardHeight
            if textField.autocorrectionType == UITextAutocorrectionType.no {
                keyboardHeight -= GlobalConstants.AKAutoCorrectionToolbarHeight
            }
            
            let height = Func.AKGetComponentAbsoluteHeightPosition(container: self.controlsContainer, component: self.save)
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
    
    // MARK: Miscellaneous
    func customSetup()
    {
        self.loadData = { (controller) -> Void in
            if let controller = controller as? AKUserViewController {
                // Hide the chart if there are not data.
                controller.loadChart()
                controller.chartContainer.isHidden = DataInterface.computeAverageSRGroupedByDay().isEmpty ? true : false
                
                controller.usernameValue.text = DataInterface.getUsername()
            }
        }
        self.configureLookAndFeel = { (controller) -> Void in
            if let controller = controller as? AKUserViewController {
                controller.usernameValue.layer.cornerRadius = GlobalConstants.AKButtonCornerRadius
                controller.save.layer.cornerRadius = GlobalConstants.AKButtonCornerRadius
            }
        }
        self.setup()
        
        // Delegate & DataSource
        self.usernameValue.delegate = self
        self.usernameValue.tag = LocalEnums.username.rawValue
    }
    
    func loadChart() {
        let formato: BarChartFormatter = BarChartFormatter()
        
        var dataEntries: [BarChartDataEntry] = []
        for (key, value) in DataInterface.computeAverageSRGroupedByDay() {
            let dataEntry = BarChartDataEntry(x: Double(key), y: Double(value))
            dataEntries.append(dataEntry)
        }
        
        let chartDataSet = BarChartDataSet(values: dataEntries, label: "Success Ratio Grouped by Day (%)")
        chartDataSet.valueFont = UIFont(name: GlobalConstants.AKSecondaryFont, size: 12)!
        chartDataSet.valueTextColor = GlobalConstants.AKRedForBlackFg
        chartDataSet.drawValuesEnabled = true
        chartDataSet.setColors([GlobalConstants.AKCoderToDoWhite], alpha: 0.75)
        
        // Configure the chart.
        self.osrChartContainer.xAxis.labelPosition = .bottom
        self.osrChartContainer.xAxis.labelFont = UIFont(name: GlobalConstants.AKDefaultFont, size: 12)!
        self.osrChartContainer.xAxis.labelTextColor = GlobalConstants.AKDefaultFg
        self.osrChartContainer.xAxis.gridColor = GlobalConstants.AKDefaultBg
        self.osrChartContainer.xAxis.gridLineCap = .square
        self.osrChartContainer.xAxis.gridLineDashLengths = [2, 2]
        self.osrChartContainer.xAxis.valueFormatter = formato
        self.osrChartContainer.xAxis.drawAxisLineEnabled = false
        
        self.osrChartContainer.leftAxis.labelFont = UIFont(name: GlobalConstants.AKDefaultFont, size: 12)!
        self.osrChartContainer.leftAxis.labelTextColor = GlobalConstants.AKDefaultFg
        self.osrChartContainer.leftAxis.gridColor = GlobalConstants.AKDefaultBg
        self.osrChartContainer.leftAxis.gridLineCap = .square
        self.osrChartContainer.leftAxis.gridLineDashLengths = [2, 2]
        self.osrChartContainer.leftAxis.axisMaximum = 115.0
        self.osrChartContainer.leftAxis.axisMinimum = 0.0
        self.osrChartContainer.leftAxis.drawAxisLineEnabled = false
        self.osrChartContainer.leftAxis.drawLabelsEnabled = false
        
        self.osrChartContainer.rightAxis.labelFont = UIFont(name: GlobalConstants.AKDefaultFont, size: 12)!
        self.osrChartContainer.rightAxis.labelTextColor = GlobalConstants.AKDefaultFg
        self.osrChartContainer.rightAxis.gridColor = GlobalConstants.AKDefaultBg
        self.osrChartContainer.rightAxis.gridLineCap = .square
        self.osrChartContainer.rightAxis.gridLineDashLengths = [2, 2]
        self.osrChartContainer.rightAxis.axisMaximum = 115.0
        self.osrChartContainer.rightAxis.axisMinimum = 0.0
        self.osrChartContainer.rightAxis.drawAxisLineEnabled = false
        self.osrChartContainer.rightAxis.drawLabelsEnabled = false
        
        self.osrChartContainer.legend.textColor = GlobalConstants.AKDefaultFg
        self.osrChartContainer.legend.font = UIFont(name: GlobalConstants.AKDefaultFont, size: 16)!
        self.osrChartContainer.legend.horizontalAlignment = .center
        
        self.osrChartContainer.backgroundColor = GlobalConstants.AKDefaultBg
        self.osrChartContainer.gridBackgroundColor = GlobalConstants.AKDefaultBg
        self.osrChartContainer.noDataText = ""
        self.osrChartContainer.chartDescription?.text = ""
        self.osrChartContainer.noDataTextColor = GlobalConstants.AKDefaultBg
        self.osrChartContainer.animate(xAxisDuration: 1.0, yAxisDuration: 1.0, easingOption: .linear)
        self.osrChartContainer.isUserInteractionEnabled = false
        
        // Load chart.
        let chartData = BarChartData(dataSet: chartDataSet)
        
        self.osrChartContainer.data = chartData
        
        let mostProductiveDay = DataInterface.mostProductiveDay()
        if mostProductiveDay != .invalid {
            self.mostProductiveDay.text = String(
                format: "%@ is your most productive day!",
                Func.AKGetDayOfWeekAsName(dayOfWeek: mostProductiveDay.rawValue)!
            )
        }
        else {
            self.mostProductiveDay.text = "Most Productive Day"
        }
    }
}

@objc(BarChartFormatter)
class BarChartFormatter: NSObject, IAxisValueFormatter
{
    func stringForValue(_ value: Double, axis: AxisBase?) -> String { return Func.AKGetDayOfWeekAsName(dayOfWeek: Int16(value), short: true)! }
}
