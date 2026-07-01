import Foundation

/// ホットキーの修飾キーが「今も押下中か」を物理キー状態から判定する純粋関数。
///
/// 取りこぼし回収（reconcile）で `CGEventSource.flagsState` の集約フラグが幽霊的に
/// 「押下中」で張り付く不具合を避けるため、各修飾キーの物理 up/down を
/// keyCode ごとに問い合わせた結果（`keyStates`）で判定する。プラットフォーム非依存に
/// テストできるよう `CGEventSource` を引数から切り離してある。
///
/// - Parameters:
///   - requiredKeyCodes: 同時押下を要求する修飾キーの仮想キーコード集合。
///   - keyStates: keyCode → 押下中(true) の対応。取得できなかったキーは欠落（= false 扱い）。
/// - Returns: 要求キーが空でなく、その全てが押下中のときだけ true。
public func hotkeyIsDown(requiredKeyCodes: Set<UInt16>, keyStates: [UInt16: Bool]) -> Bool {
    guard !requiredKeyCodes.isEmpty else { return false }
    return requiredKeyCodes.allSatisfy { keyStates[$0] == true }
}
