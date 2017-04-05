import UIKit

class AKAddBucketEntryView: AKCustomView, AKCustomViewProtocol, UITextFieldDelegate
{
    // MARK: Constants
    struct LocalConstants {
        static let AKViewWidth: CGFloat = 300.0
        static let AKViewHeight: CGFloat = 140.0
    }
    
    // MARK: Local Enums
    private enum LocalEnums: Int {
        case name = 1
    }
    
    // MARK: Outlets
    @IBOutlet var mainContainer: UIView!
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var priority: UISegmentedControl!
    @IBOutlet weak var save: UIButton!
    @IBOutlet weak var cancel: UIButton!
    
    // MARK: Actions
    @IBAction func save(_ sender: Any)
    {
        if let presenterController = self.controller as? AKBrainstormingBucketViewController {
            let name = AKTaskName(inputData: self.name.text!)
            do {
                try name.validate()
                try name.process()
            }
            catch {
                return
            }
            
            let newEntry = AKBucketEntryInterface(name: name.outputData, priority: Int16(self.priority.selectedSegmentIndex + 1))
            do {
                try newEntry.validate()
            }
            catch {
                return
            }
            
            if let entry = AKBucketEntryBuilder.mirror(interface: newEntry) {
                DataInterface.addBucketEntry(toProject: presenterController.selectedProject!, entry: entry)
                // Default Action!
                presenterController.tap(nil)
                self.controller?.hideAddBucketEntry(animate: true, completionTask: { (presenterController) -> Void in
                    if let presenterController = presenterController as? AKBrainstormingBucketViewController {
                        Func.AKReloadTableWithAnimation(tableView: presenterController.projectListTable)
                        Func.AKReloadTableWithAnimation(tableView: presenterController.bucketTable)
                    }
                })
            }
        }
    }
    
    @IBAction func cancel(_ sender: Any)
    {
        // Default Action!
        self.controller?.tap(nil)
        self.controller?.hideAddBucketEntry(animate: true, completionTask: nil)
    }
    
    // MARK: UIView Overriding
    convenience init() { self.init(frame: CGRect.zero) }
    
    // MARK: UITextFieldDelegate Implementation
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    {
        if range.length + range.location > (textField.text?.characters.count)! {
            return false
        }
        
        let newLen = (textField.text?.characters.count)! + string.characters.count - range.length
        
        switch textField.tag {
        case LocalEnums.name.rawValue:
            return newLen > GlobalConstants.AKMaxTaskNameLength ? false : true
        default:
            return newLen > GlobalConstants.AKMaxTaskNameLength ? false : true
        }
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool
    {
        Func.AKAddDoneButtonKeyboard(textField, controller: self.controller!)
        
        switch textField.tag {
        default:
            return true
        }
    }
    
    // MARK: Miscellaneous
    override func setup()
    {
        super.setup()
        
        NSLog("=> ENTERING SETUP ON FRAME: \(type(of:self))")
        
        // Delegate & DataSource
        self.name.delegate = self
        self.name.tag = LocalEnums.name.rawValue
        
        self.getView().translatesAutoresizingMaskIntoConstraints = true
        self.getView().clipsToBounds = true
        
        self.loadComponents()
        self.applyLookAndFeel()
        self.addAnimations(expandCollapseHeight: LocalConstants.AKViewHeight)
    }
    
    func loadComponents() {}
    
    func applyLookAndFeel()
    {
        self.getView().layer.cornerRadius = GlobalConstants.AKViewCornerRadius
        self.priority.subviews[2].tintColor = Func.AKGetColorForPriority(priority: .low)
        self.priority.subviews[1].tintColor = Func.AKGetColorForPriority(priority: .medium)
        self.priority.subviews[0].tintColor = Func.AKGetColorForPriority(priority: .high)
        self.save.layer.cornerRadius = GlobalConstants.AKButtonCornerRadius
        self.cancel.layer.cornerRadius = GlobalConstants.AKButtonCornerRadius
    }
    
    func draw(container: UIView, coordinates: CGPoint, size: CGSize)
    {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        self.getView().frame = CGRect(
            x: coordinates.x,
            y: coordinates.y,
            width: LocalConstants.AKViewWidth,
            height: size.height
        )
        container.addSubview(self.getView())
        CATransaction.commit()
    }
}
