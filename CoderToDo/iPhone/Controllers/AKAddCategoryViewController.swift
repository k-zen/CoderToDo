import UIKit

class AKAddCategoryViewController: AKCustomViewController, UITextFieldDelegate
{
    // MARK: Properties
    var project: Project!
    
    // MARK: Local Enums
    enum LocalEnums: Int {
        case category = 1
    }
    
    // MARK: Outlets
    @IBOutlet weak var controlsContainer: UIView!
    @IBOutlet weak var mainTitle: UILabel!
    @IBOutlet weak var categoryValue: UITextField!
    @IBOutlet weak var add: UIButton!
    @IBOutlet weak var close: UIButton!
    
    // MARK: Actions
    @IBAction func add(_ sender: Any)
    {
        do {
            let categoryName = AKCategoryName(inputData: self.categoryValue.text!)
            
            try categoryName.validate()
            try categoryName.process()
            
            if let mr = Func.AKObtainMasterReference() {
                // TODO: Check if the category doesn't exists!!!
                
                let projectCategory = ProjectCategory(context: mr.getMOC())
                projectCategory.name = categoryName.outputData
                self.project.addToProjectCategories(projectCategory)
                
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
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
    }
    
    // MARK: UITextFieldDelegate Implementation
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    {
        if range.length + range.location > (textField.text?.characters.count)! {
            return false
        }
        
        let newLen = (textField.text?.characters.count)! + string.characters.count - range.length
        
        switch textField.tag {
        case LocalEnums.category.rawValue:
            return newLen > GlobalConstants.AKMaxCategoryNameLength ? false : true
        default:
            return newLen > GlobalConstants.AKMaxCategoryNameLength ? false : true
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
    
    // MARK: Miscellaneous
    func customSetup()
    {
        super.setup()
        
        // Set Delegator.
        self.categoryValue.delegate = self
        self.categoryValue.tag = LocalEnums.category.rawValue
        
        // Custom L&F.
        self.categoryValue.layer.cornerRadius = GlobalConstants.AKButtonCornerRadius
        self.add.layer.cornerRadius = GlobalConstants.AKButtonCornerRadius
        self.close.layer.cornerRadius = GlobalConstants.AKButtonCornerRadius
    }
}
