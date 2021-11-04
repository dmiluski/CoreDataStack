import SwiftUI
import UIKit

struct ActivityIndicator: UIViewRepresentable {

    @Binding var isAnimating: Bool
    let style: UIActivityIndicatorView.Style

    /// Color of the spinner. If nil, will use system default
    @State
    var color: UIColor?

    func makeUIView(context: UIViewRepresentableContext<ActivityIndicator>) -> UIActivityIndicatorView {
        let view = UIActivityIndicatorView(style: style)

        if let color = color {
            view.color = color
        }

        return view
    }

    func updateUIView(_ uiView: UIActivityIndicatorView, context: UIViewRepresentableContext<ActivityIndicator>) {
        isAnimating ? uiView.startAnimating() : uiView.stopAnimating()
        uiView.color = color
    }
}
