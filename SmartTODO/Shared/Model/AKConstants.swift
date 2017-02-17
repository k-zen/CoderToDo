import Foundation
import MapKit
import UIKit

// MARK: Typealias
typealias ViewBlock = (_ view : UIView) -> Bool
typealias JSONObject = [String : Any]
typealias JSONObjectArray = [Any]
typealias JSONObjectStringArray = [String]
typealias DataController = AKDataController
typealias DataInterface = AKDataInterface
typealias User = AKUserMO
typealias Project = AKProjectMO
typealias Day = AKDayMO
typealias Task = AKTaskMO
typealias Category = AKCategoryMO

// MARK: Aliases
let Func = UtilityFunctions.instance(GlobalConstants.AKDebug)

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
struct GlobalConstants {
    static let AKDebug = true
    // CoreData
    static let AKDataModelName = "MainDataModel"
    static let AKDbaseFileName = "MainDataModel.sqlite"
    static let AKUserMOEntityName = "User"
    static let AKProjectMOEntityName = "Project"
    // L&F
    static let AKDefaultFont = "HelveticaNeue-Thin"
    static let AKSecondaryFont = "HelveticaNeue-CondensedBold"
    static let AKRedColor_1 = Func.AKHexColor(0xcc241d)
    static let AKRedColor_2 = Func.AKHexColor(0xfb4934)
    static let AKDefaultBg = Func.AKHexColor(0x181818)
    static let AKDefaultFg = Func.AKHexColor(0xffffff)
    static let AKTabBarBg = GlobalConstants.AKDefaultBg
    static let AKTabBarTintNormal = GlobalConstants.AKDefaultFg
    static let AKTabBarTintSelected = Func.AKHexColor(0x0088CC)
    static let AKDefaultTextfieldBorderBg = Func.AKHexColor(0x999999)
    static let AKOverlaysBg = GlobalConstants.AKDefaultBg
    static let AKDefaultViewBorderBg = Func.AKHexColor(0x999999)
    static let AKDefaultFloatingViewBorderBg = UIColor.black
    static let AKDisabledButtonBg = Func.AKHexColor(0x999999)
    static let AKEnabledButtonBg = Func.AKHexColor(0x0088CC)
    static let AKTableHeaderCellBg = Func.AKHexColor(0x181818)
    static let AKTableHeaderLeftBorderBg = Func.AKHexColor(0xd79921)
    static let AKTableCellBg = Func.AKHexColor(0x222222)
    static let AKTableCellLeftBorderBg = Func.AKHexColor(0x0088CC)
    static let AKPickerViewFg = GlobalConstants.AKDefaultFg
    static let AKButtonCornerRadius: CGFloat = 4.0
    static let AKDefaultBorderThickness = 1.4
    static let AKDefaultTextfieldBorderThickness = 2.0
    static let AKDefaultTransitionStyle = UIModalTransitionStyle.coverVertical
    // Validations
    static let AKMaxUsernameLength = 12
    static let AKMinUsernameLength = 3
    static let AKMaxProjectNameLength = 100
    static let AKMinProjectNameLength = 3
    // Dates
    static let AKWorkingDayTimeDateFormat = "HH:mm"
    static let AKAcceptingTasksDefaultTime = 2359
    // Segues
    static let AKViewProjectSegue = "ViewProjectSegue"
    static let AKViewTaskSegue = "ViewTaskSegue"
}

// MARK: Global Enumerations
enum ErrorCodes: Int {
    case ConnectionToBackEndError = -1000
    case InvalidMIMEType = -1001
    case JSONProcessingError = -1002
}

enum Exceptions: Error {
    case notInitialized(String)
    case emptyData(String)
    case invalidLength(String)
    case notValid(String)
    case invalidJSON(String)
    case invalidDate(String)
}

enum UnitOfTime: Int {
    case second = 1
    case minute = 2
    case hour = 3
}

enum CustomBorderDecorationPosition: Int {
    case top = 0
    case right = 1
    case bottom = 2
    case left = 3
}

enum ProjectStatus: String {
    case OPEN = "Open: You can mark tasks with a status."
    case ACEPTING_TASKS = "Accepting tasks for next day."
    case CLOSED = "Closed for the day."
}

enum ProjectSorting: String {
    case closingTime = "Closing Time"
    case creationDate = "Creation Date"
    case name = "Name"
    case osr = "Overall Success Rate"
}

enum SortingOrder: String {
    case ascending = "Ascending"
    case descending = "Descending"
}

enum TaskStates: Int16 {
    case DONE = 1
    case NOT_DONE = 2
    case NOT_APPLICABLE = 3
    case DILATE = 4
    case PENDING = 5
    case VERIFY = 6
    case VERIFIED = 7
    case NOT_VERIFIED = 8
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
        }
        
        component.layer.addSublayer(border)
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
            DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: task)
        }
    }
    
    ///
    /// Returns the App's delegate object.
    ///
    /// - Returns: The App's delegate object.
    ///
    func AKDelegate() -> AKAppDelegate { return UIApplication.shared.delegate as! AKAppDelegate }
    
    ///
    /// Adds a toolbar to the keyboard with a single button to close it down.
    ///
    /// - Parameter textControl: The control where to add the keyboard.
    /// - Parameter controller: The view controller that owns the control.
    ///
    func AKAddDoneButtonKeyboard(_ textControl: AnyObject, controller: AKCustomViewController) {
        let keyboardToolbar = UIToolbar()
        keyboardToolbar.frame = CGRect(x: 0, y: 0, width: textControl.bounds.width, height: 30)
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
    /// Executes some code inside a closure but in the main thread.
    ///
    /// - Parameter code: The code to be executed in the main thread.
    ///
    func AKExecuteInMainThread(code: @escaping (Void) -> Void)
    {
        OperationQueue.main.addOperation({ () -> Void in code() })
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
    func AKObtainMasterReference() -> AKMasterReference?
    {
        return Func.AKDelegate().masterRef
    }
    
    func AKPresentMessageFromError(message: String!)
    {
        do {
            if let input = message {
                let regex = try NSRegularExpression(pattern: ".*\"(.*)\"", options: NSRegularExpression.Options.caseInsensitive)
                let matches = regex.matches(in: input, options: [], range: NSMakeRange(0, input.characters.count))
                
                if let match = matches.first {
                    let range = match.rangeAt(1)
                    if let swiftRange = AKRangeFromNSRange(range, forString: input) {
                        let msg = input.substring(with: swiftRange)
                        AKPresentMessage(message: msg)
                    }
                }
            }
        }
        catch {
            NSLog("=> ERROR: \(error)")
        }
    }
    
    func AKPresentMessage(message: String!)
    {
        Func.AKExecuteInMainThread { NSLog("=> MESSAGE: \(message)") }
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
    
    func AKProcessDate(dateAsString: String, format: String) throws -> NSDate
    {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.timeZone = TimeZone(identifier: "GMT")
        
        if let date = formatter.date(from: dateAsString) {
            return date as NSDate
        }
        else {
            throw Exceptions.invalidDate("The date to be parsed was invalid.")
        }
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
}
