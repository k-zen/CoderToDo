import Foundation

class AKCategoryName: AKInputData {
    override func validate() throws {
        do {
            try isReady()
        }
        catch Exceptions.emptyData(let msg) {
            throw Exceptions.emptyData(msg)
        }
        
        guard inputData.count >= Cons.AKMinCategoryNameLength else {
            throw Exceptions.invalidLength(String(format: "The category's name must be at least %i characters.", Cons.AKMinCategoryNameLength))
        }
    }
}
