import CoreLocation
import Foundation
import UIKit

/// Base class for all ViewControllers in the App. This custom ViewController
/// implements some basic functionalities that should be present in ViewControllers
/// throughout the App.
///
/// Functionalities:
/// 01. Handle logged in/out events.
/// 02. Handle of **Tap** gestures.
/// 03. Handle of **Pinch** gestures.
/// 04. Handle of **Rotation** gestures.
/// 05. Handle of **Swipe** gestures.
/// 06. Handle of **Pan** gestures.
/// 07. Handle of **Screen Edge Pan** gestures.
/// 08. Handle of **Long Press** gestures.
/// 09. Bottom menu.
/// 10. Handle localisation events.
///
/// - Author: Andreas P. Koenzen <akc@apkc.net>
/// - Copyright: 2017 APKC.net
/// - Date: Jan 5, 2017
class AKCustomViewController: UIViewController, UIGestureRecognizerDelegate
{
    
    // MARK: Flags
    /// Flag to add a BlurView in the background.
    var shouldAddBlurView: Bool = false
    /// Flag to inhibit only the **Tap** gesture.
    var inhibitTapGesture: Bool = false
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
    let defaultOperationsWhenGesture: (AKCustomViewController, UIGestureRecognizer?) -> Void = { (controller, gesture) -> Void in
        // Always close the keyboard if open.
        controller.view.endEditing(true)
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
    var bottomMenu: UIAlertController?
    var tapGesture: UITapGestureRecognizer?
    var pinchGesture: UIPinchGestureRecognizer?
    var rotationGesture: UIRotationGestureRecognizer?
    var swipeGesture: UISwipeGestureRecognizer?
    var panGesture: UIPanGestureRecognizer?
    var screenEdgePanGesture: UIScreenEdgePanGestureRecognizer?
    var longPressGesture: UILongPressGestureRecognizer?
    var dismissViewCompletionTask: (Void) -> Void = {}
    var localizableDictionary: NSDictionary?
    
    // MARK: UIViewController Overriding
    override func viewDidLoad()
    {
        super.viewDidLoad()
        if GlobalConstants.AKDebug {
            NSLog("=> VIEW DID LOAD ON: \(type(of: self))")
        }
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        if GlobalConstants.AKDebug {
            NSLog("=> VIEW DID APPEAR ON: \(type(of: self))")
        }
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
    
    // MARK: Initialization
    func setup()
    {
        // Manage gestures.
        self.tapGesture = UITapGestureRecognizer(target: self, action: #selector(AKCustomViewController.tap(_:)))
        self.tapGesture?.delegate = self
        self.pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(AKCustomViewController.pinch(_:)))
        self.pinchGesture?.delegate = self
        self.rotationGesture = UIRotationGestureRecognizer(target: self, action: #selector(AKCustomViewController.rotate(_:)))
        self.rotationGesture?.delegate = self
        self.swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(AKCustomViewController.swipe(_:)))
        self.swipeGesture?.delegate = self
        self.panGesture = UIPanGestureRecognizer(target: self, action: #selector(AKCustomViewController.pan(_:)))
        self.panGesture?.delegate = self
        self.screenEdgePanGesture = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(AKCustomViewController.screenEdgePan(_:)))
        self.screenEdgePanGesture?.delegate = self
        self.longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(AKCustomViewController.longPress(_:)))
        self.longPressGesture?.delegate = self
        self.view.addGestureRecognizer(self.tapGesture!)
        self.view.addGestureRecognizer(self.pinchGesture!)
        self.view.addGestureRecognizer(self.rotationGesture!)
        self.view.addGestureRecognizer(self.swipeGesture!)
        self.view.addGestureRecognizer(self.panGesture!)
        self.view.addGestureRecognizer(self.screenEdgePanGesture!)
        self.view.addGestureRecognizer(self.longPressGesture!)
        
        // Miscellaneous
        self.definesPresentationContext = true
        
        // Add BlurView.
        if self.shouldAddBlurView {
            Func.AKAddBlurView(view: self.view, effect: UIBlurEffectStyle.dark)
        }
    }
    
    func loadLocalizedText()
    {
        self.localizableDictionary = {
            if let path = Bundle.main.path(forResource: "\(type(of: self))", ofType: "plist") {
                NSLog("=> INFO: READING LOCALIZATION FILE *\(type(of: self)).plist*...")
                
                return NSDictionary(contentsOfFile: path)
            }
            
            return nil
        }()
    }
    
    func setupMenu(_ title: String!, message: String!, type: UIAlertControllerStyle!)
    {
        self.bottomMenu = UIAlertController(title: title, message: message, preferredStyle: type)
    }
    
    func addMenuAction(_ title: String!, style: UIAlertActionStyle, handler: ((UIAlertAction) -> Void)?)
    {
        if let menu = self.bottomMenu {
            menu.addAction(UIAlertAction(title: title, style: style, handler: handler))
        }
    }
    
    // MARK: Presenters
    func showMenu()
    {
        if let menu = self.bottomMenu {
            self.present(menu, animated: true, completion: nil)
        }
    }
    
    func presentView(controller: AKCustomViewController,
                     dismissViewCompletionTask: @escaping (_ presenterController: AKCustomViewController, _ presentedController: AKCustomViewController) -> Void)
    {
        controller.dismissViewCompletionTask = { dismissViewCompletionTask(self, controller) }
        controller.modalTransitionStyle = GlobalConstants.AKDefaultTransitionStyle
        controller.modalPresentationStyle = .overFullScreen
        
        self.present(controller, animated: true, completion: nil)
    }
    
    // MARK: Gesture Handling
    @objc internal func tap(_ gesture: UIGestureRecognizer?)
    {
        NSLog("=> TAP GESTURE DETECTED... DOING SOMETHING...")
        self.defaultOperationsWhenGesture(self, gesture)
        self.additionalOperationsWhenTaped(gesture)
    }
    
    @objc internal func pinch(_ gesture: UIGestureRecognizer?)
    {
        NSLog("=> PINCH GESTURE DETECTED... DOING SOMETHING...")
        self.defaultOperationsWhenGesture(self, gesture)
        self.additionalOperationsWhenPinched(gesture)
    }
    
    @objc internal func rotate(_ gesture: UIGestureRecognizer?)
    {
        NSLog("=> ROTATION GESTURE DETECTED... DOING SOMETHING...")
        self.defaultOperationsWhenGesture(self, gesture)
        self.additionalOperationsWhenRotated(gesture)
    }
    
    @objc internal func swipe(_ gesture: UIGestureRecognizer?)
    {
        NSLog("=> SWIPE GESTURE DETECTED... DOING SOMETHING...")
        self.defaultOperationsWhenGesture(self, gesture)
        self.additionalOperationsWhenSwiped(gesture)
    }
    
    @objc internal func pan(_ gesture: UIGestureRecognizer?)
    {
        NSLog("=> PAN GESTURE DETECTED... DOING SOMETHING...")
        self.defaultOperationsWhenGesture(self, gesture)
        self.additionalOperationsWhenPaned(gesture)
    }
    
    @objc internal func screenEdgePan(_ gesture: UIGestureRecognizer?)
    {
        NSLog("=> SCREEN EDGE PAN GESTURE DETECTED... DOING SOMETHING...")
        self.defaultOperationsWhenGesture(self, gesture)
        self.additionalOperationsWhenScreenEdgePaned(gesture)
    }
    
    @objc internal func longPress(_ gesture: UIGestureRecognizer?)
    {
        NSLog("=> LONG PRESS GESTURE DETECTED... DOING SOMETHING...")
        self.defaultOperationsWhenGesture(self, gesture)
        self.additionalOperationsWhenLongPressed(gesture)
    }
    
    // MARK: Utility functions
    func dismissView(executeDismissTask: Bool)
    {
        OperationQueue.main.addOperation {
            if executeDismissTask {
                self.dismiss(animated: true, completion: self.dismissViewCompletionTask)
            }
            else {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    func localize(key: String) -> Any?
    {
        var response: Any?
        if let val = self.localizableDictionary?.value(forKey: key) {
            response = val
        }
        else {
            assertionFailure("=> ERROR: MISSING TRANSLATION FOR: \(key)")
        }
        
        return response
    }
}
