import UIKit

class AKSelectTaskStateView: AKCustomView, AKCustomViewProtocol
{
    // MARK: Constants
    struct LocalConstants {
        static let AKViewWidth: CGFloat = 104.0
        static let AKViewHeight: CGFloat = 179.0
    }
    
    // MARK: Properties
    var controller: AKCustomViewController?
    
    // MARK: Outlets
    @IBOutlet var mainContainer: UIView!
    
    // MARK: Actions
    @IBAction func done(_ sender: Any)
    {
        if let controller = controller as? AKViewTaskViewController {
            controller.showContinueMessage(
                message: "This action can't be undone. Continue...?",
                yesAction: { (presenterController) -> Void in
                    if let presenterController = presenterController as? AKViewTaskViewController {
                        // Change caller button.
                        presenterController.statusValue.setTitle(TaskStates.DONE.rawValue, for: .normal)
                        presenterController.changeCP.value = 100.0
                        presenterController.changeCP.isEnabled = false
                        presenterController.cpValue.text = String(format: "%.1f%%", presenterController.changeCP.value)
                        Func.AKAddBorderDeco(
                            presenterController.statusValue,
                            color: Func.AKGetColorForTaskState(taskState: TaskStates.DONE.rawValue).cgColor,
                            thickness: GlobalConstants.AKDefaultBorderThickness,
                            position: .bottom
                        )
                        // Toggle to not editable mode.
                        presenterController.markTask(mode: TaskMode.NOT_EDITABLE)
                    }
                    
                    presenterController?.hideContinueMessage(animate: true, completionTask: { (presenterController) -> Void in }) },
                noAction: { (presenterController) -> Void in
                    presenterController?.hideContinueMessage(animate: true, completionTask: { (presenterController) -> Void in }) },
                animate: true,
                completionTask: nil
            )
            
            // Collapse this view.
            controller.tap(nil)
        }
    }
    
    @IBAction func notDone(_ sender: Any)
    {
        if let controller = controller as? AKViewTaskViewController {
            // Change caller button.
            controller.statusValue.setTitle(TaskStates.NOT_DONE.rawValue, for: .normal)
            Func.AKAddBorderDeco(
                controller.statusValue,
                color: Func.AKGetColorForTaskState(taskState: TaskStates.NOT_DONE.rawValue).cgColor,
                thickness: GlobalConstants.AKDefaultBorderThickness,
                position: .bottom
            )
            
            // Collapse this view.
            controller.tap(nil)
        }
    }
    
    @IBAction func notApplicable(_ sender: Any)
    {
        if let controller = controller as? AKViewTaskViewController {
            controller.showContinueMessage(
                message: "This action can't be undone. Continue...?",
                yesAction: { (presenterController) -> Void in
                    if let presenterController = presenterController as? AKViewTaskViewController {
                        // Change caller button.
                        presenterController.statusValue.setTitle(TaskStates.NOT_APPLICABLE.rawValue, for: .normal)
                        presenterController.changeCP.value = 100.0
                        presenterController.changeCP.isEnabled = false
                        presenterController.cpValue.text = String(format: "%.1f%%", presenterController.changeCP.value)
                        Func.AKAddBorderDeco(
                            presenterController.statusValue,
                            color: Func.AKGetColorForTaskState(taskState: TaskStates.NOT_APPLICABLE.rawValue).cgColor,
                            thickness: GlobalConstants.AKDefaultBorderThickness,
                            position: .bottom
                        )
                        // Toggle to not editable mode.
                        presenterController.markTask(mode: TaskMode.NOT_EDITABLE)
                    }
                    
                    presenterController?.hideContinueMessage(animate: true, completionTask: { (presenterController) -> Void in }) },
                noAction: { (presenterController) -> Void in
                    presenterController?.hideContinueMessage(animate: true, completionTask: { (presenterController) -> Void in }) },
                animate: true,
                completionTask: nil
            )
            
            // Collapse this view.
            controller.tap(nil)
        }
    }
    
    @IBAction func dilate(_ sender: Any)
    {
        if let controller = controller as? AKViewTaskViewController {
            // Change caller button.
            controller.statusValue.setTitle(TaskStates.DILATE.rawValue, for: .normal)
            Func.AKAddBorderDeco(
                controller.statusValue,
                color: Func.AKGetColorForTaskState(taskState: TaskStates.DILATE.rawValue).cgColor,
                thickness: GlobalConstants.AKDefaultBorderThickness,
                position: .bottom
            )
            
            // Collapse this view.
            controller.tap(nil)
        }
    }
    
    @IBAction func pending(_ sender: Any)
    {
        if let controller = controller as? AKViewTaskViewController {
            // Change caller button.
            controller.statusValue.setTitle(TaskStates.PENDING.rawValue, for: .normal)
            Func.AKAddBorderDeco(
                controller.statusValue,
                color: Func.AKGetColorForTaskState(taskState: TaskStates.PENDING.rawValue).cgColor,
                thickness: GlobalConstants.AKDefaultBorderThickness,
                position: .bottom
            )
            
            // Collapse this view.
            controller.tap(nil)
        }
    }
    
    // MARK: UIView Overriding
    convenience init() { self.init(frame: CGRect.zero) }
    
    // MARK: Miscellaneous
    func setup()
    {
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
        self.getView().frame = CGRect(
            x: coordinates.x,
            y: coordinates.y,
            width: LocalConstants.AKViewWidth,
            height: size.height
        )
        container.addSubview(self.getView())
    }
}
