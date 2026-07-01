import AppKit
import SwiftUI

/// フローティングHUD用の `NSPanel` を管理する。全 Space・全アプリ上に表示する。
///
/// 非アクティブ化パネル（`.nonactivatingPanel`・使い捨て）でホスト方式が異なるため、
/// `HostedWindowController` は使わない。
@MainActor
final class HUDController {
    private var panel: NSPanel?

    /// HUD の表示状態。AI整形中フラグなどを保持する（録音状態は TranscriptionService）。
    let state = HUDState()

    /// 中止ボタンが押されたときの処理（DictationCoordinator が設定）。
    var onCancel: (() -> Void)?

    func show(_ transcription: TranscriptionService) {
        if panel != nil { return }

        let hosting = NSHostingController(rootView: RecordingHUDView(
            transcription: transcription,
            state: state,
            onCancel: { [weak self] in self?.onCancel?() }
        ))
        // SwiftUIビューにパネルサイズを追従させない（制約更新ループの回避）。
        hosting.sizingOptions = []
        let panel = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: 420, height: 120),
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        panel.level = .floating
        panel.isFloatingPanel = true
        panel.hidesOnDeactivate = false
        panel.isMovableByWindowBackground = true
        panel.backgroundColor = .clear
        panel.isOpaque = false
        panel.hasShadow = true
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        panel.contentViewController = hosting

        positionAtBottomCenter(panel)
        panel.orderFrontRegardless()
        self.panel = panel
    }

    func hide() {
        panel?.orderOut(nil)
        panel = nil
        state.isFormatting = false
    }

    private func positionAtBottomCenter(_ panel: NSPanel) {
        guard let screen = NSScreen.main else { return }
        let visible = screen.visibleFrame
        let size = panel.frame.size
        let origin = NSPoint(
            x: visible.midX - size.width / 2,
            y: visible.minY + 120
        )
        panel.setFrameOrigin(origin)
    }
}
