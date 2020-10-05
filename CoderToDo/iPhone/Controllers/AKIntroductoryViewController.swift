import UIKit

class AKIntroductoryViewController: AKCustomViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    // MARK: Properties
    var pageContainer: UIPageViewController!
    var pages = [UIViewController]()
    var currentIndex: Int?
    var pendingIndex: Int?
    
    // MARK: Outlets
    @IBOutlet weak var control: UIPageControl!
    
    // MARK: AKCustomViewController Overriding
    override func viewDidLoad() {
        super.viewDidLoad()
        self.customSetup()
    }
    
    // MARK: UIPageViewControllerDataSource Implementation
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let currentIndex = self.pages.firstIndex(of: viewController)!
        if currentIndex == 0 {
            return nil
        }
        let previousIndex = abs((currentIndex - 1) % self.pages.count)
        
        return self.pages[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let currentIndex = self.pages.firstIndex(of: viewController)!
        if currentIndex == self.pages.count-1 {
            return nil
        }
        let nextIndex = abs((currentIndex + 1) % self.pages.count)
        
        return self.pages[nextIndex]
    }
    
    // MARK: UIPageViewControllerDelegate Implementation
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        self.pendingIndex = self.pages.firstIndex(of: pendingViewControllers.first!)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            didFinishAnimating finished: Bool,
                            previousViewControllers: [UIViewController],
                            transitionCompleted completed: Bool) {
        if completed {
            self.currentIndex = self.pendingIndex
            if let index = self.currentIndex {
                self.control.currentPage = index
            }
        }
    }
    
    // MARK: Miscellaneous
    func customSetup() {
        self.setup()
        
        let page1 = AKUsernameInputViewController(nibName: "AKUsernameInputView", bundle: nil)
        page1.presenterController = self
        
        self.pages.append(page1)
        
        self.pageContainer = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        self.pageContainer.delegate = self
        self.pageContainer.dataSource = self
        self.pageContainer.setViewControllers([page1], direction: .forward, animated: true, completion: nil)
        
        self.view.addSubview(self.pageContainer.view)
        
        // Configure our custom pageControl
        self.view.bringSubviewToFront(self.control)
        self.control.numberOfPages = pages.count
        self.control.currentPage = 0
    }
}
