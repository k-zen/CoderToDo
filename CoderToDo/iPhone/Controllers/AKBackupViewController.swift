import UIKit

class AKBackupViewController: AKCustomViewController
{
    // MARK: Outlets
    @IBOutlet var lastBackupValue: UILabel!
    @IBOutlet var lastBackupSizeValue: UILabel!
    @IBOutlet var backupNow: UIButton!
    @IBOutlet var dataHashValue: UILabel!
    // @IBOutlet var automaticBackupsValue: UISwitch!
    @IBOutlet var restoreNow: UIButton!
    
    // MARK: Actions
    @IBAction func backupNow(_ sender: Any)
    {
        Func.AKToggleButtonMode(button: self.backupNow, mode: .disabled)
        
        // Check the size of this device's data. IF its smaller then alert the user.
        // Load last backup info from iCloud.
        AKCloudKitController.getLastBackupInfo(
            presenterController: self,
            completionTask: { (presenterController, backupInfo) -> Void in
                if let presenterController = presenterController as? AKBackupViewController, let backupInfo = backupInfo {
                    if let sizeLocal = AKXMLController.getLocalBackupInfo()?.size, let sizeRemote = backupInfo.size {
                        if sizeLocal < sizeRemote {
                            presenterController.showContinueMessage(
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
                                                
                                                Func.AKToggleButtonMode(button: presenterController.backupNow, mode: .enabled)
                                            }
                                    })
                                    
                                    presenterController?.hideContinueMessage(animate: true, completionTask: nil) },
                                noAction: { (presenterController) -> Void in
                                    if let presenterController = presenterController as? AKBackupViewController {
                                        Func.AKToggleButtonMode(button: presenterController.backupNow, mode: .enabled)
                                    }
                                    
                                    presenterController?.hideContinueMessage(animate: true, completionTask: nil) },
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
                                        
                                        Func.AKToggleButtonMode(button: presenterController.backupNow, mode: .enabled)
                                    }
                            })
                        }
                    }
                }
        })
    }
    
    @IBAction func restoreNow(_ sender: Any)
    {
        Func.AKToggleButtonMode(button: self.restoreNow, mode: .disabled)
        
        if !DataInterface.isProjectEmpty() {
            self.showContinueMessage(
                message: "This will wipe out your current local database and restore from this backup. Do you wish to continue...?",
                yesAction: { (presenterController) -> Void in
                    DataInterface.resetProjectData()
                    
                    if let presenterController = presenterController as? AKBackupViewController {
                        AKCloudKitController.downloadFromPrivate(
                            presenterController: presenterController,
                            completionTask: { (presenterController, backupInfo) -> Void in
                                if let presenterController = presenterController as? AKBackupViewController, let _ = backupInfo {
                                    Func.AKToggleButtonMode(button: presenterController.restoreNow, mode: .enabled)
                                    
                                    presenterController.showMessage(
                                        message: String(format: "Hooray %@, you have successfully restored your data from iCloud!", DataInterface.getUsername()),
                                        animate: true,
                                        completionTask: nil
                                    )
                                } })
                    }
                    
                    presenterController?.hideContinueMessage(animate: true, completionTask: nil) },
                noAction: { (presenterController) -> Void in
                    if let presenterController = presenterController as? AKBackupViewController {
                        Func.AKToggleButtonMode(button: presenterController.restoreNow, mode: .enabled)
                    }
                    
                    presenterController?.hideContinueMessage(animate: true, completionTask: nil) },
                animate: true,
                completionTask: nil
            )
        }
    }
    
    // @IBAction func changeAutomaticBackups(_ sender: Any)
    // {
    //     let configurationsMO = DataInterface.getConfigurations()
    //     if var configurations = AKConfigurationsBuilder.from(configurations: configurationsMO) {
    //         configurations.automaticBackups = self.automaticBackupsValue.isOn
    //
    //         DataInterface.addConfigurations(configurations: AKConfigurationsBuilder.to(configurations: configurationsMO, from: configurations))
    //     }
    // }
    
    // MARK: AKCustomViewController Overriding
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.customSetup()
        
        // Load the data.
        // self.automaticBackupsValue.isOn = DataInterface.getConfigurations()?.automaticBackups ?? false
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        
        // Disable buttons.
        Func.AKToggleButtonMode(button: self.backupNow, mode: .disabled)
        Func.AKToggleButtonMode(button: self.restoreNow, mode: .disabled)
    }
    
    override func viewDidLayoutSubviews()
    {
        super.viewDidLayoutSubviews()
        
        // Custom L&F.
        self.backupNow.layer.cornerRadius = GlobalConstants.AKButtonCornerRadius
        self.restoreNow.layer.cornerRadius = GlobalConstants.AKButtonCornerRadius
    }
    
    // MARK: Miscellaneous
    func customSetup()
    {
        super.inhibitiCloudMessage = false
        super.iCloudAccessAvailableAction = { (presenterController) -> Void in
            if let presenterController = presenterController as? AKBackupViewController {
                Func.AKToggleButtonMode(button: presenterController.backupNow, mode: .enabled)
                
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
                            Func.AKToggleButtonMode(button: presenterController.restoreNow, mode: .enabled)
                        } }
                )
            }
        }
        super.iCloudAccessErrorAction = { (presenterController) -> Void in
            presenterController?.showMessage(
                message: "There had been an error accessing your iCloud account. Please check again later.",
                animate: true,
                completionTask: nil
            )
        }
        super.setup()
    }
}
