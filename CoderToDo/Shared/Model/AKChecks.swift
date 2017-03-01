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
    /// - Parameter task: The task to process.
    ///
    static func workingDayCloseSanityChecks(task: Task) -> Void
    {
        if !DataInterface.isProjectOpen(project: (task.category?.day?.project)!) && !DataInterface.isBeforeOpen(project: (task.category?.day?.project)!) {
            if !DataInterface.isDayTomorrow(day: (task.category?.day)!) {
                // Sanity check #1
                if task.state == TaskStates.PENDING.rawValue {
                    if task.completionPercentage == 0.0 || task.completionPercentage == task.initialCompletionPercentage {
                        task.state = TaskStates.NOT_DONE.rawValue
                    }
                }
                // Sanity check #2
                if task.state == TaskStates.PENDING.rawValue && task.completionPercentage != task.initialCompletionPercentage {
                    task.initialCompletionPercentage = task.completionPercentage
                    if let pendingQueue = task.category?.day?.project?.pendingQueue {
                        pendingQueue.addToTasks(task)
                    }
                }
                // Sanity check #3
                if task.state == TaskStates.DILATE.rawValue {
                    task.initialCompletionPercentage = task.completionPercentage
                    if let dilateQueue = task.category?.day?.project?.dilateQueue {
                        dilateQueue.addToTasks(task)
                    }
                }
            }
        }
    }
    
    static func canAddTask(project: Project) throws -> Void
    {
        // Check if it's outside Working Day or First Day.
        let projectStatus = DataInterface.getProjectStatus(project: project)
        if projectStatus != ProjectStatus.ACEPTING_TASKS && projectStatus != ProjectStatus.FIRST_DAY {
            throw Exceptions.invalidProjectStatus(String(format: "Cannot add task right now %@. Please check the rules in the Help tab.", DataInterface.getUsername()))
        }
        
        // Check if there is at least 1 category.
        if project.projectCategories?.count == 0 {
            throw Exceptions.noCategories(String(format: "%@ please add at least 1 category first.", DataInterface.getUsername()))
        }
    }
}