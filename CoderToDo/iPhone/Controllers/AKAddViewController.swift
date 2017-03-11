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
                            if
                                let presenterController = presenterController as? AKAddViewController,
                                let presentedController = presentedController as? AKAddCategoryViewController {
                                presentedController.project = presenterController.project
                            } },
                         dismissViewCompletionTask: { (presenterController, presentedController) -> Void in
                            presenterController.dismissView(executeDismissTask: true) }
        )
    }
    
    @IBAction func addTask(_ sender: Any)
    {
        do {
            try AKChecks.canAddTask(project: self.project)
            self.presentView(controller: AKAddTaskViewController(nibName: "AKAddTaskView", bundle: nil),
                             taskBeforePresenting: { (presenterController, presentedController) -> Void in
                                if
                                    let presenterController = presenterController as? AKAddViewController,
                                    let presentedController = presentedController as? AKAddTaskViewController {
                                    presentedController.project = presenterController.project
                                } },
                             dismissViewCompletionTask: { (presenterController, presentedController) -> Void in
                                presenterController.dismissView(executeDismissTask: true) }
            )
        }
        catch {
            Func.AKPresentMessageFromError(controller: self, message: "\(error)")
        }
    }
    
    // MARK: AKCustomViewController Overriding
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.customSetup()
        self.loadLocalizedText()
    }
    
    override func viewDidLayoutSubviews()
    {
        super.viewDidLayoutSubviews()
        
        // Custom L&F.
        self.controlsContainer.layer.borderWidth = CGFloat(GlobalConstants.AKDefaultBorderThickness)
        self.controlsContainer.layer.borderColor = GlobalConstants.AKDefaultViewBorderBg.cgColor
    }
    
    // MARK: Miscellaneous
    func customSetup()
    {
        super.additionalOperationsWhenTaped = { (gesture) -> Void in self.dismissView(executeDismissTask: true) }
        super.setup()
    }
}
