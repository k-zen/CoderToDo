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
    static func getProjects(sortBy: ProjectSorting) -> [Project]
    {
        if let projects = DataInterface.getUser()?.project?.allObjects as? [Project] {
            switch sortBy {
            case ProjectSorting.closingTimeDescending:
                return projects.sorted {
                    let now = Date()
                    
                    let n1 = $0.closingTime as? Date ?? now
                    let n2 = $1.closingTime as? Date ?? now
                    
                    return n1.compare(n2) == ComparisonResult.orderedDescending ? true : false
                }
            case ProjectSorting.closingTimeAscending:
                return projects.sorted {
                    let now = Date()
                    
                    let n1 = $0.closingTime as? Date ?? now
                    let n2 = $1.closingTime as? Date ?? now
                    
                    return n1.compare(n2) == ComparisonResult.orderedAscending ? true : false
                }
            case ProjectSorting.creationDateDescending:
                return projects.sorted {
                    let now = Date()
                    
                    let n1 = $0.creationDate as? Date ?? now
                    let n2 = $1.creationDate as? Date ?? now
                    
                    return n1.compare(n2) == ComparisonResult.orderedDescending ? true : false
                }
            case ProjectSorting.creationDateAscending:
                return projects.sorted {
                    let now = Date()
                    
                    let n1 = $0.creationDate as? Date ?? now
                    let n2 = $1.creationDate as? Date ?? now
                    
                    return n1.compare(n2) == ComparisonResult.orderedAscending ? true : false
                }
            case ProjectSorting.nameDescending:
                return projects.sorted {
                    let n1 = $0.name ?? ""
                    let n2 = $1.name ?? ""
                    
                    return n1 > n2
                }
            case ProjectSorting.nameAscending:
                return projects.sorted {
                    let n1 = $0.name ?? ""
                    let n2 = $1.name ?? ""
                    
                    return n1 < n2
                }
            case ProjectSorting.osrDescending:
                return projects.sorted {
                    let n1 = $0.osr
                    let n2 = $1.osr
                    
                    return n1 > n2
                }
            case ProjectSorting.osrAscending:
                return projects.sorted {
                    let n1 = $0.osr
                    let n2 = $1.osr
                    
                    return n1 < n2
                }
            }
        }
        else {
            return []
        }
    }
    
    static func countProjects() -> Int { return DataInterface.getUser()?.project?.allObjects.count ?? 0 }
    
    static func countProjectPendingTasks(element: Project) -> Int
    {
        var counter = 0
        
        if let days = element.days?.allObjects as? [Day] {
            for day in days {
                if let tasks = day.task?.allObjects as? [Task] {
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
        if let startingTime = element.startingTime as? Date, let closingTime = element.closingTime as? Date {
            let now = Date()
            
            var gmtCalendar = Calendar.current
            gmtCalendar.timeZone = TimeZone(identifier: "GMT")!
            
            let nowHour = 100 * (Calendar.current.dateComponents([.hour], from: now).hour ?? 0) + (Calendar.current.dateComponents([.minute], from: now).minute ?? 0)
            let startingTimeHour = 100 * (gmtCalendar.dateComponents([.hour], from: startingTime).hour ?? 0) + (gmtCalendar.dateComponents([.minute], from: startingTime).minute ?? 0)
            let closingTimeHour = 100 * (gmtCalendar.dateComponents([.hour], from: closingTime).hour ?? 0) + (gmtCalendar.dateComponents([.minute], from: closingTime).minute ?? 0)
            
            // First check if the user is within the working day.
            if nowHour >= startingTimeHour && nowHour <= closingTimeHour + Int(element.closingTimeTolerance) {
                if GlobalConstants.AKDebug {
                    NSLog("=> INFO: USER IS WITHIN WORKING DAY.")
                    NSLog("=> INFO: NOW HOUR: %i", nowHour)
                    NSLog("=> INFO: STARTING HOUR: %i", startingTimeHour)
                    NSLog("=> INFO: CLOSING HOUR: %i", closingTimeHour)
                }
                
                return true
            }
            else {
                if GlobalConstants.AKDebug {
                    NSLog("=> INFO: USER IS NOT WITHIN WORKING DAY.")
                    NSLog("=> INFO: NOW HOUR: %i", nowHour)
                    NSLog("=> INFO: STARTING HOUR: %i", startingTimeHour)
                    NSLog("=> INFO: CLOSING HOUR: %i", closingTimeHour)
                }
                
                return false
            }
        }
        
        return false
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
            
            if nowHour >= closingTimeHour && nowHour <= closingTimeHour + 60 {
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
            let interval = Date().timeIntervalSince(creationDate)
            let runningDays = (((interval / 60.0) / 60.0) / 24.0)
            
            if GlobalConstants.AKDebug {
                NSLog("=> INFO: PROJECT RUNNING DAYS: %.3f", runningDays)
            }
            
            return Int(runningDays)
        }
        
        return 0
    }
    // ########## PROJECT'S FUNCTIONS ########## //
}
