import Foundation

class AKCategoryBuilder {
    static func mirror(interface: AKCategoryInterface) -> Category? {
        if let mr = Func.AKObtainMasterReference() {
            let category = Category(context: mr.getMOC())
            // Mirror.
            category.name = interface.name
            
            return category
        }
        
        return nil
    }
}

struct AKCategoryInterface {
    // MARK: Properties
    var name: String
    
    init() {
        self.name = ""
    }
    
    init(name: String) {
        // Required.
        self.name = name
    }
    
    // MARK: Validations
    func validate() throws {}
}
