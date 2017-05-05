import UIKit

class AKGoodiesViewController: AKCustomViewController {
    // MARK: Outlets
    @IBOutlet weak var cleaningMode: UISwitch!
    @IBOutlet weak var cancelAllNotifications: UIButton!
    
    // MARK: Actions
    @IBAction func cleaningMode(_ sender: Any) {
        let configurationsMO = DataInterface.getConfigurations()
        if var configurations = AKConfigurationsBuilder.from(configurations: configurationsMO) {
            configurations.cleaningMode = self.cleaningMode.isOn
            DataInterface.addConfigurations(configurations: AKConfigurationsBuilder.to(configurations: configurationsMO, from: configurations))
        }
    }
    
    @IBAction func cancelAllNotifications(_ sender: Any) {
        self.showContinueMessage(
            origin: CGPoint.zero,
            type: .warning,
            message: "This will cancel all notifications and can't be undone. Continue...?",
            yesAction: { (presenterController) -> Void in
                Func.AKInvalidateLocalNotification(controller: self, project: nil)
                
                presenterController?.showMessage(
                    origin: CGPoint.zero,
                    type: .info,
                    message: "All notifications were canceled!",
                    animate: true,
                    completionTask: nil
                ) },
            noAction: nil,
            animate: true,
            completionTask: nil
        )
    }
    
    // MARK: AKCustomViewController Overriding
    override func viewDidLoad() {
        super.viewDidLoad()
        self.customSetup()
    }
    
    // MARK: Miscellaneous
    func customSetup() {
        self.loadData = { (controller) -> Void in
            if let controller = controller as? AKGoodiesViewController {
                controller.cleaningMode.isOn = DataInterface.getConfigurations()?.cleaningMode ?? false
            }
        }
        self.configureLookAndFeel = { (controller) -> Void in
            if let controller = controller as? AKGoodiesViewController {
                Func.AKStyleButton(button: controller.cancelAllNotifications)
            }
        }
        self.setup()
    }
}
