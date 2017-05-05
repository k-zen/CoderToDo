import UIKit
import UserNotifications

class AKProjectNotificationsViewController: AKCustomViewController {
    // MARK: Properties
    var project: Project!
    
    // MARK: Outlets
    @IBOutlet weak var enableNotifications: UISwitch!
    
    // MARK: Actions
    @IBAction func enableNotifications(_ sender: Any) {
        var project = AKProjectBuilder.from(project: self.project)
        project.notifyClosingTime = self.enableNotifications.isOn
        AKProjectBuilder.to(project: self.project, from: project)
        
        if self.enableNotifications.isOn {
            Func.AKScheduleLocalNotification(
                controller: self,
                project: self.project,
                completionTask: { (presenterController) -> Void in
                    presenterController?.showMessage(
                        origin: CGPoint.zero,
                        type: .error,
                        message: "Ooops, there was a problem scheduling the notification.",
                        animate: true,
                        completionTask: nil
                    ) }
            )
        }
        else {
            Func.AKInvalidateLocalNotification(controller: self, project: self.project)
        }
    }
    
    // MARK: AKCustomViewController Overriding
    override func viewDidLoad() {
        super.viewDidLoad()
        self.customSetup()
    }
    
    // MARK: Miscellaneous
    func customSetup() {
        self.loadData = { (controller) -> Void in
            if let controller = controller as? AKProjectNotificationsViewController {
                controller.enableNotifications.isOn = controller.project.notifyClosingTime
            }
        }
        self.setup()
    }
}
