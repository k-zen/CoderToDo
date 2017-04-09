import UIKit

class AKTableCachingEntry
{
    // MARK: Properties
    private var entryKey: NSDate
    private var entryValue: UITableViewCell?
    // Caching System.
    private var entryValueHeight: CGFloat = 0.0
    private var heightRecomputationRoutine: ((AKCustomViewController) -> CGFloat)?
    
    // MARK: Initializers
    init(entryKey: NSDate, entryValue: UITableViewCell?) {
        self.entryKey = entryKey
        self.entryValue = entryValue
    }
    
    // MARK: Accessors
    func getKey() -> NSDate { return self.entryKey }
    
    func getValue() -> UITableViewCell?
    {
        if GlobalConstants.AKDebug {
            NSLog("=> CACHING: SERVING TABLE CELL FROM CACHE FOR KEY(%@)", self.entryKey.description)
        }
        
        return self.entryValue
    }
    
    func getValueHeight() -> CGFloat { return self.entryValueHeight }
    
    func setKey(date: NSDate?) -> Void
    {
        if let date = date {
            self.entryKey = date
        }
    }
    
    func setValue(cell: UITableViewCell?) -> Void
    {
        if let cell = cell {
            if GlobalConstants.AKDebug {
                NSLog("=> CACHING: ADDING TABLE CELL TO CACHE FOR KEY(%@)", self.entryKey.description)
            }
            
            self.entryValue = cell
        }
    }
    
    func setHeightRecomputationRoutine(routine: @escaping (AKCustomViewController) -> CGFloat) -> Void
    {
        self.heightRecomputationRoutine = routine
    }
    
    // MARK: Caching Functions
    func recomputeHeight(controller: AKCustomViewController) -> Void
    {
        self.entryValueHeight = self.heightRecomputationRoutine != nil ? self.heightRecomputationRoutine!(controller) : 0.0
    }
    
    func refetchData(dataFetch: () -> UITableViewCell) -> Void
    {
        self.entryValue = dataFetch()
    }
}
