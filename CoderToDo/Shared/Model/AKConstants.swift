import CloudKit
import Foundation
import MapKit
import UIKit
import UserNotifications

// MARK: Typealias
typealias Cons = GlobalConstants
typealias ViewBlock = (_ view : UIView) -> Bool
typealias JSONObject = [String : Any]
typealias JSONObjectArray = [Any]
typealias JSONObjectStringArray = [String]
typealias DataController = AKDataController
typealias DataInterface = AKDataInterface
typealias User = AKUserMO
typealias Configurations = AKConfigurationsMO
typealias Project = AKProjectMO
typealias ProjectCategory = AKProjectCategoryMO
typealias Day = AKDayMO
typealias Category = AKCategoryMO
typealias Task = AKTaskMO
typealias PendingQueue = AKPendingTasksQueueMO
typealias DilateQueue = AKDilateTaskQueueMO
typealias Bucket = AKBucketMO
typealias BucketEntry = AKBucketEntryMO

// MARK: Aliases
let Func = UtilityFunctions.instance(Cons.AKDebug)

// MARK: Extensions
extension Int
{
    func modulo(_ divisor: Int) -> Int
    {
        var result = self % divisor
        if (result < 0) {
            result += divisor
        }
        
        return result
    }
}

extension UIImage
{
    static func fromColor(color: UIColor, frame: CGRect) -> UIImage
    {
        UIGraphicsBeginImageContextWithOptions(frame.size, false, UIScreen.main.scale)
        
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(color.withAlphaComponent(CGFloat(1.0)).cgColor)
        context?.setLineWidth(0)
        context?.fill(frame)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return image!
    }
}

extension String
{
    ///
    /// This function computes the MD5 hash of the string.
    ///
    /// - Returns: The MD5 hash of the string.
    ///
    func computeMD5() -> String?
    {
        let length = Int(CC_MD5_DIGEST_LENGTH)
        var digest = [UInt8](repeating: 0, count: length)
        if let d = self.data(using: String.Encoding.utf8) {
            _ = d.withUnsafeBytes { (body: UnsafePointer<UInt8>) in
                CC_MD5(body, CC_LONG(d.count), &digest)
            }
        }
        
        return (0..<length).reduce("") {
            $0 + String(format: "%02x", digest[$1])
        }
    }
    
    ///
    /// This function converts the string from Base64.
    ///
    /// - Returns: The original string.
    ///
    func fromBase64() -> String?
    {
        guard let data = Data(base64Encoded: self) else {
            return nil
        }
        
        return String(data: data, encoding: .utf8)
    }
    
    ///
    /// This function converts the string to Base64 encoding.
    ///
    /// - Returns: A Base64 encoded string.
    ///
    func toBase64() -> String
    {
        return Data(self.utf8).base64EncodedString()
    }
    
    func toBool() -> Bool?
    {
        switch self {
        case "TRUE", "true", "YES", "yes", "1":
            return true
        case "FALSE", "false", "NO", "no", "0":
            return false
        default:
            return nil
        }
    }
    
    ///
    /// Splits the string by new lines.
    ///
    /// - Returns: An array of string lines.
    ///
    func splitOnNewLine() -> [String]
    {
        return self.components(separatedBy: CharacterSet.newlines)
    }
}

extension UIView
{
    func loopViewHierarchy(block : ViewBlock?)
    {
        if block?(self) ?? true {
            for subview in self.subviews {
                subview.loopViewHierarchy(block: block)
            }
        }
    }
}

// MARK: Structures
struct GlobalConstants
{
    static let AKDebug = true
    // CoreData
    static let AKDataModelName = "MainDataModel"
    static let AKDbaseFileName = "MainDataModel.sqlite"
    static let AKUserMOEntityName = "User"
    static let AKProjectMOEntityName = "Project"
    // L&F
    // ### Gruvbox Colors:
    // For white foreground:
    static let AKRedForWhiteFg = Func.AKHexColor(0xCC241D)
    static let AKGreenForWhiteFg = Func.AKHexColor(0x98971A)
    static let AKYellowForWhiteFg = Func.AKHexColor(0xD79921)
    static let AKBlueForWhiteFg = Func.AKHexColor(0x458588)
    static let AKPurpleForWhiteFg = Func.AKHexColor(0xB16286)
    static let AKAquaForWhiteFg = Func.AKHexColor(0x689D6A)
    static let AKOrangeForWhiteFg = Func.AKHexColor(0xD65D0E)
    // For black foreground:
    static let AKRedForBlackFg = Func.AKHexColor(0xFB4934)
    static let AKGreenForBlackFg = Func.AKHexColor(0xB8BB26)
    static let AKYellowForBlackFg = Func.AKHexColor(0xFABD2F)
    static let AKBlueForBlackFg = Func.AKHexColor(0x83A598)
    static let AKPurpleForBlackFg = Func.AKHexColor(0xD3869B)
    static let AKAquaForBlackFg = Func.AKHexColor(0x8EC07C)
    static let AKOrangeForBlackFg = Func.AKHexColor(0xFE8019)
    // ### Gruvbox Colors:
    // ### Custom Color Palette:
    static let AKCoderToDoBlue = Func.AKHexColor(0x007AFF)
    static let AKCoderToDoGray1 = Func.AKHexColor(0x1B1E1F)
    static let AKCoderToDoGray2 = Func.AKHexColor(0x292D2F)
    static let AKCoderToDoGray3 = Func.AKHexColor(0x353A3C)
    static let AKCoderToDoGray4 = Func.AKHexColor(0x41474A)
    static let AKCoderToDoWhite = Func.AKHexColor(0xD9D9D6)
    // ### Custom Color Palette:
    static let AKDefaultFont = "AvenirNextCondensed-Regular"
    static let AKSecondaryFont = "AvenirNextCondensed-DemiBold"
    static let AKSecondaryItalicFont = "AvenirNextCondensed-DemiBoldItalic"
    static let AKTertiaryFont = "AvenirNextCondensed-Bold"
    static let AKDefaultBg = GlobalConstants.AKCoderToDoGray1
    static let AKDefaultFg = GlobalConstants.AKCoderToDoWhite
    static let AKTabBarBg = GlobalConstants.AKCoderToDoGray1
    static let AKTabBarTintNormal = GlobalConstants.AKDefaultFg
    static let AKTabBarTintSelected = GlobalConstants.AKRedForBlackFg
    static let AKDefaultTextfieldBorderBg = GlobalConstants.AKCoderToDoGray4
    static let AKOverlaysBg = GlobalConstants.AKDefaultBg
    static let AKDefaultViewBorderBg = GlobalConstants.AKCoderToDoGray4
    static let AKEnabledButtonBg = GlobalConstants.AKCoderToDoGray3
    static let AKEnabledButtonFg = GlobalConstants.AKCoderToDoWhite
    static let AKDisabledButtonBg = Func.AKHexColor(0xA9A9A6) // Exception!!!
    static let AKDisabledButtonFg = GlobalConstants.AKCoderToDoWhite
    static let AKTableHeaderCellBg = GlobalConstants.AKCoderToDoGray2
    static let AKTableHeaderCellBorderBg = GlobalConstants.AKCoderToDoGray4
    static let AKTableCellBg = GlobalConstants.AKDefaultBg
    static let AKTableCellBorderBg = GlobalConstants.AKCoderToDoGray2
    static let AKPickerViewFg = GlobalConstants.AKDefaultFg
    static let AKPickerViewBg = GlobalConstants.AKCoderToDoGray4
    static let AKPickerFontSize: CGFloat = 18.0
    static let AKNavBarFontSize: CGFloat = 18.0
    static let AKTabBarFontSize: CGFloat = GlobalConstants.AKNavBarFontSize
    static let AKViewCornerRadius: CGFloat = 0.0
    static let AKButtonCornerRadius: CGFloat = 0.0
    static let AKDefaultBorderThickness = 2.0
    static let AKDefaultTextfieldBorderThickness = 2.0
    static let AKDefaultTransitionStyle = UIModalTransitionStyle.crossDissolve
    static let AKBadgeColorBg = GlobalConstants.AKDefaultViewBorderBg
    static let AKBadgeColorFg = GlobalConstants.AKCoderToDoWhite
    static let AKCloseKeyboardToolbarHeight: CGFloat = 30
    static let AKAutoCorrectionToolbarHeight: CGFloat = 42
    static let AKKeyboardHeight: CGFloat = 258 + GlobalConstants.AKCloseKeyboardToolbarHeight
    // Validations
    static let AKMaxUsernameLength = 40
    static let AKMinUsernameLength = 2
    static let AKMaxProjectNameLength = 40
    static let AKMinProjectNameLength = 2
    static let AKMaxCategoryNameLength = 40
    static let AKMinCategoryNameLength = 2
    static let AKMaxTaskNameLength = 140
    static let AKMinTaskNameLength = 2
    static let AKMaxTaskNoteLength = 1000
    static let AKMinTaskNoteLength = 2
    // Dates
    static let AKWorkingDayTimeDateFormat = "HH:mm"
    static let AKFullDateFormat = "yyyy-MM-dd HH:mm:ss ZZZ"
    static let AKWorkingDayStartTime = 0 // Military type of time: 00:00Hs.
    static let AKAcceptingTasksDefaultMaxTime = 2359 // Military type of time: 23:59Hs.
    // Segues
    static let AKViewProjectSegue = "ViewProjectSegue"
    static let AKViewTaskSegue = "ViewTaskSegue"
    static let AKViewProjectConfigurationsSegue = "ViewProjectConfigurationsSegue"
    static let AKViewBackupSegue = "ViewBackupSegue"
    static let AKViewProjectBucketSegue = "ViewProjectBucketSegue"
    static let AKViewUserConfigurationSegue = "ViewUserConfigurationSegue"
    static let AKViewProjectNameSegue = "ViewProjectNameSegue"
    static let AKViewProjectTimesSegue = "ViewProjectTimesSegue"
    static let AKViewProjectNotificationsSegue = "ViewProjectNotificationsSegue"
    static let AKViewUserDefinedCategoriesSegue = "ViewUserDefinedCategoriesSegue"
    static let AKViewGoodiesSegue = "ViewGoodiesSegue"
    // Notifications
    static let AKStartingTimeNotificationName = "StartingTimeNotification"
    static let AKClosingTimeNotificationName = "ClosingTimeNotification"
    // Messages
    static let AKAutoDismissMessageTime = 2.0
    // Backup
    // XML
    static let AKBackupXMLMaxNodes: UInt = 100000000
    // CloudKit
    static let AKBackupRecordTypeName = "BackupData"
    // Default Values
    static let AKDefaultProjectSortType = ProjectSorting.use
    static let AKDefaultProjectSortOrder = SortingOrder.descending
    static let AKDefaultProjectFilterType = ProjectFilter.status
    static let AKDefaultProjectFilterValue = ProjectFilterStatus.none
    static let AKDefaultProjectSearchTerm = SearchTerm(term: Search.showAll.rawValue)
    static let AKDefaultTaskSortType = TaskSorting.creationDate
    static let AKDefaultTaskSortOrder = SortingOrder.descending
    static let AKDefaultTaskFilterType = TaskFilter.state
    static let AKDefaultTaskFilterValue = TaskFilterStates.none
    static let AKDefaultTaskSearchTerm = SearchTerm(term: Search.showAll.rawValue)
}

struct Filter
{
    var projectFilter: FilterProject?
    var taskFilter: FilterTask?
    
    init(projectFilter: FilterProject?)
    {
        self.projectFilter = projectFilter
        self.taskFilter = nil
    }
    
    init(taskFilter: FilterTask?)
    {
        self.projectFilter = nil
        self.taskFilter = taskFilter
    }
}

struct FilterProject
{
    var sortType: ProjectSorting
    var sortOrder: SortingOrder
    var filterType: ProjectFilter
    var filterValue: ProjectFilterStatus
    var searchTerm: SearchTerm
    
    init()
    {
        self.sortType = Cons.AKDefaultProjectSortType
        self.sortOrder = Cons.AKDefaultProjectSortOrder
        self.filterType = Cons.AKDefaultProjectFilterType
        self.filterValue = Cons.AKDefaultProjectFilterValue
        self.searchTerm = Cons.AKDefaultProjectSearchTerm
    }
    
    init(sortType: ProjectSorting, sortOrder: SortingOrder, filterType: ProjectFilter, filterValue: ProjectFilterStatus, searchTerm: SearchTerm)
    {
        self.sortType = sortType
        self.sortOrder = sortOrder
        self.filterType = filterType
        self.filterValue = filterValue
        self.searchTerm = searchTerm
    }
}

struct FilterTask
{
    var sortType: TaskSorting
    var sortOrder: SortingOrder
    var filterType: TaskFilter
    var filterValue: TaskFilterStates
    var searchTerm: SearchTerm
    
    init()
    {
        self.sortType = Cons.AKDefaultTaskSortType
        self.sortOrder = Cons.AKDefaultTaskSortOrder
        self.filterType = Cons.AKDefaultTaskFilterType
        self.filterValue = Cons.AKDefaultTaskFilterValue
        self.searchTerm = Cons.AKDefaultTaskSearchTerm
    }
    
    init(sortType: TaskSorting, sortOrder: SortingOrder, filterType: TaskFilter, filterValue: TaskFilterStates, searchTerm: SearchTerm)
    {
        self.sortType = sortType
        self.sortOrder = sortOrder
        self.filterType = filterType
        self.filterValue = filterValue
        self.searchTerm = searchTerm
    }
}

struct SearchTerm
{
    let term: String
    
    init(term: String) { self.term = term }
    
    func match(otherTerms: [String?]) -> Bool
    {
        for otherTerm in otherTerms {
            if let otherTerm = otherTerm {
                if term.caseInsensitiveCompare(Search.showAll.rawValue) == .orderedSame {
                    return true
                }
                if otherTerm.lowercased().range(of: term.lowercased()) != nil {
                    return true
                }
            }
        }
        
        return false
    }
}

struct BackupInfo
{
    enum Fields: String {
        case dateKey = "Date"
        case md5Key = "MD5"
        case sizeKey = "Size"
        case dataKey = "Data"
        case filenameKey = "Filename"
    }
    
    var date: Date?
    var md5: String?
    var size: Int64?
    var data: Data?
    var filename: URL?
}

// MARK: Global Enumerations
enum ErrorCodes: Int
{
    case ConnectionToBackEndError = -1000
    case InvalidMIMEType = -1001
    case JSONProcessingError = -1002
}

enum Exceptions: Error
{
    case notInitialized(String)
    case emptyData(String)
    case invalidLength(String)
    case notValid(String)
    case invalidJSON(String)
    case invalidDate(String)
    case invalidProjectStatus(String)
    case noCategories(String)
    case categoryHasTasks(String)
    case categoryAlreadyExists(String)
    case notSerializableObject(String)
    case fileCreationError(String)
    case fileWriteError(String)
    case invalidFilter(String)
}

enum UnitOfTime: Int
{
    case second = 1
    case minute = 2
    case hour = 3
}

enum CustomBorderDecorationPosition: Int
{
    case top = 0
    case right = 1
    case bottom = 2
    case left = 3
    case through = 4
}

enum SortingOrder: String
{
    case ascending = "↑"
    case descending = "↓"
}

enum ProjectStatus: String
{
    case open = "Open"
    case accepting = "Accepting"
    case closed = "Closed"
    case firstDay = "First Day"
}

enum ProjectSorting: String
{
    case closingTime = "Closing Time"
    case creationDate = "Creation Date"
    case use = "By Use"
    case name = "Name"
    case osr = "Overall Success Ratio"
}

enum ProjectFilter: String
{
    case status = "Status"
}

enum ProjectFilterStatus: String
{
    case none = "None"
    case open = "Open"
    case acceptingTasks = "Accepting"
    case closed = "Closed"
    case firstDay = "First Day"
}

enum DayStatus: String
{
    case current = "Current"
    case notCurrent = "Not Current"
}

enum TaskStates: String
{
    case done = "Done"
    case notDone = "Not Done"
    case notApplicable = "Not Applicable"
    case dilate = "Dilate"
    case pending = "Pending"
}

enum TaskSorting: String
{
    case completionPercentage = "Completion Percentage"
    case creationDate = "Creation Date"
    case name = "Name"
    case state = "State"
}

enum TaskFilter: String
{
    case state = "State"
}

enum TaskFilterStates: String
{
    case none = "None"
    case done = "Done"
    case notDone = "Not Done"
    case notApplicable = "Not Applicable"
    case dilate = "Dilate"
    case pending = "Pending"
}

enum TaskStateColor: UInt
{
    case done = 0xB8BB26 // GreenForBlack
    case notDone = 0xFB4934 // RedForBlack
    case notApplicable = 0x83A598 // BlueForBlack
    case dilate = 0xFE8019 // OrangeForBlack
    case pending = 0xFABD2F // YellowForBlack
}

enum TaskMode: String
{
    case editable = "Editable"
    case notEditable = "Not Editable"
    case limitedEditing = "Limited Editing"
    case cleaningMode = "Cleaning Mode"
}

enum MenuItems: Int
{
    case add
    case sort
    case filter
    case search
    case none
}

enum Displacement: Int
{
    case up
    case down
}

enum Search: String
{
    case showAll = "*"
}

enum ExecutionMode {
    case sync
    case async
}

enum DaysOfWeek: Int16 {
    case invalid = 0
    case sunday = 1
    case monday = 2
    case tuesday = 3
    case wednesday = 4
    case thursday = 5
    case friday = 6
    case saturday = 7
}

enum ComponentMode {
    case enabled
    case disabled
}

enum Priority: Int16 {
    case low = 1
    case medium = 2
    case high = 3
}

enum ComponentDirection {
    case enableToDisable
    case disableToEnable
}

enum DisplaceableMenuStates {
    case visible
    case notVisible
}

enum MessageType: String {
    case info = "Information"
    case warning = "Warning"
    case error = "Error"
}

// MARK: Utility Functions
class UtilityFunctions
{
    private var showDebugInformation = false
    
    ///
    /// Creates and configures a new instance of the class. Use this method for
    /// calling all other functions.
    ///
    static func instance(_ showDebugInformation: Bool) -> UtilityFunctions
    {
        let instance = UtilityFunctions()
        instance.showDebugInformation = showDebugInformation
        
        return instance
    }
    
    func AKAddBlurView(view: UIView, effect: UIBlurEffectStyle, addClearColorBgToView: Bool = false)
    {
        let blurView = UIVisualEffectView(effect: UIBlurEffect(style: effect))
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurView.translatesAutoresizingMaskIntoConstraints = true
        blurView.frame = view.frame
        
        if addClearColorBgToView {
            view.backgroundColor = UIColor.clear
        }
        
        view.insertSubview(blurView, at: 0)
    }
    
    ///
    /// Adds a border line decoration to any UIView or descendant of UIView.
    ///
    /// - Parameter component: The view where to add the border.
    /// - Parameter color: The color of the border.
    /// - Parameter thickness: The thickness of the border.
    /// - Parameter position: It can be 4 types: top, bottom, left, right.
    ///
    func AKAddBorderDeco(_ component: UIView, color: CGColor, thickness: Double, position: CustomBorderDecorationPosition)
    {
        let border = CALayer()
        border.backgroundColor = color
        switch position {
        case .top:
            border.frame = CGRect(x: 0, y: 0, width: component.frame.width, height: CGFloat(thickness))
            break
        case .right:
            border.frame = CGRect(x: (component.frame.width - CGFloat(thickness)), y: 0, width: CGFloat(thickness), height: component.frame.height)
            break
        case .bottom:
            border.frame = CGRect(x: 0, y: (component.frame.height - CGFloat(thickness)), width: component.frame.width, height: CGFloat(thickness))
            break
        case .left:
            border.frame = CGRect(x: 0, y: 0, width: CGFloat(thickness), height: component.frame.height)
            break
        case .through:
            var startPositionX: CGFloat = 0.0
            var startPositionY: CGFloat = component.frame.height / 2.0
            if component.isKind(of: UILabel.self) {
                if let label = component as? UILabel {
                    startPositionX = label.intrinsicContentSize.width + 4.0
                    startPositionY = startPositionY + 2.0
                }
            }
            
            border.frame = CGRect(x: startPositionX, y: (startPositionY - CGFloat(thickness)), width: component.frame.width, height: CGFloat(thickness))
            break
        }
        
        component.layer.addSublayer(border)
        component.layoutIfNeeded()
    }
    
    ///
    /// Adds a toolbar to the keyboard with a single button to close it down.
    ///
    /// - Parameter textControl: The control where to add the keyboard.
    /// - Parameter controller: The view controller that owns the control.
    ///
    func AKAddDoneButtonKeyboard(_ textControl: AnyObject, controller: AKCustomViewController)
    {
        let keyboardToolbar = UIToolbar()
        keyboardToolbar.frame = CGRect(x: 0, y: 0, width: textControl.frame.width, height: GlobalConstants.AKCloseKeyboardToolbarHeight)
        keyboardToolbar.barTintColor = UIColor.black
        
        let flexBarButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneBarButton = UIBarButtonItem(title: "Close Keyboard", style: .done, target: controller, action: #selector(AKCustomViewController.tap(_:)))
        doneBarButton.setTitleTextAttributes(
            [
                NSFontAttributeName : UIFont(name: GlobalConstants.AKDefaultFont, size: 16.0)!,
                NSForegroundColorAttributeName: UIColor.white
            ], for: UIControlState.normal
        )
        
        keyboardToolbar.items = [flexBarButton, doneBarButton]
        
        if textControl is UITextField {
            let textControlTmp = textControl as! UITextField
            textControlTmp.inputAccessoryView = keyboardToolbar
        }
        else if textControl is UITextView {
            let textControlTmp = textControl as! UITextView
            textControlTmp.inputAccessoryView = keyboardToolbar
        }
    }
    
    ///
    /// Computes the App's build version.
    ///
    /// - Returns: The App's build version.
    ///
    func AKAppBuild() -> String
    {
        if let b = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
            return b
        }
        else {
            return "0"
        }
    }
    
    func AKAppFullVersion() -> String { return String(format: "v%@b%@", Func.AKAppVersion(), Func.AKAppBuild()) }
    
    ///
    /// Computes the App's version.
    ///
    /// - Returns: The App's version.
    ///
    func AKAppVersion() -> String
    {
        if let v = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String {
            return v
        }
        else {
            return "0"
        }
    }
    
    func AKCenterScreenCoordinate(container: UIView, width: CGFloat, height: CGFloat) -> CGPoint
    {
        let offsetX: CGFloat = (container.frame.width / 2.0) - (width / 2.0)
        let offsetY: CGFloat = (container.frame.height / 2.0) - (height / 2.0)
        
        return container.convert(CGPoint(x: offsetX, y: offsetY), to: container)
    }
    
    func AKChangeComponentWidth(component: UIView, newWidth: CGFloat)
    {
        component.frame = CGRect(origin: component.frame.origin, size: CGSize(width: newWidth, height: component.frame.height))
        component.layoutIfNeeded()
    }
    
    func AKChangeComponentHeight(component: UIView, newHeight: CGFloat)
    {
        component.frame = CGRect(origin: component.frame.origin, size: CGSize(width: component.frame.width, height: newHeight))
        component.layoutIfNeeded()
    }
    
    func AKChangeComponentYPosition(component: UIView, newY: CGFloat)
    {
        component.frame = CGRect(origin: CGPoint(x: component.frame.origin.x, y: newY), size: CGSize(width: component.frame.width, height: component.frame.height))
        component.layoutIfNeeded()
    }
    
    ///
    /// Executes a function with a delay.
    ///
    /// - Parameter delay: The delay.
    /// - Parameter isMain: Should we launch the task in the main thread...?
    /// - Parameter task:  The function to execute.
    ///
    func AKDelay(_ delay: Double, isMain: Bool = true, task: @escaping (Void) -> Void)
    {
        if isMain {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: task)
        }
        else {
            DispatchQueue.global(qos: .background).asyncAfter(deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: task)
        }
    }
    
    ///
    /// Returns the App's delegate object.
    ///
    /// - Returns: The App's delegate object.
    ///
    func AKDelegate() -> AKAppDelegate { return UIApplication.shared.delegate as! AKAppDelegate }
    
    ///
    /// Executes some code inside a closure but in the main thread.
    ///
    /// - Parameter mode: The execution mode.
    /// - Parameter code: The code to be executed in the main thread.
    ///
    func AKExecuteInMainThread(controller: AKCustomViewController?, mode: ExecutionMode, code: @escaping (AKCustomViewController?) -> Void)
    {
        switch mode {
        case .sync:
            DispatchQueue.main.sync(execute: { code(controller) })
            break
        case .async:
            DispatchQueue.main.async(execute: { code(controller) })
            break
        }
    }
    
    ///
    /// Executes some code inside a closure but in a background thread.
    ///
    /// - Parameter mode: The execution mode.
    /// - Parameter code: The code to be executed in a background thread.
    ///
    func AKExecuteInBackgroundThread(mode: ExecutionMode, code: @escaping (Void) -> Void)
    {
        switch mode {
        case .sync:
            DispatchQueue.global(qos: .background).sync(execute: { code() })
            break
        case .async:
            DispatchQueue.global(qos: .background).async(execute: { code() })
            break
        }
    }
    
    func AKFormatNumber(number: NSNumber) -> String
    {
        let numberFormatter = NumberFormatter()
        numberFormatter.locale = Locale.current
        numberFormatter.numberStyle = NumberFormatter.Style.decimal
        
        return numberFormatter.string(from: number) ?? String(format: "%@", number)
    }
    
    func AKGetComponentAbsoluteHeightPosition(container: UIView, component: UIView, isCentered: Bool = true) -> CGFloat
    {
        var height: CGFloat = (UIScreen.main.bounds.height - container.frame.height) / (isCentered ? 2.0 : 1.0)
        height += component.frame.height
        
        return abs(height)
    }
    
    func AKGetCalendarForSaving() -> Calendar
    {
        var gmtCalendar = Calendar.current
        gmtCalendar.timeZone = TimeZone(identifier: "GMT")!
        
        return gmtCalendar
    }
    
    func AKGetCalendarForLoading() -> Calendar { return Calendar.current }
    
    func AKGetCloudKitContainer() -> CKContainer { return Func.AKDelegate().cloudKitContainer }
    
    func AKGetColorForPriority(priority: Priority) -> UIColor
    {
        switch priority {
        case .low:
            return GlobalConstants.AKGreenForWhiteFg
        case .medium:
            return GlobalConstants.AKYellowForWhiteFg
        case .high:
            return GlobalConstants.AKRedForWhiteFg
        }
    }
    
    func AKGetColorForProjectStatus(projectStatus: ProjectStatus) -> UIColor
    {
        switch projectStatus {
        case .accepting:
            return GlobalConstants.AKBlueForWhiteFg
        case .open:
            return GlobalConstants.AKGreenForWhiteFg
        case .closed:
            return GlobalConstants.AKRedForWhiteFg
        case .firstDay:
            return GlobalConstants.AKOrangeForWhiteFg
        }
    }
    
    func AKGetColorForTaskState(taskState: String) -> UIColor
    {
        switch taskState {
        case TaskStates.dilate.rawValue:
            return Func.AKHexColor(TaskStateColor.dilate.rawValue)
        case TaskStates.done.rawValue:
            return Func.AKHexColor(TaskStateColor.done.rawValue)
        case TaskStates.notApplicable.rawValue:
            return Func.AKHexColor(TaskStateColor.notApplicable.rawValue)
        case TaskStates.notDone.rawValue:
            return Func.AKHexColor(TaskStateColor.notDone.rawValue)
        case TaskStates.pending.rawValue:
            return Func.AKHexColor(TaskStateColor.pending.rawValue)
        default:
            return UIColor.clear
        }
    }
    
    func AKGetDayOfWeekAsName(dayOfWeek: Int16, short: Bool = false) -> String?
    {
        switch dayOfWeek {
        case DaysOfWeek.invalid.rawValue:
            return short ? "N\\A" : "N\\A"
        case DaysOfWeek.sunday.rawValue:
            return short ? "Sun" : "Sunday"
        case DaysOfWeek.monday.rawValue:
            return short ? "Mon" : "Monday"
        case DaysOfWeek.tuesday.rawValue:
            return short ? "Tue" : "Tuesday"
        case DaysOfWeek.wednesday.rawValue:
            return short ? "Wed" : "Wednesday"
        case DaysOfWeek.thursday.rawValue:
            return short ? "Thu" : "Thursday"
        case DaysOfWeek.friday.rawValue:
            return short ? "Fri" : "Friday"
        case DaysOfWeek.saturday.rawValue:
            return short ? "Sat" : "Saturday"
        default:
            return nil
        }
    }
    
    func AKGetFormattedDate(date: Date?) -> String
    {
        if let date = date {
            let now = Date()
            let nowDateComponents = Func.AKGetCalendarForLoading().dateComponents([.day, .month, .year], from: now)
            let d1 = nowDateComponents.day ?? 0
            let m1 = nowDateComponents.month ?? 0
            let y1 = nowDateComponents.year ?? 0
            
            let tomorrow = Func.AKGetCalendarForLoading().date(byAdding: .day, value: 1, to: now)!
            let tomorrowDateComponents = Func.AKGetCalendarForLoading().dateComponents([.day, .month, .year], from: tomorrow)
            let d2 = tomorrowDateComponents.day ?? 0
            let m2 = tomorrowDateComponents.month ?? 0
            let y2 = tomorrowDateComponents.year ?? 0
            
            let yesterday = Func.AKGetCalendarForLoading().date(byAdding: .day, value: -1, to: now)!
            let yesterdayDateComponents = Func.AKGetCalendarForLoading().dateComponents([.day, .month, .year], from: yesterday)
            let d3 = yesterdayDateComponents.day ?? 0
            let m3 = yesterdayDateComponents.month ?? 0
            let y3 = yesterdayDateComponents.year ?? 0
            
            let d = Func.AKGetCalendarForLoading().dateComponents([.day], from: date).day ?? 0
            let m = Func.AKGetCalendarForLoading().dateComponents([.month], from: date).month ?? 0
            let y = Func.AKGetCalendarForLoading().dateComponents([.year], from: date).year ?? 0
            
            if d == d1 && m == m1 && y == y1 {
                return "Today"
            }
            else if d == d2 && m == m2 && y == y2 {
                return "Tomorrow"
            }
            else if d == d3 && m == m3 && y == y3 {
                return "Yesterday"
            }
            else {
                return String(format: "%.2i/%.2i/%.4i", m, d, y)
            }
        }
        
        return "N\\A"
    }
    
    func AKGetFormattedTime(date: Date?) -> String
    {
        if let date = date {
            let h = Func.AKGetCalendarForLoading().dateComponents([.hour], from: date).hour ?? 0
            let m = Func.AKGetCalendarForLoading().dateComponents([.minute], from: date).minute ?? 0
            let s = Func.AKGetCalendarForLoading().dateComponents([.second], from: date).second ?? 0
            
            return String(format: "%.2i:%.2i:%.2i", h, m, s)
        }
        
        return "N\\A"
    }
    
    func AKGetNotificationCenter() -> UNUserNotificationCenter { return Func.AKDelegate().notificationCenter }
    
    func AKGetPriorityAsName(priority: Int16) -> String?
    {
        switch priority {
        case Priority.low.rawValue:
            return "Low"
        case Priority.medium.rawValue:
            return "Medium"
        case Priority.high.rawValue:
            return "High"
        default:
            return nil
        }
    }
    
    ///
    /// Computes the difference in seconds between the local time and GMT.
    ///
    /// - Returns: The difference in hours between local time and GMT.
    ///
    func AKGetOffsetFromGMT() -> Int
    {
        return Func.AKGetCalendarForLoading().timeZone.secondsFromGMT() / 3600
    }
    
    ///
    /// Computes and generates a **UIColor** object based
    /// on it's hexadecimal representation.
    ///
    /// - Parameter hex: The hexadecimal representation of the color.
    ///
    /// - Returns: A **UIColor** object.
    ///
    func AKHexColor(_ hex: UInt) -> UIColor
    {
        let red = CGFloat((hex >> 16) & 0xFF) / 255.0
        let green = CGFloat((hex >> 8) & 0xFF) / 255.0
        let blue = CGFloat((hex) & 0xFF) / 255.0
        
        return UIColor.init(red: red, green: green, blue: blue, alpha: 1)
    }
    
    func AKIterateEnum<T: Hashable>(_: T.Type) -> AnyIterator<T>
    {
        var i = 0
        return AnyIterator {
            let next = withUnsafeBytes(of: &i) { $0.load(as: T.self) }
            if next.hashValue != i { return nil }
            i += 1
            return next
        }
    }
    
    ///
    /// Returns the App's master file object.
    ///
    /// - Returns: The App's master file object.
    ///
    func AKObtainMasterReference() -> AKMasterReference? { return Func.AKDelegate().masterRef }
    
    ///
    /// This method checks if a file archive exists and if it does then return its URL.
    ///
    /// - Parameter fileName: The name of the file archive.
    /// - Parameter location: The location in the OS file system where to find the file. i.e. NSApplicationSupportDirectory
    /// - Parameter shouldCreate: If the file does not exists then create it.
    ///
    /// - Returns: The URL of the file archive.
    ///
    func AKOpenFileArchive(fileName: String, location: FileManager.SearchPathDirectory, shouldCreate: Bool) throws -> URL?
    {
        let fm = FileManager()
        let directory = try fm.url(for: location, in: FileManager.SearchPathDomainMask.userDomainMask, appropriateFor: nil, create: true)
        
        if fm.fileExists(atPath: directory.appendingPathComponent(fileName).path) {
            return directory.appendingPathComponent(fileName)
        }
        else {
            if shouldCreate {
                if GlobalConstants.AKDebug { NSLog("=> FILE *%@* DOES NOT EXISTS! CREATING...", fileName) }
                guard fm.createFile(atPath: directory.appendingPathComponent(fileName).path, contents: nil, attributes: nil) else {
                    throw Exceptions.fileCreationError("File cannot be created.")
                }
                
                return directory.appendingPathComponent(fileName)
            }
            else {
                throw Exceptions.fileCreationError("No file to open.")
            }
        }
    }
    
    func AKPresentMessageFromError(controller: AKCustomViewController, message: String!)
    {
        do {
            if let input = message {
                let regex = try NSRegularExpression(pattern: ".*\"(.*)\"", options: NSRegularExpression.Options.caseInsensitive)
                let matches = regex.matches(in: input, options: [], range: NSMakeRange(0, input.characters.count))
                
                if let match = matches.first {
                    let range = match.rangeAt(1)
                    if let swiftRange = AKRangeFromNSRange(range, forString: input) {
                        let msg = input.substring(with: swiftRange)
                        AKPresentMessage(controller: controller, message: msg)
                    }
                }
            }
        }
        catch {
            NSLog("=> ERROR: \(error)")
        }
    }
    
    func AKPresentMessage(controller: AKCustomViewController, message: String!)
    {
        Func.AKExecuteInMainThread(controller: controller, mode: .async, code: { (controller) -> Void in
            controller?.showMessage(
                origin: CGPoint.zero,
                type: .error,
                message: message,
                animate: true,
                completionTask: nil
            )
        })
    }
    
    ///
    /// Executes code and measures the execution time.
    ///
    /// - Parameter title: The title of the operation.
    /// - Parameter operation: The code to be executed in a closure.
    ///
    func AKPrintTimeElapsedWhenRunningCode(title: String, operation: () -> ())
    {
        let startTime = CFAbsoluteTimeGetCurrent()
        operation()
        let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
        NSLog("=> INFO: TIME ELAPSED FOR \(title): %.4f seconds.", timeElapsed)
    }
    
    func AKProcessDate(dateAsString: String, format: String, timeZone: TimeZone) -> NSDate?
    {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.timeZone = timeZone
        
        if let date = formatter.date(from: dateAsString) {
            return date as NSDate
        }
        
        return nil
    }
    
    func AKProcessDateToString(date: Date, format: String, timeZone: TimeZone) -> String
    {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.timeZone = timeZone
        
        return formatter.string(from: date)
    }
    
    func AKProcessDayOfWeek(date: NSDate?, gmtOffset: Int) -> Int
    {
        if let date = date as Date? {
            var gmtCalendar = Calendar.current
            gmtCalendar.timeZone = TimeZone(identifier: "GMT")!
            
            let dateWithOffset = gmtCalendar.date(byAdding: .hour, value: gmtOffset, to: date)!
            
            return gmtCalendar.dateComponents([.weekday], from: dateWithOffset).weekday ?? 0
        }
        
        return 0
    }
    
    func AKRangeFromNSRange(_ nsRange: NSRange, forString str: String) -> Range<String.Index>?
    {
        let fromUTF16 = str.utf16.startIndex.advanced(by: nsRange.location)
        let toUTF16 = fromUTF16.advanced(by: nsRange.length)
        
        if let from = String.Index(fromUTF16, within: str), let to = String.Index(toUTF16, within: str) {
            return from ..< to
        }
        
        return nil
    }
    
    func AKReloadTable(tableView: UITableView)
    {
        tableView.reloadData()
        tableView.layoutIfNeeded()
    }
    
    func AKScheduleLocalNotification(
        controller: AKCustomViewController?,
        project: Project,
        completionTask: ((AKCustomViewController?) -> Void)?) -> Void {
        let closingTimeContent = UNMutableNotificationContent()
        closingTimeContent.title = String(format: "Project: %@", project.name!)
        closingTimeContent.body = String(
            format: "Hi %@, closing time is due for your project. You have %i minutes for editing tasks before this day is marked as closed.",
            DataInterface.getUsername(),
            project.closingTimeTolerance
        )
        closingTimeContent.sound = UNNotificationSound.default()
        Func.AKGetNotificationCenter().add(
            UNNotificationRequest(
                identifier: String(format: "%@:%@", GlobalConstants.AKClosingTimeNotificationName, project.name!),
                content: closingTimeContent,
                trigger: UNCalendarNotificationTrigger(
                    dateMatching: Func.AKGetCalendarForLoading().dateComponents([.hour,.minute,.second,], from: project.closingTime! as Date),
                    repeats: true
                )
            ),
            withCompletionHandler: { (error) in
                if let _ = error {
                    if completionTask != nil {
                        completionTask!(controller)
                    }
                } }
        )
    }
    
    func AKInvalidateLocalNotification(controller: AKCustomViewController?, project: Project?) -> Void
    {
        if let project = project {
            Func.AKGetNotificationCenter().removeDeliveredNotifications(
                withIdentifiers: [String(
                    format: "%@:%@",
                    GlobalConstants.AKClosingTimeNotificationName,
                    project.name!)])
            Func.AKGetNotificationCenter().removePendingNotificationRequests(
                withIdentifiers: [String(
                    format: "%@:%@",
                    GlobalConstants.AKClosingTimeNotificationName,
                    project.name!)])
        }
        else {
            Func.AKGetNotificationCenter().removeAllDeliveredNotifications()
            Func.AKGetNotificationCenter().removeAllPendingNotificationRequests()
        }
    }
    
    ///
    /// Create an image with the form of a square.
    ///
    /// - Parameter side:        The length of the side.
    /// - Parameter strokeColor: The color of the stroke.
    /// - Parameter strokeAlpha: The alpha factor of the stroke.
    /// - Parameter fillColor:   The color of the fill.
    /// - Parameter fillAlpha:   The alpha factor of the fill.
    ///
    /// - Returns: An image object in the form of a square.
    ///
    func AKSquareImage(_ sideLength: Double, strokeColor: UIColor, strokeAlpha: Float, fillColor: UIColor, fillAlpha: Float) -> UIImage
    {
        let buffer = 2.0
        let rect = CGRect(x: 0, y: 0, width: sideLength * 2.0 + buffer, height: sideLength * 2.0 + buffer)
        
        UIGraphicsBeginImageContextWithOptions(rect.size, false, UIScreen.main.scale)
        
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(fillColor.withAlphaComponent(CGFloat(fillAlpha)).cgColor)
        context?.setStrokeColor(strokeColor.withAlphaComponent(CGFloat(strokeAlpha)).cgColor)
        context?.setLineWidth(1)
        context?.fill(rect)
        context?.stroke(rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return image!
    }
    
    func AKToggleButtonMode(controller: AKCustomViewController, button: UIButton, mode: ComponentMode, showSpinner: Bool, direction: ComponentDirection)
    {
        switch mode {
        case .enabled:
            button.isEnabled = true
            button.backgroundColor = Cons.AKEnabledButtonBg
            
            if showSpinner {
                if direction == .enableToDisable {
                    controller.spinner.startAnimating()
                }
                else {
                    controller.spinner.stopAnimating()
                }
            }
            break
        case .disabled:
            button.isEnabled = false
            button.backgroundColor = Cons.AKDisabledButtonBg
            
            if showSpinner {
                if direction == .disableToEnable {
                    controller.spinner.startAnimating()
                }
                else {
                    controller.spinner.stopAnimating()
                }
            }
            break
        }
    }
}
