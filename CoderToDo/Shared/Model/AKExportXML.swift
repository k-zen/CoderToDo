import Foundation

class AKExportXML: NSObject
{
    static func writeToFile() throws
    {
        if let fileName = try Func.AKOpenFileArchive(fileName: "DataExport.xml", location: .documentDirectory, shouldCreate: true), let data = AKXMLBuilder.marshall() {
            try data.write(to: fileName, options: .atomic)
        }
    }
    
    static func readFromFile() throws
    {
        if let fileName = try Func.AKOpenFileArchive(fileName: "DataExport.xml", location: .documentDirectory, shouldCreate: false) {
            try AKXMLBuilder.unmarshall(data: try Data(contentsOf: fileName))
        }
    }
}
