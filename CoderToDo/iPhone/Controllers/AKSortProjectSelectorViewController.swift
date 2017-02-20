import UIKit

class AKSortProjectSelectorViewController: AKCustomViewController, UIPickerViewDataSource, UIPickerViewDelegate
{
    // MARK: Local Enums
    enum LocalEnums: Int {
        case filters = 1
        case order = 2
    }
    
    // MARK: Properties
    var filtersData = [ProjectSorting]()
    var orderData = [SortingOrder]()
    
    // MARK: Outlets
    @IBOutlet weak var controlsContainer: UIView!
    @IBOutlet weak var mainTitle: UILabel!
    @IBOutlet weak var filters: UIPickerView!
    @IBOutlet weak var order: UIPickerView!
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
        self.filters.selectRow(2, inComponent: 0, animated: true)
        self.order.selectRow(0, inComponent: 0, animated: true)
    }
    
    override func loadLocalizedText() {
        super.loadLocalizedText()
        
        // Load pickers.
        for filter in Func.AKIterateEnum(ProjectSorting.self) {
            self.filtersData.append(filter)
        }
        for order in Func.AKIterateEnum(SortingOrder.self) {
            self.orderData.append(order)
        }
    }
    
    // MARK: UIPickerViewDelegate Implementation
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?
    {
        switch pickerView.tag {
        case LocalEnums.filters.rawValue:
            return self.filtersData[row].rawValue
        case LocalEnums.order.rawValue:
            return self.orderData[row].rawValue
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
        case LocalEnums.order.rawValue:
            pickerLabel.text = self.orderData[row].rawValue
        default:
            pickerLabel.text = ""
        }
        
        pickerLabel.font = UIFont(name: GlobalConstants.AKSecondaryFont, size: 16)
        pickerLabel.textAlignment = NSTextAlignment.center
        
        return pickerLabel
    }
    
    // MARK: UIPickerViewDataSource Implementation
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
    {
        switch pickerView.tag {
        case LocalEnums.filters.rawValue:
            return self.filtersData.count
        case LocalEnums.order.rawValue:
            return self.orderData.count
        default:
            return 0
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int { return 1 }
    
    // MARK: Miscellaneous
    func customSetup()
    {
        super.additionalOperationsWhenTaped = { (gesture) -> Void in self.dismissView(executeDismissTask: false) }
        super.setup()
        
        // Set Delegator.
        self.filters.delegate = self
        self.filters.dataSource = self
        self.filters.tag = LocalEnums.filters.rawValue
        self.order.delegate = self
        self.order.dataSource = self
        self.order.tag = LocalEnums.order.rawValue
        
        // Custom L&F.
        Func.AKAddBlurView(view: self.controlsContainer, effect: UIBlurEffectStyle.dark, addClearColorBgToView: true)
        
        self.filters.layer.cornerRadius = GlobalConstants.AKButtonCornerRadius
        self.order.layer.cornerRadius = GlobalConstants.AKButtonCornerRadius
        self.sort.layer.cornerRadius = GlobalConstants.AKButtonCornerRadius
        
        Func.AKAddBorderDeco(
            self.controlsContainer,
            color: GlobalConstants.AKDefaultViewBorderBg.cgColor,
            thickness: GlobalConstants.AKDefaultBorderThickness,
            position: .top
        )
    }
}
