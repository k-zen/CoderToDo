import UIKit

class AKTableCachingEntry {
    // MARK: Properties
    private var key: Date
    private var parentCell: AKDaysTableViewCell?
    private var childView: AKTasksTableView?
    // Caching System.
    private var parentCellHeight: CGFloat = 0.0
    private var parentCellHeightRecomputationRoutine: ((AKCustomViewController) -> CGFloat)?
    private var childViewHeight: CGFloat = 0.0
    private var childViewHeightRecomputationRoutine: ((AKCustomViewController) -> CGFloat)?
    
    // MARK: Initializers
    init(key: Date, parentCell: AKDaysTableViewCell?, childView: AKTasksTableView?) {
        self.key = key
        self.parentCell = parentCell
        self.childView = childView
    }
    
    // MARK: Accessors
    func getKey() -> Date { return self.key }
    
    func getParentCell() -> AKDaysTableViewCell? {
        if Cons.AKDebug {
            NSLog("=> CACHING: SERVING TABLE CELL FROM CACHE FOR KEY(%@)", self.key.description)
        }
        
        return self.parentCell
    }
    
    func getChildView() -> AKTasksTableView? {
        if Cons.AKDebug {
            NSLog("=> CACHING: SERVING TABLE VIEW FROM CACHE FOR KEY(%@)", self.key.description)
        }
        
        return self.childView
    }
    
    func getParentCellHeight() -> CGFloat { return self.parentCellHeight }
    
    func getChildViewHeight() -> CGFloat { return self.childViewHeight }
    
    func setKey(date: Date?) -> Void {
        if let date = date {
            self.key = date
        }
    }
    
    func setParentCell(cell: AKDaysTableViewCell?) -> Void {
        if let cell = cell {
            if Cons.AKDebug {
                NSLog("=> CACHING: ADDING TABLE CELL TO CACHE FOR KEY(%@)", self.key.description)
            }
            
            self.parentCell = cell
        }
    }
    
    func setChildView(view: AKTasksTableView?) -> Void {
        if let view = view {
            if Cons.AKDebug {
                NSLog("=> CACHING: ADDING TABLE VIEW TO CACHE FOR KEY(%@)", self.key.description)
            }
            
            self.childView = view
        }
    }
    
    func setParentCellHeightRecomputationRoutine(routine: @escaping (AKCustomViewController) -> CGFloat) -> Void {
        self.parentCellHeightRecomputationRoutine = routine
    }
    
    func setChildViewHeightRecomputationRoutine(routine: @escaping (AKCustomViewController) -> CGFloat) -> Void {
        self.childViewHeightRecomputationRoutine = routine
    }
    
    // MARK: Caching Functions
    func recomputeParentCellHeight(controller: AKCustomViewController) -> Void { self.parentCellHeight = self.parentCellHeightRecomputationRoutine != nil ? self.parentCellHeightRecomputationRoutine!(controller) : 0.0 }
    
    func recomputeChildViewHeight(controller: AKCustomViewController) -> Void { self.childViewHeight = self.childViewHeightRecomputationRoutine != nil ? self.childViewHeightRecomputationRoutine!(controller) : 0.0 }
    
    func refetchParentCell(dataFetch: () -> AKDaysTableViewCell) -> Void { self.parentCell = dataFetch() }
    
    func refetchChildView(dataFetch: () -> AKTasksTableView) -> Void { self.childView = dataFetch() }
}
