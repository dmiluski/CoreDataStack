import Foundation

import SwiftUI
import UIKit

/// CollectionView wrapper of SwiftUI View
///
/// Responsible for displaying **rich** version of Cell
class RouteCell: SwiftUICollectionViewCell<RouteCellView> {
    func configure(with route: Route, parent: UIViewController) {
        configure(in: parent, withView: RouteCellView(route: route))
    }
}
