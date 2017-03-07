import Foundation
import UIKit

protocol AKCustomViewProtocol
{
    var defaultOperationsExpand: (AKCustomView) -> Void { get set }
    var defaultOperationsCollapse: (AKCustomView) -> Void { get set }
    
    func loadComponents() -> Void
    
    func applyLookAndFeel() -> Void
    
    func addAnimations() -> Void
    
    func draw(container: UIView, coordinates: CGPoint, size: CGSize) -> Void
    
    func expand(completionTask: ((_ presenterController: AKCustomViewController?) -> Void)?) -> Void
    
    func collapse(completionTask: ((_ presenterController: AKCustomViewController?) -> Void)?) -> Void
}
