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
    
    static func countProjectPendingTasks(project: Project) -> Int
    {
        var counter = 0
        
        if let days = project.days?.allObjects as? [Day] {
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
    
    static func isProjectWithinWorkingDay(project: Project) -> Bool
    {
        return DataInterface.getProjectStatus(project: project) == ProjectStatus.OPEN ? true : false
    }
    
    static func getProjectStatus(project: Project) -> ProjectStatus
    {
        if let startingTime = project.startingTime as? Date, let closingTime = project.closingTime as? Date {
            let now = Date()
            
            let nowHour = 100 * (Func.AKGetCalendarForLoading().dateComponents([.hour], from: now).hour ?? 0) + (Func.AKGetCalendarForLoading().dateComponents([.minute], from: now).minute ?? 0)
            let startingTimeHour = 100 * (Func.AKGetCalendarForLoading().dateComponents([.hour], from: startingTime).hour ?? 0) + (Func.AKGetCalendarForLoading().dateComponents([.minute], from: startingTime).minute ?? 0)
            let closingTimeHour = 100 * (Func.AKGetCalendarForLoading().dateComponents([.hour], from: closingTime).hour ?? 0) + (Func.AKGetCalendarForLoading().dateComponents([.minute], from: closingTime).minute ?? 0)
            
            if nowHour >= closingTimeHour && nowHour <= closingTimeHour + (GlobalConstants.AKAcceptingTasksDefaultTime - closingTimeHour) {
                if GlobalConstants.AKDebug {
                    NSLog("=> INFO: WORKING DAY FINISHED.")
                    NSLog("=> INFO: NOW HOUR: %i", nowHour)
                    NSLog("=> INFO: STARTING HOUR: %i", startingTimeHour)
                    NSLog("=> INFO: CLOSING HOUR: %i", closingTimeHour)
                }
                
                return ProjectStatus.ACEPTING_TASKS
            }
            else if nowHour >= startingTimeHour && nowHour <= closingTimeHour + Int(project.closingTimeTolerance) {
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
    
    static func getProjectRunningDays(project: Project) -> Int
    {
        if let creationDate = project.creationDate as? Date {
            let now = Date()
            
            let runningDays = Func.AKGetCalendarForLoading().dateComponents([.day], from: now, to: creationDate).day ?? 0
            
            if GlobalConstants.AKDebug {
                NSLog("=> INFO: PROJECT RUNNING DAYS: %i", runningDays)
            }
            
            return runningDays
        }
        
        return 0
    }
    
    static func addNewWorkingDay(project: Project)
    {
        if let mr = Func.AKObtainMasterReference() {
            let now = Date()
            let tomorrow = Func.AKGetCalendarForLoading().date(byAdding: .day, value: 1, to: now)!
            let nowDateComponents = Func.AKGetCalendarForLoading().dateComponents([.day, .month, .year], from: tomorrow)
            let d1 = nowDateComponents.day ?? 0
            let m1 = nowDateComponents.month ?? 0
            let y1 = nowDateComponents.year ?? 0
            
            // Check if the project already contains tomorrow.
            var alreadyContainsDate = false
            if let days = project.days?.allObjects as? [Day] {
                for day in days {
                    if let date = day.date as? Date {
                        let dateComponents = Func.AKGetCalendarForLoading().dateComponents([.day, .month, .year], from: date)
                        let d2 = dateComponents.day ?? 0
                        let m2 = dateComponents.month ?? 0
                        let y2 = dateComponents.year ?? 0
                        
                        if GlobalConstants.AKDebug {
                            NSLog("=> INFO: NOW (%@), TOMORROW (%@), DATE (%@)", now.description, tomorrow.description, date.description)
                        }
                        
                        if (d1 == d2) && (m1 == m2) && (y1 == y2) {
                            alreadyContainsDate = true
                            break
                        }
                    }
                }
            }
            
            if !alreadyContainsDate {
                // Add the next working day. That means:
                // 1. If it's a new day, but the working day has not begun yet. i.e. 00:00Hs. and the working day for the project is 09:00Hs. (DISCONTINUED)
                // 2. If it's a new day, but the working day has begun, then add for tomorrow. i.e. 17:01Hs. and the working day lasted until 17:00Hs.
                if let startingTime = project.startingTime as? Date, let closingTime = project.closingTime as? Date {
                    let nowHour = 100 * (Func.AKGetCalendarForLoading().dateComponents([.hour], from: now).hour ?? 0) + (Func.AKGetCalendarForLoading().dateComponents([.minute], from: now).minute ?? 0)
                    let startingTimeHour = 100 * (Func.AKGetCalendarForLoading().dateComponents([.hour], from: startingTime).hour ?? 0) + (Func.AKGetCalendarForLoading().dateComponents([.minute], from: startingTime).minute ?? 0)
                    let closingTimeHour = 100 * (Func.AKGetCalendarForLoading().dateComponents([.hour], from: closingTime).hour ?? 0) + (Func.AKGetCalendarForLoading().dateComponents([.minute], from: closingTime).minute ?? 0)
                    
                    if nowHour <= startingTimeHour {
                        if GlobalConstants.AKDebug {
                            NSLog("=> INFO: WORKING DAY NOT BEGUN YET (CLOSED). DOING NOTHING!")
                        }
                    }
                    else if nowHour >= closingTimeHour && nowHour <= closingTimeHour + (GlobalConstants.AKAcceptingTasksDefaultTime - closingTimeHour) {
                        if GlobalConstants.AKDebug {
                            NSLog("=> INFO: WORKING DAY ALREADY FINISHED. ADDING TOMORROW!")
                        }
                        
                        let day = Day(context: mr.getMOC())
                        day.date = Func.AKGetCalendarForSaving().date(byAdding: .day, value: 1, to: now)! as NSDate
                        
                        // ### For debug only!
                        // for k in 1...10 {
                        //     let task = Task(context: mr.getMOC())
                        //     task.name = String(format: "Testing tasks #%i.", k)
                        //     task.creationDate = now as NSDate
                        //
                        //     day.addToTasks(task)
                        // }
                        
                        project.addToDays(day)
                    }
                }
            }
        }
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
            let d = Func.AKGetCalendarForLoading().dateComponents([.day], from: date).day ?? 0
            let m = Func.AKGetCalendarForLoading().dateComponents([.month], from: date).month ?? 0
            let y = Func.AKGetCalendarForLoading().dateComponents([.year], from: date).year ?? 0
            
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
    // ########## CATEGORY'S FUNCTIONS ########## //
    static func getCategories(project: Project) -> [Category]
    {
        if let categories = project.categories?.allObjects as? [Category] {
            return categories.sorted {
                let n1 = $0.name ?? ""
                let n2 = $1.name ?? ""
                
                return n1 < n2
            }
        }
        
        return []
    }
    
    static func countCategories(project: Project) -> Int { return project.categories?.allObjects.count ?? 0 }
    // ########## CATEGORY'S FUNCTIONS ########## //
}