import Foundation

class AKProjectName: AKInputData {
    override func validate() throws {
        do {
            try isReady()
        }
        catch Exceptions.emptyData(let msg) {
            throw Exceptions.emptyData(msg)
        }
        
        guard inputData.characters.count >= Cons.AKMinProjectNameLength else {
            throw Exceptions.invalidLength(String(format: "The project's name must be at least %i characters.", Cons.AKMinProjectNameLength))
        }
    }
}
