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
        UINavigationBar.appearance().titleTextAttributes = [
            NSFontAttributeName: UIFont(name: GlobalConstants.AKDefaultFont, size: 22.0) ?? UIFont.systemFont(ofSize: 18),
            NSForegroundColorAttributeName: GlobalConstants.AKDefaultFg
        ]
        UINavigationBar.appearance().tintColor = GlobalConstants.AKTabBarTintSelected
        
        // ### Read persisted data.
        self.masterRef = AKMasterReference.loadData()
        
        return true
    }
}
