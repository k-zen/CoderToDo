import Foundation

class AKProjectCategoryBuilder
{
    static func mirror(interface: AKProjectCategoryInterface) -> ProjectCategory?
    {
        if let mr = Func.AKObtainMasterReference() {
            let projectCategory = ProjectCategory(context: mr.getMOC())
            // Mirror.
            projectCategory.name = interface.name
            
            return projectCategory
        }
        
        return nil
    }
}

struct AKProjectCategoryInterface
{
    // MARK: Properties
    var name: String
    
    init()
    {
        self.name = ""
    }
    
    init(name: String)
    {
        // Required.
        self.name = name
    }
    
    // MARK: Validations
    func validate() throws {}
}
