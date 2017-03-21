import CoreData
import Foundation

class AKDataController: NSObject
{
    // MARK: Properties
    private let managedObjectContext: NSManagedObjectContext
    
    // MARK: Initializers
    override init()
    {
        guard let modelURL = Bundle.main.url(forResource: GlobalConstants.AKDataModelName, withExtension:"momd") else {
            fatalError("=> ERROR: LOADING COREDATA MODEL FROM BUNDLE!")
        }
        
        guard let mom = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalError("=> ERROR: INITIALIZING FROM: \(modelURL)")
        }
        
        let psc = NSPersistentStoreCoordinator(managedObjectModel: mom)
        self.managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        self.managedObjectContext.persistentStoreCoordinator = psc
        
        let appSupportDir: URL?
        do {
            appSupportDir = try FileManager().url(for: FileManager.SearchPathDirectory.applicationSupportDirectory,
                                                  in: FileManager.SearchPathDomainMask.userDomainMask,
                                                  appropriateFor: nil,
                                                  create: true
            )
        }
        catch {
            fatalError("=> ERROR: \(error)")
        }
        
        if let appSupportDir = appSupportDir {
            let storeURL = URL(fileURLWithPath: appSupportDir.appendingPathComponent(GlobalConstants.AKDbaseFileName).relativePath, isDirectory: false)
            
            do {
                try psc.addPersistentStore(
                    ofType: NSSQLiteStoreType,
                    configurationName: nil,
                    at: storeURL,
                    options: [
                        NSMigratePersistentStoresAutomaticallyOption : NSNumber(value: true),
                        NSInferMappingModelAutomaticallyOption : NSNumber(value: true)
                    ]
                )
            }
            catch {
                fatalError("=> ERROR: \(error)")
            }
        }
    }
    
    // MARK: Accessors
    func getMOC() -> NSManagedObjectContext { return self.managedObjectContext }
}
