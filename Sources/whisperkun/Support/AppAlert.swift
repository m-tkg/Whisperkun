import AppKit

/// メニューバー常駐（accessory）アプリ向けの NSAlert 表示ヘルパ。
@MainActor
enum AppAlert {
    /// 単純な通知アラート（OK のみ）。
    static func show(title: String, message: String) {
        let alert = NSAlert()
        alert.messageText = title
        alert.informativeText = message
        alert.addButton(withTitle: String(localized: "OK"))
        runModal(alert)
    }

    /// アラートを確実に見える状態で表示する。メニューバー常駐(accessory)アプリでは
    /// アプリが前面化されないと runModal がアラート不可視のまま固まるため、
    /// 前面化＋アラートを最前面レベルにしてから実行する。
    @discardableResult
    static func runModal(_ alert: NSAlert) -> NSApplication.ModalResponse {
        NSApp.activate(ignoringOtherApps: true)
        alert.window.level = .modalPanel
        return alert.runModal()
    }
}
