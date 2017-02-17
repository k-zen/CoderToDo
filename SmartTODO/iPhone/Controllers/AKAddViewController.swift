import UIKit

class AKAddViewController: AKCustomViewController
{
    // MARK: Outlets
    @IBOutlet weak var controlsContainer: UIView!
    
    // MARK: Actions
    @IBAction func addCategory(_ sender: Any)
    {
        NSLog("=> INFO: ADDING CATEGORY!")
    }
    
    @IBAction func addTask(_ sender: Any)
    {
        NSLog("=> INFO: ADDING TASK!")
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
    }
    
    override func loadLocalizedText() {
        super.loadLocalizedText()
    }
    
    // MARK: Miscellaneous
    func customSetup()
    {
        super.additionalOperationsWhenTaped = { (gesture) -> Void in self.dismissView(executeDismissTask: false) }
        super.setup()
        
        // Custom L&F.
        self.controlsContainer.layer.cornerRadius = GlobalConstants.AKViewCornerRadius
        self.controlsContainer.layer.masksToBounds = true
        Func.AKAddBlurView(view: self.controlsContainer, effect: UIBlurEffectStyle.dark, addClearColorBgToView: true)
    }
}
