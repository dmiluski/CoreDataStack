import Foundation
import UIKit
import SwiftUI

struct NavigationViewControllerRepresentable: UIViewControllerRepresentable {

    var rootViewController: UIViewController

    func makeUIViewController(context: NavigationViewControllerRepresentable.Context) -> UINavigationController {
        let controller = UINavigationController(rootViewController: rootViewController)
        controller.navigationBar.prefersLargeTitles = true
        return controller
    }

    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {}
}
