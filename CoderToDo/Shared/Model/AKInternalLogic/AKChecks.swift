import Foundation

class AKChecks {
    ///
    /// Sanity checks: IF ALL CODE IS CORRECT, THE SANITY CHECKS SHOULD ONLY EXECUTE AT THE END OF THE CURRENT DAY
    /// AND PERFORMS CLOSING OF TASKS (SANITY CHECKS IN GENERAL).
    /// 1. Mark the task as NOT_DONE.
    ///  If the project is closed and is NOT today before working day AND
    ///      day is not tomorrow AND
    ///          a. the state is PENDING
    ///          b. the CP is == 0.0% OR
    ///          c. the ICP is == CP
    /// 2. Add the task to PendingQueue.
    ///  If the project is closed and is NOT today before working day AND
    ///      day is not tomorrow AND
    ///          a. the state is PENDING
    ///          b. the CP has been incremented in the day.
    /// 3. Add the task to DilateQueue.
    ///  If the project is closed and is NOT today before working day AND
    ///      day is not tomorrow AND
    ///          a. the state is DILATE
    /// 4. Add tasks marked as NOT_DONE to PendingQueue.
    ///  If the project is closed and is NOT today before working day AND
    ///      day is not tomorrow AND
    ///          a. the state is NOT_DONE
    ///  DO NOT remove from the original day!
    ///
    /// - Parameter controller: The controller which called the function.
    /// - Parameter task: The task to process.
    ///
    static func workingDayCloseSanityChecks(controller: AKCustomViewController, task: Task) -> Void {
        let projectStatus = DataInterface.getProjectStatus(project: (task.category?.day?.project)!)
        
        var result = 0
        // Checks
        switch projectStatus {
        case .accepting:
            result += DataInterface.isDayTomorrow(day: (task.category?.day)!) ? 1 : 0
            break
        case .closed:
            result += DataInterface.isDayToday(day: (task.category?.day)!) ? 1 : 0
            break
        default: // All other states should exclude filters.
            result += 1
            break
        }
        
        if result < 1 {
            // Sanity check #1
            AKChecks.sanityChecks_1(controller: controller, task: task)
            
            // Sanity check #2
            if task.state == TaskStates.pending.rawValue && task.completionPercentage != task.initialCompletionPercentage {
                if !DataInterface.addPendingTask(task: task) {
                    if Cons.AKDebug {
                        NSLog("=> ERROR: ERROR ADDING TASK TO PENDING QUEUE!")
                    }
                }
            }
            
            // Sanity check #3
            if task.state == TaskStates.dilate.rawValue {
                if !DataInterface.addDilateTask(task: task) {
                    if Cons.AKDebug {
                        NSLog("=> ERROR: ERROR ADDING TASK TO DILATE QUEUE!")
                    }
                }
            }
            
            // Sanity check #4
            if task.state == TaskStates.notDone.rawValue && !task.migrated {
                // ################################################################################################## //
                // # This function WILL ALWAYS return a new next day (tomorrow), because this checks always execute # //
                // # at the end of the day, when the working day is over and the state is *Accepting*.              # //
                // ################################################################################################## //
                if let newDay = DataInterface.addNewWorkingDay(project: (task.category?.day?.project)!) {
                    if let mr = Func.AKObtainMasterReference() {
                        // Duplicate the task.
                        var duplicate = AKTaskBuilder.from(task: task)
                        duplicate.setState(TaskStates.pending.rawValue)
                        
                        // Add the category to the new day.
                        if let categoryName = task.category?.name {
                            if let newTask = AKTaskBuilder.mirror(interface: duplicate) {
                                if let category = DataInterface.getCategoryByName(day: newDay, name: categoryName) {
                                    category.addToTasks(newTask)
                                    newDay.addToCategories(category)
                                }
                                else {
                                    let newCategory = Category(context: mr.getMOC())
                                    newCategory.name = categoryName
                                    newCategory.addToTasks(newTask)
                                    newDay.addToCategories(newCategory)
                                }
                                
                                if !DataInterface.addPendingTask(task: newTask) {
                                    if Cons.AKDebug {
                                        NSLog("=> ERROR: ERROR ADDING TASK TO PENDING QUEUE!")
                                    }
                                }
                                else {
                                    // Mark the original as migrated to avoid migrate the task twice.
                                    task.migrated = true
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    static func sanityChecks_1(controller: AKCustomViewController, task: Task) -> Void {
        let projectStatus = DataInterface.getProjectStatus(project: (task.category?.day?.project)!)
        
        var result = 0
        // Checks
        switch projectStatus {
        case .accepting:
            result += DataInterface.isDayTomorrow(day: (task.category?.day)!) ? 1 : 0
            break
        case .closed:
            result += DataInterface.isDayToday(day: (task.category?.day)!) ? 1 : 0
            break
        default: // All other states should exclude filters.
            result += 1
            break
        }
        
        if result < 1 {
            if task.state == TaskStates.pending.rawValue {
                if task.completionPercentage == 0.0 || task.completionPercentage == task.initialCompletionPercentage {
                    task.state = TaskStates.notDone.rawValue
                }
            }
        }
    }
    
    static func canAddTask(project: Project) throws -> Void {
        // Check if it's outside Working Day or First Day.
        let projectStatus = DataInterface.getProjectStatus(project: project)
        if projectStatus != .accepting && projectStatus != .firstDay {
            throw Exceptions.invalidProjectStatus(String(format: "Cannot add task right now %@. Please check the rules in the Help tab.", DataInterface.getUsername()))
        }
        
        // Check if there is at least 1 category.
        if DataInterface.countProjectCategories(project: project) == 0 {
            throw Exceptions.noCategories(String(format: "%@ please add at least 1 category first.", DataInterface.getUsername()))
        }
    }
}
