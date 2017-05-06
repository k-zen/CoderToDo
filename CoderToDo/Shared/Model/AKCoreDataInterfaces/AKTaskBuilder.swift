import Foundation

class AKTaskBuilder {
    static func mirror(interface: AKTaskInterface) -> Task? {
        if let mr = Func.AKObtainMasterReference() {
            let task = Task(context: mr.getMOC())
            // Mirror.
            task.completionPercentage = interface.completionPercentage
            task.creationDate = interface.creationDate
            task.initialCompletionPercentage = interface.initialCompletionPercentage
            task.migrated = interface.migrated
            task.name = interface.name
            task.note = interface.note
            task.state = interface.state
            task.totalCompletion = interface.totalCompletion
            
            return task
        }
        
        return nil
    }
    
    static func from(task: Task) -> AKTaskInterface {
        var interface = AKTaskInterface()
        // Mirror.
        interface.completionPercentage = task.completionPercentage
        interface.creationDate = task.creationDate
        interface.initialCompletionPercentage = task.initialCompletionPercentage
        interface.migrated = task.migrated
        interface.name = task.name
        interface.note = task.note
        interface.state = task.state
        interface.totalCompletion = task.totalCompletion
        
        return interface
    }
    
    static func to(task: Task, from interface: AKTaskInterface) -> Void {
        // Mirror.
        task.completionPercentage = interface.completionPercentage
        task.creationDate = interface.creationDate
        task.initialCompletionPercentage = interface.initialCompletionPercentage
        task.migrated = interface.migrated
        task.name = interface.name
        task.note = interface.note
        task.state = interface.state
        task.totalCompletion = interface.totalCompletion
    }
}

struct AKTaskInterface {
    // MARK: Properties
    var completionPercentage: Float
    var creationDate: NSDate?
    var initialCompletionPercentage: Float
    var migrated: Bool
    var name: String?
    var note: String?
    var state: String?
    var totalCompletion: Float
    
    init() {
        self.completionPercentage = 0.0
        self.creationDate = NSDate()
        self.initialCompletionPercentage = 0.0
        self.migrated = false
        self.name = ""
        self.note = ""
        self.state = TaskStates.pending.rawValue
        self.totalCompletion = 1.0
    }
    
    init(name: String, state: String) {
        // Required.
        self.name = name
        
        // Optional.
        self.completionPercentage = 0.0
        self.initialCompletionPercentage = 0.0
        self.migrated = false
        self.note = ""
        self.state = state
        self.totalCompletion = 1.0
        
        // Fixed.
        self.creationDate = NSDate()
    }
    
    // MARK: Setters
    mutating func setCompletionPercentage(_ asString: String) {
        if asString.isEmpty {
            self.completionPercentage = 0.0
        }
        else {
            self.completionPercentage = Float(asString) ?? 0.0
        }
    }
    
    mutating func setCreationDate(_ asString: String) {
        if let date = Func.AKProcessDate(
            dateAsString: asString,
            format: Cons.AKFullDateFormat,
            timeZone: TimeZone(identifier: "GMT")!) {
            self.creationDate = date
        }
    }
    
    mutating func setInitialCompletionPercentage(_ asString: String) {
        if asString.isEmpty {
            self.initialCompletionPercentage = 0.0
        }
        else {
            self.initialCompletionPercentage = Float(asString) ?? 0.0
        }
    }
    
    mutating func setMigrated(_ asString: String) {
        if asString.isEmpty {
            self.migrated = false
        }
        else {
            self.migrated = asString.toBool() ?? false
        }
    }
    
    mutating func setState(_ asString: String) {
        if asString.isEmpty {
            self.state = TaskStates.pending.rawValue
        }
        else {
            self.state = asString
        }
    }
    
    mutating func setTotalCompletion(_ asString: String) {
        if asString.isEmpty {
            self.totalCompletion = 1.0
        }
        else {
            self.totalCompletion = Float(asString) ?? 1.0
        }
    }
    
    // MARK: Validations
    func validate() throws {}
}
