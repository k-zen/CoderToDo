import Foundation

class AKTaskBuilder
{
    static func mirror(interface: AKTaskInterface) -> Task?
    {
        if let mr = Func.AKObtainMasterReference() {
            let task = Task(context: mr.getMOC())
            // Mirror.
            task.completionPercentage = interface.completionPercentage
            task.creationDate = interface.creationDate
            task.initialCompletionPercentage = interface.initialCompletionPercentage
            task.name = interface.name
            task.note = interface.note
            task.state = interface.state
            
            return task
        }
        
        return nil
    }
    
    static func from(task: Task) -> AKTaskInterface
    {
        var interface = AKTaskInterface()
        // Mirror.
        interface.completionPercentage = task.completionPercentage
        interface.creationDate = task.creationDate
        interface.initialCompletionPercentage = task.initialCompletionPercentage
        interface.name = task.name
        interface.note = task.note
        interface.state = task.state
        
        return interface
    }
    
    static func to(task: Task, from interface: AKTaskInterface) -> Void
    {
        // Mirror.
        task.completionPercentage = interface.completionPercentage
        task.creationDate = interface.creationDate
        task.initialCompletionPercentage = interface.initialCompletionPercentage
        task.name = interface.name
        task.note = interface.note
        task.state = interface.state
    }
}

struct AKTaskInterface
{
    // MARK: Properties
    var completionPercentage: Float
    var creationDate: NSDate?
    var initialCompletionPercentage: Float
    var name: String?
    var note: String?
    var state: String?
    
    init()
    {
        self.completionPercentage = 0.0
        self.creationDate = NSDate()
        self.initialCompletionPercentage = 0.0
        self.name = ""
        self.note = ""
        self.state = TaskStates.pending.rawValue
    }
    
    init(name: String, state: String)
    {
        // Required.
        self.name = name
        
        // Optional.
        self.completionPercentage = 0.0
        self.initialCompletionPercentage = 0.0
        self.note = ""
        self.state = state
        
        // Fixed.
        self.creationDate = NSDate()
    }
    
    // MARK: Setters
    mutating func setCompletionPercentage(_ asString: String)
    {
        if asString.isEmpty {
            self.completionPercentage = 0.0
        }
        else {
            self.completionPercentage = Float(asString) ?? 0.0
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
    
    mutating func setInitialCompletionPercentage(_ asString: String)
    {
        if asString.isEmpty {
            self.initialCompletionPercentage = 0.0
        }
        else {
            self.initialCompletionPercentage = Float(asString) ?? 0.0
        }
    }
    
    mutating func setState(_ asString: String)
    {
        if asString.isEmpty {
            self.state = TaskStates.pending.rawValue
        }
        else {
            self.state = asString
        }
    }
    
    // MARK: Validations
    func validate() throws {}
}
