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
            for day in days { // Iterate all days.
                if let categories = day.categories?.allObjects as? [Category] {
                    for category in categories { // Foreach day iterate categories.
                        if let tasks = category.tasks?.allObjects as? [Task] {
                            for task in tasks { // Count pending tasks in each category.
                                if task.state == TaskStates.PENDING.rawValue {
                                    counter += 1
                                }
                            }
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
            
            return abs(runningDays)
        }
        
        return 0
    }
    
    static func addNewWorkingDay(project: Project) -> Day?
    {
        if let mr = Func.AKObtainMasterReference() {
            let now = Date()
            let tomorrow = Func.AKGetCalendarForLoading().date(byAdding: .day, value: 1, to: now)!
            let tomorrowDateComponents = Func.AKGetCalendarForLoading().dateComponents([.day, .month, .year], from: tomorrow)
            let d1 = tomorrowDateComponents.day ?? 0
            let m1 = tomorrowDateComponents.month ?? 0
            let y1 = tomorrowDateComponents.year ?? 0
            
            // Check if the project already contains tomorrow.
            var alreadyContainsDate = false
            var foundDay: Day?
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
                            foundDay = day
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
                        project.addToDays(day)
                        
                        return day
                    }
                }
            }
            else {
                return foundDay!
            }
        }
        
        return nil
    }
    
    static func updateDay(project: Project, updatedDay: Day) -> Bool
    {
        if let dayToLook = updatedDay.date as? Date {
            let dayToLookDateComponents = Func.AKGetCalendarForLoading().dateComponents([.day, .month, .year], from: dayToLook)
            let d1 = dayToLookDateComponents.day ?? 0
            let m1 = dayToLookDateComponents.month ?? 0
            let y1 = dayToLookDateComponents.year ?? 0
            
            var alreadyContainsDate = false
            var foundDay: Day?
            if let days = project.days?.allObjects as? [Day] {
                for day in days {
                    if let date = day.date as? Date {
                        let dateComponents = Func.AKGetCalendarForLoading().dateComponents([.day, .month, .year], from: date)
                        let d2 = dateComponents.day ?? 0
                        let m2 = dateComponents.month ?? 0
                        let y2 = dateComponents.year ?? 0
                        
                        if GlobalConstants.AKDebug {
                            NSLog("=> INFO: DAYTOLOOK (%@), DATE (%@)", dayToLook.description, date.description)
                        }
                        
                        if (d1 == d2) && (m1 == m2) && (y1 == y2) {
                            alreadyContainsDate = true
                            foundDay = day
                            break
                        }
                    }
                }
            }
            
            if alreadyContainsDate {
                project.removeFromDays(foundDay!)
                project.addToDays(updatedDay)
                
                return true
            }
        }
        
        return false
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
            let now = Date()
            let nowDateComponents = Func.AKGetCalendarForLoading().dateComponents([.day, .month, .year], from: now)
            let d1 = nowDateComponents.day ?? 0
            let m1 = nowDateComponents.month ?? 0
            let y1 = nowDateComponents.year ?? 0
            
            let tomorrow = Func.AKGetCalendarForLoading().date(byAdding: .day, value: 1, to: now)!
            let tomorrowDateComponents = Func.AKGetCalendarForLoading().dateComponents([.day, .month, .year], from: tomorrow)
            let d2 = tomorrowDateComponents.day ?? 0
            let m2 = tomorrowDateComponents.month ?? 0
            let y2 = tomorrowDateComponents.year ?? 0
            
            let yesterday = Func.AKGetCalendarForLoading().date(byAdding: .day, value: -1, to: now)!
            let yesterdayDateComponents = Func.AKGetCalendarForLoading().dateComponents([.day, .month, .year], from: yesterday)
            let d3 = yesterdayDateComponents.day ?? 0
            let m3 = yesterdayDateComponents.month ?? 0
            let y3 = yesterdayDateComponents.year ?? 0
            
            let d = Func.AKGetCalendarForLoading().dateComponents([.day], from: date).day ?? 0
            let m = Func.AKGetCalendarForLoading().dateComponents([.month], from: date).month ?? 0
            let y = Func.AKGetCalendarForLoading().dateComponents([.year], from: date).year ?? 0
            
            if d == d1 && m == m1 && y == y1 {
                return "Today"
            }
            else if d == d2 && m == m2 && y == y2 {
                return "Tomorrow"
            }
            else if d == d3 && m == m3 && y == y3 {
                return "Yesterday"
            }
            else {
                return String(format: "%.2i/%.2i/%.4i", m, d, y)
            }
        }
        
        return "N\\A"
    }
    // ########## DAY'S FUNCTIONS ########## //
    // ########## CATEGORY'S FUNCTIONS ########## //
    static func listCategoriesInProject(project: Project) -> [String]
    {
        if let projectCategories = project.projectCategories?.allObjects as? [ProjectCategory] {
            return projectCategories.sorted {
                let n1 = $0.name ?? ""
                let n2 = $1.name ?? ""
                
                return n1 < n2
                }.map({ $0.name! })
        }
        
        return []
    }
    
    static func getCategories(day: Day) -> [Category]
    {
        if let categories = day.categories?.allObjects as? [Category] {
            return categories.sorted {
                let n1 = $0.name ?? ""
                let n2 = $1.name ?? ""
                
                return n1 < n2
            }
        }
        
        return []
    }
    
    static func getCategoryByName(day: Day, name: String) -> Category?
    {
        if let categories = day.categories?.allObjects as? [Category] {
            for category in categories {
                if name.caseInsensitiveCompare(category.name!) == ComparisonResult.orderedSame {
                    return category
                }
            }
        }
        
        return nil
    }
    
    static func countCategories(day: Day) -> Int { return day.categories?.allObjects.count ?? 0 }
    // ########## CATEGORY'S FUNCTIONS ########## //
    // ########## TASK'S FUNCTIONS ########## //
    static func getTasks(category: Category) -> [Task]
    {
        if let tasks = category.tasks?.allObjects as? [Task] {
            return tasks.sorted {
                let now = Date()
                
                let n1 = $0.creationDate as? Date ?? now
                let n2 = $1.creationDate as? Date ?? now
                
                return n1.compare(n2) == ComparisonResult.orderedDescending ? true : false
            }
        }
        
        return []
    }
    
    static func countTasks(category: Category) -> Int { return category.tasks?.allObjects.count ?? 0 }
    
    static func countAllTasksInDay(day: Day) -> Int
    {
        var counter = 0
        
        if let categories = day.categories?.allObjects as? [Category] {
            for category in categories {
                if let tasks = category.tasks?.allObjects as? [Task] {
                    counter += tasks.count
                }
            }
        }
        
        return counter
    }
    // ########## TASK'S FUNCTIONS ########## //
}
