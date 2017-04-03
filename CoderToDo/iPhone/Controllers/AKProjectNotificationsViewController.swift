import UIKit
import UserNotifications

class AKProjectNotificationsViewController: AKCustomViewController
{
    // MARK: Properties
    var project: Project!
    
    // MARK: Outlets
    @IBOutlet weak var enableNotifications: UISwitch!
    
    // MARK: Actions
    @IBAction func enableNotifications(_ sender: Any)
    {
        var project = AKProjectBuilder.from(project: self.project)
        project.notifyClosingTime = self.enableNotifications.isOn
        AKProjectBuilder.to(project: self.project, from: project)
        
        if self.enableNotifications.isOn {
            let closingTimeContent = UNMutableNotificationContent()
            closingTimeContent.title = String(format: "Project: %@", self.project.name!)
            closingTimeContent.body = String(
                format: "Hi %@, it's me again... closing time is due for your project. You have %i minutes for editing tasks before this day is marked as closed.",
                DataInterface.getUsername(),
                self.project.closingTimeTolerance
            )
            closingTimeContent.sound = UNNotificationSound.default()
            Func.AKGetNotificationCenter().add(
                UNNotificationRequest(
                    identifier: String(format: "%@:%@", GlobalConstants.AKClosingTimeNotificationName, self.project.name!),
                    content: closingTimeContent,
                    trigger: UNCalendarNotificationTrigger(
                        dateMatching: Func.AKGetCalendarForLoading().dateComponents([.hour,.minute,.second,], from: self.project.closingTime! as Date),
                        repeats: true
                    )
                ),
                withCompletionHandler: { (error) in
                    if let _ = error {
                        self.showMessage(
                            message: "Ooops, there was a problem scheduling the notification.",
                            animate: true,
                            completionTask: nil
                        )
                    } }
            )
        }
        else {
            Func.AKGetNotificationCenter().removeDeliveredNotifications(withIdentifiers: [String(format: "%@:%@", GlobalConstants.AKClosingTimeNotificationName, self.project.name!)])
            Func.AKGetNotificationCenter().removePendingNotificationRequests(withIdentifiers: [String(format: "%@:%@", GlobalConstants.AKClosingTimeNotificationName, self.project.name!)])
        }
    }
    
    // MARK: AKCustomViewController Overriding
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.customSetup()
        
        // Load the data.
        self.enableNotifications.isOn = self.project.notifyClosingTime
    }
    
    override func viewDidLayoutSubviews()
    {
        super.viewDidLayoutSubviews()
    }
    
    // MARK: Miscellaneous
    func customSetup()
    {
        super.setup()
    }
}
