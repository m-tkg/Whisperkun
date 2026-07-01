import AppKit

/// 起動時のプロセス制御。
enum AppLaunchGuard {
    /// 同一バンドルIDのインスタンスが既に動いていれば、それを前面化して自プロセスを終了する。
    static func terminateIfAlreadyRunning() {
        guard let bundleID = Bundle.main.bundleIdentifier else { return }
        let others = NSRunningApplication
            .runningApplications(withBundleIdentifier: bundleID)
            .filter { $0 != NSRunningApplication.current }
        guard let existing = others.first else { return }
        existing.activate(options: [.activateAllWindows])
        exit(0)
    }
}
