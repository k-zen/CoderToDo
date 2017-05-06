import Foundation

class AKXMLController: NSObject {
    static func writeToFile() throws -> BackupInfo? {
        if let fileName = try Func.AKOpenFileArchive(fileName: "DataExport.xml", location: .documentDirectory, shouldCreate: true) {
            var backupInfo = AKXMLBuilder.marshall()
            
            if let data = backupInfo?.data {
                try data.write(to: fileName, options: .atomic)
                
                // Save the filename to the BackupInfo dictionary.
                backupInfo?.filename = fileName
            }
            
            return backupInfo
        }
        
        return nil
    }
    
    static func readFromFile() throws {
        if let fileName = try Func.AKOpenFileArchive(fileName: "DataExport.xml", location: .documentDirectory, shouldCreate: false) {
            try AKXMLBuilder.unmarshall(data: try Data(contentsOf: fileName))
        }
    }
    
    static func getLocalBackupInfo() -> BackupInfo? { return AKXMLBuilder.marshall() }
}
