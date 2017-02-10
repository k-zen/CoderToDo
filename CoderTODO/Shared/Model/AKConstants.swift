import Foundation
import MapKit
import UIKit

// MARK: Typealias
typealias ViewBlock = (_ view : UIView) -> Bool
typealias JSONObject = [String : Any]
typealias JSONObjectArray = [Any]
typealias JSONObjectStringArray = [String]
typealias User = AKUserMO

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
    func splitOnNewLine () -> [String]
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
    static let AKDataModelName = "MainDataModel"
    static let AKDbaseFileName = "MainDataModel.sqlite"
    static let AKDefaultFont = "HelveticaNeue-Thin"
    static let AKRedColor_1 = GlobalFunctions.instance(false).AKHexColor(0xDF3732)
    static let AKDefaultBg = GlobalFunctions.instance(false).AKHexColor(0x29282D)
    static let AKDefaultFg = GlobalFunctions.instance(false).AKHexColor(0xFFFFFF)
    static let AKTabBarBg = GlobalConstants.AKDefaultBg
    static let AKTabBarTintNormal = GlobalFunctions.instance(false).AKHexColor(0xFFFFFF)
    static let AKTabBarTintSelected = GlobalFunctions.instance(false).AKHexColor(0x0088CC)
    static let AKDefaultTextfieldBorderBg = GlobalFunctions.instance(false).AKHexColor(0x999999)
    static let AKOverlaysBg = GlobalConstants.AKDefaultBg
    static let AKDefaultViewBorderBg = GlobalFunctions.instance(false).AKHexColor(0x000000)
    static let AKDefaultFloatingViewBorderBg = UIColor.black
    static let AKDisabledButtonBg = GlobalFunctions.instance(false).AKHexColor(0x999999)
    static let AKEnabledButtonBg = GlobalConstants.AKRedColor_1
    static let AKTableHeaderCellBg = UIColor.black
    static let AKTableHeaderLeftBorderBg = GlobalFunctions.instance(false).AKHexColor(0xEBDBB2)
    static let AKTableCellBg = GlobalConstants.AKDefaultBg
    static let AKTableCellLeftBorderBg = GlobalConstants.AKTableHeaderLeftBorderBg
    static let AKButtonCornerRadius: CGFloat = 4.0
    static let AKDefaultBorderThickness = 1.5
    static let AKMaxUsernameLength = 12
    static let AKMinUsernameLength = 3
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

// MARK: Global Functions
class GlobalFunctions {
    private var showDebugInformation = false
    
    ///
    /// Creates and configures a new instance of the class. Use this method for
    /// calling all other functions.
    ///
    static func instance(_ showDebugInformation: Bool) -> GlobalFunctions
    {
        let instance = GlobalFunctions()
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
    
    ///
    /// Returns the App's master file object.
    ///
    /// - Returns: The App's master file object.
    ///
    func AKObtainMasterReference() -> AKMasterReference?
    {
        return GlobalFunctions.instance(self.showDebugInformation).AKDelegate().masterRef
    }
    
    ///
    /// Returns the user data structure.
    ///
    /// - Returns: The user data structure.
    ///
    func AKGetUser() -> User?
    {
        return GlobalFunctions.instance(self.showDebugInformation).AKObtainMasterReference()?.user
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
            NSLog("=> Generic Error ==> %@", "\(error)")
        }
    }
    
    func AKPresentMessage(message: String!)
    {
        GlobalFunctions.instance(false).AKExecuteInMainThread {}
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
