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
    /// Flag to make local notification's check on each ViewController.
    /// Default value is **true**, each ViewController must explicitly enable the check.
    var inhibitLocalNotificationMessage: Bool = true
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
        // Always collapse the message view.
        controller.hideMessage()
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
    // Overlay Controllers
    let messageOverlayController = AKMessageView()
    var messageOverlayView: UIView!
    let continueMessageOverlayController = AKContinueMessageView()
    var continueMessageOverlayView: UIView!
    let topMenuOverlayController = AKTopMenuView()
    var topMenuOverlayView: UIView!
    
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
        
        // Checks
        if !self.inhibitLocalNotificationMessage {
            self.manageGrantToLocalNotifications()
        }
        
        // Persist to disk data each time a view controller appears.
        AKMasterReference.saveData(instance: Func.AKObtainMasterReference())
    }
    
    override func viewDidLayoutSubviews()
    {
        super.viewDidLayoutSubviews()
        
        // Setup the overlays.
        var origin = self.view.frame.width / 2.0 - (AKMessageView.LocalConstants.AKViewWidth / 2.0)
        self.messageOverlayView = self.messageOverlayController.customView
        self.messageOverlayController.controller = self
        self.messageOverlayView.frame = CGRect(
            x: origin,
            y: 40.0,
            width: AKMessageView.LocalConstants.AKViewWidth,
            height: 0.0
        )
        self.messageOverlayView.translatesAutoresizingMaskIntoConstraints = true
        self.messageOverlayView.clipsToBounds = true
        self.messageOverlayView.layer.cornerRadius = GlobalConstants.AKViewCornerRadius
        self.messageOverlayView.layer.borderWidth = CGFloat(GlobalConstants.AKDefaultBorderThickness)
        self.messageOverlayView.layer.borderColor = GlobalConstants.AKDefaultViewBorderBg.cgColor
        self.view.addSubview(self.messageOverlayView)
        
        origin = self.view.frame.width / 2.0 - (AKContinueMessageView.LocalConstants.AKViewWidth / 2.0)
        self.continueMessageOverlayView = self.continueMessageOverlayController.customView
        self.continueMessageOverlayController.controller = self
        self.continueMessageOverlayView.frame = CGRect(
            x: origin,
            y: 40.0,
            width: AKContinueMessageView.LocalConstants.AKViewWidth,
            height: 0.0
        )
        self.continueMessageOverlayView.translatesAutoresizingMaskIntoConstraints = true
        self.continueMessageOverlayView.clipsToBounds = true
        self.continueMessageOverlayView.layer.cornerRadius = GlobalConstants.AKViewCornerRadius
        self.continueMessageOverlayView.layer.borderWidth = CGFloat(GlobalConstants.AKDefaultBorderThickness)
        self.continueMessageOverlayView.layer.borderColor = GlobalConstants.AKDefaultViewBorderBg.cgColor
        self.view.addSubview(self.continueMessageOverlayView)
        
        self.topMenuOverlayView = self.topMenuOverlayController.customView
        self.topMenuOverlayController.controller = self
        self.topMenuOverlayView.frame = CGRect(
            x: 0.0,
            y: 0.0,
            width: self.view.frame.width,
            height: 0.0
        )
        self.topMenuOverlayView.translatesAutoresizingMaskIntoConstraints = true
        self.topMenuOverlayView.clipsToBounds = true
        self.view.addSubview(self.topMenuOverlayView)
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
    
    func setupBottomMenu(_ title: String!, message: String!, type: UIAlertControllerStyle!)
    {
        self.bottomMenu = UIAlertController(title: title, message: message, preferredStyle: type)
    }
    
    func addBottomMenuAction(_ title: String!, style: UIAlertActionStyle, handler: ((UIAlertAction) -> Void)?)
    {
        if let menu = self.bottomMenu {
            menu.addAction(UIAlertAction(title: title, style: style, handler: handler))
        }
    }
    
    // MARK: Presenters
    func showBottomMenu()
    {
        if let menu = self.bottomMenu {
            self.present(menu, animated: true, completion: nil)
        }
    }
    
    func presentView(controller: AKCustomViewController,
                     taskBeforePresenting: @escaping (_ presenterController: AKCustomViewController, _ presentedController: AKCustomViewController) -> Void,
                     dismissViewCompletionTask: @escaping (_ presenterController: AKCustomViewController, _ presentedController: AKCustomViewController) -> Void)
    {
        controller.dismissViewCompletionTask = { dismissViewCompletionTask(self, controller) }
        controller.modalTransitionStyle = GlobalConstants.AKDefaultTransitionStyle
        controller.modalPresentationStyle = .overFullScreen
        
        taskBeforePresenting(self, controller)
        
        self.present(controller, animated: true, completion: nil)
    }
    
    func showMessage(message: String)
    {
        self.messageOverlayController.message.text = message
        
        UIView.beginAnimations(AKMessageView.LocalConstants.AKExpandHeightAnimation, context: nil)
        let origin = self.view.bounds.width / 2.0 - (AKMessageView.LocalConstants.AKViewWidth / 2.0)
        self.messageOverlayView.frame = CGRect(
            x: origin,
            y: 40.0,
            width: AKMessageView.LocalConstants.AKViewWidth,
            height: AKMessageView.LocalConstants.AKViewHeight
        )
        UIView.commitAnimations()
    }
    
    func showContinueMessage(message: String,
                             yesButtonTitle: String = "Yes",
                             noButtonTitle: String = "No",
                             yesAction: @escaping (_ presenterController: AKCustomViewController?) -> Void,
                             noAction: @escaping (_ presenterController: AKCustomViewController?) -> Void)
    {
        self.continueMessageOverlayController.message.text = message
        self.continueMessageOverlayController.yes.setTitle(yesButtonTitle, for: .normal)
        self.continueMessageOverlayController.no.setTitle(noButtonTitle, for: .normal)
        self.continueMessageOverlayController.yesAction = yesAction
        self.continueMessageOverlayController.noAction = noAction
        
        UIView.beginAnimations(AKContinueMessageView.LocalConstants.AKExpandHeightAnimation, context: nil)
        let origin = self.view.bounds.width / 2.0 - (AKContinueMessageView.LocalConstants.AKViewWidth / 2.0)
        self.continueMessageOverlayView.frame = CGRect(
            x: origin,
            y: 40.0,
            width: AKContinueMessageView.LocalConstants.AKViewWidth,
            height: AKContinueMessageView.LocalConstants.AKViewHeight
        )
        UIView.commitAnimations()
    }
    
    func showTopMenu()
    {
        UIView.beginAnimations(AKTopMenuView.LocalConstants.AKExpandHeightAnimation, context: nil)
        self.topMenuOverlayView.frame = CGRect(
            x: 0.0,
            y: 0.0,
            width: self.topMenuOverlayView.frame.width,
            height: AKTopMenuView.LocalConstants.AKViewHeight
        )
        UIView.commitAnimations()
    }
    
    func hideMessage()
    {
        UIView.beginAnimations(AKMessageView.LocalConstants.AKCollapseHeightAnimation, context: nil)
        let origin = self.view.bounds.width / 2.0 - (AKMessageView.LocalConstants.AKViewWidth / 2.0)
        self.messageOverlayView.frame = CGRect(
            x: origin,
            y: 40.0,
            width: AKMessageView.LocalConstants.AKViewWidth,
            height: 0.0
        )
        UIView.commitAnimations()
    }
    
    func hideContinueMessage(completionTask: @escaping (_ presenterController: AKCustomViewController?) -> Void)
    {
        UIView.beginAnimations(AKContinueMessageView.LocalConstants.AKCollapseHeightAnimation, context: nil)
        let origin = self.view.bounds.width / 2.0 - (AKContinueMessageView.LocalConstants.AKViewWidth / 2.0)
        self.continueMessageOverlayView.frame = CGRect(
            x: origin,
            y: 40.0,
            width: AKContinueMessageView.LocalConstants.AKViewWidth,
            height: 0.0
        )
        CATransaction.setCompletionBlock {
            completionTask(self)
        }
        UIView.commitAnimations()
    }
    
    func hideTopMenu()
    {
        UIView.beginAnimations(AKTopMenuView.LocalConstants.AKCollapseHeightAnimation, context: nil)
        self.topMenuOverlayView.frame = CGRect(
            x: 0.0,
            y: 0.0,
            width: self.topMenuOverlayView.frame.width,
            height: 0.0
        )
        UIView.commitAnimations()
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
    func manageGrantToLocalNotifications()
    {
        Func.AKGetNotificationCenter().requestAuthorization(options: [.alert, .sound]) { (granted, error) in
            if !granted {
                Func.AKExecuteInMainThread {
                    self.showContinueMessage(
                        message: "CoderToDo needs to be able to send you local notifications in order to alert you about project times. Go to \"Settings\" to enable it.",
                        yesButtonTitle: "Open Settings",
                        noButtonTitle: "No",
                        yesAction: { (presenterController) -> Void in
                            presenterController?.hideContinueMessage(completionTask: { (presenterController) -> Void in
                                if let url = URL(string:UIApplicationOpenSettingsURLString) {
                                    Func.AKDelay(0.0, task: { () in UIApplication.shared.open(url, options: [:], completionHandler: nil) })
                                }
                            }) },
                        noAction: { (presenterController) -> Void in
                            presenterController?.hideContinueMessage(completionTask: { (presenterController) -> Void in
                                // TODO: Make this setting persistent.
                                presenterController?.inhibitLocalNotificationMessage = true
                            }) }
                    )
                }
            }
            else {
                NSLog("=> INFO: USER HAS AUTHORIZED LOCAL NOTIFICATIONS.")
            }
        }
    }
    
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
