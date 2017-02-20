import Foundation

class AKTaskName: AKInputData
{
    override func validate() throws
    {
        do {
            try isReady()
        }
        catch Exceptions.emptyData(let msg) {
            throw Exceptions.emptyData(msg)
        }
        
        guard inputData.characters.count >= GlobalConstants.AKMinTaskNameLength else {
            throw Exceptions.invalidLength(String(format: "The task's name must be at least %i characters.", GlobalConstants.AKMinTaskNameLength))
        }
    }
}
