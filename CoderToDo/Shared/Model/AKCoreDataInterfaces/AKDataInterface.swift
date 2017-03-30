import Foundation
import UserNotifications

class AKDataInterface
{
    static func firstTime() -> Bool { return DataInterface.getUser()?.username == nil }
    
    // ########## USER'S FUNCTIONS ########## //
    static func addUser(user: User) -> Void
    {
        Func.AKObtainMasterReference()?.getUser()?.creationDate = user.creationDate
        Func.AKObtainMasterReference()?.getUser()?.username = user.username
    }
    
    ///
    /// Returns the user data structure.
    ///
    /// - Returns: The user data structure.
    ///
    static func getUser() -> User? { return Func.AKObtainMasterReference()?.getUser() }
    
    static func getUsername() -> String { return DataInterface.getUser()?.username ?? "" }
    // ########## USER'S FUNCTIONS ########## //
    // ########## CONFIGURATIONS'S FUNCTIONS ########## //
    static func addConfigurations(configurations: Configurations?) -> Void
    {
        if let user = DataInterface.getUser() {
            user.configurations = configurations
        }
    }
    
    static func getConfigurations() -> Configurations?
    {
        if let configurations = DataInterface.getUser()?.configurations {
            return configurations
        }
        
        return nil
    }
    // ########## CONFIGURATIONS'S FUNCTIONS ########## //
    // ########## PROJECT'S FUNCTIONS ########## //
    static func isProjectEmpty() -> Bool { return DataInterface.getUser()?.project == nil }
    
    static func resetProjectData() -> Void { DataInterface.getUser()?.project = nil }
    
    static func addProject(project: Project) -> Bool
    {
        var result = 0
        if let mr = Func.AKObtainMasterReference(), let user = DataInterface.getUser() {
            // Add both necessary queues.
            project.pendingQueue = PendingQueue(context: mr.getMOC())
            project.dilateQueue = DilateQueue(context: mr.getMOC())
            
            // Schedule notifications.
            if project.notifyClosingTime {
                let closingTimeContent = UNMutableNotificationContent()
                closingTimeContent.title = String(format: "Project: %@", project.name!)
                closingTimeContent.body = String(
                    format: "Hi %@, it's me again... closing time is due for your project. You have %i minutes for editing tasks before this day is marked as closed.",
                    DataInterface.getUsername(),
                    project.closingTimeTolerance
                )
                closingTimeContent.sound = UNNotificationSound.default()
                Func.AKGetNotificationCenter().add(
                    UNNotificationRequest(
                        identifier: String(format: "%@:%@", GlobalConstants.AKClosingTimeNotificationName, project.name!),
                        content: closingTimeContent,
                        trigger: UNCalendarNotificationTrigger(
                            dateMatching: Func.AKGetCalendarForLoading().dateComponents([.hour,.minute,.second,], from: project.closingTime as! Date),
                            repeats: true
                        )
                    ),
                    withCompletionHandler: { (error) in
                        if let _ = error {
                            result += 1
                        } }
                )
            }
            
            user.addToProject(project)
        }
        
        return result == 0 ? true : false
    }
    
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
    
    static func getProjectStatus(project: Project, useToleranceForAccepting: Bool = false) -> ProjectStatus
    {
        if let startingTime = project.startingTime as? Date, let closingTime = project.closingTime as? Date, let creationTime = project.creationDate as? Date {
            let now = Date()
            let nowHour = 100 * (Func.AKGetCalendarForLoading().dateComponents([.hour], from: now).hour ?? 0) + (Func.AKGetCalendarForLoading().dateComponents([.minute], from: now).minute ?? 0)
            let startingTimeHour = 100 * (Func.AKGetCalendarForLoading().dateComponents([.hour], from: startingTime).hour ?? 0) + (Func.AKGetCalendarForLoading().dateComponents([.minute], from: startingTime).minute ?? 0)
            let closingTimeHour = 100 * (Func.AKGetCalendarForLoading().dateComponents([.hour], from: closingTime).hour ?? 0) + (Func.AKGetCalendarForLoading().dateComponents([.minute], from: closingTime).minute ?? 0)
            
            // ###### FIRST DAY
            // This is a very special case where the user has just downloaded the application and is
            // ready to start adding days while the working day is OPEN, and it's called FIRST_DAY.
            // Only one time we must allow this to happen. This modification is to allow the user
            // to create tasks for the current day!
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
            if nowHour >= closingTimeHour + (useToleranceForAccepting ? Int(project.closingTimeTolerance) : 0) && nowHour <= GlobalConstants.AKAcceptingTasksDefaultMaxTime {
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
            let tomorrow: Date!
            if DataInterface.getProjectStatus(project: project) == .firstDay {
                tomorrow = Func.AKGetCalendarForLoading().date(byAdding: .day, value: 0, to: now)! // In this case tomorrow == today...!
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
                if DataInterface.getProjectStatus(project: project) == .firstDay {
                    if GlobalConstants.AKDebug {
                        NSLog("=> INFO: WORKING DAY IS FIRST DAY. ADDING TODAY!")
                    }
                    
                    let today = Day(context: mr.getMOC())
                    today.date = Func.AKGetCalendarForSaving().date(byAdding: .day, value: 0, to: now)! as NSDate
                    today.gmtOffset = Int16(TimeZone.current.secondsFromGMT() / 3600)
                    project.addToDays(today)
                    
                    return today
                }
                else if DataInterface.getProjectStatus(project: project) == .accepting {
                    if GlobalConstants.AKDebug {
                        NSLog("=> INFO: WORKING DAY ALREADY FINISHED. ADDING TOMORROW!")
                    }
                    
                    let tomorrow = Day(context: mr.getMOC())
                    tomorrow.date = Func.AKGetCalendarForSaving().date(byAdding: .day, value: 1, to: now)! as NSDate
                    tomorrow.gmtOffset = Int16(TimeZone.current.secondsFromGMT() / 3600)
                    project.addToDays(tomorrow)
                    
                    return tomorrow
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
                osr += (day.sr / 100.0)
                counter += 1
            }
        }
        
        project.osr = counter > 0 ? (osr / counter) * 100.0 : 0.0
        
        return project.osr
    }
    
    static func computeAverageSRGroupedByDay() -> [Int16 : Float]
    {
        var average = [
            DaysOfWeek.sunday.rawValue : Float(0.0),
            DaysOfWeek.monday.rawValue : Float(0.0),
            DaysOfWeek.tuesday.rawValue : Float(0.0),
            DaysOfWeek.wednesday.rawValue : Float(0.0),
            DaysOfWeek.thursday.rawValue : Float(0.0),
            DaysOfWeek.friday.rawValue : Float(0.0),
            DaysOfWeek.saturday.rawValue : Float(0.0)
        ]
        var counters = [
            DaysOfWeek.sunday.rawValue : Float(0.0),
            DaysOfWeek.monday.rawValue : Float(0.0),
            DaysOfWeek.tuesday.rawValue : Float(0.0),
            DaysOfWeek.wednesday.rawValue : Float(0.0),
            DaysOfWeek.thursday.rawValue : Float(0.0),
            DaysOfWeek.friday.rawValue : Float(0.0),
            DaysOfWeek.saturday.rawValue : Float(0.0)
        ]
        
        for project in DataInterface.getProjects(filter: Filter(projectFilter: FilterProject())) {
            for day in DataInterface.getDays(project: project) {
                let dayOfWeek = Int16(Func.AKProcessDayOfWeek(date: day.date, gmtOffset: -3)) // TODO: Change this when time is right!
                if let currentValue = average[dayOfWeek], let currentCounter = counters[dayOfWeek] {
                    average[dayOfWeek] = currentValue + (day.sr / 100.0)
                    counters[dayOfWeek] = currentCounter + 1
                }
            }
        }
        
        // Recompute the value.
        for (key, _) in average {
            average[key] = counters[key]! > 0 ? (average[key]! / counters[key]!) * 100.0 : 0.0
        }
        
        // Check if at least one counter is > 0.
        var returnEmpty = true
        for (_, value) in counters {
            if value > 0.0 {
                returnEmpty = false
            }
        }
        
        return returnEmpty ? [:] : average
    }
    
    static func mostProductiveDay() -> DaysOfWeek
    {
        var average = [
            DaysOfWeek.sunday.rawValue : Float(0.0),
            DaysOfWeek.monday.rawValue : Float(0.0),
            DaysOfWeek.tuesday.rawValue : Float(0.0),
            DaysOfWeek.wednesday.rawValue : Float(0.0),
            DaysOfWeek.thursday.rawValue : Float(0.0),
            DaysOfWeek.friday.rawValue : Float(0.0),
            DaysOfWeek.saturday.rawValue : Float(0.0)
        ]
        var counters = [
            DaysOfWeek.sunday.rawValue : Float(0.0),
            DaysOfWeek.monday.rawValue : Float(0.0),
            DaysOfWeek.tuesday.rawValue : Float(0.0),
            DaysOfWeek.wednesday.rawValue : Float(0.0),
            DaysOfWeek.thursday.rawValue : Float(0.0),
            DaysOfWeek.friday.rawValue : Float(0.0),
            DaysOfWeek.saturday.rawValue : Float(0.0)
        ]
        
        for project in DataInterface.getProjects(filter: Filter(projectFilter: FilterProject())) {
            for day in DataInterface.getDays(project: project) {
                let dayOfWeek = Int16(Func.AKProcessDayOfWeek(date: day.date, gmtOffset: -3)) // TODO: Change this when time is right!
                if let currentValue = average[dayOfWeek], let currentCounter = counters[dayOfWeek] {
                    average[dayOfWeek] = currentValue + (day.sr / 100.0)
                    counters[dayOfWeek] = currentCounter + 1
                }
            }
        }
        
        // Recompute the value.
        for (key, _) in average {
            average[key] = counters[key]! > 0 ? (average[key]! / counters[key]!) * 100.0 : 0.0
        }
        
        // Check if at least one counter is > 0.
        var returnEmpty = true
        for (_, value) in counters {
            if value > 0.0 {
                returnEmpty = false
            }
        }
        
        // Find the max value.
        var maxKey = Float(0.0)
        var maxValue = Float(0.0)
        for (key, value) in average {
            if value > maxValue {
                maxKey = Float(key)
                maxValue = value
            }
        }
        
        return returnEmpty ? .invalid : DaysOfWeek(rawValue: Int16(maxKey))!
    }
    // ########## PROJECT'S FUNCTIONS ########## //
    // ########## DAY'S FUNCTIONS ########## //
    static func getDays(project: Project, filterEmpty: Bool = false, filter: Filter = Filter(taskFilter: FilterTask())) -> [Day]
    {
        if let days = project.days?.allObjects as? [Day] {
            return days.sorted {
                let now = Date()
                let n1 = $0.date as? Date ?? now
                let n2 = $1.date as? Date ?? now
                
                return n1.compare(n2) == ComparisonResult.orderedDescending ? true : false
                }.filter({ (day) -> Bool in
                    if filterEmpty {
                        return DataInterface.countTasksInDay(day: day, filter: filter) > 0
                    }
                    else {
                        return true
                    }
                })
        }
        
        return []
    }
    
    static func getDayOfTask(task: Task?) -> Day? { return task?.category?.day ?? nil }
    
    static func countDays(project: Project, filterEmpty: Bool = false, filter: Filter = Filter(taskFilter: FilterTask())) -> Int
    {
        return DataInterface.getDays(project: project, filterEmpty: filterEmpty, filter: filter).count
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
                        if task.state == TaskStates.done.rawValue || task.state == TaskStates.pending.rawValue {
                            sr += (abs(task.completionPercentage - task.initialCompletionPercentage) / 100.0)
                            counter += 1
                        }
                    }
                }
            }
        }
        
        day.sr = counter > 0 ? (sr / counter) * 100.0 : 0.0
        
        return day.sr
    }
    
    static func countDayPendingTasks(day: Day) -> Int
    {
        var counter = 0
        
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
        
        return counter
    }
    // ########## DAY'S FUNCTIONS ########## //
    // ########## CATEGORY'S FUNCTIONS ########## //
    static func getCategories(day: Day, filterEmpty: Bool = false, filter: Filter = Filter(taskFilter: FilterTask())) -> [Category]
    {
        if let categories = day.categories?.allObjects as? [Category] {
            return categories.sorted {
                let n1 = $0.name ?? ""
                let n2 = $1.name ?? ""
                
                return n1 < n2
                }.filter({ (category) -> Bool in
                    if filterEmpty {
                        return DataInterface.countTasksInCategory(category: category, filter: filter) > 0
                    }
                    else {
                        return true
                    }
                })
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
    
    static func countCategories(day: Day, filterEmpty: Bool = false, filter: Filter = Filter(taskFilter: FilterTask())) -> Int
    {
        return DataInterface.getCategories(day: day, filterEmpty: filterEmpty, filter: filter).count
    }
    // ########## CATEGORY'S FUNCTIONS ########## //
    // ########## TASK'S FUNCTIONS ########## //
    static func addTask(toProject project: Project, toCategoryNamed categoryName: String, task: Task) -> Bool
    {
        if let mr = Func.AKObtainMasterReference() {
            // Allways add today to the table if not present, if present return the last day.
            if let currentDay = DataInterface.addNewWorkingDay(project: project) {
                if let category = DataInterface.getCategoryByName(day: currentDay, name: categoryName) {
                    category.addToTasks(task)
                    currentDay.addToCategories(category)
                }
                else {
                    let newCategory = Category(context: mr.getMOC())
                    newCategory.name = categoryName
                    newCategory.addToTasks(task)
                    currentDay.addToCategories(newCategory)
                }
                
                return DataInterface.updateDay(project: project, updatedDay: currentDay)
            }
        }
        
        return false
    }
    
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
    
    static func migrateTaskToCategory(toCategoryNamed categoryName: String, task: Task) -> Bool
    {
        if let day = task.category?.day {
            if let category = DataInterface.getCategoryByName(day: day, name: categoryName) {
                category.addToTasks(task)
            }
            else {
                if let mr = Func.AKObtainMasterReference() {
                    let newCategory = Category(context: mr.getMOC())
                    newCategory.name = categoryName
                    newCategory.addToTasks(task)
                    day.addToCategories(newCategory)
                }
            }
            
            return true
        }
        
        return false
    }
    
    static func migrateTasksFromQueues(toProject project: Project) -> Bool
    {
        if let mr = Func.AKObtainMasterReference() {
            // Allways add today to the table if not present, if present return the last day.
            if let currentDay = DataInterface.addNewWorkingDay(project: project) {
                let migratedPendingDay = DataInterface.getDayOfTask(task: DataInterface.getPendingTasks(project: project).first)
                let migratedDilateDay = DataInterface.getDayOfTask(task: DataInterface.getDilateTasks(project: project).first)
                
                // Add task from PendingQueue.
                for task in DataInterface.getPendingTasks(project: project) {
                    if let categoryName = task.category?.name {
                        // Here is the problem where tasks in queues where not added to the next day. If the next day
                        // doesn't have the category for which the task belongs, then it will return NIL and never execute
                        // this block of code.
                        // SOLUTION: If the new day doesn't have the category, then create a new one with the same name.
                        if let category = DataInterface.getCategoryByName(day: currentDay, name: categoryName) {
                            category.addToTasks(task)
                            currentDay.addToCategories(category)
                            
                            // Remove from queue.
                            project.pendingQueue?.removeFromTasks(task)
                            
                            task.creationDate = currentDay.date
                            task.initialCompletionPercentage = task.completionPercentage
                        }
                        else {
                            let newCategory = Category(context: mr.getMOC())
                            newCategory.name = categoryName
                            newCategory.addToTasks(task)
                            currentDay.addToCategories(newCategory)
                            
                            // Remove from queue.
                            project.pendingQueue?.removeFromTasks(task)
                            
                            task.creationDate = currentDay.date
                            task.initialCompletionPercentage = task.completionPercentage
                        }
                    }
                }
                
                // Add task from DilateQueue.
                for task in DataInterface.getDilateTasks(project: project) {
                    if let categoryName = task.category?.name {
                        // Here is the problem where tasks in queues where not added to the next day. If the next day
                        // doesn't have the category for which the task belongs, then it will return NIL and never execute
                        // this block of code.
                        // SOLUTION: If the new day doesn't have the category, then create a new one with the same name.
                        if let category = DataInterface.getCategoryByName(day: currentDay, name: categoryName) {
                            category.addToTasks(task)
                            currentDay.addToCategories(category)
                            
                            // Remove from queue.
                            project.dilateQueue?.removeFromTasks(task)
                            
                            task.creationDate = currentDay.date
                            task.initialCompletionPercentage = task.completionPercentage
                        }
                        else {
                            let newCategory = Category(context: mr.getMOC())
                            newCategory.name = categoryName
                            newCategory.addToTasks(task)
                            currentDay.addToCategories(newCategory)
                            
                            // Remove from queue.
                            project.dilateQueue?.removeFromTasks(task)
                            
                            task.creationDate = currentDay.date
                            task.initialCompletionPercentage = task.completionPercentage
                        }
                    }
                }
                
                // To avoid having an empty day, because all tasks from one day have been moved, then check the day
                // from which the pending or dilate tasks come from and if they are empty remove those days from the
                // project.
                if let day1 = migratedPendingDay, let day2 = migratedDilateDay {
                    // Count the task in both days.
                    let leftTasks = DataInterface.countTasksInDay(day: day1, filter: Filter(taskFilter: FilterTask())) + DataInterface.countTasksInDay(day: day2, filter: Filter(taskFilter: FilterTask()))
                    if leftTasks == 0 {
                        project.removeFromDays(day1)
                        project.removeFromDays(day2)
                    }
                }
                
                return DataInterface.updateDay(project: project, updatedDay: currentDay)
            }
        }
        
        return false
    }
    
    static func addPendingTask(task: Task) -> Bool
    {
        if let pendingQueue = task.category?.day?.project?.pendingQueue {
            pendingQueue.addToTasks(task)
            
            return true
        }
        
        return false
    }
    
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
    
    static func countPendingTasks(project: Project) -> Int { return DataInterface.getPendingTasks(project: project).count }
    
    static func addDilateTask(task: Task) -> Bool
    {
        if let dilateQueue = task.category?.day?.project?.dilateQueue {
            dilateQueue.addToTasks(task)
            
            return true
        }
        
        return false
    }
    
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
    
    static func countDilateTasks(project: Project) -> Int { return DataInterface.getDilateTasks(project: project).count }
    // ########## TASK'S FUNCTIONS ########## //
    // ########## PROJECTCATEGORIES' FUNCTIONS ########## //
    static func addProjectCategory(toProject project: Project, categoryName: String) throws
    {
        if let mr = Func.AKObtainMasterReference() {
            if let _ = DataInterface.getProjectCategoryByName(project: project, name: categoryName) {
                throw Exceptions.categoryAlreadyExists("There is already a category with that name. Please choose another one.")
            }
            
            let projectCategory = ProjectCategory(context: mr.getMOC())
            projectCategory.name = categoryName
            
            project.addToProjectCategories(projectCategory)
        }
    }
    
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
    
    static func countProjectCategories(project: Project) -> Int { return DataInterface.listProjectCategories(project: project).count }
    
    ///
    /// Searches for a given project category inside a given project and returns it if it's found or
    /// NIL if not found.
    ///
    /// - Parameter project: The project where to look.
    /// - Parameter name: The name of the category.
    ///
    /// - Returns: The project category or NIL if not found.
    ///
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
