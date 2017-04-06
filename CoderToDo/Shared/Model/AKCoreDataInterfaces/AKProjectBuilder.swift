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
            project.gmtOffset = interface.gmtOffset
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
    
    static func from(project: Project) -> AKProjectInterface
    {
        var interface = AKProjectInterface()
        // Mirror.
        interface.closingTime = project.closingTime
        interface.closingTimeTolerance = project.closingTimeTolerance
        interface.creationDate = project.creationDate
        interface.gmtOffset = project.gmtOffset
        interface.name = project.name
        interface.notifyClosingTime = project.notifyClosingTime
        interface.osr = project.osr
        interface.startingTime = project.startingTime
        
        return interface
    }
    
    static func to(project: Project, from interface: AKProjectInterface) -> Void
    {
        // Mirror.
        project.closingTime = interface.closingTime
        project.closingTimeTolerance = interface.closingTimeTolerance
        project.creationDate = interface.creationDate
        project.gmtOffset = interface.gmtOffset
        project.name = interface.name
        project.notifyClosingTime = interface.notifyClosingTime
        project.osr = interface.osr
        project.startingTime = interface.startingTime
    }
}

struct AKProjectInterface
{
    // MARK: Properties
    var closingTime: NSDate?
    var closingTimeTolerance: Int16
    var creationDate: NSDate?
    var gmtOffset: Int16
    var name: String?
    var notifyClosingTime: Bool
    var osr: Float
    var startingTime: NSDate?
    
    init()
    {
        self.closingTime = Func.AKProcessDate(
            dateAsString: "17:00",
            format: GlobalConstants.AKWorkingDayTimeDateFormat,
            timeZone: Func.AKGetCalendarForLoading().timeZone)!
        self.closingTimeTolerance = 30
        self.creationDate = NSDate()
        self.gmtOffset = 0
        self.name = ""
        self.notifyClosingTime = true
        self.osr = 0.0
        self.startingTime = Func.AKProcessDate(
            dateAsString: "09:00",
            format: GlobalConstants.AKWorkingDayTimeDateFormat,
            timeZone: Func.AKGetCalendarForLoading().timeZone)!
    }
    
    init(name: String)
    {
        // Required.
        self.name = name
        
        // Optional.
        self.closingTime = Func.AKProcessDate(
            dateAsString: "17:00",
            format: GlobalConstants.AKWorkingDayTimeDateFormat,
            timeZone: Func.AKGetCalendarForLoading().timeZone)!
        self.closingTimeTolerance = 30
        self.gmtOffset = 0
        self.notifyClosingTime = true
        self.osr = 0.0
        self.startingTime = Func.AKProcessDate(
            dateAsString: "09:00",
            format: GlobalConstants.AKWorkingDayTimeDateFormat,
            timeZone: Func.AKGetCalendarForLoading().timeZone)!
        
        // Fixed.
        self.creationDate = NSDate()
    }
    
    // MARK: Setters
    mutating func setClosingTime(_ asString: String, format: String = GlobalConstants.AKFullDateFormat, timeZone: TimeZone = TimeZone(identifier: "GMT")!)
    {
        if let date = Func.AKProcessDate(
            dateAsString: asString,
            format: format,
            timeZone: timeZone) {
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
        if let date = Func.AKProcessDate(
            dateAsString: asString,
            format: GlobalConstants.AKFullDateFormat,
            timeZone: TimeZone(identifier: "GMT")!) {
            self.creationDate = date
        }
    }
    
    mutating func setGMTOffset(_ asString: String)
    {
        if let gmtOffset = Int16(asString) {
            self.gmtOffset = gmtOffset
        }
    }
    
    mutating func setNotifyClosingTime(_ asString: String)
    {
        if asString.isEmpty {
            self.notifyClosingTime = true
        }
        else {
            self.notifyClosingTime = asString.toBool() ?? true
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
    
    mutating func setStartingTime(_ asString: String, format: String = GlobalConstants.AKFullDateFormat, timeZone: TimeZone = TimeZone(identifier: "GMT")!)
    {
        if let date = Func.AKProcessDate(
            dateAsString: asString,
            format: format,
            timeZone: timeZone) {
            self.startingTime = date
        }
    }
    
    // MARK: Validations
    func validate() throws
    {
        // Check times.
        // 1. Closing time must be later than starting time.
        if let close = self.closingTime as Date?, let start = self.startingTime as Date? {
            let dateComparison = close.compare(start)
            if dateComparison == ComparisonResult.orderedAscending || dateComparison == ComparisonResult.orderedSame {
                throw Exceptions.invalidDate("The \"Working Day Closing Time\" must be later in time than \"Working Day Starting Time\".")
            }
        }
    }
}
