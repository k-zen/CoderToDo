import UIKit

class AKChangesViewController: AKCustomViewController {
    // MARK: Outlets
    @IBOutlet weak var webView: UIWebView!
    
    // MARK: AKCustomViewController Overriding
    override func viewDidLoad() {
        super.viewDidLoad()
        self.customSetup()
    }
    
    // MARK: Miscellaneous
    func customSetup() {
        self.loadData = { (controller) -> Void in
            if let controller = controller as? AKChangesViewController {
                controller.webView.loadRequest(URLRequest(url: URL(fileURLWithPath: Bundle.main.path(forResource: "changes", ofType: "html")!)))
            }
        }
        self.setup()
    }
}
