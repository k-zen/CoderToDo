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
        UITabBar.appearance().barTintColor = GlobalConstants.AKTabBarBg
        UITabBarItem.appearance().setTitleTextAttributes(
            [
                NSFontAttributeName: UIFont(name: GlobalConstants.AKDefaultFont, size: 18.0) ?? UIFont.systemFont(ofSize: 18.0),
                NSForegroundColorAttributeName: GlobalConstants.AKTabBarTintNormal
            ], for: UIControlState.normal
        )
        UITabBarItem.appearance().setTitleTextAttributes(
            [
                NSFontAttributeName: UIFont(name: GlobalConstants.AKDefaultFont, size: 18.0) ?? UIFont.systemFont(ofSize: 18.0),
                NSForegroundColorAttributeName: GlobalConstants.AKTabBarTintSelected
            ], for: UIControlState.selected
        )
        UINavigationBar.appearance().titleTextAttributes = [
            NSFontAttributeName: UIFont(name: GlobalConstants.AKDefaultFont, size: 22.0) ?? UIFont.systemFont(ofSize: 22),
            NSForegroundColorAttributeName: GlobalConstants.AKDefaultFg
        ]
        UINavigationBar.appearance().tintColor = GlobalConstants.AKTabBarTintSelected
        UIBarButtonItem.appearance().setTitleTextAttributes([
            NSFontAttributeName: UIFont(name: GlobalConstants.AKDefaultFont, size: 18.0) ?? UIFont.systemFont(ofSize: 18),
            NSForegroundColorAttributeName: GlobalConstants.AKTabBarTintSelected
            ], for: .normal
        )
        
        // ### Read persisted data.
        self.masterRef = AKMasterReference.loadData()
        
        return true
    }
}
