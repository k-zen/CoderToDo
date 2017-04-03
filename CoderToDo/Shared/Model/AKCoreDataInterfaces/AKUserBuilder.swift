import Foundation

class AKUserBuilder
{
    static func mirror(interface: AKUserInterface) -> User?
    {
        if let mr = Func.AKObtainMasterReference() {
            let user = User(context: mr.getMOC())
            // Mirror.
            user.creationDate = interface.creationDate
            user.username = interface.username
            
            return user
        }
        
        return nil
    }
}

struct AKUserInterface
{
    // MARK: Properties
    var creationDate: NSDate
    var username: String
    
    init()
    {
        self.creationDate = NSDate()
        self.username = ""
    }
    
    init(username: String)
    {
        // Required.
        self.username = username
        
        // Optional.
        
        // Fixed.
        self.creationDate = NSDate()
    }
    
    // MARK: Setters
    mutating func setCreationDate(_ asString: String)
    {
        if let date = Func.AKProcessDate(
            dateAsString: asString,
            format: GlobalConstants.AKFullDateFormat,
            timeZone: TimeZone(identifier: "GMT")!) {
            self.creationDate = date
        }
    }
    
    // MARK: Validations
    func validate() throws {}
}
