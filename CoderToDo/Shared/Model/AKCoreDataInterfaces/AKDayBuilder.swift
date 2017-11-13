import Foundation

class AKDayBuilder {
    static func mirror(interface: AKDayInterface) -> Day? {
        if let mr = Func.AKObtainMasterReference() {
            let day = Day(context: mr.getMOC())
            // Mirror.
            day.date = interface.date as Date
            day.gmtOffset = interface.gmtOffset
            day.sr = interface.sr
            
            return day
        }
        
        return nil
    }
}

struct AKDayInterface {
    // MARK: Properties
    var date: Date
    var gmtOffset: Int16
    var sr: Float
    
    init() {
        self.date = Date()
        self.gmtOffset = 0
        self.sr = 0.0
    }
    
    init(date: Date, gmtOffset: Int16) {
        // Required.
        self.date = date
        self.gmtOffset = gmtOffset
        
        // Optional.
        self.sr = 0.0
    }
    
    // MARK: Setters
    mutating func setDate(_ asString: String) {
        if let date = Func.AKProcessDate(
            dateAsString: asString,
            format: Cons.AKFullDateFormat,
            timeZone: TimeZone(identifier: "GMT")!) {
            self.date = date
        }
    }
    
    mutating func setGMTOffset(_ asString: String) {
        if let gmtOffset = Int16(asString) {
            self.gmtOffset = gmtOffset
        }
    }
    
    mutating func setSR(_ asString: String) {
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
