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
    
    // MARK: Validations
    func validate() throws {}
}
