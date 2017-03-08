import Foundation
import UIKit

protocol AKCustomViewProtocol
{
    func loadComponents() -> Void
    
    func applyLookAndFeel() -> Void
    
    func addAnimations() -> Void
    
    func draw(container: UIView, coordinates: CGPoint, size: CGSize) -> Void
    
    func expand(completionTask: ((_ presenterController: AKCustomViewController?) -> Void)?) -> Void
    
    func collapse(completionTask: ((_ presenterController: AKCustomViewController?) -> Void)?) -> Void
}
