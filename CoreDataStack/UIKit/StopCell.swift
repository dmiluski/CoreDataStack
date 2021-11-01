import Foundation

import SwiftUI
import UIKit

/// CollectionView wrapper of SwiftUI View
///
/// Responsible for displaying **rich** version of Cell
class StopCell: SwiftUICollectionViewCell<StopCellView> {
    func configure(stop: Stop, parent: UIViewController) {
        configure(in: parent, withView: StopCellView(stop: stop))
    }
}
