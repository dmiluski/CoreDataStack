import UIKit

/// Generic Anchorable Provider of interfaces shared between UIView and UILayoutGuide
///
/// Allows either UIView or UILayoutGuide to be passed as an anchorable target
protocol Anchorable {
    var leadingAnchor: NSLayoutXAxisAnchor { get }

    var trailingAnchor: NSLayoutXAxisAnchor { get }

    var leftAnchor: NSLayoutXAxisAnchor { get }

    var rightAnchor: NSLayoutXAxisAnchor { get }

    var topAnchor: NSLayoutYAxisAnchor { get }

    var bottomAnchor: NSLayoutYAxisAnchor { get }

    var widthAnchor: NSLayoutDimension { get }

    var heightAnchor: NSLayoutDimension { get }

    var centerXAnchor: NSLayoutXAxisAnchor { get }

    var centerYAnchor: NSLayoutYAxisAnchor { get }
}

extension UIView: Anchorable {}
extension UILayoutGuide: Anchorable {}
