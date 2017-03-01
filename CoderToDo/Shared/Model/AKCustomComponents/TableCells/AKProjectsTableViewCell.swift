import UIKit

class AKProjectsTableViewCell: UITableViewCell
{
    // MARK: Properties
    var controller: AKCustomViewController?
    var project: Project?
    
    // MARK: Outlets
    @IBOutlet weak var mainContainer: UIView!
    @IBOutlet weak var infoContainer: UIView!
    @IBOutlet weak var osrValue: UILabel!
    @IBOutlet weak var stateContainer: UIView!
    @IBOutlet weak var runningDaysValue: UILabel!
    @IBOutlet weak var addTomorrowTask: UIButton!
    @IBOutlet weak var statusValue: UILabel!
    @IBOutlet weak var startValue: UILabel!
    @IBOutlet weak var closeValue: UILabel!
    
    // MARK: Actions
    @IBAction func addTomorrowTask(_ sender: Any)
    {
        if let project = self.project, let presenterController = self.controller as? AKListProjectsViewController {
            do {
                try AKChecks.canAddTask(project: project)
                presenterController.presentView(controller: AKAddTaskViewController(nibName: "AKAddTaskView", bundle: nil),
                                                taskBeforePresenting: { (presenterController, presentedController) -> Void in
                                                    if let presentedController = presentedController as? AKAddTaskViewController {
                                                        presentedController.project = project
                                                    } },
                                                dismissViewCompletionTask: { (presenterController, presentedController) -> Void in
                                                    NSLog("=> INFO: \(type(of: presentedController)) MODAL PRESENTATION HAS BEEN DISMISSED...")
                                                    
                                                    presenterController.dismissView(executeDismissTask: true) }
                )
            }
            catch {
                Func.AKPresentMessageFromError(controller: presenterController, message: "\(error)")
            }
        }
    }
    
    // MARK: UITableViewCell Overriding
    override func awakeFromNib()
    {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)
    }
}
