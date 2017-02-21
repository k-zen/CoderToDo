import UIKit

@UIApplicationMain
class AKAppDelegate: UIResponder, UIApplicationDelegate
{
    // MARK: Properties
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
        
        return true
    }
}
