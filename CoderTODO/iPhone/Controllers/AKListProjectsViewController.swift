import UIKit

class AKListProjectsViewController: AKCustomViewController
{
    // MARK: AKCustomViewController Overriding
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.customSetup()
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
    }
    
    // MARK: Miscellaneous
    func customSetup()
    {
        super.shouldCheckUsernameSet = true
        super.setup()
    }
}
