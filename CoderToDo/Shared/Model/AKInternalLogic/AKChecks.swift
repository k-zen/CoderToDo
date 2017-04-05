import Foundation

class AKChecks
{
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
    ///
    /// - Parameter controller: The controller which called the function.
    /// - Parameter task: The task to process.
    ///
    static func workingDayCloseSanityChecks(controller: AKCustomViewController, task: Task) -> Void
    {
        if DataInterface.getProjectStatus(project: (task.category?.day?.project)!) == .accepting {
            if !DataInterface.isDayTomorrow(day: (task.category?.day)!) {
                // Sanity check #1
                if task.state == TaskStates.pending.rawValue {
                    if task.completionPercentage == 0.0 || task.completionPercentage == task.initialCompletionPercentage {
                        task.state = TaskStates.notDone.rawValue
                    }
                }
                // Sanity check #2
                if task.state == TaskStates.pending.rawValue && task.completionPercentage != task.initialCompletionPercentage {
                    if !DataInterface.addPendingTask(task: task) {
                        NSLog("=> ERROR: ERROR ADDING TASK TO PENDING QUEUE!")
                    }
                }
                // Sanity check #3
                if task.state == TaskStates.dilate.rawValue {
                    if !DataInterface.addDilateTask(task: task) {
                        NSLog("=> ERROR: ERROR ADDING TASK TO DILATE QUEUE!")
                    }
                }
            }
        }
    }
    
    static func canAddTask(project: Project) throws -> Void
    {
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
