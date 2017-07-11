import CloudKit
import Foundation

class AKCloudKitController: NSObject {
    static func uploadToPrivate(
        presenterController: AKCustomViewController,
        completionTask: ((_ presenterController: AKCustomViewController?, _ backupInfo: BackupInfo?) -> Void)?) {
        do {
            if let backupInfo = try AKXMLController.writeToFile() {
                if let date = backupInfo.date, let md5 = backupInfo.md5, let size = backupInfo.size, let filename = backupInfo.filename {
                    if Cons.AKDebug {
                        NSLog("=> INFO: BACKUP INFORMATION")
                        NSLog("=> INFO: ------------------")
                        NSLog("=> INFO: DATE => %@", date.description)
                        NSLog("=> INFO: MD5 => %@", md5)
                        NSLog("=> INFO: SIZE => %d", size)
                    }
                    
                    let backup = CKRecord(recordType: Cons.AKBackupRecordTypeName, recordID: CKRecordID(recordName: Date().description))
                    backup.setValue("Entry", forKey: "Name")
                    backup.setValue(date, forKey: BackupInfo.Fields.dateKey.rawValue)
                    backup.setValue(md5, forKey: BackupInfo.Fields.md5Key.rawValue)
                    backup.setValue(size, forKey: BackupInfo.Fields.sizeKey.rawValue)
                    backup.setValue(CKAsset(fileURL: filename), forKey: BackupInfo.Fields.dataKey.rawValue)
                    
                    Func.AKGetCloudKitContainer().privateCloudDatabase.save(
                        backup,
                        completionHandler: { (record, error) -> Void in
                            Func.AKExecuteInMainThread(controller: presenterController, mode: .async, code: { (controller) -> Void in
                                guard error == nil else {
                                    // TODO: Show error message and disable function.
                                    NSLog("=> ERROR: \(String(describing: error))")
                                    return
                                }
                                
                                if completionTask != nil {
                                    completionTask!(controller, backupInfo)
                                }
                            }) }
                    )
                }
            }
        }
        catch {
            fatalError("=> ERROR: \(error)")
        }
    }
    
    static func downloadFromPrivate(
        presenterController: AKCustomViewController,
        completionTask: ((_ presenterController: AKCustomViewController?, _ backupInfo: BackupInfo?) -> Void)?) {
        var backupInfo = [BackupInfo]()
        
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: Cons.AKBackupRecordTypeName, predicate: predicate)
        query.sortDescriptors = [NSSortDescriptor(key: BackupInfo.Fields.dateKey.rawValue, ascending: false)]
        
        let queryOperation = CKQueryOperation(query: query)
        queryOperation.resultsLimit = 1
        queryOperation.desiredKeys = [
            BackupInfo.Fields.dateKey.rawValue,
            BackupInfo.Fields.md5Key.rawValue,
            BackupInfo.Fields.sizeKey.rawValue,
            BackupInfo.Fields.dataKey.rawValue,
        ]
        queryOperation.recordFetchedBlock = { (record) -> Void in
            var info = BackupInfo()
            
            do {
                if
                    let d = record[BackupInfo.Fields.dateKey.rawValue] as? Date,
                    let m = record[BackupInfo.Fields.md5Key.rawValue] as? String,
                    let s = record[BackupInfo.Fields.sizeKey.rawValue] as? Int64,
                    let a = record[BackupInfo.Fields.dataKey.rawValue] as? CKAsset {
                    info.date = d
                    info.md5 = m
                    info.size = s
                    info.data = try Data(contentsOf: a.fileURL)
                    
                    backupInfo.append(info)
                }
            }
            catch {
                fatalError("=> ERROR: \(error)")
            }
        }
        queryOperation.queryCompletionBlock = { (cursor, error) -> Void in
            Func.AKExecuteInMainThread(controller: presenterController, mode: .async, code: { (controller) -> Void in
                guard error == nil else {
                    // TODO: Show error message and disable function.
                    NSLog("=> ERROR: \(String(describing: error))")
                    return
                }
                
                if backupInfo.count > 0 {
                    do {
                        if let d = backupInfo.first?.data {
                            try AKXMLBuilder.unmarshall(data: d)
                        }
                    }
                    catch {
                        fatalError("=> ERROR: \(error)")
                    }
                    
                    if completionTask != nil {
                        completionTask!(controller, backupInfo.first)
                    }
                }
            })
        }
        
        Func.AKGetCloudKitContainer().privateCloudDatabase.add(queryOperation)
    }
    
    static func getLastBackupInfo(
        presenterController: AKCustomViewController,
        forceCompletionTask: Bool = false,
        completionTask: ((_ presenterController: AKCustomViewController?, _ backupInfo: BackupInfo?) -> Void)?) {
        var backupInfo = [BackupInfo]()
        
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: Cons.AKBackupRecordTypeName, predicate: predicate)
        query.sortDescriptors = [NSSortDescriptor(key: BackupInfo.Fields.dateKey.rawValue, ascending: false)]
        
        let queryOperation = CKQueryOperation(query: query)
        queryOperation.resultsLimit = 1
        queryOperation.desiredKeys = [
            BackupInfo.Fields.dateKey.rawValue,
            BackupInfo.Fields.md5Key.rawValue,
            BackupInfo.Fields.sizeKey.rawValue
        ]
        queryOperation.recordFetchedBlock = { (record) -> Void in
            var info = BackupInfo()
            
            if
                let d = record[BackupInfo.Fields.dateKey.rawValue] as? Date,
                let m = record[BackupInfo.Fields.md5Key.rawValue] as? String,
                let s = record[BackupInfo.Fields.sizeKey.rawValue] as? Int64 {
                info.date = d
                info.md5 = m
                info.size = s
            }
            
            backupInfo.append(info)
        }
        queryOperation.queryCompletionBlock = { (cursor, error) -> Void in
            Func.AKExecuteInMainThread(controller: presenterController, mode: .async, code: { (controller) -> Void in
                guard error == nil else {
                    // TODO: Show error message and disable function.
                    NSLog("=> ERROR: \(String(describing: error))")
                    return
                }
                
                if completionTask != nil {
                    if backupInfo.count > 0 {
                        completionTask!(controller, backupInfo.first)
                    }
                    else if backupInfo.count == 0 && forceCompletionTask {
                        completionTask!(controller, nil)
                    }
                }
            })
        }
        
        Func.AKGetCloudKitContainer().privateCloudDatabase.add(queryOperation)
    }
}
