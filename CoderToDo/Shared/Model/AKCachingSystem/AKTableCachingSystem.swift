import UIKit

class AKTableCachingSystem {
    // MARK: Properties
    private let projectName: String
    private var cachingEntries = [String : [Date : AKTableCachingEntry]]()
    
    // MARK: Initializers
    init(projectName: String) {
        self.projectName = projectName
        self.cachingEntries[projectName] = [Date : AKTableCachingEntry]()
    }
    
    // MARK: Caching Functions
    func addEntry(controller: AKCustomViewController, key: Date, newEntry: AKTableCachingEntry) -> Void {
        if self.cachingEntries[self.projectName] != nil {
            if Cons.AKDebug {
                NSLog("=> CACHING: ADDING ENTRY TO CACHE FOR KEY(%@)", key.description)
            }
            
            self.cachingEntries[self.projectName]!.updateValue(newEntry, forKey: key)
        }
    }
    
    func getEntry(controller: AKCustomViewController, key: Date) -> AKTableCachingEntry? {
        if self.cachingEntries[self.projectName] != nil {
            if Cons.AKDebug {
                NSLog("=> CACHING: SERVING ENTRY FROM CACHE FOR KEY(%@)", key.description)
            }
            
            return self.cachingEntries[self.projectName]![key]
        }
        
        return nil
    }
    
    func triggerHeightRecomputation(controller: AKCustomViewController) -> Void {
        if self.cachingEntries[self.projectName] != nil {
            for (key, value) in self.cachingEntries[self.projectName]! {
                if Cons.AKDebug {
                    NSLog("=> CACHING: RECOMPUTING HEIGHT FOR KEY(%@)", key.description)
                }
                
                value.recomputeParentCellHeight(controller: controller)
                value.recomputeChildViewHeight(controller: controller)
            }
        }
    }
    
    func triggerChildViewsReload(controller: AKCustomViewController) -> Void {
        if self.cachingEntries[self.projectName] != nil {
            for (key, value) in self.cachingEntries[self.projectName]! {
                if let view = value.getChildView() {
                    if Cons.AKDebug {
                        NSLog("=> CACHING: RELOADING CHILD TABLE VIEW FOR KEY(%@)", key.description)
                    }
                    
                    Func.AKReloadTable(tableView: view.tasksTable)
                }
            }
        }
    }
}
