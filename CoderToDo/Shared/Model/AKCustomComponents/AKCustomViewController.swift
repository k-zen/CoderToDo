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
    // MARK: Constants
    struct LocalConstants {
        static let AKDisplaceDownAnimation = "displaceDown"
        static let AKDisplaceUpAnimation = "displaceUp"
    }
    
    // MARK: Flags
    /// Flag to make local notification's check on each ViewController.
    /// Default value is **true**, each ViewController must explicitly enable the check.
    var inhibitLocalNotificationMessage: Bool = true
    /// Flag to make iCloud's check on each ViewController.
    /// Default value is **true**, each ViewController must explicitly enable the check.
    var inhibitiCloudMessage: Bool = true
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
        controller.hideMessage(
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
    var iCloudAccessErrorAction: (AKCustomViewController?) -> Void = { (presenterController) -> Void in }
    var iCloudAccessAvailableAction: (AKCustomViewController?) -> Void = { (presenterController) -> Void in }
    // Overlay Controllers
    let messageOverlay = AKMessageView()
    let continueMessageOverlay = AKContinueMessageView()
    let topMenuOverlay = AKTopMenuView()
    let addMenuItemOverlay = AKAddView()
    let sortMenuItemOverlay = AKSortView()
    let filterMenuItemOverlay = AKFilterView()
    let searchMenuItemOverlay = AKSearchView()
    let addBucketEntryOverlay = AKAddBucketEntryView()
    let migrateBucketEntryOverlay = AKMigrateBucketEntryView()
    // Menu
    var selectedMenuItem: MenuItems = .none
    var isMenuVisible: Bool = false
    var isMenuItemVisible: Bool = false
    
    // MARK: Animations
    let displaceDownProjectsTable = CABasicAnimation(keyPath: LocalConstants.AKDisplaceDownAnimation)
    let displaceUpProjectsTable = CABasicAnimation(keyPath: LocalConstants.AKDisplaceUpAnimation)
    
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
        if !self.inhibitLocalNotificationMessage && (DataInterface.getConfigurations()?.showLocalNotificationMessage ?? true) {
            self.manageGrantToLocalNotifications()
        }
        if !self.inhibitiCloudMessage {
            self.manageGrantToiCloud()
        }
        
        // Persist to disk data each time a view controller appears.
        AKMasterReference.saveData(instance: Func.AKObtainMasterReference())
    }
    
    override func viewDidLayoutSubviews()
    {
        super.viewDidLayoutSubviews()
        
        // Setup the overlays.
        self.messageOverlay.controller = self
        self.messageOverlay.setup()
        self.messageOverlay.draw(
            container: self.view,
            coordinates: CGPoint.zero,
            size: CGSize.zero
        )
        
        self.continueMessageOverlay.controller = self
        self.continueMessageOverlay.setup()
        self.continueMessageOverlay.draw(
            container: self.view,
            coordinates: CGPoint.zero,
            size: CGSize.zero
        )
        
        self.topMenuOverlay.controller = self
        self.topMenuOverlay.setup()
        self.topMenuOverlay.draw(
            container: self.view,
            coordinates: CGPoint.zero,
            size: CGSize(width: self.view.frame.width, height: 0.0)
        )
        
        self.addMenuItemOverlay.controller = self
        self.addMenuItemOverlay.setup()
        self.addMenuItemOverlay.draw(
            container: self.view,
            coordinates: CGPoint(x: 0.0, y: AKTopMenuView.LocalConstants.AKViewHeight),
            size: CGSize(width: self.view.frame.width, height: 0.0)
        )
        
        self.sortMenuItemOverlay.controller = self
        self.sortMenuItemOverlay.setup()
        self.sortMenuItemOverlay.draw(
            container: self.view,
            coordinates: CGPoint(x: 0.0, y: AKTopMenuView.LocalConstants.AKViewHeight),
            size: CGSize(width: self.view.frame.width, height: 0.0)
        )
        
        self.filterMenuItemOverlay.controller = self
        self.filterMenuItemOverlay.setup()
        self.filterMenuItemOverlay.draw(
            container: self.view,
            coordinates: CGPoint(x: 0.0, y: AKTopMenuView.LocalConstants.AKViewHeight),
            size: CGSize(width: self.view.frame.width, height: 0.0)
        )
        
        self.searchMenuItemOverlay.controller = self
        self.searchMenuItemOverlay.setup()
        self.searchMenuItemOverlay.draw(
            container: self.view,
            coordinates: CGPoint(x: 0.0, y: AKTopMenuView.LocalConstants.AKViewHeight),
            size: CGSize(width: self.view.frame.width, height: 0.0)
        )
        
        self.addBucketEntryOverlay.controller = self
        self.addBucketEntryOverlay.setup()
        self.addBucketEntryOverlay.draw(
            container: self.view,
            coordinates: CGPoint.zero,
            size: CGSize.zero
        )
        
        self.migrateBucketEntryOverlay.controller = self
        self.migrateBucketEntryOverlay.setup()
        self.migrateBucketEntryOverlay.draw(
            container: self.view,
            coordinates: CGPoint.zero,
            size: CGSize.zero
        )
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
    
    // MARK: Floating Views
    func showMessage(
        message: String,
        autoDismiss: Bool = false,
        animate: Bool,
        completionTask: ((_ presenterController: AKCustomViewController?) -> Void)?)
    {
        self.messageOverlay.message.text = message
        self.messageOverlay.expand(
            controller: self,
            expandHeight: AKMessageView.LocalConstants.AKViewHeight,
            animate: animate,
            completionTask: completionTask
        )
        
        if autoDismiss {
            Func.AKDelay(GlobalConstants.AKAutoDismissMessageTime, isMain: true, task: {
                self.hideMessage(
                    animate: animate,
                    completionTask: completionTask
                )
            })
        }
    }
    
    func showContinueMessage(message: String,
                             yesButtonTitle: String = "Yes",
                             noButtonTitle: String = "No",
                             yesAction: ((_ presenterController: AKCustomViewController?) -> Void)?,
                             noAction: ((_ presenterController: AKCustomViewController?) -> Void)?,
                             animate: Bool,
                             completionTask: ((_ presenterController: AKCustomViewController?) -> Void)?)
    {
        self.continueMessageOverlay.message.text = message
        self.continueMessageOverlay.yes.setTitle(yesButtonTitle, for: .normal)
        self.continueMessageOverlay.no.setTitle(noButtonTitle, for: .normal)
        self.continueMessageOverlay.yesAction = yesAction
        self.continueMessageOverlay.noAction = noAction
        self.continueMessageOverlay.expand(
            controller: self,
            expandHeight: AKContinueMessageView.LocalConstants.AKViewHeight,
            animate: animate,
            completionTask: completionTask
        )
    }
    
    func showTopMenu(
        animate: Bool,
        completionTask: ((_ presenterController: AKCustomViewController?) -> Void)?)
    {
        self.topMenuOverlay.expand(
            controller: self,
            expandHeight: AKTopMenuView.LocalConstants.AKViewHeight,
            animate: animate,
            completionTask: completionTask
        )
    }
    
    func showAddMenuItem(
        animate: Bool,
        completionTask: ((_ presenterController: AKCustomViewController?) -> Void)?)
    {
        self.addMenuItemOverlay.expand(controller: self,
                                       expandHeight: AKAddView.LocalConstants.AKViewHeight,
                                       animate: animate,
                                       completionTask: completionTask
        )
    }
    
    func showSortMenuItem(
        animate: Bool,
        completionTask: ((_ presenterController: AKCustomViewController?) -> Void)?)
    {
        self.sortMenuItemOverlay.expand(controller: self,
                                        expandHeight: AKSortView.LocalConstants.AKViewHeight,
                                        animate: animate,
                                        completionTask: completionTask
        )
    }
    
    func showFilterMenuItem(
        animate: Bool,
        completionTask: ((_ presenterController: AKCustomViewController?) -> Void)?)
    {
        self.filterMenuItemOverlay.expand(
            controller: self,
            expandHeight: AKFilterView.LocalConstants.AKViewHeight,
            animate: animate,
            completionTask: completionTask
        )
    }
    
    func showSearchMenuItem(
        animate: Bool,
        completionTask: ((_ presenterController: AKCustomViewController?) -> Void)?)
    {
        self.searchMenuItemOverlay.expand(
            controller: self,
            expandHeight: AKSearchView.LocalConstants.AKViewHeight,
            animate: animate,
            completionTask: completionTask
        )
    }
    
    func showAddBucketEntry(
        animate: Bool,
        completionTask: ((_ presenterController: AKCustomViewController?) -> Void)?)
    {
        self.addBucketEntryOverlay.expand(
            controller: self,
            expandHeight: AKAddBucketEntryView.LocalConstants.AKViewHeight,
            animate: animate,
            completionTask: completionTask
        )
    }
    
    func showMigrateBucketEntry(
        animate: Bool,
        completionTask: ((_ presenterController: AKCustomViewController?) -> Void)?)
    {
        self.migrateBucketEntryOverlay.expand(
            controller: self,
            expandHeight: AKMigrateBucketEntryView.LocalConstants.AKViewHeight,
            animate: animate,
            completionTask: completionTask
        )
    }
    
    func hideMessage(
        animate: Bool,
        completionTask: ((_ presenterController: AKCustomViewController?) -> Void)?)
    {
        self.messageOverlay.collapse(
            controller: self,
            animate: animate,
            completionTask: completionTask
        )
    }
    
    func hideContinueMessage(
        animate: Bool,
        completionTask: ((_ presenterController: AKCustomViewController?) -> Void)?)
    {
        self.continueMessageOverlay.collapse(
            controller: self,
            animate: animate,
            completionTask: completionTask
        )
    }
    
    func hideTopMenu(
        animate: Bool,
        completionTask: ((_ presenterController: AKCustomViewController?) -> Void)?)
    {
        self.topMenuOverlay.collapse(
            controller: self,
            animate: animate,
            completionTask: completionTask
        )
    }
    
    func hideAddMenuItem(
        animate: Bool,
        completionTask: ((_ presenterController: AKCustomViewController?) -> Void)?)
    {
        self.addMenuItemOverlay.collapse(
            controller: self,
            animate: animate,
            completionTask: completionTask
        )
    }
    
    func hideSortMenuItem(
        animate: Bool,
        completionTask: ((_ presenterController: AKCustomViewController?) -> Void)?)
    {
        self.sortMenuItemOverlay.collapse(
            controller: self,
            animate: animate,
            completionTask: completionTask
        )
    }
    
    func hideFilterMenuItem(
        animate: Bool,
        completionTask: ((_ presenterController: AKCustomViewController?) -> Void)?)
    {
        self.filterMenuItemOverlay.collapse(
            controller: self,
            animate: animate,
            completionTask: completionTask
        )
    }
    
    func hideSearchMenuItem(
        animate: Bool,
        completionTask: ((_ presenterController: AKCustomViewController?) -> Void)?)
    {
        self.searchMenuItemOverlay.collapse(
            controller: self,
            animate: animate,
            completionTask: completionTask
        )
    }
    
    func hideAddBucketEntry(
        animate: Bool,
        completionTask: ((_ presenterController: AKCustomViewController?) -> Void)?)
    {
        self.addBucketEntryOverlay.collapse(
            controller: self,
            animate: animate,
            completionTask: completionTask
        )
    }
    
    func hideMigrateBucketEntry(
        animate: Bool,
        completionTask: ((_ presenterController: AKCustomViewController?) -> Void)?)
    {
        self.migrateBucketEntryOverlay.collapse(
            controller: self,
            animate: animate,
            completionTask: completionTask
        )
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
                Func.AKExecuteInMainThread(controller: self, mode: .sync, code: { (controller) -> Void in
                    controller?.showContinueMessage(
                        message: "CoderToDo needs to be able to send you local notifications in order to alert you about project times. Go to \"Settings\" to enable it.",
                        yesButtonTitle: "Open Settings",
                        noButtonTitle: "No",
                        yesAction: { (presenterController) -> Void in
                            if let url = URL(string: UIApplicationOpenSettingsURLString) {
                                Func.AKDelay(0.0, task: { () in UIApplication.shared.open(url, options: [:], completionHandler: nil) })
                            } },
                        noAction: { (presenterController) -> Void in
                            let configurationsMO = DataInterface.getConfigurations()
                            if var configurations = AKConfigurationsBuilder.from(configurations: configurationsMO) {
                                configurations.showLocalNotificationMessage = false
                                DataInterface.addConfigurations(configurations: AKConfigurationsBuilder.to(configurations: configurationsMO, from: configurations))
                            } },
                        animate: true,
                        completionTask: nil
                    )
                })
            }
            else {
                NSLog("=> INFO: USER HAS AUTHORIZED LOCAL NOTIFICATIONS.")
            }
        }
    }
    
    func manageGrantToiCloud()
    {
        Func.AKGetCloudKitContainer().accountStatus(completionHandler: { (accountStatus, error) -> Void in
            Func.AKExecuteInMainThread(controller: self, mode: .async, code: { (controller) -> Void in
                guard error == nil else {
                    controller?.iCloudAccessErrorAction(controller)
                    return
                }
                
                switch accountStatus {
                case .available:
                    controller?.iCloudAccessAvailableAction(controller)
                    break
                default:
                    controller?.showContinueMessage(
                        message: "You need to be signed into iCloud and have *iCloud Drive* set to on. Go to *Settings -> iCloud* to enable it.",
                        yesButtonTitle: "Open Settings",
                        noButtonTitle: "No",
                        yesAction: { (presenterController) -> Void in
                            if let url = URL(string: UIApplicationOpenSettingsURLString) {
                                Func.AKDelay(0.0, task: { () in UIApplication.shared.open(url, options: [:], completionHandler: nil) })
                            } },
                        noAction: nil,
                        animate: true,
                        completionTask: nil
                    )
                    break
                }
            })
        })
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
    
    // MARK: Animations
    func configureAnimations(displacementHeight: CGFloat)
    {
        self.displaceDownProjectsTable.fromValue = 0.0
        self.displaceDownProjectsTable.toValue = displacementHeight
        self.displaceDownProjectsTable.duration = 1.0
        self.displaceDownProjectsTable.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        self.displaceDownProjectsTable.autoreverses = false
        self.view.layer.add(self.displaceDownProjectsTable, forKey: LocalConstants.AKDisplaceDownAnimation)
        
        self.displaceUpProjectsTable.fromValue = displacementHeight
        self.displaceUpProjectsTable.toValue = 0.0
        self.displaceUpProjectsTable.duration = 1.0
        self.displaceUpProjectsTable.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        self.displaceUpProjectsTable.autoreverses = false
        self.view.layer.add(self.displaceUpProjectsTable, forKey: LocalConstants.AKDisplaceUpAnimation)
    }
    
    func displaceDownTable(
        tableView: UITableView,
        offset: CGFloat,
        animate: Bool,
        completionTask: ((_ presenterController: AKCustomViewController?) -> Void)?)
    {
        self.isMenuVisible = true
        self.showTopMenu(animate: animate, completionTask: completionTask)
        
        if animate {
            UIView.beginAnimations(LocalConstants.AKDisplaceDownAnimation, context: nil)
            Func.AKChangeComponentYPosition(component: tableView, newY: tableView.frame.origin.y + offset)
            Func.AKChangeComponentHeight(component: tableView, newHeight: tableView.frame.height - offset)
            UIView.commitAnimations()
        }
        else {
            Func.AKChangeComponentYPosition(component: tableView, newY: tableView.frame.origin.y + offset)
            Func.AKChangeComponentHeight(component: tableView, newHeight: tableView.frame.height - offset)
        }
    }
    
    func displaceUpTable(
        tableView: UITableView,
        offset: CGFloat,
        animate: Bool,
        completionTask: ((_ presenterController: AKCustomViewController?) -> Void)?)
    {
        self.isMenuVisible = false
        self.hideTopMenu(animate: animate, completionTask: completionTask)
        
        var newOffset = offset
        if self.isMenuItemVisible {
            switch self.selectedMenuItem {
            case .add:
                newOffset += AKAddView.LocalConstants.AKViewHeight
                self.isMenuItemVisible = false
                self.hideAddMenuItem(animate: animate, completionTask: completionTask)
                break
            case .sort:
                newOffset += AKSortView.LocalConstants.AKViewHeight
                self.isMenuItemVisible = false
                self.hideSortMenuItem(animate: animate, completionTask: completionTask)
                break
            case .filter:
                newOffset += AKFilterView.LocalConstants.AKViewHeight
                self.isMenuItemVisible = false
                self.hideFilterMenuItem(animate: animate, completionTask: completionTask)
                break
            case .search:
                newOffset += AKSearchView.LocalConstants.AKViewHeight
                self.isMenuItemVisible = false
                self.hideSearchMenuItem(animate: animate, completionTask: completionTask)
                break
            default:
                break
            }
        }
        
        if animate {
            UIView.beginAnimations(LocalConstants.AKDisplaceUpAnimation, context: nil)
            Func.AKChangeComponentYPosition(component: tableView, newY: tableView.frame.origin.y - newOffset)
            Func.AKChangeComponentHeight(component: tableView, newHeight: tableView.frame.height + newOffset)
            UIView.commitAnimations()
        }
        else {
            Func.AKChangeComponentYPosition(component: tableView, newY: tableView.frame.origin.y - newOffset)
            Func.AKChangeComponentHeight(component: tableView, newHeight: tableView.frame.height + newOffset)
        }
    }
    
    func toggleMenuItem(
        tableView: UITableView,
        menuItem: MenuItems,
        animate: Bool,
        completionTask: ((_ presenterController: AKCustomViewController?) -> Void)?)
    {
        var offset: CGFloat = 0.0
        let direction: Displacement = !self.isMenuItemVisible ? .down : .up
        
        switch menuItem {
        case .add:
            self.selectedMenuItem = .add
            offset += AKAddView.LocalConstants.AKViewHeight
            if direction == Displacement.down {
                self.isMenuItemVisible = true
                self.showAddMenuItem(animate: animate, completionTask: completionTask)
            }
            else {
                self.isMenuItemVisible = false
                self.hideAddMenuItem(animate: animate, completionTask: completionTask)
            }
            break
        case .sort:
            self.selectedMenuItem = .sort
            offset += AKSortView.LocalConstants.AKViewHeight
            if direction == Displacement.down {
                self.isMenuItemVisible = true
                self.showSortMenuItem(animate: animate, completionTask: completionTask)
            }
            else {
                self.isMenuItemVisible = false
                self.hideSortMenuItem(animate: animate, completionTask: completionTask)
            }
            break
        case .filter:
            self.selectedMenuItem = .filter
            offset += AKFilterView.LocalConstants.AKViewHeight
            if direction == Displacement.down {
                self.isMenuItemVisible = true
                self.showFilterMenuItem(animate: animate, completionTask: completionTask)
            }
            else {
                self.isMenuItemVisible = false
                self.hideFilterMenuItem(animate: animate, completionTask: completionTask)
            }
            break
        case .search:
            self.selectedMenuItem = .search
            offset += AKSearchView.LocalConstants.AKViewHeight
            if direction == Displacement.down {
                self.isMenuItemVisible = true
                self.showSearchMenuItem(animate: animate, completionTask: completionTask)
            }
            else {
                self.isMenuItemVisible = false
                self.hideSearchMenuItem(animate: animate, completionTask: completionTask)
            }
            break
        default:
            break
        }
        
        if animate {
            if direction == Displacement.down {
                UIView.beginAnimations(LocalConstants.AKDisplaceDownAnimation, context: nil)
                Func.AKChangeComponentYPosition(component: tableView, newY: tableView.frame.origin.y + offset)
                Func.AKChangeComponentHeight(component: tableView, newHeight: tableView.frame.height - offset)
                UIView.commitAnimations()
            }
            else {
                UIView.beginAnimations(LocalConstants.AKDisplaceUpAnimation, context: nil)
                Func.AKChangeComponentYPosition(component: tableView, newY: tableView.frame.origin.y - offset)
                Func.AKChangeComponentHeight(component: tableView, newHeight: tableView.frame.height + offset)
                UIView.commitAnimations()
            }
        }
        else {
            if direction == Displacement.down {
                Func.AKChangeComponentYPosition(component: tableView, newY: tableView.frame.origin.y + offset)
                Func.AKChangeComponentHeight(component: tableView, newHeight: tableView.frame.height - offset)
            }
            else {
                Func.AKChangeComponentYPosition(component: tableView, newY: tableView.frame.origin.y - offset)
                Func.AKChangeComponentHeight(component: tableView, newHeight: tableView.frame.height + offset)
            }
        }
    }
}
