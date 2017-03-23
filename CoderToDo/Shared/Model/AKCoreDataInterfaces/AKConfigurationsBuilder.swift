import Foundation

class AKConfigurationsBuilder
{
    static func mirror(interface: AKConfigurationsInterface) -> Configurations?
    {
        if let mr = Func.AKObtainMasterReference() {
            let configurations = Configurations(context: mr.getMOC())
            // Mirror.
            configurations.automaticBackups = interface.automaticBackups
            configurations.cleaningMode = interface.cleaningMode
            configurations.showLocalNotificationMessage = interface.showLocalNotificationMessage
            configurations.useLocalNotifications = interface.useLocalNotifications
            configurations.weekFirstDay = interface.weekFirstDay
            configurations.weekLastDay = interface.weekLastDay
            
            return configurations
        }
        
        return nil
    }
    
    static func from(configurations: Configurations?) -> AKConfigurationsInterface?
    {
        if let configurations = configurations {
            var interface = AKConfigurationsInterface()
            // Mirror.
            interface.automaticBackups = configurations.automaticBackups
            interface.cleaningMode = configurations.cleaningMode
            interface.showLocalNotificationMessage = configurations.showLocalNotificationMessage
            interface.useLocalNotifications = configurations.useLocalNotifications
            interface.weekFirstDay = configurations.weekFirstDay
            interface.weekLastDay = configurations.weekLastDay
            
            return interface
        }
        
        return nil
    }
    
    static func to(configurations: Configurations?, from interface: AKConfigurationsInterface) -> Configurations?
    {
        if let configurations = configurations {
            // Mirror.
            configurations.automaticBackups = interface.automaticBackups
            configurations.cleaningMode = interface.cleaningMode
            configurations.showLocalNotificationMessage = interface.showLocalNotificationMessage
            configurations.useLocalNotifications = interface.useLocalNotifications
            configurations.weekFirstDay = interface.weekFirstDay
            configurations.weekLastDay = interface.weekLastDay
            
            return configurations
        }
        
        return nil
    }
}

struct AKConfigurationsInterface
{
    // MARK: Properties
    var automaticBackups: Bool
    var cleaningMode: Bool
    var showLocalNotificationMessage: Bool
    var useLocalNotifications: Bool
    var weekFirstDay: Int16
    var weekLastDay: Int16
    
    init()
    {
        self.automaticBackups = false
        self.cleaningMode = false
        self.showLocalNotificationMessage = true
        self.useLocalNotifications = true
        self.weekFirstDay = DaysOfWeek.monday.rawValue
        self.weekLastDay = DaysOfWeek.friday.rawValue
    }
    
    // MARK: Setters
    mutating func setAutomaticBackups(_ asString: String)
    {
        if asString.isEmpty {
            self.automaticBackups = false
        }
        else {
            self.automaticBackups = asString.toBool() ?? false
        }
    }
    
    mutating func setCleaningMode(_ asString: String)
    {
        if asString.isEmpty {
            self.cleaningMode = false
        }
        else {
            self.cleaningMode = asString.toBool() ?? false
        }
    }
    
    mutating func setShowLocalNotificationMessage(_ asString: String)
    {
        if asString.isEmpty {
            self.showLocalNotificationMessage = true
        }
        else {
            self.showLocalNotificationMessage = asString.toBool() ?? true
        }
    }
    
    mutating func setUseLocalNotifications(_ asString: String)
    {
        if asString.isEmpty {
            self.useLocalNotifications = true
        }
        else {
            self.useLocalNotifications = asString.toBool() ?? true
        }
    }
    
    mutating func setWeekFirstDay(_ asString: String)
    {
        if let day = Int16(asString) {
            self.weekFirstDay = day
        }
    }
    
    mutating func setWeekLastDay(_ asString: String)
    {
        if let day = Int16(asString) {
            self.weekLastDay = day
        }
    }
    
    // MARK: Validations
    func validate() throws {}
}
