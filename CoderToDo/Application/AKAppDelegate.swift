import CloudKit
import Crashlytics
import Fabric
import UIKit
import UserNotifications

@UIApplicationMain
class AKAppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    // MARK: Properties
    let notificationCenter = UNUserNotificationCenter.current()
    let cloudKitContainer = CKContainer(identifier: "iCloud.net.apkc.projects.ios.CoderToDo")
    var masterRef: AKMasterReference?
    var window: UIWindow?
    
    // MARK: UIApplicationDelegate Implementation
    func applicationWillTerminate(_ application: UIApplication) { AKMasterReference.saveData(instance: self.masterRef) }
    
    func applicationWillResignActive(_ application: UIApplication) { AKMasterReference.saveData(instance: self.masterRef) }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // ### Customize the App.
        // ### TabBar
        UITabBarItem.appearance().setTitleTextAttributes(
            [
                NSAttributedString.Key.font: UIFont(
                    name: Cons.AKDefaultFont,
                    size: Cons.AKTabBarFontSize) ?? UIFont.systemFont(ofSize: Cons.AKTabBarFontSize),
                NSAttributedString.Key.foregroundColor: Cons.AKTabBarTintNormal
            ], for: .normal
        )
        UITabBarItem.appearance().setTitleTextAttributes(
            [
                NSAttributedString.Key.font: UIFont(
                    name: Cons.AKDefaultFont,
                    size: Cons.AKTabBarFontSize) ?? UIFont.systemFont(ofSize: Cons.AKTabBarFontSize),
                NSAttributedString.Key.foregroundColor: Cons.AKTabBarTintSelected
            ], for: .selected
        )
        UITabBar.appearance().barTintColor = Cons.AKTabBarBg
        // ### BarButton
        UIBarButtonItem.appearance().setTitleTextAttributes(
            [
                NSAttributedString.Key.font: UIFont(
                    name: Cons.AKSecondaryFont,
                    size: Cons.AKTabBarFontSize) ?? UIFont.systemFont(ofSize: Cons.AKTabBarFontSize),
                NSAttributedString.Key.foregroundColor: Cons.AKTabBarTintSelected
            ], for: .normal
        )
        // ### NavBar
        UINavigationBar.appearance().titleTextAttributes = [
            NSAttributedString.Key.font: UIFont(
                name: Cons.AKSecondaryFont,
                size: Cons.AKNavBarFontSize) ?? UIFont.systemFont(ofSize: Cons.AKNavBarFontSize),
            NSAttributedString.Key.foregroundColor: Cons.AKDefaultFg
        ]
        UINavigationBar.appearance().tintColor = Cons.AKTabBarTintSelected
        // ### SegmentedControl
        UISegmentedControl.appearance().setTitleTextAttributes(
            [
                NSAttributedString.Key.font: UIFont(
                    name: Cons.AKSecondaryFont,
                    size: 14.0) ?? UIFont.systemFont(ofSize: 14.0),
                NSAttributedString.Key.foregroundColor: Cons.AKDefaultFg
            ], for: .normal
        )
        UISegmentedControl.appearance().setTitleTextAttributes(
            [
                NSAttributedString.Key.font: UIFont(
                    name: Cons.AKSecondaryFont,
                    size: 14.0) ?? UIFont.systemFont(ofSize: 14.0),
                NSAttributedString.Key.foregroundColor: UIColor.black
            ], for: .selected
        )
        // ### Misc
        UIPickerView.appearance().backgroundColor = Cons.AKCoderToDoGray2
        UITextView.appearance().backgroundColor = Cons.AKCoderToDoGray2
        
        // ### Read persisted data.
        self.masterRef = AKMasterReference.loadData()
        self.masterRef?.dump()
        
        // ### Delegates.
        self.notificationCenter.delegate = self
        
        // ### Fabric.
        Fabric.with([Crashlytics.self])
        
        return true
    }
    
    // MARK: UNUserNotificationCenterDelegate Implementation
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert,.sound])
    }
}
