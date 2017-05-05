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
class AKCustomViewController: UIViewController, UIGestureRecognizerDelegate {
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
    /// Flag to add a Spinner to the left slot of the navigation controller.
    var shouldAddSpinner: Bool = false
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
    /// Operations to perform when loading the view.
    var loadData: (AKCustomViewController) -> Void = { (controller) -> Void in }
    /// Operations to perform when quiting the view.
    var saveData: (AKCustomViewController) -> Void = { (controller) -> Void in }
    /// Operations to perform to configure the L&F.
    var configureLookAndFeel: (AKCustomViewController) -> Void = { (controller) -> Void in }
    
    // MARK: Properties
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
    var spinner: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.white)
    var currentEditableComponent: UIView?
    var currentScrollContainer: UIScrollView?
    
    // MARK: Overlays
    let messageOverlay = AKMessageView()
    let continueMessageOverlay = AKContinueMessageView()
    let topMenuOverlay = AKTopMenuView()
    let addMenuItemOverlay = AKAddView()
    let sortMenuItemOverlay = AKSortView()
    let filterMenuItemOverlay = AKFilterView()
    let searchMenuItemOverlay = AKSearchView()
    let migrateBucketEntryOverlay = AKMigrateBucketEntryView()
    let initialMessageOverlay = AKInitialMessageView()
    let selectCategoryOverlay = AKSelectCategoryView()
    let selectTaskStateOverlay = AKSelectTaskStateView()
    
    // MARK: Menu
    var selectedMenuItem: MenuItems = .none
    var isMenuVisible: Bool = false
    var isMenuItemVisible: Bool = false
    
    // MARK: Animations
    let displaceDownTable = CABasicAnimation(keyPath: LocalConstants.AKDisplaceDownAnimation)
    let displaceUpTable = CABasicAnimation(keyPath: LocalConstants.AKDisplaceUpAnimation)
    
    // MARK: UIViewController Overriding
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if GlobalConstants.AKDebug {
            NSLog("=> VIEW DID LOAD ON: \(type(of: self))")
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
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
        
        self.loadData(self)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.saveData(self)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.configureLookAndFeel(self)
    }
    
    // MARK: UIGestureRecognizerDelegate Implementation
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
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
    func setup() {
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
        
        // Add spinner.
        if self.shouldAddSpinner {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: self.spinner)
        }
        
        // Observers.
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(AKCustomViewController.keyboardWasShow(notification:)),
            name: NSNotification.Name.UIKeyboardDidShow,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(AKCustomViewController.keyboardWillBeHidden(notification:)),
            name: NSNotification.Name.UIKeyboardWillHide,
            object: nil
        )
    }
    
    func loadLocalizedText() {
        self.localizableDictionary = {
            if let path = Bundle.main.path(forResource: "\(type(of: self))", ofType: "plist") {
                NSLog("=> INFO: READING LOCALIZATION FILE *\(type(of: self)).plist*...")
                
                return NSDictionary(contentsOfFile: path)
            }
            
            return nil
        }()
    }
    
    // MARK: Presenters
    func presentView(controller: AKCustomViewController,
                     taskBeforePresenting: @escaping (_ presenterController: AKCustomViewController, _ presentedController: AKCustomViewController) -> Void,
                     dismissViewCompletionTask: @escaping (_ presenterController: AKCustomViewController, _ presentedController: AKCustomViewController) -> Void) {
        controller.dismissViewCompletionTask = { dismissViewCompletionTask(self, controller) }
        controller.modalTransitionStyle = GlobalConstants.AKDefaultTransitionStyle
        controller.modalPresentationStyle = .overFullScreen
        
        taskBeforePresenting(self, controller)
        
        self.present(controller, animated: false, completion: nil)
    }
    
    // MARK: Floating Views
    func showMessage(
        origin: CGPoint,
        type: MessageType,
        message: String,
        animate: Bool,
        completionTask: ((_ presenterController: AKCustomViewController?) -> Void)?) {
        // The origin never changes so fix it to the controller's view.
        var origin = Func.AKCenterScreenCoordinate(
            container: self.view,
            width: AKMessageView.LocalConstants.AKViewWidth,
            height: AKMessageView.LocalConstants.AKViewHeight
        )
        origin.y -= 0.0 // Move up Y points from the center.
        
        // Configure the overlay.
        self.messageOverlay.controller = self
        self.messageOverlay.setup()
        self.messageOverlay.draw(container: self.view, coordinates: origin, size: CGSize.zero)
        switch type {
        case .info:
            self.messageOverlay.title.text = MessageType.info.rawValue
            self.messageOverlay.title.backgroundColor = Func.AKGetColorForPriority(priority: .low)
            break
        case .warning:
            self.messageOverlay.title.text = MessageType.warning.rawValue
            self.messageOverlay.title.backgroundColor = Func.AKGetColorForPriority(priority: .medium)
            break
        case .error:
            self.messageOverlay.title.text = MessageType.error.rawValue
            self.messageOverlay.title.backgroundColor = Func.AKGetColorForPriority(priority: .high)
            break
        }
        self.messageOverlay.message.text = message
        
        // Expand/Show the overlay.
        self.messageOverlay.expand(
            controller: self,
            expandHeight: AKMessageView.LocalConstants.AKViewHeight,
            animate: animate,
            completionTask: completionTask
        )
    }
    
    func showContinueMessage(origin: CGPoint,
                             type: MessageType,
                             message: String,
                             yesButtonTitle: String = "Yes",
                             noButtonTitle: String = "No",
                             yesAction: ((_ presenterController: AKCustomViewController?) -> Void)?,
                             noAction: ((_ presenterController: AKCustomViewController?) -> Void)?,
                             animate: Bool,
                             completionTask: ((_ presenterController: AKCustomViewController?) -> Void)?) {
        // The origin never changes so fix it to the controller's view.
        var origin = Func.AKCenterScreenCoordinate(
            container: self.view,
            width: AKContinueMessageView.LocalConstants.AKViewWidth,
            height: AKContinueMessageView.LocalConstants.AKViewHeight
        )
        origin.y -= 0.0 // Move up Y points from the center.
        
        // Configure the overlay.
        self.continueMessageOverlay.controller = self
        self.continueMessageOverlay.setup()
        self.continueMessageOverlay.draw(container: self.view, coordinates: origin, size: CGSize.zero)
        switch type {
        case .info:
            self.continueMessageOverlay.title.text = MessageType.info.rawValue
            self.continueMessageOverlay.title.backgroundColor = Func.AKGetColorForPriority(priority: .low)
            break
        case .warning:
            self.continueMessageOverlay.title.text = MessageType.warning.rawValue
            self.continueMessageOverlay.title.backgroundColor = Func.AKGetColorForPriority(priority: .medium)
            break
        case .error:
            self.continueMessageOverlay.title.text = MessageType.error.rawValue
            self.continueMessageOverlay.title.backgroundColor = Func.AKGetColorForPriority(priority: .high)
            break
        }
        self.continueMessageOverlay.message.text = message
        self.continueMessageOverlay.yes.setTitle(yesButtonTitle, for: .normal)
        self.continueMessageOverlay.no.setTitle(noButtonTitle, for: .normal)
        self.continueMessageOverlay.yesAction = yesAction
        self.continueMessageOverlay.noAction = noAction
        
        // Expand/Show the overlay.
        self.continueMessageOverlay.expand(
            controller: self,
            expandHeight: AKContinueMessageView.LocalConstants.AKViewHeight,
            animate: animate,
            completionTask: completionTask
        )
    }
    
    func showTopMenu(
        origin: CGPoint,
        animate: Bool,
        completionTask: ((_ presenterController: AKCustomViewController?) -> Void)?) {
        // The origin never changes so fix it to the controller's view.
        let origin = CGPoint.zero
        
        // Configure the overlay.
        self.topMenuOverlay.controller = self
        self.topMenuOverlay.setup()
        self.topMenuOverlay.draw(container: self.view, coordinates: origin, size: CGSize(width: self.view.frame.width, height: 0.0))
        
        // Expand/Show the overlay.
        self.topMenuOverlay.expand(
            controller: self,
            expandHeight: AKTopMenuView.LocalConstants.AKViewHeight,
            animate: animate,
            completionTask: completionTask
        )
    }
    
    func showAddMenuItem(
        origin: CGPoint,
        animate: Bool,
        completionTask: ((_ presenterController: AKCustomViewController?) -> Void)?) {
        // The origin never changes so fix it to the controller's view.
        let origin = CGPoint(x: 0.0, y: AKTopMenuView.LocalConstants.AKViewHeight)
        
        // Configure the overlay.
        self.addMenuItemOverlay.controller = self
        self.addMenuItemOverlay.setup()
        self.addMenuItemOverlay.draw(container: self.view, coordinates: origin, size: CGSize(width: self.view.frame.width, height: 0.0))
        
        // Expand/Show the overlay.
        self.addMenuItemOverlay.expand(controller: self,
                                       expandHeight: AKAddView.LocalConstants.AKViewHeight,
                                       animate: animate,
                                       completionTask: completionTask
        )
    }
    
    func showSortMenuItem(
        origin: CGPoint,
        animate: Bool,
        completionTask: ((_ presenterController: AKCustomViewController?) -> Void)?) {
        // The origin never changes so fix it to the controller's view.
        let origin = CGPoint(x: 0.0, y: AKTopMenuView.LocalConstants.AKViewHeight)
        
        // Configure the overlay.
        self.sortMenuItemOverlay.controller = self
        self.sortMenuItemOverlay.setup()
        self.sortMenuItemOverlay.draw(container: self.view, coordinates: origin, size: CGSize(width: self.view.frame.width, height: 0.0))
        
        // Expand/Show the overlay.
        self.sortMenuItemOverlay.expand(controller: self,
                                        expandHeight: AKSortView.LocalConstants.AKViewHeight,
                                        animate: animate,
                                        completionTask: completionTask
        )
    }
    
    func showFilterMenuItem(
        origin: CGPoint,
        animate: Bool,
        completionTask: ((_ presenterController: AKCustomViewController?) -> Void)?) {
        // The origin never changes so fix it to the controller's view.
        let origin = CGPoint(x: 0.0, y: AKTopMenuView.LocalConstants.AKViewHeight)
        
        // Configure the overlay.
        self.filterMenuItemOverlay.controller = self
        self.filterMenuItemOverlay.setup()
        self.filterMenuItemOverlay.draw(container: self.view, coordinates: origin, size: CGSize(width: self.view.frame.width, height: 0.0))
        
        // Expand/Show the overlay.
        self.filterMenuItemOverlay.expand(
            controller: self,
            expandHeight: AKFilterView.LocalConstants.AKViewHeight,
            animate: animate,
            completionTask: completionTask
        )
    }
    
    func showSearchMenuItem(
        origin: CGPoint,
        animate: Bool,
        completionTask: ((_ presenterController: AKCustomViewController?) -> Void)?) {
        // The origin never changes so fix it to the controller's view.
        let origin = CGPoint(x: 0.0, y: AKTopMenuView.LocalConstants.AKViewHeight)
        
        // Configure the overlay.
        self.searchMenuItemOverlay.controller = self
        self.searchMenuItemOverlay.setup()
        self.searchMenuItemOverlay.draw(container: self.view, coordinates: origin, size: CGSize(width: self.view.frame.width, height: 0.0))
        
        // Expand/Show the overlay.
        self.searchMenuItemOverlay.expand(
            controller: self,
            expandHeight: AKSearchView.LocalConstants.AKViewHeight,
            animate: animate,
            completionTask: completionTask
        )
    }
    
    func showAddBucketEntry(
        origin: CGPoint,
        animate: Bool,
        completionTask: ((_ presenterController: AKCustomViewController?) -> Void)?) -> AKAddBucketEntryView {
        // The origin never changes so fix it to the controller's view.
        var origin = Func.AKCenterScreenCoordinate(
            container: self.view,
            width: AKAddBucketEntryView.LocalConstants.AKViewWidth,
            height: AKAddBucketEntryView.LocalConstants.AKViewHeight
        )
        origin.y -= 0.0 // Move up Y points from the center.
        
        // Configure the overlay.
        let addBucketEntryOverlay = AKAddBucketEntryView()
        addBucketEntryOverlay.controller = self
        addBucketEntryOverlay.setup()
        addBucketEntryOverlay.draw(container: self.view, coordinates: origin, size: CGSize.zero)
        
        // Expand/Show the overlay.
        addBucketEntryOverlay.expand(
            controller: self,
            expandHeight: AKAddBucketEntryView.LocalConstants.AKViewHeight,
            animate: animate,
            completionTask: completionTask
        )
        
        return addBucketEntryOverlay
    }
    
    func showMigrateBucketEntry(
        origin: CGPoint,
        animate: Bool,
        completionTask: ((_ presenterController: AKCustomViewController?) -> Void)?) {
        // The origin never changes so fix it to the controller's view.
        var origin = Func.AKCenterScreenCoordinate(
            container: self.view,
            width: AKMigrateBucketEntryView.LocalConstants.AKViewWidth,
            height: AKMigrateBucketEntryView.LocalConstants.AKViewHeight
        )
        origin.y -= 0.0 // Move up Y points from the center.
        
        // Configure the overlay.
        self.migrateBucketEntryOverlay.controller = self
        self.migrateBucketEntryOverlay.setup()
        self.migrateBucketEntryOverlay.draw(container: self.view, coordinates: origin, size: CGSize.zero)
        
        // Expand/Show the overlay.
        self.migrateBucketEntryOverlay.expand(
            controller: self,
            expandHeight: AKMigrateBucketEntryView.LocalConstants.AKViewHeight,
            animate: animate,
            completionTask: completionTask
        )
    }
    
    func showInitialMessage(
        origin: CGPoint,
        title: String,
        message: String,
        animate: Bool,
        completionTask: ((_ presenterController: AKCustomViewController?) -> Void)?) {
        // Configure the overlay.
        self.initialMessageOverlay.controller = self
        self.initialMessageOverlay.setup()
        self.initialMessageOverlay.draw(container: self.view, coordinates: origin, size: CGSize.zero)
        self.initialMessageOverlay.title.text = title
        self.initialMessageOverlay.message.text = message
        
        // Expand/Show the overlay.
        self.initialMessageOverlay.expand(
            controller: self,
            expandHeight: AKInitialMessageView.LocalConstants.AKViewHeight,
            animate: animate,
            completionTask: completionTask
        )
    }
    
    func showSelectCategory(
        origin: CGPoint,
        animate: Bool,
        completionTask: ((_ presenterController: AKCustomViewController?) -> Void)?) {
        // The origin never changes so fix it to the controller's view.
        var origin = Func.AKCenterScreenCoordinate(
            container: self.view,
            width: AKSelectCategoryView.LocalConstants.AKViewWidth,
            height: AKSelectCategoryView.LocalConstants.AKViewHeight
        )
        origin.y -= 0.0 // Move up Y points from the center.
        
        // Configure the overlay.
        self.selectCategoryOverlay.controller = self
        self.selectCategoryOverlay.setup()
        self.selectCategoryOverlay.draw(container: self.view, coordinates: origin, size: CGSize.zero)
        
        // Expand/Show the overlay.
        self.selectCategoryOverlay.expand(
            controller: self,
            expandHeight: AKSelectCategoryView.LocalConstants.AKViewHeight,
            animate: true,
            completionTask: nil
        )
    }
    
    func showSelectTaskState(
        origin: CGPoint,
        animate: Bool,
        completionTask: ((_ presenterController: AKCustomViewController?) -> Void)?) {
        // Configure the overlay.
        self.selectTaskStateOverlay.controller = self
        self.selectTaskStateOverlay.setup()
        self.selectTaskStateOverlay.draw(container: self.view, coordinates: origin, size: CGSize.zero)
        
        // Expand/Show the overlay.
        self.selectTaskStateOverlay.expand(
            controller: self,
            expandHeight: AKSelectTaskStateView.LocalConstants.AKViewHeight,
            animate: true,
            completionTask: nil
        )
    }
    
    func hideMessage(animate: Bool, completionTask: ((_ presenterController: AKCustomViewController?) -> Void)?) {
        self.messageOverlay.collapse(
            controller: self,
            animate: animate,
            completionTask: completionTask
        )
    }
    
    func hideContinueMessage(animate: Bool, completionTask: ((_ presenterController: AKCustomViewController?) -> Void)?) {
        self.continueMessageOverlay.collapse(
            controller: self,
            animate: animate,
            completionTask: completionTask
        )
    }
    
    func hideTopMenu(animate: Bool, completionTask: ((_ presenterController: AKCustomViewController?) -> Void)?) {
        self.topMenuOverlay.collapse(
            controller: self,
            animate: animate,
            completionTask: completionTask
        )
    }
    
    func hideAddMenuItem(animate: Bool, completionTask: ((_ presenterController: AKCustomViewController?) -> Void)?) {
        self.addMenuItemOverlay.collapse(
            controller: self,
            animate: animate,
            completionTask: completionTask
        )
    }
    
    func hideSortMenuItem(animate: Bool, completionTask: ((_ presenterController: AKCustomViewController?) -> Void)?) {
        self.sortMenuItemOverlay.collapse(
            controller: self,
            animate: animate,
            completionTask: completionTask
        )
    }
    
    func hideFilterMenuItem(animate: Bool, completionTask: ((_ presenterController: AKCustomViewController?) -> Void)?) {
        self.filterMenuItemOverlay.collapse(
            controller: self,
            animate: animate,
            completionTask: completionTask
        )
    }
    
    func hideSearchMenuItem(animate: Bool, completionTask: ((_ presenterController: AKCustomViewController?) -> Void)?) {
        self.searchMenuItemOverlay.collapse(
            controller: self,
            animate: animate,
            completionTask: completionTask
        )
    }
    
    func hideAddBucketEntry(
        instance: AKAddBucketEntryView?,
        animate: Bool,
        completionTask: ((_ presenterController: AKCustomViewController?) -> Void)?) {
        instance?.collapse(
            controller: self,
            animate: animate,
            completionTask: completionTask
        )
    }
    
    func hideMigrateBucketEntry(animate: Bool, completionTask: ((_ presenterController: AKCustomViewController?) -> Void)?) {
        self.migrateBucketEntryOverlay.collapse(
            controller: self,
            animate: animate,
            completionTask: completionTask
        )
    }
    
    func hideInitialMessage(animate: Bool, completionTask: ((_ presenterController: AKCustomViewController?) -> Void)?) {
        self.initialMessageOverlay.collapse(
            controller: self,
            animate: animate,
            completionTask: completionTask
        )
    }
    
    func hideSelectCategory(animate: Bool, completionTask: ((_ presenterController: AKCustomViewController?) -> Void)?) {
        self.selectCategoryOverlay.collapse(
            controller: self,
            animate: true,
            completionTask: nil
        )
    }
    
    func hideSelectTaskState(animate: Bool, completionTask: ((_ presenterController: AKCustomViewController?) -> Void)?) {
        self.selectTaskStateOverlay.collapse(
            controller: self,
            animate: true,
            completionTask: nil
        )
    }
    
    // MARK: Gesture Handling
    @objc internal func tap(_ gesture: UIGestureRecognizer?) {
        NSLog("=> TAP GESTURE DETECTED... DOING SOMETHING...")
        self.defaultOperationsWhenGesture(self, gesture)
        self.additionalOperationsWhenTaped(gesture)
    }
    
    @objc internal func pinch(_ gesture: UIGestureRecognizer?) {
        NSLog("=> PINCH GESTURE DETECTED... DOING SOMETHING...")
        self.defaultOperationsWhenGesture(self, gesture)
        self.additionalOperationsWhenPinched(gesture)
    }
    
    @objc internal func rotate(_ gesture: UIGestureRecognizer?) {
        NSLog("=> ROTATION GESTURE DETECTED... DOING SOMETHING...")
        self.defaultOperationsWhenGesture(self, gesture)
        self.additionalOperationsWhenRotated(gesture)
    }
    
    @objc internal func swipe(_ gesture: UIGestureRecognizer?) {
        NSLog("=> SWIPE GESTURE DETECTED... DOING SOMETHING...")
        self.defaultOperationsWhenGesture(self, gesture)
        self.additionalOperationsWhenSwiped(gesture)
    }
    
    @objc internal func pan(_ gesture: UIGestureRecognizer?) {
        NSLog("=> PAN GESTURE DETECTED... DOING SOMETHING...")
        self.defaultOperationsWhenGesture(self, gesture)
        self.additionalOperationsWhenPaned(gesture)
    }
    
    @objc internal func screenEdgePan(_ gesture: UIGestureRecognizer?) {
        NSLog("=> SCREEN EDGE PAN GESTURE DETECTED... DOING SOMETHING...")
        self.defaultOperationsWhenGesture(self, gesture)
        self.additionalOperationsWhenScreenEdgePaned(gesture)
    }
    
    @objc internal func longPress(_ gesture: UIGestureRecognizer?) {
        NSLog("=> LONG PRESS GESTURE DETECTED... DOING SOMETHING...")
        self.defaultOperationsWhenGesture(self, gesture)
        self.additionalOperationsWhenLongPressed(gesture)
    }
    
    // MARK: Utility functions
    func manageGrantToLocalNotifications() {
        Func.AKGetNotificationCenter().requestAuthorization(options: [.alert, .sound]) { (granted, error) in
            if !granted {
                Func.AKExecuteInMainThread(controller: self, mode: .sync, code: { (controller) -> Void in
                    controller?.showContinueMessage(
                        origin: CGPoint.zero,
                        type: .info,
                        message: "CoderToDo needs to be able to send you local notifications in order to alert you about project times. Go to Settings to enable it.",
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
    
    func manageGrantToiCloud() {
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
                        origin: CGPoint.zero,
                        type: .info,
                        message: "You need to be signed into iCloud and have iCloud Drive set to on. Go to Settings to enable it.",
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
    
    func dismissView(executeDismissTask: Bool) {
        OperationQueue.main.addOperation {
            if executeDismissTask {
                self.dismiss(animated: true, completion: self.dismissViewCompletionTask)
            }
            else {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    func localize(key: String) -> Any? {
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
    func configureAnimations(displacementHeight: CGFloat) {
        self.displaceDownTable.fromValue = 0.0
        self.displaceDownTable.toValue = displacementHeight
        self.displaceDownTable.duration = 0.5
        self.displaceDownTable.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        self.displaceDownTable.autoreverses = false
        self.view.layer.add(self.displaceDownTable, forKey: LocalConstants.AKDisplaceDownAnimation)
        
        self.displaceUpTable.fromValue = displacementHeight
        self.displaceUpTable.toValue = 0.0
        self.displaceUpTable.duration = 0.5
        self.displaceUpTable.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        self.displaceUpTable.autoreverses = false
        self.view.layer.add(self.displaceUpTable, forKey: LocalConstants.AKDisplaceUpAnimation)
    }
    
    func displaceDownTable(
        tableView: UITableView,
        offset: CGFloat,
        animate: Bool,
        completionTask: ((_ presenterController: AKCustomViewController?) -> Void)?) {
        self.isMenuVisible = true
        self.showTopMenu(origin: CGPoint.zero, animate: animate, completionTask: completionTask)
        
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
        completionTask: ((_ presenterController: AKCustomViewController?) -> Void)?) {
        self.isMenuVisible = false
        self.hideTopMenu(animate: animate, completionTask: completionTask)
        
        var newOffset = offset
        if self.isMenuItemVisible {
            switch self.selectedMenuItem {
            case .add:
                newOffset += AKAddView.LocalConstants.AKViewHeight
                self.isMenuItemVisible = false
                self.hideAddMenuItem(animate: animate, completionTask: nil)
                break
            case .sort:
                newOffset += AKSortView.LocalConstants.AKViewHeight
                self.isMenuItemVisible = false
                self.hideSortMenuItem(animate: animate, completionTask: nil)
                break
            case .filter:
                newOffset += AKFilterView.LocalConstants.AKViewHeight
                self.isMenuItemVisible = false
                self.hideFilterMenuItem(animate: animate, completionTask: nil)
                break
            case .search:
                newOffset += AKSearchView.LocalConstants.AKViewHeight
                self.isMenuItemVisible = false
                self.hideSearchMenuItem(animate: animate, completionTask: nil)
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
        completionTask: ((_ presenterController: AKCustomViewController?) -> Void)?) {
        var offset: CGFloat = 0.0
        let direction: Displacement = !self.isMenuItemVisible ? .down : .up
        
        switch menuItem {
        case .add:
            self.selectedMenuItem = .add
            offset += AKAddView.LocalConstants.AKViewHeight
            if direction == Displacement.down {
                self.isMenuItemVisible = true
                self.showAddMenuItem(origin: CGPoint.zero, animate: animate, completionTask: completionTask)
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
                self.showSortMenuItem(origin: CGPoint.zero, animate: animate, completionTask: completionTask)
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
                self.showFilterMenuItem(origin: CGPoint.zero, animate: animate, completionTask: completionTask)
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
                self.showSearchMenuItem(origin: CGPoint.zero, animate: animate, completionTask: completionTask)
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
    
    // MARK: Observers
    func keyboardWasShow(notification: NSNotification) {
        if let info = notification.userInfo, let editableComponent = self.currentEditableComponent {
            if let kbSize = (info[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size {
                var viewRect = self.view.frame
                viewRect.size.height += (UIScreen.main.bounds.height - viewRect.size.height)
                
                var visibleRect = CGRect(x: 0.0, y: 0.0, width: viewRect.size.width, height: viewRect.size.height)
                visibleRect.size.height -= (kbSize.height + GlobalConstants.AKCloseKeyboardToolbarHeight)
                
                var absoluteComponent = editableComponent.convert(editableComponent.bounds, to: self.view)
                absoluteComponent.origin.y += self.navigationController?.topViewController == self ? 49.0 : 0.0
                
                if GlobalConstants.AKDebug {
                    NSLog("=> ### COMPONENT REPOSITION INFO ###")
                    NSLog("=> COMPONENT: X:%f,Y:%f", absoluteComponent.origin.x, absoluteComponent.origin.y)
                    NSLog("=> VIEW: W:%f,H:%f", self.view.frame.width, self.view.frame.height)
                    NSLog("=> VISIBLE RECT: W:%f,H:%f", visibleRect.width, visibleRect.height)
                    NSLog("=> KEYBOARD: W:%f,H:%f", kbSize.width, kbSize.height)
                    NSLog("=> SCREEN: W:%f,H:%f", UIScreen.main.bounds.width, UIScreen.main.bounds.height)
                    NSLog("=> ### COMPONENT REPOSITION INFO ###")
                }
                
                if !visibleRect.contains(absoluteComponent) {
                    var newPosition = CGPoint(x: 0.0, y: absoluteComponent.origin.y + editableComponent.frame.height)
                    newPosition.y -= visibleRect.size.height
                    
                    self.currentScrollContainer?.setContentOffset(newPosition, animated: true)
                }
            }
        }
    }
    
    func keyboardWillBeHidden(notification: NSNotification) { self.currentScrollContainer?.setContentOffset(CGPoint.zero, animated: true) }
}
