import UIKit

class AKNotesTextField: UITextField
{
    override func textRect(forBounds bounds: CGRect) -> CGRect
    {
        super.textRect(forBounds: bounds)
        return bounds.insetBy(dx: 10, dy: 10)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect
    {
        super.editingRect(forBounds: bounds)
        return bounds.insetBy(dx: 10, dy: 10)
    }
}
