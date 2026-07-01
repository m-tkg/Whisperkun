import AppKit
import SwiftUI

/// オンボーディングウィンドウ（NSWindow）を管理する。
@MainActor
final class OnboardingController: HostedWindowController {
    init() {
        super.init(configuration: .init(
            title: String(localized: "はじめに"),
            identifier: "onboarding",
            styleMask: [.titled, .closable],
            contentSize: NSSize(width: 460, height: 380)
        ))
    }

    /// 権限が未充足なら表示する。
    func showIfNeeded(_ appState: AppState) {
        guard !appState.permissions.allGranted else { return }
        show(appState)
    }

    func show(_ appState: AppState) {
        show {
            OnboardingView(appState: appState) { [weak self] in
                self?.close()
            }
        }
    }
}
