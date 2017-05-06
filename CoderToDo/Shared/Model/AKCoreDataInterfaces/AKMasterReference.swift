import CoreData
import Foundation

class AKMasterReference: NSObject
{
    // MARK: Properties
    /// The managed object context needed to handle the data.
    private let moc: NSManagedObjectContext
    /// This is the entry point to all data. Everything starts with the user data structure.
    var user: User? = nil
    
    // MARK: Initializers
    override init()
    {
        self.moc = DataController().getMOC()
        super.init()
        do {
            if let users = try self.moc.fetch(NSFetchRequest<NSFetchRequestResult>(entityName: Cons.AKUserMOEntityName)) as? [User] {
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
                if Cons.AKDebug {
                    NSLog("=> INFO: SAVED CORE DATA.")
                }
            }
            else {
                if Cons.AKDebug {
                    NSLog("=> INFO: THERE ARE NO CHANGES TO SAVE!")
                }
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
    func dump() -> Void
    {
        let data = NSMutableString()
        data.appendFormat("=>   USERNAME: %@\n", DataInterface.getUsername())
        data.appendFormat("=>       CREATION DATE: %@\n", DataInterface.getUser()?.creationDate?.description ?? "")
        data.appendFormat("=>       GMTOFFSET: %i\n", DataInterface.getUser()?.gmtOffset ?? 0)
        data.appendFormat("=>   CONFIGURATIONS:\n")
        if let configurations = DataInterface.getConfigurations() {
            data.appendFormat("=>       AUTOMATIC BACKUPS: %@\n", configurations.automaticBackups ? "YES" : "NO")
            data.appendFormat("=>       CLEANING MODE (TRANSIENT): %@\n", configurations.cleaningMode ? "YES" : "NO")
            data.appendFormat("=>       SHOW LOCAL NOTIFICATION MESSAGE: %@\n", configurations.showLocalNotificationMessage ? "YES" : "NO")
            data.appendFormat("=>       USE LOCAL NOTIFICATIONS: %@\n", configurations.useLocalNotifications ? "YES" : "NO")
            data.appendFormat("=>       WEEK FIRST DAY: %@\n", Func.AKGetDayOfWeekAsName(dayOfWeek: configurations.weekFirstDay) ?? "")
            data.appendFormat("=>       WEEK LAST DAY: %@\n", Func.AKGetDayOfWeekAsName(dayOfWeek: configurations.weekLastDay) ?? "")
        }
        data.appendFormat("=>   PROJECTS:\n")
        for project in DataInterface.getProjects(filter: Filter(projectFilter: FilterProject())) {
            data.appendFormat("=>       CLOSING TIME: %@\n", project.closingTime?.description ?? "")
            data.appendFormat("=>       CLOSING TIME TOLERANCE: %i\n", project.closingTimeTolerance)
            data.appendFormat("=>       CREATION DATE: %@\n", project.creationDate?.description ?? "")
            data.appendFormat("=>       GMTOFFSET: %i\n", project.gmtOffset)
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
                data.appendFormat("=>           MIGRATED: %@\n", taskInQueue.migrated ? "YES" : "NO")
                data.appendFormat("=>           NAME: %@\n", taskInQueue.name ?? "")
                data.appendFormat("=>           NOTE: %@\n", taskInQueue.note ?? "")
                data.appendFormat("=>           STATE: %@\n", taskInQueue.state ?? "")
                data.appendFormat("=>           TOTAL COMPLETION: %.2f\n", taskInQueue.totalCompletion)
                data.appendFormat("=>           ------\n")
            }
            data.appendFormat("=>       DILATE QUEUE: (%i)\n", DataInterface.countDilateTasks(project: project))
            for taskInQueue in DataInterface.getDilateTasks(project: project) {
                data.appendFormat("=>           COMPLETION PERCENTAGE: %.2f\n", taskInQueue.completionPercentage)
                data.appendFormat("=>           INITIAL COMPLETION PERCENTAGE: %.2f\n", taskInQueue.initialCompletionPercentage)
                data.appendFormat("=>           CREATION DATE: %@\n", taskInQueue.creationDate?.description ?? "")
                data.appendFormat("=>           MIGRATED: %@\n", taskInQueue.migrated ? "YES" : "NO")
                data.appendFormat("=>           NAME: %@\n", taskInQueue.name ?? "")
                data.appendFormat("=>           NOTE: %@\n", taskInQueue.note ?? "")
                data.appendFormat("=>           STATE: %@\n", taskInQueue.state ?? "")
                data.appendFormat("=>           TOTAL COMPLETION: %.2f\n", taskInQueue.totalCompletion)
                data.appendFormat("=>           ------\n")
            }
            data.appendFormat("=>       BUCKET: (%i)\n", DataInterface.countBucketEntries(project: project, forDate: ""))
            for bucketEntry in DataInterface.getBucketEntries(project: project, forDate: "") {
                data.appendFormat("=>           CREATION DATE: %@\n", bucketEntry.creationDate?.description ?? "")
                data.appendFormat("=>           GMTOFFSET: %i\n", bucketEntry.gmtOffset)
                data.appendFormat("=>           NAME: %@\n", bucketEntry.name ?? "")
                data.appendFormat("=>           PRIORITY: %i\n", bucketEntry.priority)
                data.appendFormat("=>           ------\n")
            }
            data.appendFormat("=>       DAYS: (%i)\n", DataInterface.countDays(project: project))
            for day in DataInterface.getDays(project: project) {
                data.appendFormat("=>           DATE: %@\n", day.date?.description ?? "")
                data.appendFormat("=>           GMTOFFSET: %i\n", day.gmtOffset)
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
                        data.appendFormat("=>                   MIGRATED: %@\n", task.migrated ? "YES" : "NO")
                        data.appendFormat("=>                   NAME: %@\n", task.name ?? "")
                        data.appendFormat("=>                   NOTE: %@\n", task.note ?? "")
                        data.appendFormat("=>                   STATE: %@\n", task.state ?? "")
                        data.appendFormat("=>                   TOTAL COMPLETION: %.2f\n", task.totalCompletion)
                        data.appendFormat("=>                   ------\n")
                    }
                    data.appendFormat("=>               ------\n")
                }
                data.appendFormat("=>           ------\n")
            }
            data.appendFormat("=>       ------\n")
        }
        
        if Cons.AKDebug {
            NSLog("=> COREDATA DUMP ######")
            NSLog("=> DATA HASH: %@", data.description.computeMD5() ?? "")
            print(data.description)
            NSLog("=> COREDATA DUMP ######")
        }
    }
}
