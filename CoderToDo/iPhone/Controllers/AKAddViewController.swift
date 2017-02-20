import UIKit

class AKAddViewController: AKCustomViewController
{
    // MARK: Properties
    var project: Project!
    
    // MARK: Outlets
    @IBOutlet weak var controlsContainer: UIView!
    @IBOutlet weak var addCategory: UIButton!
    @IBOutlet weak var addTask: UIButton!
    
    // MARK: Actions
    @IBAction func addCategory(_ sender: Any)
    {
        self.presentView(controller: AKAddCategoryViewController(nibName: "AKAddCategoryView", bundle: nil),
                         taskBeforePresenting: { (presenterController, presentedController) -> Void in
                            if let controller1 = presenterController as? AKAddViewController, let controller2 = presentedController as? AKAddCategoryViewController {
                                controller2.project = controller1.project
                            } },
                         dismissViewCompletionTask: { (presenterController, presentedController) -> Void in
                            NSLog("=> INFO: \(type(of: presentedController)) MODAL PRESENTATION HAS BEEN DISMISSED...")
                            
                            presenterController.dismissView(executeDismissTask: true) }
        )
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
        Func.AKAddBlurView(view: self.controlsContainer, effect: UIBlurEffectStyle.dark, addClearColorBgToView: true)
        
        self.addCategory.layer.cornerRadius = GlobalConstants.AKButtonCornerRadius
        self.addTask.layer.cornerRadius = GlobalConstants.AKButtonCornerRadius
        
        Func.AKAddBorderDeco(
            self.controlsContainer,
            color: GlobalConstants.AKDefaultViewBorderBg.cgColor,
            thickness: GlobalConstants.AKDefaultBorderThickness,
            position: .top
        )
    }
}
