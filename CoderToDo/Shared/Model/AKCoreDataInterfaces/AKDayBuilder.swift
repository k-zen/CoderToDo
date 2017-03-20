import Foundation

class AKDayBuilder
{
    static func mirror(interface: AKDayInterface) -> Day?
    {
        if let mr = Func.AKObtainMasterReference() {
            let day = Day(context: mr.getMOC())
            // Mirror.
            day.date = interface.date
            day.sr = interface.sr
            
            return day
        }
        
        return nil
    }
}

struct AKDayInterface
{
    // MARK: Properties
    var date: NSDate
    var sr: Float
    
    init()
    {
        self.date = NSDate()
        self.sr = 0.0
    }
    
    init(date: NSDate)
    {
        // Required.
        self.date = date
        
        // Optional.
        self.sr = 0.0
    }
    
    // MARK: Setters
    mutating func setDate(_ asString: String)
    {
        if let date = Func.AKProcessGMTDate(
            dateAsString: asString) {
            self.date = date
        }
    }
    
    mutating func setSR(_ asString: String)
    {
        if asString.isEmpty {
            self.sr = 0.0
        }
        else {
            self.sr = Float(asString) ?? 0.0
        }
    }
    
    // MARK: Validations
    func validate() throws {}
}
