//
//  DisableInteractivePopGesture.swift
//  HYFIT
//

import SwiftUI
import UIKit

/// Disables UINavigationController interactive pop while this view is visible.
struct DisableInteractivePopGesture: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> Controller {
        Controller()
    }

    func updateUIViewController(_ uiViewController: Controller, context: Context) {}

    final class Controller: UIViewController {
        private weak var gesture: UIGestureRecognizer?
        private var wasEnabled: Bool?

        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            guard let pop = navigationController?.interactivePopGestureRecognizer else { return }
            gesture = pop
            wasEnabled = pop.isEnabled
            pop.isEnabled = false
        }

        override func viewWillDisappear(_ animated: Bool) {
            super.viewWillDisappear(animated)
            if let gesture, let wasEnabled {
                gesture.isEnabled = wasEnabled
            }
        }
    }
}

extension View {
    func disableInteractivePopGesture() -> some View {
        background(DisableInteractivePopGesture())
    }
}
