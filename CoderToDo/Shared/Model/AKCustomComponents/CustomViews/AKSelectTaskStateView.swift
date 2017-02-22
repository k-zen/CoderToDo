import UIKit

class AKSelectTaskStateView: AKCustomView
{
    // MARK: Constants
    struct LocalConstants {
        static let AKViewHeight: CGFloat = 287.0
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
            // TODO: Implement message here that this action can't be undone.
            
            // Change caller button.
            controller.statusValue.setTitle(TaskStates.DONE.rawValue, for: .normal)
            controller.changeCP.value = 100.0
            controller.changeCP.isEnabled = false
            controller.cpValue.text = String(format: "%.1f%%", controller.changeCP.value)
            Func.AKAddBorderDeco(
                controller.statusValue,
                color: Func.AKGetColorForTaskState(taskState: TaskStates.DONE.rawValue).cgColor,
                thickness: GlobalConstants.AKDefaultBorderThickness,
                position: .bottom
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
    
    @IBAction func notAplicable(_ sender: Any)
    {
        if let controller = controller as? AKViewTaskViewController {
            // Change caller button.
            controller.statusValue.setTitle(TaskStates.NOT_APPLICABLE.rawValue, for: .normal)
            Func.AKAddBorderDeco(
                controller.statusValue,
                color: Func.AKGetColorForTaskState(taskState: TaskStates.NOT_APPLICABLE.rawValue).cgColor,
                thickness: GlobalConstants.AKDefaultBorderThickness,
                position: .bottom
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
    
    @IBAction func verify(_ sender: Any)
    {
        if let controller = controller as? AKViewTaskViewController {
            // Change caller button.
            controller.statusValue.setTitle(TaskStates.VERIFY.rawValue, for: .normal)
            Func.AKAddBorderDeco(
                controller.statusValue,
                color: Func.AKGetColorForTaskState(taskState: TaskStates.VERIFY.rawValue).cgColor,
                thickness: GlobalConstants.AKDefaultBorderThickness,
                position: .bottom
            )
            
            // Collapse this view.
            controller.tap(nil)
        }
    }
    
    @IBAction func verified(_ sender: Any)
    {
        if let controller = controller as? AKViewTaskViewController {
            // Change caller button.
            controller.statusValue.setTitle(TaskStates.VERIFIED.rawValue, for: .normal)
            Func.AKAddBorderDeco(
                controller.statusValue,
                color: Func.AKGetColorForTaskState(taskState: TaskStates.VERIFIED.rawValue).cgColor,
                thickness: GlobalConstants.AKDefaultBorderThickness,
                position: .bottom
            )
            
            // Collapse this view.
            controller.tap(nil)
        }
    }
    
    @IBAction func notVerified(_ sender: Any)
    {
        if let controller = controller as? AKViewTaskViewController {
            // Change caller button.
            controller.statusValue.setTitle(TaskStates.NOT_VERIFIED.rawValue, for: .normal)
            Func.AKAddBorderDeco(
                controller.statusValue,
                color: Func.AKGetColorForTaskState(taskState: TaskStates.NOT_VERIFIED.rawValue).cgColor,
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
        self.customView.layer.add(self.expandHeight, forKey: LocalConstants.AKExpandHeightAnimation)
        
        self.collapseHeight.fromValue = LocalConstants.AKViewHeight
        self.collapseHeight.toValue = 0.0
        self.collapseHeight.duration = 1.0
        self.collapseHeight.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        self.collapseHeight.autoreverses = false
        self.customView.layer.add(self.collapseHeight, forKey: LocalConstants.AKCollapseHeightAnimation)
    }
}
