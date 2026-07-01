/// 文字起こしの実行状態。
public enum TranscriptionPhase: Equatable, Sendable {
    case idle
    case preparing      // モデル/言語アセットの準備中
    case listening      // 録音・認識中
    case failed(String)
}

/// 文字起こしセッションの世代（generation）と phase 遷移判断の純粋状態機械。
///
/// TranscriptionService の非同期セットアップは await を挟むたびに「自分の世代が
/// まだ現行か」を確認し、stop / 再 begin で世代が進んでいたら中断して `.listening` へ
/// 遷移しない。その判断をここに集約する（I/O・AVFoundation の操作は持たない）。
///
/// 使い方（TranscriptionService と 1:1 対応）:
/// - `begin()` … 世代を進め `.preparing` へ。返った世代を非同期セットアップへ渡す
/// - `isCurrent(_:)` … await 境界ごとの中断チェック
/// - `commitListening(_:)` … 準備完了。現行世代なら `.listening` へ
/// - `fail(_:message:)` … 現行世代の失敗のみ反映（古い世代は stop 側が状態を持つ）
/// - `forceFail(message:)` … 結果ストリームのエラーなど世代によらない失敗
/// - `stop()` … 世代を進めて進行中セットアップを無効化。停止処理が必要なら true
/// - `finishStop()` … 停止処理の完了。`.idle` へ戻す
public struct TranscriptionSession: Sendable, Equatable {
    public private(set) var phase: TranscriptionPhase = .idle
    public private(set) var generation = 0

    public init() {}

    /// 録音・準備が進行中か（`.preparing` / `.listening`）。
    public var isRunning: Bool {
        fatalError("未実装")
    }

    /// セッションを開始する。世代を進め `.preparing` にし、その世代を返す。
    public mutating func begin() -> Int {
        fatalError("未実装")
    }

    /// `gen` がまだ現行世代か（違えば進行中のセットアップは中断すべき）。
    public func isCurrent(_ gen: Int) -> Bool {
        fatalError("未実装")
    }

    /// 準備完了。`gen` が現行世代なら `.listening` へ遷移して true。古い世代なら何もしない。
    @discardableResult
    public mutating func commitListening(_ gen: Int) -> Bool {
        fatalError("未実装")
    }

    /// `gen` が現行世代なら `.failed` へ遷移して true。古い世代なら何もしない。
    @discardableResult
    public mutating func fail(_ gen: Int, message: String) -> Bool {
        fatalError("未実装")
    }

    /// 世代によらず `.failed` へ遷移する（結果ストリームのエラー用）。
    public mutating func forceFail(message: String) {
        fatalError("未実装")
    }

    /// 停止する。世代を進めて進行中のセットアップを無効化し、
    /// 停止処理（リソース解放・確定待ち）が必要（＝進行中だった）なら true を返す。
    /// phase は停止処理の完了（`finishStop`）まで変えない（「認識中」表示を保つ従来挙動）。
    public mutating func stop() -> Bool {
        fatalError("未実装")
    }

    /// 停止処理の完了。`.idle` へ戻す。
    public mutating func finishStop() {
        fatalError("未実装")
    }
}
