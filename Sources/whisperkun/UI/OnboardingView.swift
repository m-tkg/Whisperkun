import AppKit
import SwiftUI

/// 初回起動時に3つの権限付与を案内するオンボーディング。
struct OnboardingView: View {
    @Bindable var appState: AppState
    var onClose: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text("whisperkun へようこそ")
                    .font(.title2.bold())
                Text("音声入力を使うには、次の3つの権限が必要です。")
                    .foregroundStyle(.secondary)
            }

            step(
                number: 1,
                title: "マイク",
                detail: "音声を取り込みます。",
                granted: appState.permissions.microphone == .granted,
                action: { Task { await appState.permissions.requestMicrophone() } }
            )
            step(
                number: 2,
                title: "音声認識",
                detail: "オンデバイスで文字起こしします。",
                granted: appState.permissions.speechRecognition == .granted,
                action: { Task { await appState.permissions.requestSpeechRecognition() } }
            )
            step(
                number: 3,
                title: "アクセシビリティ",
                detail: "他アプリへの貼り付けとホットキーに使います。システム設定で許可後、「再確認」を押してください。",
                granted: appState.permissions.accessibilityGranted,
                action: {
                    appState.permissions.requestAccessibility()
                    appState.ensureHotkeyInstalled()
                }
            )

            HStack {
                Button("再確認") { appState.ensureHotkeyInstalled() }
                Spacer()
                Button(appState.permissions.allGranted ? "始める" : "あとで") { onClose() }
                    .keyboardShortcut(.defaultAction)
            }
        }
        .padding(24)
        .frame(width: 460, height: 380)
        // オンボーディング表示中だけ前面化＋Dock表示する。
        .background(ForegroundActivation())
    }

    @ViewBuilder
    private func step(number: Int, title: LocalizedStringKey, detail: LocalizedStringKey, granted: Bool, action: @escaping () -> Void) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: granted ? PermissionState.granted.symbolName : "\(number).circle")
                .font(.title2)
                .foregroundStyle(granted ? PermissionState.granted.indicatorColor : .secondary)
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.headline)
                Text(detail).font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
            if !granted {
                Button("許可", action: action)
            }
        }
    }
}

