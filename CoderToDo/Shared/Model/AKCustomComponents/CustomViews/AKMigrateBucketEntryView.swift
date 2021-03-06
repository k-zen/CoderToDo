import UIKit

class AKMigrateBucketEntryView: AKCustomView, AKCustomViewProtocol, UIPickerViewDataSource, UIPickerViewDelegate, UITextViewDelegate {
    // MARK: Constants
    struct LocalConstants {
        static let AKViewWidth: CGFloat = 300.0
        static let AKViewHeight: CGFloat = 359.0
    }
    
    // MARK: Local Enums
    private enum LocalEnums: Int {
        case taskName = 1
        case category = 2
    }
    
    // MARK: Properties
    private var categoryData = [String]()
    
    // MARK: Outlets
    @IBOutlet var mainContainer: UIView!
    @IBOutlet weak var taskNameValue: UITextView!
    @IBOutlet weak var categoryValue: UIPickerView!
    @IBOutlet weak var initialStateValue: UISegmentedControl!
    @IBOutlet weak var migrate: UIButton!
    @IBOutlet weak var cancel: UIButton!
    
    // MARK: Actions
    @IBAction func migrate(_ sender: Any) {
        if let presenterController = self.controller as? AKBrainstormingBucketViewController {
            // Sanity Checks
            for task in DataInterface.getAllTasksInProject(project: presenterController.selectedProject!) {
                AKChecks.workingDayCloseSanityChecks(controller: presenterController, task: task)
            }
            
            let selectedCategory = self.categoryData[self.categoryValue.selectedRow(inComponent: 0)]
            let taskName = AKTaskName(inputData: self.taskNameValue.text!)
            do {
                try taskName.validate()
                try taskName.process()
            }
            catch {
                return
            }
            
            // Add the new task.
            let newTask = AKTaskInterface(
                name: taskName.outputData,
                state: self.initialStateValue.titleForSegment(at: self.initialStateValue.selectedSegmentIndex)!
            )
            do {
                try newTask.validate()
            }
            catch {
                return
            }
            
            if let task = AKTaskBuilder.mirror(interface: newTask) {
                if DataInterface.addTask(toProject: presenterController.selectedProject!, toCategoryNamed: selectedCategory, task: task) {
                    // Default Action!
                    presenterController.tap(nil)
                    self.controller?.hideMigrateBucketEntry(animate: true, completionTask: { (presenterController) -> Void in
                        if let presenterController = presenterController as? AKBrainstormingBucketViewController {
                            if let project = presenterController.selectedProject, let entry = presenterController.selectedBucketEntry {
                                DataInterface.removeBucketEntry(project: project, entry: entry)
                                
                                Func.AKReloadTable(tableView: presenterController.projectListTable)
                                Func.AKReloadTable(tableView: presenterController.bucketTable)
                            }
                        }
                    })
                }
            }
        }
    }
    
    @IBAction func cancel(_ sender: Any) {
        // Default Action!
        self.controller?.tap(nil)
        self.controller?.hideMigrateBucketEntry(animate: true, completionTask: nil)
    }
    
    // MARK: UIView Overriding
    convenience init() { self.init(frame: CGRect.zero) }
    
    // MARK: UIPickerViewDelegate Implementation
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch pickerView.tag {
        case LocalEnums.category.rawValue:
            return self.categoryData[row]
        default:
            return ""
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let pickerLabel = UILabel()
        pickerLabel.textColor = Cons.AKPickerViewFg
        
        switch pickerView.tag {
        case LocalEnums.category.rawValue:
            pickerLabel.text = self.categoryData[row]
            break
        default:
            pickerLabel.text = ""
            break
        }
        
        pickerLabel.backgroundColor = Cons.AKPickerViewBg
        pickerLabel.font = UIFont(name: Cons.AKSecondaryFont, size: Cons.AKPickerFontSize)
        pickerLabel.textAlignment = NSTextAlignment.center
        
        return pickerLabel
    }
    
    // MARK: UIPickerViewDataSource Implementation
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView.tag {
        case LocalEnums.category.rawValue:
            return self.categoryData.count
        default:
            return 0
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int { return 1 }
    
    // MARK: UITextViewDelegate Implementation
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if range.length + range.location > (textView.text?.count)! {
            return false
        }
        
        let newLen = (textView.text?.count)! + text.count - range.length
        
        switch textView.tag {
        case LocalEnums.taskName.rawValue:
            return newLen > Cons.AKMaxTaskNameLength ? false : true
        default:
            return newLen > Cons.AKMaxTaskNameLength ? false : true
        }
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        Func.AKAddDoneButtonKeyboard(textView, controller: self.controller!)
        
        switch textView.tag {
        default:
            return true
        }
    }
    
    // MARK: Miscellaneous
    override func setup() {
        super.shouldAddBlurView = true
        super.setup()
        
        // Delegate & DataSource
        self.taskNameValue.delegate = self
        self.taskNameValue.tag = LocalEnums.taskName.rawValue
        self.categoryValue.delegate = self
        self.categoryValue.dataSource = self
        self.categoryValue.tag = LocalEnums.category.rawValue
        
        self.getView().translatesAutoresizingMaskIntoConstraints = true
        self.getView().clipsToBounds = true
        
        self.loadComponents()
        self.applyLookAndFeel()
        self.addAnimations(expandCollapseHeight: LocalConstants.AKViewHeight)
    }
    
    func loadComponents() {
        if let presenterController = self.controller as? AKBrainstormingBucketViewController {
            if let project = presenterController.selectedProject {
                self.categoryData.removeAll()
                for categoryName in DataInterface.listProjectCategories(project: project) {
                    self.categoryData.append(categoryName)
                }
                
                // Set default values.
                self.categoryValue.selectRow(0, inComponent: 0, animated: true)
            }
        }
    }
    
    func applyLookAndFeel() {
        self.getView().layer.cornerRadius = Cons.AKViewCornerRadius
        self.getView().layer.masksToBounds = true
        self.getView().layer.borderColor = Cons.AKCoderToDoGray3.cgColor
        self.getView().layer.borderWidth = Cons.AKViewBorderWidth
        self.mainContainer.backgroundColor = UIColor.clear
        
        Func.AKStyleTextView(textView: self.taskNameValue)
        
        self.initialStateValue.subviews[1].tintColor = Func.AKGetColorForTaskState(taskState: TaskStates.pending.rawValue)
        self.initialStateValue.subviews[0].tintColor = Func.AKGetColorForTaskState(taskState: TaskStates.dilate.rawValue)
        
        Func.AKStyleButton(button: self.migrate)
        Func.AKStyleButton(button: self.cancel)
    }
    
    func draw(container: UIView, coordinates: CGPoint, size: CGSize) {
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
    
    func resetViewDefaults(controller: AKCustomViewController) {}
}
