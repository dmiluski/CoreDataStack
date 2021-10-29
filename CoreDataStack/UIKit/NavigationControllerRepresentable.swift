import Foundation
import UIKit
import SwiftUI

struct NavigationViewControllerRepresentable: UIViewControllerRepresentable {

    var rootViewController: UIViewController

    func makeUIViewController(context: NavigationViewControllerRepresentable.Context) -> UINavigationController {
        UINavigationController(rootViewController: rootViewController)
    }

    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {}
}
