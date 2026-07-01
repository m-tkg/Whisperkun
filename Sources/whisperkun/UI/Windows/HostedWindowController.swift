import AppKit
import SwiftUI

/// SwiftUI ビューを自前の `NSWindow` にホストする共通基盤。
///
/// メニューバー常駐（accessory）＋ AppKit メニュー構成では SwiftUI のシーン
/// （Settings 等）が開けない/前面に出ないため、`NSHostingController` + `NSWindow`
/// で自前ホストする。生成済みならウィンドウを再利用して前面化する。
@MainActor
class HostedWindowController {
    struct Configuration {
        var title: String
        var identifier: String
        var styleMask: NSWindow.StyleMask
        var contentSize: NSSize
        /// 前面化時に `orderFrontRegardless` も呼ぶか（背面の既存ウィンドウも強制的に前へ出す）。
        /// 設定ウィンドウは true、オンボーディングは false（従来挙動を維持）。
        var ordersFrontRegardless = false
    }

    private(set) var window: NSWindow?
    private let configuration: Configuration

    init(configuration: Configuration) {
        self.configuration = configuration
    }

    /// 表示する（生成済みなら再利用して前面化）。
    func show(@ViewBuilder content: () -> some View) {
        if let window {
            bringToFront(window)
            return
        }

        let hosting = NSHostingController(rootView: content())
        // SwiftUIビューにウィンドウサイズを追従させない（制約更新ループの回避）。
        hosting.sizingOptions = []
        let window = NSWindow(contentViewController: hosting)
        window.title = configuration.title
        window.identifier = NSUserInterfaceItemIdentifier(configuration.identifier)
        window.styleMask = configuration.styleMask
        window.isReleasedWhenClosed = false
        window.setContentSize(configuration.contentSize)
        window.center()
        bringToFront(window)
        self.window = window
    }

    /// 閉じて破棄する（次回 show で作り直す）。
    func close() {
        window?.close()
        window = nil
    }

    private func bringToFront(_ window: NSWindow) {
        window.makeKeyAndOrderFront(nil)
        if configuration.ordersFrontRegardless {
            window.orderFrontRegardless()
        }
        NSApp.activate(ignoringOtherApps: true)
    }
}
