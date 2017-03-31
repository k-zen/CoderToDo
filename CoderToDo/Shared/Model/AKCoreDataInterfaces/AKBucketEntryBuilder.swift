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
    
    init()
    {
        self.name = ""
        self.creationDate = NSDate()
    }
    
    init(name: String)
    {
        // Required.
        self.name = name
        
        // Optional.
        
        // Fixed.
        self.creationDate = NSDate()
    }
    
    // MARK: Validations
    func validate() throws {}
}
