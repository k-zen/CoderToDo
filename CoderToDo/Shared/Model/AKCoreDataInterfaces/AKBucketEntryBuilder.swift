import Foundation

class AKBucketEntryBuilder {
    static func mirror(interface: AKBucketEntryInterface) -> BucketEntry? {
        if let mr = Func.AKObtainMasterReference() {
            let entry = BucketEntry(context: mr.getMOC())
            // Mirror.
            entry.creationDate = interface.creationDate
            entry.gmtOffset = interface.gmtOffset
            entry.name = interface.name
            entry.priority = interface.priority
            
            return entry
        }
        
        return nil
    }
}

struct AKBucketEntryInterface {
    // MARK: Properties
    var creationDate: NSDate
    var gmtOffset: Int16
    var name: String
    var priority: Int16
    
    init() {
        self.creationDate = NSDate()
        self.gmtOffset = 0
        self.name = ""
        self.priority = 0
    }
    
    init(name: String, priority: Int16) {
        // Required.
        self.name = name
        self.priority = priority
        
        // Optional.
        self.gmtOffset = 0
        
        // Fixed.
        self.creationDate = NSDate()
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
    
    mutating func setPriority(_ asString: String) {
        if let priority = Int16(asString) {
            self.priority = priority
        }
    }
    
    // MARK: Validations
    func validate() throws {}
}
