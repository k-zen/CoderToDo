import CoreData
import Foundation

class AKMasterReference: NSObject
{
    // MARK: Properties
    /// The managed object context needed to handle the data.
    private let moc: NSManagedObjectContext
    /// This is the entry point to all data. Everything starts with the user data structure.
    private var user: User? = nil
    
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
    
    func getUser() -> User? { return self.user }
    
    // MARK: Utilities
    ///
    /// This function loads the data into memory from persistence.
    ///
    /// - Returns: A reference file to the data.
    ///
    static func loadData() -> AKMasterReference { return AKMasterReference() }
    
    ///
    /// This function saves the data from memory into persistance.
    ///
    /// - Parameter instance: The instance containing the data.
    ///
    static func saveData(instance: AKMasterReference?)
    {
        do {
            if (instance?.moc.hasChanges)! {
                try instance?.moc.save()
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
    func dump()
    {
        let data = NSMutableString()
        data.appendFormat("=>   USERNAME: %@\n", DataInterface.getUsername())
        data.appendFormat("=>   PROJECTS:\n")
        for project in DataInterface.getProjects(filter: Filter(projectFilter: FilterProject())) {
            data.appendFormat("=>       CLOSING TIME: %@\n", project.closingTime?.description ?? "")
            data.appendFormat("=>       CLOSING TIME TOLERANCE: %i\n", project.closingTimeTolerance)
            data.appendFormat("=>       CREATION DATE: %@\n", project.creationDate?.description ?? "")
            data.appendFormat("=>       NAME: %@\n", project.name ?? "")
            data.appendFormat("=>       NOTIFY CLOSING TIME: %@\n", project.notifyClosingTime ? "YES" : "NO")
            data.appendFormat("=>       OSR: %.2f\n", project.osr)
            data.appendFormat("=>       STARTING TIME: %@\n", project.startingTime?.description ?? "")
            data.appendFormat("=>       PROJECT CATEGORIES: (%i)\n", DataInterface.countProjectCategories(project: project))
            for projectCategory in DataInterface.listProjectCategories(project: project) {
                data.appendFormat("=>           NAME: %@\n", projectCategory)
            }
            data.appendFormat("=>       PENDING QUEUE: (%i)\n", DataInterface.countPendingTasks(project: project))
            for taskInQueue in DataInterface.getPendingTasks(project: project) {
                data.appendFormat("=>           COMPLETION PERCENTAGE: %.2f\n", taskInQueue.completionPercentage)
                data.appendFormat("=>           INITIAL COMPLETION PERCENTAGE: %.2f\n", taskInQueue.initialCompletionPercentage)
                data.appendFormat("=>           CREATION DATE: %@\n", taskInQueue.creationDate?.description ?? "")
                data.appendFormat("=>           NAME: %@\n", taskInQueue.name ?? "")
                data.appendFormat("=>           NOTE: %@\n", taskInQueue.note ?? "")
                data.appendFormat("=>           STATE: %@\n", taskInQueue.state ?? "")
                data.appendFormat("=>           ------\n")
            }
            data.appendFormat("=>       DILATE QUEUE: (%i)\n", DataInterface.countDilateTasks(project: project))
            for taskInQueue in DataInterface.getDilateTasks(project: project) {
                data.appendFormat("=>           COMPLETION PERCENTAGE: %.2f\n", taskInQueue.completionPercentage)
                data.appendFormat("=>           INITIAL COMPLETION PERCENTAGE: %.2f\n", taskInQueue.initialCompletionPercentage)
                data.appendFormat("=>           CREATION DATE: %@\n", taskInQueue.creationDate?.description ?? "")
                data.appendFormat("=>           NAME: %@\n", taskInQueue.name ?? "")
                data.appendFormat("=>           NOTE: %@\n", taskInQueue.note ?? "")
                data.appendFormat("=>           STATE: %@\n", taskInQueue.state ?? "")
                data.appendFormat("=>           ------\n")
            }
            data.appendFormat("=>       DAYS: (%i)\n", DataInterface.countDays(project: project))
            for day in DataInterface.getDays(project: project) {
                data.appendFormat("=>           DATE: %@\n", day.date?.description ?? "")
                data.appendFormat("=>           SR: %.2f\n", day.sr)
                data.appendFormat("=>           CATEGORIES: (%i)\n", DataInterface.countCategories(day: day))
                for category in DataInterface.getCategories(day: day) {
                    var taskFilter = FilterTask()
                    taskFilter.sortType = TaskSorting.name
                    data.appendFormat("=>               NAME: %@\n", category.name ?? "")
                    data.appendFormat("=>               TASKS: (%i)\n", DataInterface.countTasksInCategory(category: category, filter: Filter(taskFilter: taskFilter)))
                    for task in DataInterface.getTasks(category: category, filter: Filter(taskFilter: taskFilter)) {
                        data.appendFormat("=>                   COMPLETION PERCENTAGE: %.2f\n", task.completionPercentage)
                        data.appendFormat("=>                   INITIAL COMPLETION PERCENTAGE: %.2f\n", task.initialCompletionPercentage)
                        data.appendFormat("=>                   CREATION DATE: %@\n", task.creationDate?.description ?? "")
                        data.appendFormat("=>                   NAME: %@\n", task.name ?? "")
                        data.appendFormat("=>                   NOTE: %@\n", task.note ?? "")
                        data.appendFormat("=>                   STATE: %@\n", task.state ?? "")
                        data.appendFormat("=>                   ------\n")
                    }
                    data.appendFormat("=>               ------\n")
                }
                data.appendFormat("=>           ------\n")
            }
            data.appendFormat("=>       ------\n")
        }
        
        NSLog("=> COREDATA DUMP ######")
        NSLog("=> DATA HASH: %@", data.description.computeMD5() ?? "")
        print(data.description)
        NSLog("=> COREDATA DUMP ######")
    }
}
