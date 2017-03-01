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
            if (instance?.moc.hasChanges)! {
                try instance?.dump().moc.save()
                NSLog("=> INFO: SAVED CORE DATA.")
            }
            else {
                NSLog("=> INFO: THERE ARE NO CHANGES TO SAVE!")
            }
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
            NSLog("=>       NAME: %@", project.name ?? "N\\A")
            NSLog("=>       NOTIFY CLOSING TIME: %@", project.notifyClosingTime ? "YES" : "NO")
            NSLog("=>       OSR: %.2f", project.osr)
            NSLog("=>       STARTING TIME: %@", project.startingTime?.description ?? "N\\A")
            NSLog("=>       PROJECT CATEGORIES: (%i)", project.projectCategories?.count ?? 0)
            for projectCategory in DataInterface.listCategoriesInProject(project: project) {
                NSLog("=>           NAME: %@", projectCategory)
            }
            NSLog("=>       PENDING QUEUE: (%i)", project.pendingQueue?.tasks?.count ?? 0)
            if let tasksInQueue = project.pendingQueue?.tasks?.allObjects as? [Task] {
                for taskInQueue in tasksInQueue {
                    NSLog("=>           COMPLETION PERCENTAGE: %.2f", taskInQueue.completionPercentage)
                    NSLog("=>           INITIAL COMPLETION PERCENTAGE: %.2f", taskInQueue.initialCompletionPercentage)
                    NSLog("=>           CREATION DATE: %@", taskInQueue.creationDate?.description ?? "N\\A")
                    NSLog("=>           NAME: %@", taskInQueue.name ?? "N\\A")
                    NSLog("=>           NOTE: %@", taskInQueue.note ?? "N\\A")
                    NSLog("=>           STATE: %@", taskInQueue.state ?? "N\\A")
                    NSLog("=>           ------")
                }
            }
            NSLog("=>       DILATE QUEUE: (%i)", project.dilateQueue?.tasks?.count ?? 0)
            if let tasksInQueue = project.dilateQueue?.tasks?.allObjects as? [Task] {
                for taskInQueue in tasksInQueue {
                    NSLog("=>           COMPLETION PERCENTAGE: %.2f", taskInQueue.completionPercentage)
                    NSLog("=>           INITIAL COMPLETION PERCENTAGE: %.2f", taskInQueue.initialCompletionPercentage)
                    NSLog("=>           CREATION DATE: %@", taskInQueue.creationDate?.description ?? "N\\A")
                    NSLog("=>           NAME: %@", taskInQueue.name ?? "N\\A")
                    NSLog("=>           NOTE: %@", taskInQueue.note ?? "N\\A")
                    NSLog("=>           STATE: %@", taskInQueue.state ?? "N\\A")
                    NSLog("=>           ------")
                }
            }
            NSLog("=>       DAYS: (%i)", DataInterface.countDays(project: project))
            for day in DataInterface.getDays(project: project) {
                NSLog("=>           DATE: %@", day.date?.description ?? "N\\A")
                NSLog("=>           SR: %.2f", day.sr)
                NSLog("=>           CATEGORIES: (%i)", DataInterface.countCategories(day: day))
                for category in DataInterface.getCategories(day: day) {
                    NSLog("=>               NAME: %@", category.name ?? "N\\A")
                    NSLog("=>               TASKS: (%i)", DataInterface.countTasks(category: category))
                    for task in DataInterface.getTasks(category: category) {
                        NSLog("=>                   COMPLETION PERCENTAGE: %.2f", task.completionPercentage)
                        NSLog("=>                   INITIAL COMPLETION PERCENTAGE: %.2f", task.initialCompletionPercentage)
                        NSLog("=>                   CREATION DATE: %@", task.creationDate?.description ?? "N\\A")
                        NSLog("=>                   NAME: %@", task.name ?? "N\\A")
                        NSLog("=>                   NOTE: %@", task.note ?? "N\\A")
                        NSLog("=>                   STATE: %@", task.state ?? "N\\A")
                        NSLog("=>                   ------")
                    }
                    NSLog("=>               ------")
                }
                NSLog("=>           ------")
            }
            NSLog("=>       ------")
        }
        NSLog("=> COREDATA DUMP ######")
        
        return self
    }
}
