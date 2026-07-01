import AppKit
import SwiftUI

/// 設定ウィンドウ（NSWindow）を管理する。
///
/// SwiftUI の `Settings` シーンは、メニューバー常駐（accessory）＋ AppKit メニュー（NSStatusItem）構成だと
/// `showSettingsWindow:` で開けない（アクションは true を返すが窓を生成しない）。そのため
/// `SettingsView` を自前の `NSWindow` にホストする。前面化/Dock 表示は `ForegroundActivation` が担う。
@MainActor
final class SettingsWindowController: HostedWindowController {
    init() {
        super.init(configuration: .init(
            title: String(localized: "設定"),
            identifier: "settings",
            styleMask: [.titled, .closable, .miniaturizable],
            contentSize: NSSize(width: 560, height: 420),
            ordersFrontRegardless: true
        ))
    }

    /// 設定ウィンドウを表示（生成済みなら再利用して前面化）する。
    func show(_ appState: AppState) {
        show {
            SettingsView(appState: appState)
                .modelContainer(appState.modelContainer)
        }
    }
}
