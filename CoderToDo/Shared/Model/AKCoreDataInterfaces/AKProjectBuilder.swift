import Foundation

class AKProjectBuilder
{
    static func mirror(interface: AKProjectInterface) -> Project?
    {
        if let mr = Func.AKObtainMasterReference() {
            let project = Project(context: mr.getMOC())
            // Mirror.
            project.closingTime = interface.closingTime
            project.closingTimeTolerance = interface.closingTimeTolerance
            project.creationDate = interface.creationDate
            project.name = interface.name
            project.notifyClosingTime = interface.notifyClosingTime
            project.osr = interface.osr
            project.startingTime = interface.startingTime
            // Queues.
            project.pendingQueue = PendingQueue(context: mr.getMOC())
            project.dilateQueue = DilateQueue(context: mr.getMOC())
            
            return project
        }
        
        return nil
    }
}

struct AKProjectInterface
{
    // MARK: Properties
    var closingTime: NSDate
    var closingTimeTolerance: Int16
    var creationDate: NSDate
    var name: String
    var notifyClosingTime: Bool
    var osr: Float
    var startingTime: NSDate
    
    init()
    {
        self.closingTime = Func.AKProcessDate(
            dateAsString: "17:00",
            format: GlobalConstants.AKWorkingDayTimeDateFormat)!
        self.closingTimeTolerance = 30
        self.creationDate = NSDate()
        self.name = ""
        self.notifyClosingTime = true
        self.osr = 0.0
        self.startingTime = Func.AKProcessDate(
            dateAsString: "09:00",
            format: GlobalConstants.AKWorkingDayTimeDateFormat)!
    }
    
    init(name: String)
    {
        // Required.
        self.name = name
        
        // Optional.
        self.closingTime = Func.AKProcessDate(
            dateAsString: "17:00",
            format: GlobalConstants.AKWorkingDayTimeDateFormat)!
        self.closingTimeTolerance = 30
        self.notifyClosingTime = true
        self.osr = 0.0
        self.startingTime = Func.AKProcessDate(
            dateAsString: "09:00",
            format: GlobalConstants.AKWorkingDayTimeDateFormat)!
        
        // Fixed.
        self.creationDate = NSDate()
    }
    
    // MARK: Setters
    mutating func setClosingTime(_ asString: String)
    {
        if let date = Func.AKProcessGMTDate(
            dateAsString: asString) {
            self.closingTime = date
        }
    }
    
    mutating func setClosingTimeTolerance(_ asString: String)
    {
        if let tolerance = Int16(asString) {
            self.closingTimeTolerance = tolerance
        }
    }
    
    mutating func setCreationDate(_ asString: String)
    {
        if let date = Func.AKProcessGMTDate(
            dateAsString: asString) {
            self.creationDate = date
        }
    }
    
    mutating func setNotifyClosingTime(_ asString: String)
    {
        if asString.isEmpty {
            self.notifyClosingTime = true
        }
        else {
            self.notifyClosingTime = Bool(asString) ?? true
        }
    }
    
    mutating func setOSR(_ asString: String)
    {
        if asString.isEmpty {
            self.osr = 0.0
        }
        else {
            self.osr = Float(asString) ?? 0.0
        }
    }
    
    mutating func setStartingTime(_ asString: String)
    {
        if let date = Func.AKProcessGMTDate(
            dateAsString: asString) {
            self.startingTime = date
        }
    }
    
    // MARK: Validations
    func validate() throws
    {
        // Check times.
        // 1. Closing time must be later than starting time.
        let dateComparison = self.closingTime.compare(self.startingTime as Date)
        if dateComparison == ComparisonResult.orderedAscending || dateComparison == ComparisonResult.orderedSame {
            throw Exceptions.invalidDate("The \"Working Day Closing Time\" must be later in time than \"Working Day Starting Time\".")
        }
    }
}
