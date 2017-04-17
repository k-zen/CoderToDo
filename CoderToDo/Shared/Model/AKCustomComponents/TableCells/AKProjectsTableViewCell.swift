import UIKit

class AKProjectsTableViewCell: UITableViewCell
{
    // MARK: Properties
    let displaceableMenuOverlay = AKDisplaceableTableMenuView()
    var swipeLeftGesture: UISwipeGestureRecognizer?
    var swipeRightGesture: UISwipeGestureRecognizer?
    var controller: AKCustomViewController?
    var project: Project?
    
    // MARK: Outlets
    @IBOutlet weak var mainContainer: UIView!
    @IBOutlet weak var infoContainer: UIView!
    @IBOutlet weak var osrValue: UILabel!
    @IBOutlet weak var runningDaysValue: UILabel!
    @IBOutlet weak var startValue: UILabel!
    @IBOutlet weak var closeValue: UILabel!
    @IBOutlet weak var newDayStateValue: UILabel!
    @IBOutlet weak var addTomorrowTask: UIButton!
    
    // MARK: Constraints
    @IBOutlet weak var newDayStateValueHeight: NSLayoutConstraint!
    
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
                                                    if let presenterController = presenterController as? AKListProjectsViewController {
                                                        Func.AKReloadTable(tableView: presenterController.projectsTable) // Reload the table to update the *New Day State* label.
                                                    }
                                                    
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
        
        // Manage gestures.
        self.swipeLeftGesture = UISwipeGestureRecognizer(target: self, action: #selector(AKProjectsTableViewCell.swipeLeft(_:)))
        self.swipeLeftGesture?.delegate = self
        self.swipeLeftGesture?.direction = .left
        self.addGestureRecognizer(self.swipeLeftGesture!)
        self.swipeRightGesture = UISwipeGestureRecognizer(target: self, action: #selector(AKProjectsTableViewCell.swipeRight(_:)))
        self.swipeRightGesture?.delegate = self
        self.swipeRightGesture?.direction = .right
        self.addGestureRecognizer(self.swipeRightGesture!)
        
        // Custom L&F.
        self.addTomorrowTask.layer.cornerRadius = GlobalConstants.AKButtonCornerRadius
        self.selectionStyle = UITableViewCellSelectionStyle.none
        self.mainContainer.backgroundColor = GlobalConstants.AKTableCellBg
        Func.AKAddBorderDeco(
            self.infoContainer,
            color: GlobalConstants.AKTableCellBorderBg.cgColor,
            thickness: GlobalConstants.AKDefaultBorderThickness * 4.0,
            position: .left
        )
    }
    
    override func setSelected(_ selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)
        
        self.toggleDisplaceableMenu(state: .notVisible)
    }
    
    // MARK: UIGestureRecognizerDelegate Implementation
    override func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool
    {
        if gestureRecognizer.isKind(of: UISwipeGestureRecognizer.self) {
            return true
        }
        else {
            return false // By default disable all gestures!
        }
    }
    
    // MARK: Gesture Handling
    @objc internal func swipeLeft(_ gesture: UIGestureRecognizer?) { self.toggleDisplaceableMenu(state: .visible) }
    
    @objc internal func swipeRight(_ gesture: UIGestureRecognizer?) { self.toggleDisplaceableMenu(state: .notVisible) }
    
    // MARK: Menu Handling
    func toggleDisplaceableMenu(state: DisplaceableMenuStates)
    {
        switch state {
        case .visible:
            // The origin never changes so fix it to the controller's view.
            var origin = CGPoint.zero
            origin.x = self.frame.width - AKDisplaceableTableMenuView.LocalConstants.AKViewWidth
            
            // Configure the overlay.
            self.displaceableMenuOverlay.controller = self.controller
            self.displaceableMenuOverlay.tableCell = self
            self.displaceableMenuOverlay.setup()
            self.displaceableMenuOverlay.draw(container: self, coordinates: origin, size: CGSize.zero)
            self.displaceableMenuOverlay.editAction = { (overlay, controller) -> Void in
                if let overlay = overlay as? AKDisplaceableTableMenuView, let controller = self.controller as? AKListProjectsViewController {
                    if let cell = overlay.tableCell {
                        if let indexPath = controller.projectsTable.indexPath(for: cell) {
                            let project = DataInterface.getProjects(filter: controller.projectFilter)[indexPath.section]
                            
                            controller.performSegue(
                                withIdentifier: GlobalConstants.AKViewProjectConfigurationsSegue,
                                sender: project
                            )
                        }
                    }
                }
            }
            self.displaceableMenuOverlay.deleteAction = { (overlay, controller) -> Void in
                if let overlay = overlay as? AKDisplaceableTableMenuView, let controller = self.controller as? AKListProjectsViewController {
                    if let cell = overlay.tableCell {
                        controller.showContinueMessage(
                            origin: CGPoint.zero,
                            type: .warning,
                            message: "WARNING: This action can't be undone. You will lose all of your project's data! Continue...?",
                            yesAction: { (presenterController) -> Void in
                                if let controller = presenterController as? AKListProjectsViewController {
                                    if let indexPath = controller.projectsTable.indexPath(for: cell) {
                                        let project = DataInterface.getProjects(filter: controller.projectFilter)[indexPath.section]
                                        
                                        // Remove data structure.
                                        DataInterface.getUser()?.removeFromProject(project)
                                        // Invalidate notifications.
                                        Func.AKInvalidateLocalNotification(controller: controller, project: project)
                                        
                                        Func.AKReloadTable(tableView: controller.projectsTable)
                                    }
                                } },
                            noAction: { (presenterController) -> Void in
                                if let controller = presenterController as? AKListProjectsViewController {
                                    Func.AKReloadTable(tableView: controller.projectsTable)
                                } },
                            animate: true,
                            completionTask: nil
                        )
                    }
                }
            }
            
            // Expand/Show the overlay.
            self.displaceableMenuOverlay.expand(
                controller: self.controller,
                expandHeight: self.frame.height,
                animate: true,
                completionTask: nil
            )
            break
        case .notVisible:
            self.displaceableMenuOverlay.collapse(
                controller: self.controller,
                animate: true,
                completionTask: nil
            )
            break
        }
    }
    
    func toggleAddTaskButton()
    {
        if let project = self.project {
            if DataInterface.getProjectStatus(project: project) == .accepting || DataInterface.getProjectStatus(project: project) == .firstDay {
                self.addTomorrowTask.isHidden = false
            }
            else {
                self.addTomorrowTask.isHidden = true
            }
        }
    }
}
