import UIKit

class AKCustomView: UIView, UIGestureRecognizerDelegate
{
    // MARK: Constants
    private struct LocalConstants {
        static let AKExpandHeightAnimation = "expandHeight"
        static let AKCollapseHeightAnimation = "collapseHeight"
    }
    
    // MARK: Flags
    /// Flag to inhibit only the **Tap** gesture.
    var inhibitTapGesture: Bool = true
    /// Flag to inhibit only the **Pinch** gesture.
    var inhibitPinchGesture: Bool = true
    /// Flag to inhibit only the **Rotation** gesture.
    var inhibitRotationGesture: Bool = true
    /// Flag to inhibit only the **Swipe** gesture.
    var inhibitSwipeGesture: Bool = true
    /// Flag to inhibit only the **Pan** gesture.
    var inhibitPanGesture: Bool = true
    /// Flag to inhibit only the **Screen Edge Pan** gesture.
    /// MUST BE ENABLED WITH **inhibitPanGesture** and an edge
    /// must be set.
    var inhibitScreenEdgePanGesture: Bool = true
    /// Flag to inhibit only the **Long Press** gesture.
    var inhibitLongPressGesture: Bool = true
    // MARK: Operations (Closures)
    /// Defaults actions when a gesture event is produced. Not modifiable by child classes.
    let defaultOperationsWhenGesture: (AKCustomViewController?, UIGestureRecognizer?) -> Void = { (controller, gesture) -> Void in
        // Always close the keyboard if open.
        controller?.view.endEditing(true)
        // Always collapse the message view.
        controller?.hideMessage(
            animate: true,
            completionTask: nil
        )
    }
    /// Operations to perform when a **Tap** gesture is detected.
    var additionalOperationsWhenTaped: (UIGestureRecognizer?) -> Void = { (gesture) -> Void in }
    /// Operations to perform when a **Pinch** gesture is detected.
    var additionalOperationsWhenPinched: (UIGestureRecognizer?) -> Void = { (gesture) -> Void in }
    /// Operations to perform when a **Rotation** gesture is detected.
    var additionalOperationsWhenRotated: (UIGestureRecognizer?) -> Void = { (gesture) -> Void in }
    /// Operations to perform when a **Swiped** gesture is detected.
    var additionalOperationsWhenSwiped: (UIGestureRecognizer?) -> Void = { (gesture) -> Void in }
    /// Operations to perform when a **Pan** gesture is detected.
    var additionalOperationsWhenPaned: (UIGestureRecognizer?) -> Void = { (gesture) -> Void in }
    /// Operations to perform when a **Screen Edge Pan** gesture is detected.
    var additionalOperationsWhenScreenEdgePaned: (UIGestureRecognizer?) -> Void = { (gesture) -> Void in }
    /// Operations to perform when a **Long Press** gesture is detected.
    var additionalOperationsWhenLongPressed: (UIGestureRecognizer?) -> Void = { (gesture) -> Void in }
    
    // MARK: Properties
    private let expandHeight = CABasicAnimation(keyPath: LocalConstants.AKExpandHeightAnimation)
    private let collapseHeight = CABasicAnimation(keyPath: LocalConstants.AKCollapseHeightAnimation)
    private var customView: UIView = UIView()
    var tapGesture: UITapGestureRecognizer?
    var pinchGesture: UIPinchGestureRecognizer?
    var rotationGesture: UIRotationGestureRecognizer?
    var swipeGesture: UISwipeGestureRecognizer?
    var panGesture: UIPanGestureRecognizer?
    var screenEdgePanGesture: UIScreenEdgePanGestureRecognizer?
    var longPressGesture: UILongPressGestureRecognizer?
    var controller: AKCustomViewController?
    
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
    
    // MARK: Miscellaneous
    func setup()
    {
        // Manage gestures.
        self.tapGesture = UITapGestureRecognizer(target: self, action: #selector(AKCustomView.tap(_:)))
        self.tapGesture?.delegate = self
        self.pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(AKCustomView.pinch(_:)))
        self.pinchGesture?.delegate = self
        self.rotationGesture = UIRotationGestureRecognizer(target: self, action: #selector(AKCustomView.rotate(_:)))
        self.rotationGesture?.delegate = self
        self.swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(AKCustomView.swipe(_:)))
        self.swipeGesture?.delegate = self
        self.panGesture = UIPanGestureRecognizer(target: self, action: #selector(AKCustomView.pan(_:)))
        self.panGesture?.delegate = self
        self.screenEdgePanGesture = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(AKCustomView.screenEdgePan(_:)))
        self.screenEdgePanGesture?.delegate = self
        self.longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(AKCustomView.longPress(_:)))
        self.longPressGesture?.delegate = self
        self.getView().addGestureRecognizer(self.tapGesture!)
        self.getView().addGestureRecognizer(self.pinchGesture!)
        self.getView().addGestureRecognizer(self.rotationGesture!)
        self.getView().addGestureRecognizer(self.swipeGesture!)
        self.getView().addGestureRecognizer(self.panGesture!)
        self.getView().addGestureRecognizer(self.screenEdgePanGesture!)
        self.getView().addGestureRecognizer(self.longPressGesture!)
    }
    
    // MARK: UIGestureRecognizerDelegate Implementation
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool
    {
        if gestureRecognizer.isKind(of: UITapGestureRecognizer.self) {
            return !self.inhibitTapGesture
        }
        else if gestureRecognizer.isKind(of: UIPinchGestureRecognizer.self) {
            return !self.inhibitPinchGesture
        }
        else if gestureRecognizer.isKind(of: UIRotationGestureRecognizer.self) {
            return !self.inhibitRotationGesture
        }
        else if gestureRecognizer.isKind(of: UISwipeGestureRecognizer.self) {
            return !self.inhibitSwipeGesture
        }
        else if gestureRecognizer.isKind(of: UIPanGestureRecognizer.self) {
            return !self.inhibitPanGesture
        }
        else if gestureRecognizer.isKind(of: UIScreenEdgePanGestureRecognizer.self) {
            return !self.inhibitScreenEdgePanGesture
        }
        else if gestureRecognizer.isKind(of: UILongPressGestureRecognizer.self) {
            return !self.inhibitLongPressGesture
        }
        else {
            return false // By default disable all gestures!
        }
    }
    
    // MARK: Gesture Handling
    @objc internal func tap(_ gesture: UIGestureRecognizer?)
    {
        NSLog("=> TAP GESTURE DETECTED... DOING SOMETHING...")
        self.defaultOperationsWhenGesture(self.controller, gesture)
        self.additionalOperationsWhenTaped(gesture)
    }
    
    @objc internal func pinch(_ gesture: UIGestureRecognizer?)
    {
        NSLog("=> PINCH GESTURE DETECTED... DOING SOMETHING...")
        self.defaultOperationsWhenGesture(self.controller, gesture)
        self.additionalOperationsWhenPinched(gesture)
    }
    
    @objc internal func rotate(_ gesture: UIGestureRecognizer?)
    {
        NSLog("=> ROTATION GESTURE DETECTED... DOING SOMETHING...")
        self.defaultOperationsWhenGesture(self.controller, gesture)
        self.additionalOperationsWhenRotated(gesture)
    }
    
    @objc internal func swipe(_ gesture: UIGestureRecognizer?)
    {
        NSLog("=> SWIPE GESTURE DETECTED... DOING SOMETHING...")
        self.defaultOperationsWhenGesture(self.controller, gesture)
        self.additionalOperationsWhenSwiped(gesture)
    }
    
    @objc internal func pan(_ gesture: UIGestureRecognizer?)
    {
        NSLog("=> PAN GESTURE DETECTED... DOING SOMETHING...")
        self.defaultOperationsWhenGesture(self.controller, gesture)
        self.additionalOperationsWhenPaned(gesture)
    }
    
    @objc internal func screenEdgePan(_ gesture: UIGestureRecognizer?)
    {
        NSLog("=> SCREEN EDGE PAN GESTURE DETECTED... DOING SOMETHING...")
        self.defaultOperationsWhenGesture(self.controller, gesture)
        self.additionalOperationsWhenScreenEdgePaned(gesture)
    }
    
    @objc internal func longPress(_ gesture: UIGestureRecognizer?)
    {
        NSLog("=> LONG PRESS GESTURE DETECTED... DOING SOMETHING...")
        self.defaultOperationsWhenGesture(self.controller, gesture)
        self.additionalOperationsWhenLongPressed(gesture)
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
