import UIKit

class AKAddView: AKCustomView
{
    // MARK: Constants
    struct LocalConstants {
        static let AKViewHeight: CGFloat = 41.5
    }
    
    // MARK: Outlets
    @IBOutlet var mainContainer: UIView!
    @IBOutlet weak var addCategory: UIButton!
    @IBOutlet weak var addTask: UIButton!
    
    // MARK: Actions
    @IBAction func addCategory(_ sender: Any)
    {
        if let _ = self.controller as? AKListProjectsViewController {
            // Ignore...
        }
        else if let controller = self.controller as? AKViewProjectViewController {
            controller.presentView(controller: AKAddCategoryViewController(nibName: "AKAddCategoryView", bundle: nil),
                                   taskBeforePresenting: { (presenterController, presentedController) -> Void in
                                    if
                                        let presenterController = presenterController as? AKViewProjectViewController,
                                        let presentedController = presentedController as? AKAddCategoryViewController {
                                        presentedController.project = presenterController.project
                                    } },
                                   dismissViewCompletionTask: { (presenterController, presentedController) -> Void in }
            )
        }
    }
    
    @IBAction func addTask(_ sender: Any)
    {
        if let _ = self.controller as? AKListProjectsViewController {
            // Ignore...
        }
        else if let controller = self.controller as? AKViewProjectViewController {
            do {
                try AKChecks.canAddTask(project: controller.project)
                controller.presentView(controller: AKAddTaskViewController(nibName: "AKAddTaskView", bundle: nil),
                                       taskBeforePresenting: { (presenterController, presentedController) -> Void in
                                        if
                                            let presenterController = presenterController as? AKViewProjectViewController,
                                            let presentedController = presentedController as? AKAddTaskViewController {
                                            presentedController.project = presenterController.project
                                        } },
                                       dismissViewCompletionTask: { (presenterController, presentedController) -> Void in
                                        if let presenterController = presenterController as? AKViewProjectViewController {
                                            // Trigger caching recomputation, because table has changed.
                                            presenterController.cachingSystem.setTriggerHeightRecomputation(controller: presenterController)
                                            
                                            // Reload all tables.
                                            Func.AKReloadTableWithAnimation(tableView: presenterController.daysTable)
                                            for customCell in presenterController.customCellArray {
                                                Func.AKReloadTableWithAnimation(tableView: customCell.tasksTable!)
                                            }
                                            
                                            // Check that at least one task was added.
                                            if DataInterface.getAllTasksInProject(project: presenterController.project).count > 0 {
                                                presenterController.hideInitialMessage(animate: true, completionTask: nil)
                                            }
                                        } })
            }
            catch {
                Func.AKPresentMessageFromError(controller: controller, message: "\(error)")
            }
        }
    }
    
    // MARK: UIView Overriding
    convenience init() { self.init(frame: CGRect.zero) }
    
    // MARK: Miscellaneous
    override func setup()
    {
        super.setup()
        
        NSLog("=> ENTERING SETUP ON FRAME: \(type(of:self))")
        
        self.getView().translatesAutoresizingMaskIntoConstraints = true
        self.getView().clipsToBounds = true
        
        self.loadComponents()
        self.applyLookAndFeel()
        self.addAnimations(expandCollapseHeight: LocalConstants.AKViewHeight)
    }
    
    func loadComponents() {}
    
    func applyLookAndFeel() {}
    
    func draw(container: UIView, coordinates: CGPoint, size: CGSize)
    {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        self.getView().frame = CGRect(
            x: coordinates.x,
            y: coordinates.y,
            width: size.width,
            height: size.height
        )
        container.addSubview(self.getView())
        CATransaction.commit()
    }
}
