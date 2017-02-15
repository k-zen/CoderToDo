import UIKit

class AKSortProjectSelectorViewController: AKCustomViewController, UIPickerViewDataSource, UIPickerViewDelegate
{
    // MARK: Local Enums
    enum LocalEnums: Int {
        case filters = 1
    }
    
    // MARK: Properties
    var filtersData = [ProjectSorting]()
    
    // MARK: Outlets
    @IBOutlet weak var controlsContainer: UIView!
    @IBOutlet weak var mainTitle: UILabel!
    @IBOutlet weak var filters: UIPickerView!
    @IBOutlet weak var sort: UIButton!
    
    // MARK: Actions
    @IBAction func sort(_ sender: Any)
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
        self.filters.selectRow(0, inComponent: 0, animated: true)
    }
    
    override func loadLocalizedText() {
        super.loadLocalizedText()
        
        // Load pickers.
        for filter in Func.AKIterateEnum(ProjectSorting.self) {
            self.filtersData.append(filter)
        }
    }
    
    // MARK: UIPickerViewDelegate Implementation
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?
    {
        switch pickerView.tag {
        case LocalEnums.filters.rawValue:
            return self.filtersData[row].rawValue
        default:
            return ""
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView
    {
        let pickerLabel = UILabel()
        pickerLabel.textColor = GlobalConstants.AKPickerViewFg
        
        switch pickerView.tag {
        case LocalEnums.filters.rawValue:
            pickerLabel.text = self.filtersData[row].rawValue
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
        case LocalEnums.filters.rawValue:
            return self.filtersData.count
        default:
            return 0
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int { return 1 }
    
    // MARK: Miscellaneous
    func customSetup()
    {
        super.shouldAddBlurView = true
        super.setup()
        
        // Set Delegator.
        self.filters.delegate = self
        self.filters.dataSource = self
        self.filters.tag = LocalEnums.filters.rawValue
        
        // Custom L&F.
        self.controlsContainer.backgroundColor = UIColor.clear
        self.filters.layer.cornerRadius = GlobalConstants.AKButtonCornerRadius
        self.sort.layer.cornerRadius = GlobalConstants.AKButtonCornerRadius
    }
}
