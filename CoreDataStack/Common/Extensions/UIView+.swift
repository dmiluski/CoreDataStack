import UIKit

extension UIView {

    /// Adds view and fits to bounds
    ///
    /// - Parameters
    ///     - view: View to embed in superView
    ///     - container: Provides placement container (either UIView or UILayoutGuide). Defaults to self
    func embed(view: UIView, relativeTo: Anchorable? = nil) {

        let container = relativeTo ?? self
        addSubview(view)

        // Fit to containing View
        // Disable to apply constraints
        view.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            view.topAnchor.constraint(equalTo: container.topAnchor),
            view.bottomAnchor.constraint(equalTo: container.bottomAnchor),
        ])
    }
}
