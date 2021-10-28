import UIKit

// MARK: - Modal Helpers

extension UIViewController {

    /// Highest ViewController in the hierarchy
    var topMostViewController: UIViewController {
        return presentedViewController?.topMostViewController ?? self
    }
}

// MARK: - Child ViewController Helpers

extension UIViewController {

    /// Embeds a ViewController as a child viewController, filling its container view
    ///
    /// - Parameters:
    ///     - viewController: Child Controller to add
    ///     - container: Provides view to add as subview. (By default is viewController's view)
    ///     - relativeTo: Provide anchor reference. Eg. Could use view or view's layoutMarginesGuide. ((By default is viewController's view)
    func embed(
        viewController: UIViewController,
        in container: UIView? = nil,
        relativeTo: Anchorable? = nil
    ) {

        // Determine where to add ass childView
        let container = container ?? view

        // Determine what reference to use to anchor view
        let relation = relativeTo ?? container

        // Add as child to forward trait/events
        addChild(viewController)

        // Embed in expected frame/layout
        container?.embed(view: viewController.view, relativeTo: relation)

        viewController.didMove(toParent: self)
    }
}
