
import SwiftUI
import UIKit

/// Generic Base class providing ability to embed SwiftUI View content in a cell
open class SwiftUICollectionViewCell<Content>: UICollectionViewListCell where Content: View {

    enum RelativeLayout {

        /// Respects ContentView's LayoutMargins Guide
        case layoutMarginGuide

        case view(UIView)

        case custom(UILayoutGuide)
    }

    /// Controller to host the SwiftUI View
    private(set) var hostingController: UIHostingController<Content>?

    /// ContentView Relative Layout
    /// This must be set prior to initial configuring of cell
    var relativeLayout: RelativeLayout = .layoutMarginGuide

    /// Configures cell with SwiftUI Content
    ///
    /// - Parameters:
    ///     - parent: Parent ViewController providing lifecycle events
    ///     - content: SwiftUI View content to be displayed in the cell
    func configure(in parent: UIViewController, withView content: Content) {

        // Lazily load/configure content
        if let hostingController = self.hostingController {

            hostingController.rootView = content
            hostingController.view.invalidateIntrinsicContentSize()
            hostingController.view.layoutIfNeeded()
        } else {
            let hostController = UIHostingController(rootView: content)
            parent.embed(
                viewController: hostController,
                in: contentView,
                relativeTo: relativeTo
            )
            hostController.view.backgroundColor = .clear
            hostingController = hostController
        }
    }

    deinit {
        hostingController?.willMove(toParent: nil)
        hostingController?.view.removeFromSuperview()
        hostingController?.removeFromParent()
        hostingController = nil
    }

    // MARK: - Helper

    /// Placement in contentView
    private var relativeTo: Anchorable {
        switch relativeLayout {
        case .layoutMarginGuide:
            return contentView.layoutMarginsGuide
        case let .view(view):
            return view
        case let .custom(guide):
            return guide
        }
    }
}
