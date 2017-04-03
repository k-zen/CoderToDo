import Foundation

class AKBucketEntryBuilder
{
    static func mirror(interface: AKBucketEntryInterface) -> BucketEntry?
    {
        if let mr = Func.AKObtainMasterReference() {
            let entry = BucketEntry(context: mr.getMOC())
            // Mirror.
            entry.name = interface.name
            entry.creationDate = interface.creationDate
            entry.priority = interface.priority
            
            return entry
        }
        
        return nil
    }
}

struct AKBucketEntryInterface
{
    // MARK: Properties
    var name: String
    var creationDate: NSDate
    var priority: Int16
    
    init()
    {
        self.name = ""
        self.creationDate = NSDate()
        self.priority = 0
    }
    
    init(name: String, priority: Int16)
    {
        // Required.
        self.name = name
        self.priority = priority
        
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
    
    mutating func setPriority(_ asString: String)
    {
        if let priority = Int16(asString) {
            self.priority = priority
        }
    }
    
    // MARK: Validations
    func validate() throws {}
}
