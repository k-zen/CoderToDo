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
                            if let presenterController = presenterController as? AKAddViewController, let presentedController = presentedController as? AKAddCategoryViewController {
                                presentedController.project = presenterController.project
                            } },
                         dismissViewCompletionTask: { (presenterController, presentedController) -> Void in
                            NSLog("=> INFO: \(type(of: presentedController)) MODAL PRESENTATION HAS BEEN DISMISSED...")
                            
                            presenterController.dismissView(executeDismissTask: true) }
        )
    }
    
    @IBAction func addTask(_ sender: Any)
    {
        switch DataInterface.getProjectStatus(project: self.project) {
        case ProjectStatus.ACEPTING_TASKS:
            self.presentView(controller: AKAddTaskViewController(nibName: "AKAddTaskView", bundle: nil),
                             taskBeforePresenting: { (presenterController, presentedController) -> Void in
                                if let presenterController = presenterController as? AKAddViewController, let presentedController = presentedController as? AKAddTaskViewController {
                                    presentedController.project = presenterController.project
                                } },
                             dismissViewCompletionTask: { (presenterController, presentedController) -> Void in
                                NSLog("=> INFO: \(type(of: presentedController)) MODAL PRESENTATION HAS BEEN DISMISSED...")
                                
                                presenterController.dismissView(executeDismissTask: true) }
            )
            break
        default:
            self.showMessage(message: "You are not allowed to add new tasks now. Wait for the working day to finish.")
            break
        }
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
        // Func.AKAddBlurView(view: self.controlsContainer, effect: UIBlurEffectStyle.dark, addClearColorBgToView: true)
        
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
