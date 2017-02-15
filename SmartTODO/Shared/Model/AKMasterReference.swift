import CoreData
import Foundation

class AKMasterReference: NSObject
{
    // MARK: Properties
    /// The managed object context needed to handle the data.
    let moc: NSManagedObjectContext
    /// This is the entry point to all data. Everything starts with the user data structure.
    var user: User? = nil
    
    // MARK: Initializers
    override init()
    {
        self.moc = DataController().getMOC()
        super.init()
        do {
            if let users = try self.moc.fetch(NSFetchRequest<NSFetchRequestResult>(entityName: GlobalConstants.AKUserMOEntityName)) as? [User] {
                self.user = users.count > 0 ? users.first! : User(context: self.moc)
            }
        }
        catch {
            fatalError("=> ERROR: \(error)")
        }
    }
    
    // MARK: Accessors
    func getMOC() -> NSManagedObjectContext { return self.moc }
    
    // MARK: Utilities
    ///
    /// This function loads the data into memory from persistence.
    ///
    /// - Returns: A reference file to the data.
    ///
    static func loadData() -> AKMasterReference
    {
        return AKMasterReference().dump()
    }
    
    ///
    /// This function saves the data from memory into persistance.
    ///
    /// - Parameter instance: The instance containing the data.
    ///
    static func saveData(instance: AKMasterReference?) -> Void
    {
        do {
            try instance?.dump().moc.save()
        }
        catch {
            fatalError("=> ERROR: \(error)")
        }
    }
    
    ///
    /// This function dumps the data to the console for debugging purposes.
    ///
    /// - Returns: The self instance. Useful for concatenating calls.
    ///
    func dump() -> AKMasterReference
    {
        NSLog("=> COREDATA DUMP ######")
        NSLog("=>   USERNAME: %@", self.user?.username ?? "N\\A")
        NSLog("=>   PROJECTS:")
        let projects = (self.user?.project)!
        for case let project as Project in projects {
            NSLog("=>       CLOSING TIME: %@", project.closingTime?.description ?? "N\\A")
            NSLog("=>       CLOSING TIME TOLERANCE: %i", project.closingTimeTolerance)
            NSLog("=>       CREATION DATE: %@", project.creationDate?.description ?? "N\\A")
            NSLog("=>       MAX. CATEGORIES: %i", project.maxCategories)
            NSLog("=>       MAX. TASKS: %i", project.maxTasks)
            NSLog("=>       NAME: %@", project.name ?? "N\\A")
            NSLog("=>       NOTIFY CLOSING TIME: %@", project.notifyClosingTime ? "YES" : "NO")
            NSLog("=>       OSR: %.2f", project.osr)
            NSLog("=>       STARTING TIME: %@", project.startingTime?.description ?? "N\\A")
            NSLog("=>       ------")
        }
        NSLog("=> COREDATA DUMP ######")
        
        return self
    }
}
