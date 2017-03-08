import UIKit

class AKCustomView: UIView
{
    // MARK: Constants
    private struct LocalConstants {
        static let AKExpandHeightAnimation = "expandHeight"
        static let AKCollapseHeightAnimation = "collapseHeight"
    }
    
    // MARK: Properties
    private let expandHeight = CABasicAnimation(keyPath: LocalConstants.AKExpandHeightAnimation)
    private let collapseHeight = CABasicAnimation(keyPath: LocalConstants.AKCollapseHeightAnimation)
    private var customView: UIView = UIView()
    
    // MARK: UIView Overriding
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        
        // Load NIB file.
        if let nib = Bundle.main.loadNibNamed("\(type(of: self))", owner: self, options: nil)?.first as? UIView {
            self.customView = nib
            self.customView.isUserInteractionEnabled = true
            self.addSubview(self.customView)
            
            NSLog("=> INFO: INITIALIZING CUSTOM CLASS *\(type(of: self))* VIA init(frame:)...")
        }
        else {
            NSLog("=> ERROR: FAILED TO INITIALIZE CUSTOM CLASS *\(type(of: self))* VIA init(frame:)...")
        }
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        
        // Load NIB file.
        if let nib = Bundle.main.loadNibNamed("\(type(of: self))", owner: self, options: nil)?.first as? UIView {
            self.customView = nib
            self.customView.isUserInteractionEnabled = true
            self.addSubview(self.customView)
            
            NSLog("=> INFO: INITIALIZING CUSTOM CLASS *\(type(of: self))* VIA init(coder:)...")
        }
        else {
            NSLog("=> ERROR: FAILED TO INITIALIZE CUSTOM CLASS *\(type(of: self))* VIA init(coder:)...")
        }
    }
    
    // MARK: Accessors
    internal func getView() -> UIView { return self.customView }
    
    // MARK: Animations
    internal func addAnimations(expandCollapseHeight: CGFloat)
    {
        self.expandHeight.fromValue = 0.0
        self.expandHeight.toValue = expandCollapseHeight
        self.expandHeight.duration = 1.0
        self.expandHeight.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        self.expandHeight.autoreverses = false
        self.getView().layer.add(self.expandHeight, forKey: LocalConstants.AKExpandHeightAnimation)
        
        self.collapseHeight.fromValue = expandCollapseHeight
        self.collapseHeight.toValue = 0.0
        self.collapseHeight.duration = 1.0
        self.collapseHeight.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        self.collapseHeight.autoreverses = false
        self.getView().layer.add(self.collapseHeight, forKey: LocalConstants.AKCollapseHeightAnimation)
    }
    
    internal func expand(
        controller: AKCustomViewController,
        expandHeight: CGFloat,
        animate: Bool,
        completionTask: ((_ presenterController: AKCustomViewController?) -> Void)?)
    {
        if animate {
            UIView.beginAnimations(LocalConstants.AKExpandHeightAnimation, context: nil)
            Func.AKChangeComponentHeight(component: self.getView(), newHeight: expandHeight)
            CATransaction.setCompletionBlock {
                if completionTask != nil {
                    completionTask!(controller)
                }
            }
            UIView.commitAnimations()
        }
        else {
            Func.AKChangeComponentHeight(component: self.getView(), newHeight: expandHeight)
            if completionTask != nil {
                completionTask!(controller)
            }
        }
    }
    
    internal func collapse(
        controller: AKCustomViewController,
        animate: Bool,
        completionTask: ((_ presenterController: AKCustomViewController?) -> Void)?)
    {
        if animate {
            UIView.beginAnimations(LocalConstants.AKCollapseHeightAnimation, context: nil)
            Func.AKChangeComponentHeight(component: self.getView(), newHeight: 0.0)
            CATransaction.setCompletionBlock {
                if completionTask != nil {
                    completionTask!(controller)
                }
            }
            UIView.commitAnimations()
        }
        else {
            Func.AKChangeComponentHeight(component: self.getView(), newHeight: 0.0)
            if completionTask != nil {
                completionTask!(controller)
            }
        }
    }
}
