import UIKit
import UserNotifications

@UIApplicationMain
class AKAppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate
{
    // MARK: Properties
    let notificationCenter = UNUserNotificationCenter.current()
    var masterRef: AKMasterReference?
    var window: UIWindow?
    
    // MARK: UIApplicationDelegate Implementation
    func applicationWillTerminate(_ application: UIApplication)
    {
        AKMasterReference.saveData(instance: self.masterRef)
    }
    
    func applicationWillResignActive(_ application: UIApplication)
    {
        AKMasterReference.saveData(instance: self.masterRef)
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool
    {
        // ### Customize the App.
        UITabBarItem.appearance().setTitleTextAttributes(
            [
                NSFontAttributeName: UIFont(name: GlobalConstants.AKDefaultFont, size: 18.0) ?? UIFont.systemFont(ofSize: 18.0),
                NSForegroundColorAttributeName: GlobalConstants.AKTabBarTintNormal
            ], for: .normal
        )
        UITabBarItem.appearance().setTitleTextAttributes(
            [
                NSFontAttributeName: UIFont(name: GlobalConstants.AKDefaultFont, size: 18.0) ?? UIFont.systemFont(ofSize: 18.0),
                NSForegroundColorAttributeName: GlobalConstants.AKTabBarTintSelected
            ], for: .selected
        )
        UITabBar.appearance().barTintColor = GlobalConstants.AKTabBarBg
        UIBarButtonItem.appearance().setTitleTextAttributes(
            [
                NSFontAttributeName: UIFont(name: GlobalConstants.AKDefaultFont, size: 18.0) ?? UIFont.systemFont(ofSize: 18.0),
                NSForegroundColorAttributeName: GlobalConstants.AKDefaultFg
            ], for: .normal
        )
        UINavigationBar.appearance().titleTextAttributes = [
            NSFontAttributeName: UIFont(name: GlobalConstants.AKDefaultFont, size: 18.0) ?? UIFont.systemFont(ofSize: 18.0),
            NSForegroundColorAttributeName: GlobalConstants.AKDefaultFg
        ]
        UINavigationBar.appearance().tintColor = GlobalConstants.AKDefaultFg
        
        // ### Read persisted data.
        self.masterRef = AKMasterReference.loadData()
        
        // ### Delegates.
        self.notificationCenter.delegate = self
        
        return true
    }
    
    // MARK: UNUserNotificationCenterDelegate Implementation
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void)
    {
        completionHandler([.alert,.sound])
    }
}
