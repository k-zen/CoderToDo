import Charts
import UIKit

class AKUserViewController: AKCustomViewController, UITextFieldDelegate {
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
    @IBAction func save(_ sender: Any) {
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
    override func viewDidLoad() {
        super.viewDidLoad()
        self.customSetup()
    }
    
    // MARK: UITextFieldDelegate Implementation
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if range.length + range.location > (textField.text?.characters.count)! {
            return false
        }
        
        let newLen = (textField.text?.characters.count)! + string.characters.count - range.length
        
        switch textField.tag {
        case LocalEnums.username.rawValue:
            return newLen > Cons.AKMaxUsernameLength ? false : true
        default:
            return newLen > Cons.AKMaxUsernameLength ? false : true
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
    
    // MARK: Miscellaneous
    func customSetup() {
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
                Func.AKStyleTextField(textField: controller.usernameValue)
                Func.AKStyleButton(button: controller.save)
            }
        }
        self.currentScrollContainer = self.scrollContainer
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
        chartDataSet.valueFont = UIFont(name: Cons.AKSecondaryFont, size: 12)!
        chartDataSet.valueTextColor = Cons.AKRedForBlackFg
        chartDataSet.drawValuesEnabled = true
        chartDataSet.setColors([Cons.AKCoderToDoWhite], alpha: 0.75)
        
        // Configure the chart.
        self.osrChartContainer.xAxis.labelPosition = .bottom
        self.osrChartContainer.xAxis.labelFont = UIFont(name: Cons.AKDefaultFont, size: 12)!
        self.osrChartContainer.xAxis.labelTextColor = Cons.AKDefaultFg
        self.osrChartContainer.xAxis.gridColor = Cons.AKDefaultBg
        self.osrChartContainer.xAxis.gridLineCap = .square
        self.osrChartContainer.xAxis.gridLineDashLengths = [2, 2]
        self.osrChartContainer.xAxis.valueFormatter = formato
        self.osrChartContainer.xAxis.drawAxisLineEnabled = false
        
        self.osrChartContainer.leftAxis.labelFont = UIFont(name: Cons.AKDefaultFont, size: 12)!
        self.osrChartContainer.leftAxis.labelTextColor = Cons.AKDefaultFg
        self.osrChartContainer.leftAxis.gridColor = Cons.AKDefaultBg
        self.osrChartContainer.leftAxis.gridLineCap = .square
        self.osrChartContainer.leftAxis.gridLineDashLengths = [2, 2]
        self.osrChartContainer.leftAxis.axisMaximum = 115.0
        self.osrChartContainer.leftAxis.axisMinimum = 0.0
        self.osrChartContainer.leftAxis.drawAxisLineEnabled = false
        self.osrChartContainer.leftAxis.drawLabelsEnabled = false
        
        self.osrChartContainer.rightAxis.labelFont = UIFont(name: Cons.AKDefaultFont, size: 12)!
        self.osrChartContainer.rightAxis.labelTextColor = Cons.AKDefaultFg
        self.osrChartContainer.rightAxis.gridColor = Cons.AKDefaultBg
        self.osrChartContainer.rightAxis.gridLineCap = .square
        self.osrChartContainer.rightAxis.gridLineDashLengths = [2, 2]
        self.osrChartContainer.rightAxis.axisMaximum = 115.0
        self.osrChartContainer.rightAxis.axisMinimum = 0.0
        self.osrChartContainer.rightAxis.drawAxisLineEnabled = false
        self.osrChartContainer.rightAxis.drawLabelsEnabled = false
        
        self.osrChartContainer.legend.textColor = Cons.AKDefaultFg
        self.osrChartContainer.legend.font = UIFont(name: Cons.AKDefaultFont, size: 16)!
        self.osrChartContainer.legend.horizontalAlignment = .center
        
        self.osrChartContainer.backgroundColor = Cons.AKDefaultBg
        self.osrChartContainer.gridBackgroundColor = Cons.AKDefaultBg
        self.osrChartContainer.noDataText = ""
        self.osrChartContainer.chartDescription?.text = ""
        self.osrChartContainer.noDataTextColor = Cons.AKDefaultBg
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
class BarChartFormatter: NSObject, IAxisValueFormatter {
    func stringForValue(_ value: Double, axis: AxisBase?) -> String { return Func.AKGetDayOfWeekAsName(dayOfWeek: Int16(value), short: true)! }
}
