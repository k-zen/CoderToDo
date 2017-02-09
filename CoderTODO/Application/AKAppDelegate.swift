import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate
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
        // ### Read persisted data.
        self.masterRef = AKMasterReference.loadData()
        
        return true
    }
}
