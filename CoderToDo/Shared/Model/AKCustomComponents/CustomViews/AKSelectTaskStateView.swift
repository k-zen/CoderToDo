import UIKit

class AKSelectTaskStateView: AKCustomView
{
    // MARK: Constants
    struct LocalConstants {
        static let AKViewHeight: CGFloat = 179.0
        static let AKExpandHeightAnimation = "expandHeight"
        static let AKCollapseHeightAnimation = "collapseHeight"
    }
    
    // MARK: Properties
    let expandHeight = CABasicAnimation(keyPath: LocalConstants.AKExpandHeightAnimation)
    let collapseHeight = CABasicAnimation(keyPath: LocalConstants.AKCollapseHeightAnimation)
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
                        presenterController.toggleEditMode(mode: TaskMode.NOT_EDITABLE)
                    }
                    
                    presenterController?.hideContinueMessage(completionTask: { (presenterController) -> Void in }) },
                noAction: { (presenterController) -> Void in
                    presenterController?.hideContinueMessage(completionTask: { (presenterController) -> Void in }) }
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
                        presenterController.toggleEditMode(mode: TaskMode.NOT_EDITABLE)
                    }
                    
                    presenterController?.hideContinueMessage(completionTask: { (presenterController) -> Void in }) },
                noAction: { (presenterController) -> Void in
                    presenterController?.hideContinueMessage(completionTask: { (presenterController) -> Void in }) }
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
    convenience init()
    {
        NSLog("=> DEFAULT init()")
        self.init(frame: CGRect.zero)
    }
    
    override init(frame: CGRect)
    {
        NSLog("=> FRAME init()")
        super.init(frame: frame)
        setup()
    }
    
    required init(coder aDecoder: NSCoder)
    {
        NSLog("=> CODER init()")
        super.init(coder: aDecoder)!
    }
    
    // MARK: Miscellaneous
    func setup()
    {
        NSLog("=> ENTERING SETUP ON FRAME: \(type(of:self))")
        
        self.expandHeight.fromValue = 0.0
        self.expandHeight.toValue = LocalConstants.AKViewHeight
        self.expandHeight.duration = 1.0
        self.expandHeight.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        self.expandHeight.autoreverses = false
        self.getView().layer.add(self.expandHeight, forKey: LocalConstants.AKExpandHeightAnimation)
        
        self.collapseHeight.fromValue = LocalConstants.AKViewHeight
        self.collapseHeight.toValue = 0.0
        self.collapseHeight.duration = 1.0
        self.collapseHeight.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        self.collapseHeight.autoreverses = false
        self.getView().layer.add(self.collapseHeight, forKey: LocalConstants.AKCollapseHeightAnimation)
    }
}
