import UIKit

class AKRulesViewController: AKCustomViewController {
    // MARK: Outlets
    @IBOutlet var mainContainer: UIView!
    @IBOutlet weak var scrollContainer: UIScrollView!
    @IBOutlet weak var controlsContainer: UIView!
    @IBOutlet weak var versionValue: UILabel!
    
    // MARK: AKCustomViewController Overriding
    override func viewDidLoad() {
        super.viewDidLoad()
        self.customSetup()
    }
    
    // MARK: Miscellaneous
    func customSetup() {
        self.loadData = { (controller) -> Void in
            if let controller = controller as? AKRulesViewController {
                controller.versionValue.text = String(format: "Version %@ Build %@", Func.AKAppVersion(), Func.AKAppBuild())
            }
        }
        self.setup()
    }
}
