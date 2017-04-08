import UIKit

class AKBackupViewController: AKCustomViewController
{
    // MARK: Outlets
    @IBOutlet var lastBackupValue: UILabel!
    @IBOutlet var lastBackupSizeValue: UILabel!
    @IBOutlet var backupNow: UIButton!
    @IBOutlet var dataHashValue: UILabel!
    @IBOutlet var restoreNow: UIButton!
    
    // MARK: Actions
    @IBAction func backupNow(_ sender: Any)
    {
        Func.AKToggleButtonMode(controller: self, button: self.backupNow, mode: .disabled, showSpinner: true, direction: .disableToEnable)
        
        // Check the size of this device's data. IF its smaller then alert the user.
        // Load last backup info from iCloud.
        AKCloudKitController.getLastBackupInfo(
            presenterController: self,
            completionTask: { (presenterController, backupInfo) -> Void in
                if let presenterController = presenterController as? AKBackupViewController, let backupInfo = backupInfo {
                    if let sizeLocal = AKXMLController.getLocalBackupInfo()?.size, let sizeRemote = backupInfo.size {
                        if sizeLocal < sizeRemote {
                            presenterController.showContinueMessage(
                                origin: CGPoint.zero,
                                type: .warning,
                                message: "The file you have in iCloud appears to be bigger in size than the one you have on your device. Do you wish to continue...?",
                                yesAction: { (presenterController) -> Void in
                                    // Make backup here from a background thread.
                                    AKCloudKitController.uploadToPrivate(
                                        presenterController: self,
                                        completionTask: { (presenterController, backupInfo) -> Void in
                                            if let presenterController = presenterController as? AKBackupViewController, let backupInfo = backupInfo {
                                                // Set the last backup's information.
                                                presenterController.lastBackupValue.text = String(
                                                    format: "%@ %@",
                                                    Func.AKGetFormattedDate(date: backupInfo.date),
                                                    Func.AKGetFormattedTime(date: backupInfo.date)
                                                )
                                                presenterController.lastBackupSizeValue.text = String(format: "%@ bytes", Func.AKFormatNumber(number: NSNumber(value: backupInfo.size ?? 0)))
                                                presenterController.dataHashValue.text = backupInfo.md5 ?? ""
                                                
                                                Func.AKToggleButtonMode(controller: self, button: presenterController.backupNow, mode: .enabled, showSpinner: true, direction: .disableToEnable)
                                            }
                                    }) },
                                noAction: { (presenterController) -> Void in
                                    if let presenterController = presenterController as? AKBackupViewController {
                                        Func.AKToggleButtonMode(controller: self, button: presenterController.backupNow, mode: .enabled, showSpinner: true, direction: .disableToEnable)
                                    } },
                                animate: true,
                                completionTask: nil
                            )
                        }
                        else {
                            // Make backup here from a background thread.
                            AKCloudKitController.uploadToPrivate(
                                presenterController: self,
                                completionTask: { (presenterController, backupInfo) -> Void in
                                    if let presenterController = presenterController as? AKBackupViewController, let backupInfo = backupInfo {
                                        // Set the last backup's information.
                                        presenterController.lastBackupValue.text = String(
                                            format: "%@ %@",
                                            Func.AKGetFormattedDate(date: backupInfo.date),
                                            Func.AKGetFormattedTime(date: backupInfo.date)
                                        )
                                        presenterController.lastBackupSizeValue.text = String(format: "%@ bytes", Func.AKFormatNumber(number: NSNumber(value: backupInfo.size ?? 0)))
                                        presenterController.dataHashValue.text = backupInfo.md5 ?? ""
                                        
                                        Func.AKToggleButtonMode(controller: self, button: presenterController.backupNow, mode: .enabled, showSpinner: true, direction: .disableToEnable)
                                    }
                            })
                        }
                    }
                }
        })
    }
    
    @IBAction func restoreNow(_ sender: Any)
    {
        Func.AKToggleButtonMode(controller: self, button: self.restoreNow, mode: .disabled, showSpinner: true, direction: .disableToEnable)
        
        if !DataInterface.isProjectEmpty() {
            self.showContinueMessage(
                origin: CGPoint.zero,
                type: .warning,
                message: "This will wipe out your current local database and restore from this backup. Do you wish to continue...?",
                yesAction: { (presenterController) -> Void in
                    DataInterface.resetProjectData()
                    
                    if let presenterController = presenterController as? AKBackupViewController {
                        AKCloudKitController.downloadFromPrivate(
                            presenterController: presenterController,
                            completionTask: { (presenterController, backupInfo) -> Void in
                                if let presenterController = presenterController as? AKBackupViewController, let _ = backupInfo {
                                    Func.AKToggleButtonMode(controller: self, button: presenterController.restoreNow, mode: .enabled, showSpinner: true, direction: .disableToEnable)
                                    
                                    presenterController.showMessage(
                                        origin: CGPoint.zero,
                                        type: .info,
                                        message: String(format: "Hooray %@, you have successfully restored your data from iCloud!", DataInterface.getUsername()),
                                        animate: true,
                                        completionTask: nil
                                    )
                                } })
                    } },
                noAction: { (presenterController) -> Void in
                    if let presenterController = presenterController as? AKBackupViewController {
                        Func.AKToggleButtonMode(controller: self, button: presenterController.restoreNow, mode: .enabled, showSpinner: true, direction: .disableToEnable)
                    } },
                animate: true,
                completionTask: nil
            )
        }
    }
    
    // MARK: AKCustomViewController Overriding
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.customSetup()
    }
    
    // MARK: Miscellaneous
    func customSetup()
    {
        self.shouldAddSpinner = true
        self.inhibitiCloudMessage = false
        self.iCloudAccessAvailableAction = { (presenterController) -> Void in
            if let presenterController = presenterController as? AKBackupViewController {
                Func.AKToggleButtonMode(controller: self, button: presenterController.backupNow, mode: .enabled, showSpinner: false, direction: .disableToEnable)
                
                // Load last backup info from iCloud.
                AKCloudKitController.getLastBackupInfo(
                    presenterController: presenterController,
                    completionTask: { (presenterController, backupInfo) -> Void in
                        if let presenterController = presenterController as? AKBackupViewController, let backupInfo = backupInfo {
                            // Set the last backup's information.
                            presenterController.lastBackupValue.text = String(
                                format: "%@ %@",
                                Func.AKGetFormattedDate(date: backupInfo.date),
                                Func.AKGetFormattedTime(date: backupInfo.date)
                            )
                            presenterController.lastBackupSizeValue.text = String(format: "%@ bytes", Func.AKFormatNumber(number: NSNumber(value: backupInfo.size ?? 0)))
                            presenterController.dataHashValue.text = backupInfo.md5 ?? ""
                            
                            // Enable restore button, ONLY if there is
                            // at least 1 record to restore from.
                            Func.AKToggleButtonMode(controller: self, button: presenterController.restoreNow, mode: .enabled, showSpinner: false, direction: .disableToEnable)
                        } }
                )
            }
        }
        self.iCloudAccessErrorAction = { (presenterController) -> Void in
            presenterController?.showMessage(
                origin: CGPoint.zero,
                type: .error,
                message: "There had been an error accessing your iCloud account. Please check again later.",
                animate: true,
                completionTask: nil
            )
        }
        self.loadData = { (controller) -> Void in
            if let controller = controller as? AKBackupViewController {
                // Disable buttons.
                Func.AKToggleButtonMode(controller: controller, button: controller.backupNow, mode: .disabled, showSpinner: false, direction: .disableToEnable)
                Func.AKToggleButtonMode(controller: controller, button: controller.restoreNow, mode: .disabled, showSpinner: false, direction: .disableToEnable)
            }
        }
        self.configureLookAndFeel = { (controller) -> Void in
            if let controller = controller as? AKBackupViewController {
                controller.backupNow.layer.cornerRadius = GlobalConstants.AKButtonCornerRadius
                controller.restoreNow.layer.cornerRadius = GlobalConstants.AKButtonCornerRadius
            }
        }
        self.setup()
    }
}
