import CoreData
import Foundation

class AKDataController: NSObject
{
    // MARK: Properties
    private let managedObjectContext: NSManagedObjectContext
    
    // MARK: Initializers
    override init()
    {
        guard let modelURL = Bundle.main.url(forResource: "MainDataModel", withExtension:"momd") else {
            fatalError("=> ERROR: LOADING COREDATA MODEL FROM BUNDLE!")
        }
        
        guard let mom = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalError("=> ERROR: INITIALIZING FROM: \(modelURL)")
        }
        
        let psc = NSPersistentStoreCoordinator(managedObjectModel: mom)
        self.managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        self.managedObjectContext.persistentStoreCoordinator = psc
        
        do {
            let appSupportDir = try FileManager().url(for: FileManager.SearchPathDirectory.applicationSupportDirectory,
                                                      in: FileManager.SearchPathDomainMask.userDomainMask,
                                                      appropriateFor: nil,
                                                      create: true
            )
            let storeURL = URL(fileURLWithPath: appSupportDir.appendingPathComponent("MainDataModel.sqlite").relativePath, isDirectory: false)
            try psc.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeURL, options: nil)
        }
        catch {
            fatalError("=> ERROR: \(error)")
        }
    }
    
    // MARK: Accessors
    func getMOC() -> NSManagedObjectContext { return self.managedObjectContext }
}
