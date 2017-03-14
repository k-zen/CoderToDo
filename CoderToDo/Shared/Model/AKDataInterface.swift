import Foundation

class AKDataInterface
{
    ///
    /// Returns the user data structure.
    ///
    /// - Returns: The user data structure.
    ///
    static func getUser() -> User? { return Func.AKObtainMasterReference()?.getUser() }
    
    static func getUsername() -> String { return (DataInterface.getUser()?.username)! }
    
    // ########## PROJECT'S FUNCTIONS ########## //
    ///
    /// Computes the list of projects using filters passed in by the user, or default
    /// filters if none had been set.
    ///
    /// - Parameter filter: The filter to be used in the list.
    ///
    /// - Returns: A list of projects.
    ///
    static func getProjects(filter: Filter) -> [Project]
    {
        // Check the filter.
        if let projectFilter = filter.projectFilter {
            if let projects = DataInterface.getUser()?.project?.allObjects as? [Project] {
                // The total projects.
                var result = projects
                
                // Sort projects.
                switch projectFilter.sortType {
                case .closingTime:
                    result = result.sorted {
                        let now = Date()
                        let n1 = $0.closingTime as? Date ?? now
                        let n2 = $1.closingTime as? Date ?? now
                        
                        return projectFilter.sortOrder == SortingOrder.descending ?
                            (n1.compare(n2) == ComparisonResult.orderedDescending ? true : false) :
                            (n1.compare(n2) == ComparisonResult.orderedAscending ? true : false)
                    }
                    break
                case .creationDate:
                    result = result.sorted {
                        let now = Date()
                        let n1 = $0.creationDate as? Date ?? now
                        let n2 = $1.creationDate as? Date ?? now
                        
                        return projectFilter.sortOrder == SortingOrder.descending ?
                            (n1.compare(n2) == ComparisonResult.orderedDescending ? true : false) :
                            (n1.compare(n2) == ComparisonResult.orderedAscending ? true : false)
                    }
                    break
                case .name:
                    result = result.sorted {
                        let n1 = $0.name ?? ""
                        let n2 = $1.name ?? ""
                        
                        return projectFilter.sortOrder == SortingOrder.descending ? (n1 > n2) : (n1 < n2)
                    }
                    break
                case .osr:
                    result = result.sorted {
                        let n1 = $0.osr
                        let n2 = $1.osr
                        
                        return projectFilter.sortOrder == SortingOrder.descending ? (n1 > n2) : (n1 < n2)
                    }
                    break
                }
                
                // Filter projects.
                switch projectFilter.filterType {
                case .status:
                    result = result.filter({ (project) -> Bool in
                        return projectFilter.filterValue == .none ? true : DataInterface.getProjectStatus(project: project).rawValue == projectFilter.filterValue.rawValue
                    })
                    break
                }
                
                // Match a search term.
                switch projectFilter.searchTerm {
                default:
                    result = result.filter({ (project) -> Bool in
                        return projectFilter.searchTerm.match(otherTerms: [project.name])
                    })
                    break
                }
                
                return result
            }
        }
        
        return []
    }
    
    static func countProjectPendingTasks(project: Project) -> Int
    {
        var counter = 0
        
        if let days = project.days?.allObjects as? [Day] {
            for day in days { // Iterate all days.
                if let categories = day.categories?.allObjects as? [Category] {
                    for category in categories { // Foreach day iterate categories.
                        if let tasks = category.tasks?.allObjects as? [Task] {
                            for task in tasks { // Count pending tasks in each category.
                                if task.state == TaskStates.pending.rawValue {
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
    
    ///
    /// This function will check if a given project is open or closed.
    ///
    /// - Parameter project: The project to check.
    ///
    /// - Returns: TRUE if the project is "OPEN" (check for documentation to see when a project can be open), FALSE otherwise.
    ///
    static func isProjectOpen(project: Project) -> Bool
    {
        if let startingTime = project.startingTime as? Date, let closingTime = project.closingTime as? Date {
            let now = Date()
            let nowHour = 100 * (Func.AKGetCalendarForLoading().dateComponents([.hour], from: now).hour ?? 0) + (Func.AKGetCalendarForLoading().dateComponents([.minute], from: now).minute ?? 0)
            let startingTimeHour = 100 * (Func.AKGetCalendarForLoading().dateComponents([.hour], from: startingTime).hour ?? 0) + (Func.AKGetCalendarForLoading().dateComponents([.minute], from: startingTime).minute ?? 0)
            let closingTimeHour = 100 * (Func.AKGetCalendarForLoading().dateComponents([.hour], from: closingTime).hour ?? 0) + (Func.AKGetCalendarForLoading().dateComponents([.minute], from: closingTime).minute ?? 0)
            
            return nowHour >= startingTimeHour && nowHour <= closingTimeHour + Int(project.closingTimeTolerance)
        }
        
        return false
    }
    
    static func isBeforeOpen(project: Project) -> Bool
    {
        if let startingTime = project.startingTime as? Date {
            let now = Date()
            let nowHour = 100 * (Func.AKGetCalendarForLoading().dateComponents([.hour], from: now).hour ?? 0) + (Func.AKGetCalendarForLoading().dateComponents([.minute], from: now).minute ?? 0)
            let startingTimeHour = 100 * (Func.AKGetCalendarForLoading().dateComponents([.hour], from: startingTime).hour ?? 0) + (Func.AKGetCalendarForLoading().dateComponents([.minute], from: startingTime).minute ?? 0)
            
            return nowHour >= GlobalConstants.AKWorkingDayStartTime && nowHour < startingTimeHour
        }
        
        return false
    }
    
    static func getProjectStatus(project: Project) -> ProjectStatus
    {
        if let startingTime = project.startingTime as? Date, let closingTime = project.closingTime as? Date, let creationTime = project.creationDate as? Date {
            let now = Date()
            let nowHour = 100 * (Func.AKGetCalendarForLoading().dateComponents([.hour], from: now).hour ?? 0) + (Func.AKGetCalendarForLoading().dateComponents([.minute], from: now).minute ?? 0)
            let startingTimeHour = 100 * (Func.AKGetCalendarForLoading().dateComponents([.hour], from: startingTime).hour ?? 0) + (Func.AKGetCalendarForLoading().dateComponents([.minute], from: startingTime).minute ?? 0)
            let closingTimeHour = 100 * (Func.AKGetCalendarForLoading().dateComponents([.hour], from: closingTime).hour ?? 0) + (Func.AKGetCalendarForLoading().dateComponents([.minute], from: closingTime).minute ?? 0)
            
            // ###### FIRST DAY
            // Special case when the user opens the App for the first time. This is called *First Day*.
            let nowDateComponents = Func.AKGetCalendarForLoading().dateComponents([.day, .month, .year], from: now)
            let d1 = nowDateComponents.day ?? 0
            let m1 = nowDateComponents.month ?? 0
            let y1 = nowDateComponents.year ?? 0
            
            let creationDateComponents = Func.AKGetCalendarForLoading().dateComponents([.day, .month, .year], from: creationTime)
            let d2 = creationDateComponents.day ?? 0
            let m2 = creationDateComponents.month ?? 0
            let y2 = creationDateComponents.year ?? 0
            
            if nowHour >= GlobalConstants.AKWorkingDayStartTime && nowHour < closingTimeHour && ((d1 == d2) && (m1 == m2) && (y1 == y2)) {
                return .firstDay
            }
            // ###### FIRST DAY
            
            // ###### NORMAL DAY
            if nowHour >= closingTimeHour && nowHour <= GlobalConstants.AKAcceptingTasksDefaultMaxTime {
                return .accepting
            }
            else if nowHour >= startingTimeHour && nowHour <= closingTimeHour + Int(project.closingTimeTolerance) {
                return .open
            }
            else {
                return .closed
            }
            // ###### NORMAL DAY
        }
        
        return .closed
    }
    
    static func getProjectRunningDays(project: Project) -> Int
    {
        if let creationDate = project.creationDate as? Date {
            let now = Date()
            let runningDays = Func.AKGetCalendarForLoading().dateComponents([.day], from: now, to: creationDate).day ?? 0
            
            return abs(runningDays)
        }
        
        return 0
    }
    
    static func addNewWorkingDay(project: Project) -> Day?
    {
        if let mr = Func.AKObtainMasterReference() {
            let now = Date()
            // This is a very special case where the user has just downloaded the application and is
            // ready to start adding days while the working day is OPEN, and it's called FIRST_DAY.
            // Only one time we must allow this to happen. This modification is to allow the user
            // to create tasks for the current day!
            let tomorrow: Date!
            if DataInterface.getProjectStatus(project: project) == .firstDay {
                tomorrow = Func.AKGetCalendarForLoading().date(byAdding: .day, value: 0, to: now)!
            }
            else {
                tomorrow = Func.AKGetCalendarForLoading().date(byAdding: .day, value: 1, to: now)!
            }
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
                    
                    // This is a very special case where the user has just downloaded the application and is
                    // ready to start adding days while the working day is OPEN, and it's called FIRST_DAY.
                    // Only one time we must allow this to happen. This modification is to allow the user
                    // to create tasks for the current day!
                    if DataInterface.getProjectStatus(project: project) == .firstDay {
                        if GlobalConstants.AKDebug {
                            NSLog("=> INFO: WORKING DAY IS FIRST DAY. ADDING TODAY!")
                        }
                        
                        let day = Day(context: mr.getMOC())
                        day.date = Func.AKGetCalendarForSaving().date(byAdding: .day, value: 0, to: now)! as NSDate
                        project.addToDays(day)
                        
                        return day
                    }
                    
                    if nowHour <= startingTimeHour {
                        if GlobalConstants.AKDebug {
                            NSLog("=> INFO: WORKING DAY NOT BEGUN YET (CLOSED). DOING NOTHING!")
                        }
                    }
                    else if nowHour >= closingTimeHour + Int(project.closingTimeTolerance) && nowHour <= GlobalConstants.AKAcceptingTasksDefaultMaxTime {
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
    
    static func computeOSR(project: Project) -> Float
    {
        var osr: Float = 0.0
        var counter: Float = 0.0
        
        if let days = project.days?.allObjects as? [Day] {
            for day in days {
                osr += (DataInterface.computeSRForDay(day: day) / 100.0)
                counter += 1
            }
        }
        
        project.osr = counter > 0 ? (osr / counter) * 100 : 0.0
        
        return project.osr
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
    
    static func countDays(project: Project) -> Int { return project.days?.count ?? 0 }
    
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
    
    static func getDayStatus(day: Day) -> DayStatus
    {
        let now = Date()
        let nowDateComponents = Func.AKGetCalendarForLoading().dateComponents([.day, .month, .year], from: now)
        let d1 = nowDateComponents.day ?? 0
        let m1 = nowDateComponents.month ?? 0
        let y1 = nowDateComponents.year ?? 0
        
        if let date = day.date as? Date {
            let dateComponents = Func.AKGetCalendarForLoading().dateComponents([.day, .month, .year], from: date)
            let d2 = dateComponents.day ?? 0
            let m2 = dateComponents.month ?? 0
            let y2 = dateComponents.year ?? 0
            
            if (d1 == d2) && (m1 == m2) && (y1 == y2) {
                return .current
            }
        }
        
        return .notCurrent
    }
    
    static func isDayToday(day: Day) -> Bool
    {
        let now = Date()
        let today = Func.AKGetCalendarForLoading().date(byAdding: .day, value: 0, to: now)!
        let todayDateComponents = Func.AKGetCalendarForLoading().dateComponents([.day, .month, .year], from: today)
        let d1 = todayDateComponents.day ?? 0
        let m1 = todayDateComponents.month ?? 0
        let y1 = todayDateComponents.year ?? 0
        
        if let date = day.date as? Date {
            let dateComponents = Func.AKGetCalendarForLoading().dateComponents([.day, .month, .year], from: date)
            let d2 = dateComponents.day ?? 0
            let m2 = dateComponents.month ?? 0
            let y2 = dateComponents.year ?? 0
            
            if (d1 == d2) && (m1 == m2) && (y1 == y2) {
                return true
            }
        }
        
        return false
    }
    
    static func isDayTomorrow(day: Day) -> Bool
    {
        let now = Date()
        let tomorrow = Func.AKGetCalendarForLoading().date(byAdding: .day, value: 1, to: now)!
        let tomorrowDateComponents = Func.AKGetCalendarForLoading().dateComponents([.day, .month, .year], from: tomorrow)
        let d1 = tomorrowDateComponents.day ?? 0
        let m1 = tomorrowDateComponents.month ?? 0
        let y1 = tomorrowDateComponents.year ?? 0
        
        if let date = day.date as? Date {
            let dateComponents = Func.AKGetCalendarForLoading().dateComponents([.day, .month, .year], from: date)
            let d2 = dateComponents.day ?? 0
            let m2 = dateComponents.month ?? 0
            let y2 = dateComponents.year ?? 0
            
            if (d1 == d2) && (m1 == m2) && (y1 == y2) {
                return true
            }
        }
        
        return false
    }
    
    static func computeSRForDay(day: Day) -> Float
    {
        var sr: Float = 0.0
        var counter: Float = 0.0
        
        if let categories = day.categories?.allObjects as? [Category] {
            for category in categories {
                if let tasks = category.tasks?.allObjects as? [Task] {
                    for task in tasks {
                        if task.state != TaskStates.dilate.rawValue && task.state != TaskStates.notApplicable.rawValue {
                            sr += (task.completionPercentage / 100.0)
                            counter += 1
                        }
                    }
                }
            }
        }
        
        day.sr = counter > 0 ? (sr / counter) * 100 : 0.0
        
        return day.sr
    }
    // ########## DAY'S FUNCTIONS ########## //
    // ########## CATEGORY'S FUNCTIONS ########## //
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
    
    static func countCategories(day: Day) -> Int { return day.categories?.count ?? 0 }
    // ########## CATEGORY'S FUNCTIONS ########## //
    // ########## TASK'S FUNCTIONS ########## //
    ///
    /// Computes the list of tasks using filters passed in by the user, or default
    /// filters if none had been set.
    ///
    /// - Parameter filter: The filter to be used in the list.
    ///
    /// - Returns: A list of tasks.
    ///
    static func getTasks(category: Category, filter: Filter) -> [Task]
    {
        // Check the filter.
        if let taskFilter = filter.taskFilter {
            if let tasks = category.tasks?.allObjects as? [Task] {
                var result = tasks
                
                // Sort tasks.
                switch taskFilter.sortType {
                case .completionPercentage:
                    result = result.sorted {
                        let n1 = $0.completionPercentage
                        let n2 = $1.completionPercentage
                        
                        return taskFilter.sortOrder == SortingOrder.descending ? (n1 > n2) : (n1 < n2)
                    }
                    break
                case .creationDate:
                    result = result.sorted {
                        let now = Date()
                        let n1 = $0.creationDate as? Date ?? now
                        let n2 = $1.creationDate as? Date ?? now
                        
                        return taskFilter.sortOrder == SortingOrder.descending ?
                            (n1.compare(n2) == ComparisonResult.orderedDescending ? true : false) :
                            (n1.compare(n2) == ComparisonResult.orderedAscending ? true : false)
                    }
                    break
                case .name:
                    result = result.sorted {
                        let n1 = $0.name ?? ""
                        let n2 = $1.name ?? ""
                        
                        return taskFilter.sortOrder == SortingOrder.descending ? (n1 > n2) : (n1 < n2)
                    }
                    break
                case .state:
                    result = result.sorted {
                        let n1 = $0.state ?? ""
                        let n2 = $1.state ?? ""
                        
                        return taskFilter.sortOrder == SortingOrder.descending ? (n1 > n2) : (n1 < n2)
                    }
                    break
                }
                
                switch taskFilter.filterType {
                case .state:
                    result = result.filter({ (task) -> Bool in
                        return taskFilter.filterValue == .none ? true : task.state?.caseInsensitiveCompare(taskFilter.filterValue.rawValue) == .orderedSame
                    })
                    break
                }
                
                switch taskFilter.searchTerm {
                default:
                    result = result.filter({ (task) -> Bool in
                        return taskFilter.searchTerm.match(otherTerms: [task.name, task.note])
                    })
                    break
                }
                
                return result
            }
        }
        
        return []
    }
    
    ///
    /// Counts all tasks in a given day. It respects the use of filters,
    /// because sometimes we need to count tasks in a day which
    /// had been filtered by the user.
    ///
    /// - Parameter day: The day where to count tasks.
    /// - Parameter filter: The filter to be used in the list.
    ///
    /// - Returns: The task's count.
    ///
    static func countTasksInDay(day: Day, filter: Filter) -> Int
    {
        var counter = 0
        if let categories = day.categories?.allObjects as? [Category] {
            for category in categories {
                counter += DataInterface.getTasks(category: category, filter: filter).count
            }
        }
        
        return counter
    }
    
    ///
    /// Counts all tasks in a given category. It respects the use of filters,
    /// because sometimes we need to count tasks in a category which
    /// had been filtered by the user.
    ///
    /// - Parameter category: The category where to count tasks.
    /// - Parameter filter: The filter to be used in the list.
    ///
    /// - Returns: The task's count.
    ///
    static func countTasksInCategory(category: Category, filter: Filter) -> Int { return DataInterface.getTasks(category: category, filter: filter).count }
    
    static func getPendingTasks(project: Project) -> [Task]
    {
        if let tasks = project.pendingQueue?.tasks?.allObjects as? [Task] {
            return tasks.sorted {
                let n1 = $0.name ?? ""
                let n2 = $1.name ?? ""
                
                return n1 < n2
            }
        }
        
        return []
    }
    
    static func countPendingTasks(project: Project) -> Int { return project.pendingQueue?.tasks?.count ?? 0 }
    
    static func getDilateTasks(project: Project) -> [Task]
    {
        if let tasks = project.dilateQueue?.tasks?.allObjects as? [Task] {
            return tasks.sorted {
                let n1 = $0.name ?? ""
                let n2 = $1.name ?? ""
                
                return n1 < n2
            }
        }
        
        return []
    }
    
    static func countDilateTasks(project: Project) -> Int { return project.dilateQueue?.tasks?.count ?? 0 }
    // ########## TASK'S FUNCTIONS ########## //
    // ########## PROJECTCATEGORIES' FUNCTIONS ########## //
    static func listProjectCategories(project: Project) -> [String]
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
    
    static func countProjectCategories(project: Project) -> Int { return project.projectCategories?.count ?? 0 }
    
    static func getProjectCategoryByName(project: Project, name: String) -> ProjectCategory?
    {
        if let projectCategories = project.projectCategories?.allObjects as? [ProjectCategory] {
            for projectCategory in projectCategories {
                if name.caseInsensitiveCompare(projectCategory.name!) == ComparisonResult.orderedSame {
                    return projectCategory
                }
            }
        }
        
        return nil
    }
    
    ///
    /// Function to remove a project category from a given project. The only constraint
    /// is that the category doesnt' hold a task.
    ///
    /// - Parameter project: The project where the category belongs.
    /// - Parameter name: The name of the category
    ///
    /// - Throws: categoryHasTasks exception if we cannot remove the category because it has tasks.
    ///
    static func removeProjectCategory(project: Project, name: String) throws
    {
        var hasTasks: Bool = false
        for day in DataInterface.getDays(project: project) {
            if let category = DataInterface.getCategoryByName(day: day, name: name) {
                if (category.tasks?.count)! > 0 {
                    hasTasks = true
                    break
                }
            }
        }
        
        if !hasTasks {
            if let projectCategory = DataInterface.getProjectCategoryByName(project: project, name: name) {
                project.removeFromProjectCategories(projectCategory)
            }
        }
        else {
            throw Exceptions.categoryHasTasks(String(format: "%@ we cannot remove this category because it contains tasks. Sorry.", DataInterface.getUsername()))
        }
    }
    // ########## PROJECTCATEGORIES' FUNCTIONS ########## //
}
