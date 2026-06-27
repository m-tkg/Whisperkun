import AppKit

/// メニューバーアイコンの右下に重ねる赤バッジ（小さな赤丸）。
///
/// ベースアイコンは template のまま（メニューバーの明暗で自動着色）維持し、色付きの赤丸は
/// この別 view を `statusItem.button` にオーバーレイして表現する。画像に焼き込むと自動着色が壊れるため。
/// メニューバー背景に溶けないよう細い白の縁取りを付ける。クリックはボタン（メニュー表示）へ通すため
/// `hitTest` で当たり判定を透過させる。
@MainActor
final class UpdateBadgeView: NSView {
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        wantsLayer = true
        let layer = self.layer ?? CALayer()
        layer.backgroundColor = NSColor.systemRed.cgColor
        layer.borderColor = NSColor.white.cgColor
        layer.borderWidth = 1
        self.layer = layer
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layout() {
        super.layout()
        // 常に正円にする（サイズに追従）。
        layer?.cornerRadius = min(bounds.width, bounds.height) / 2
    }

    /// クリックを下のボタンへ透過させ、メニュー表示を妨げない。
    override func hitTest(_ point: NSPoint) -> NSView? {
        nil
    }
}
