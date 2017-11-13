import Foundation

class AKUserBuilder {
    static func mirror(interface: AKUserInterface) -> User? {
        if let mr = Func.AKObtainMasterReference() {
            let user = User(context: mr.getMOC())
            // Mirror.
            user.creationDate = interface.creationDate
            user.gmtOffset = interface.gmtOffset
            user.username = interface.username
            
            return user
        }
        
        return nil
    }
    
    static func from(user: User) -> AKUserInterface {
        var interface = AKUserInterface()
        // Mirror.
        interface.creationDate = user.creationDate
        interface.gmtOffset = user.gmtOffset
        interface.username = user.username
        
        return interface
    }
    
    static func to(user: User, from interface: AKUserInterface) -> Void {
        // Mirror.
        user.creationDate = interface.creationDate
        user.gmtOffset = interface.gmtOffset
        user.username = interface.username
    }
}

struct AKUserInterface {
    // MARK: Properties
    var creationDate: Date?
    var gmtOffset: Int16
    var username: String?
    
    init() {
        self.creationDate = Date()
        self.gmtOffset = 0
        self.username = ""
    }
    
    init(username: String) {
        // Required.
        self.username = username
        
        // Optional.
        self.gmtOffset = 0
        
        // Fixed.
        self.creationDate = Date()
    }
    
    // MARK: Setters
    mutating func setCreationDate(_ asString: String) {
        if let date = Func.AKProcessDate(
            dateAsString: asString,
            format: Cons.AKFullDateFormat,
            timeZone: TimeZone(identifier: "GMT")!) {
            self.creationDate = date
        }
    }
    
    mutating func setGMTOffset(_ asString: String) {
        if let gmtOffset = Int16(asString) {
            self.gmtOffset = gmtOffset
        }
    }
    
    // MARK: Validations
    func validate() throws {}
}
