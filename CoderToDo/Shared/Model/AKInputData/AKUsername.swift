import Foundation

class AKUsername: AKInputData {
    override func validate() throws {
        do {
            try isReady()
        }
        catch Exceptions.emptyData(let msg) {
            throw Exceptions.emptyData(msg)
        }
        
        guard inputData.count >= Cons.AKMinUsernameLength else {
            throw Exceptions.invalidLength(String(format: "The username must be at least %i characters.", Cons.AKMinUsernameLength))
        }
    }
}
