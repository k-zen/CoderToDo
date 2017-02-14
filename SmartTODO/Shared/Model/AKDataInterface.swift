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
    
    static func getProjects(sortBy: ProjectSorting) -> [Project]
    {
        if let projects = DataInterface.getUser()?.project?.allObjects as? [Project] {
            switch sortBy {
            case ProjectSorting.name:
                return projects.sorted {
                    let n1 = $0.name ?? ""
                    let n2 = $1.name ?? ""
                    
                    return n1 < n2
                }
            default:
                return projects.sorted {
                    let n1 = $0.name ?? ""
                    let n2 = $1.name ?? ""
                    
                    return n1 < n2
                }
            }
        }
        else {
            return []
        }
    }
    
    static func countProjects() -> Int { return DataInterface.getUser()?.project?.allObjects.count ?? 0 }
}
