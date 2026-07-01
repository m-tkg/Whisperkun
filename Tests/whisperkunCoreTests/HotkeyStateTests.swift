import Testing
@testable import whisperkunCore

@Suite struct HotkeyStateTests {
    // keyCode は macOS の仮想キーコード（左Shift=56 / 右Shift=60 / 左Control=59 想定）。

    @Test func 必須キーが全て押下ならtrue() {
        let states: [UInt16: Bool] = [56: true, 59: true]
        #expect(hotkeyIsDown(requiredKeyCodes: [56, 59], keyStates: states))
    }

    @Test func 一つでも解放されていればfalse() {
        let states: [UInt16: Bool] = [56: true, 59: false]
        #expect(!hotkeyIsDown(requiredKeyCodes: [56, 59], keyStates: states))
    }

    @Test func 状態が未知のキーはfalse扱い() {
        // keyState 取得に失敗して辞書に無い場合でも「押下中」と誤判定しない。
        #expect(!hotkeyIsDown(requiredKeyCodes: [56], keyStates: [:]))
    }

    @Test func 必須キーが空ならfalse() {
        // 未設定（監視なし）を押下とみなさない。
        #expect(!hotkeyIsDown(requiredKeyCodes: [], keyStates: [56: true]))
    }

    @Test func 左右を取り違えたキーではtrueにならない() {
        // 左Shift(56) を要求しているのに右Shift(60) だけ押されていても down にしない。
        let states: [UInt16: Bool] = [60: true]
        #expect(!hotkeyIsDown(requiredKeyCodes: [56], keyStates: states))
    }
}
