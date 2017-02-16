import Foundation

class AKDataInterface
{
    ///
    /// Returns the user data structure.
    ///
    /// - Returns: The user data structure.
    ///
    static func getUser() -> User?
    {
        return Func.AKObtainMasterReference()?.user
    }
    
    // ########## PROJECT'S FUNCTIONS ########## //
    static func getProjects(sortBy: ProjectSorting, order: SortingOrder) -> [Project]
    {
        if let projects = DataInterface.getUser()?.project?.allObjects as? [Project] {
            switch sortBy {
            case ProjectSorting.closingTime:
                return projects.sorted {
                    let now = Date()
                    
                    let n1 = $0.closingTime as? Date ?? now
                    let n2 = $1.closingTime as? Date ?? now
                    
                    return order == SortingOrder.descending ?
                        (n1.compare(n2) == ComparisonResult.orderedDescending ? true : false) :
                        (n1.compare(n2) == ComparisonResult.orderedAscending ? true : false)
                }
            case ProjectSorting.creationDate:
                return projects.sorted {
                    let now = Date()
                    
                    let n1 = $0.creationDate as? Date ?? now
                    let n2 = $1.creationDate as? Date ?? now
                    
                    return order == SortingOrder.descending ?
                        (n1.compare(n2) == ComparisonResult.orderedDescending ? true : false) :
                        (n1.compare(n2) == ComparisonResult.orderedAscending ? true : false)
                }
            case ProjectSorting.name:
                return projects.sorted {
                    let n1 = $0.name ?? ""
                    let n2 = $1.name ?? ""
                    
                    return order == SortingOrder.descending ? (n1 > n2) : (n1 < n2)
                }
            case ProjectSorting.osr:
                return projects.sorted {
                    let n1 = $0.osr
                    let n2 = $1.osr
                    
                    return order == SortingOrder.descending ? (n1 > n2) : (n1 < n2)
                }
            }
        }
        
        return []
    }
    
    static func countProjects() -> Int { return DataInterface.getUser()?.project?.allObjects.count ?? 0 }
    
    static func countProjectPendingTasks(element: Project) -> Int
    {
        var counter = 0
        
        if let days = element.days?.allObjects as? [Day] {
            for day in days {
                if let tasks = day.tasks?.allObjects as? [Task] {
                    for task in tasks {
                        if task.state == TaskStates.PENDING.rawValue {
                            counter += 1
                        }
                    }
                }
            }
        }
        
        return counter
    }
    
    static func isProjectWithinWorkingDay(element: Project) -> Bool
    {
        return DataInterface.getProjectStatus(element: element) == ProjectStatus.OPEN ? true : false
    }
    
    static func getProjectStatus(element: Project) -> ProjectStatus
    {
        if let startingTime = element.startingTime as? Date, let closingTime = element.closingTime as? Date {
            let now = Date()
            
            var gmtCalendar = Calendar.current
            gmtCalendar.timeZone = TimeZone(identifier: "GMT")!
            
            let nowHour = 100 * (Calendar.current.dateComponents([.hour], from: now).hour ?? 0) + (Calendar.current.dateComponents([.minute], from: now).minute ?? 0)
            let startingTimeHour = 100 * (gmtCalendar.dateComponents([.hour], from: startingTime).hour ?? 0) + (gmtCalendar.dateComponents([.minute], from: startingTime).minute ?? 0)
            let closingTimeHour = 100 * (gmtCalendar.dateComponents([.hour], from: closingTime).hour ?? 0) + (gmtCalendar.dateComponents([.minute], from: closingTime).minute ?? 0)
            
            if nowHour >= closingTimeHour && nowHour <= closingTimeHour + GlobalConstants.AKAcceptingTasksDefaultTime {
                if GlobalConstants.AKDebug {
                    NSLog("=> INFO: WORKING DAY FINISHED.")
                    NSLog("=> INFO: NOW HOUR: %i", nowHour)
                    NSLog("=> INFO: STARTING HOUR: %i", startingTimeHour)
                    NSLog("=> INFO: CLOSING HOUR: %i", closingTimeHour)
                }
                
                return ProjectStatus.ACEPTING_TASKS
            }
            else if nowHour >= startingTimeHour && nowHour <= closingTimeHour + Int(element.closingTimeTolerance) {
                if GlobalConstants.AKDebug {
                    NSLog("=> INFO: WORKING DAY OPEN.")
                    NSLog("=> INFO: NOW HOUR: %i", nowHour)
                    NSLog("=> INFO: STARTING HOUR: %i", startingTimeHour)
                    NSLog("=> INFO: CLOSING HOUR: %i", closingTimeHour)
                }
                
                return ProjectStatus.OPEN
            }
            else {
                if GlobalConstants.AKDebug {
                    NSLog("=> INFO: WORKING DAY CLOSED.")
                    NSLog("=> INFO: NOW HOUR: %i", nowHour)
                    NSLog("=> INFO: STARTING HOUR: %i", startingTimeHour)
                    NSLog("=> INFO: CLOSING HOUR: %i", closingTimeHour)
                }
                
                return ProjectStatus.CLOSED
            }
        }
        
        return ProjectStatus.CLOSED
    }
    
    static func getProjectRunningDays(element: Project) -> Int
    {
        if let creationDate = element.creationDate as? Date {
            let now = Date()
            
            var gmtCalendar = Calendar.current
            gmtCalendar.timeZone = TimeZone(identifier: "GMT")!
            
            let runningDays = gmtCalendar.dateComponents([.day], from: now, to: creationDate).day ?? 0
            
            if GlobalConstants.AKDebug {
                NSLog("=> INFO: PROJECT RUNNING DAYS: %i", runningDays)
            }
            
            return runningDays
        }
        
        return 0
    }
    // ########## PROJECT'S FUNCTIONS ########## //
    // ########## DAY'S FUNCTIONS ########## //
    static func getDays(project: Project) -> [Day]
    {
        if let days = project.days?.allObjects as? [Day] {
            return days.sorted {
                let now = Date()
                
                let n1 = $0.date as? Date ?? now
                let n2 = $1.date as? Date ?? now
                
                return n1.compare(n2) == ComparisonResult.orderedDescending ? true : false
            }
        }
        
        return []
    }
    
    static func countDays(project: Project) -> Int { return project.days?.allObjects.count ?? 0 }
    
    static func getDayTitle(day: Day) -> String
    {
        if let date = day.date as? Date {
            var gmtCalendar = Calendar.current
            gmtCalendar.timeZone = TimeZone(identifier: "GMT")!
            
            let d = gmtCalendar.dateComponents([.day], from: date).day ?? 0
            let m = gmtCalendar.dateComponents([.month], from: date).month ?? 0
            let y = gmtCalendar.dateComponents([.year], from: date).year ?? 0
            
            return String(format: "%.2i/%.2i/%.4i", m, d, y)
        }
        
        return "N\\A"
    }
    // ########## DAY'S FUNCTIONS ########## //
    // ########## TASK'S FUNCTIONS ########## //
    static func getTasks(day: Day) -> [Task]
    {
        if let tasks = day.tasks?.allObjects as? [Task] {
            return tasks.sorted {
                let now = Date()
                
                let n1 = $0.creationDate as? Date ?? now
                let n2 = $1.creationDate as? Date ?? now
                
                return n1.compare(n2) == ComparisonResult.orderedDescending ? true : false
            }
        }
        
        return []
    }
    
    static func countTasks(day: Day) -> Int { return day.tasks?.allObjects.count ?? 0 }
    // ########## TASK'S FUNCTIONS ########## //
}
