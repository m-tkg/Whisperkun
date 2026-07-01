import Testing
@testable import whisperkunCore

@Suite struct TranscriptionSessionTests {
    @Test func 正常系はbegin準備完了stopで一巡する() {
        var session = TranscriptionSession()
        #expect(session.phase == .idle)
        #expect(!session.isRunning)

        let gen = session.begin()
        #expect(session.phase == .preparing)
        #expect(session.isRunning)
        #expect(session.isCurrent(gen))

        let committed = session.commitListening(gen)
        #expect(committed)
        #expect(session.phase == .listening)
        #expect(session.isRunning)

        let needsStop = session.stop()
        #expect(needsStop)
        // 停止処理の完了までは phase を変えない（「認識中」表示を保つ）。
        #expect(session.phase == .listening)

        session.finishStop()
        #expect(session.phase == .idle)
        #expect(!session.isRunning)
    }

    @Test func beginは世代を進める() {
        var session = TranscriptionSession()
        let g1 = session.begin()
        let g2 = session.begin()
        #expect(g2 > g1)
        #expect(!session.isCurrent(g1))
        #expect(session.isCurrent(g2))
    }

    @Test func preparing中にstopすると古い世代のcommitは拒否される() {
        var session = TranscriptionSession()
        let gen = session.begin()
        let needsStop = session.stop()
        #expect(needsStop)  // preparing 中でも停止処理は必要
        #expect(!session.isCurrent(gen))
        let committed = session.commitListening(gen)
        #expect(!committed)
        #expect(session.phase != .listening)  // .listening へ遷移して固着しない
        session.finishStop()
        #expect(session.phase == .idle)
    }

    @Test func 再beginで古い世代のcommitは拒否され新しい世代は通る() {
        var session = TranscriptionSession()
        let g1 = session.begin()
        let g2 = session.begin()
        let oldCommitted = session.commitListening(g1)
        #expect(!oldCommitted)
        #expect(session.phase == .preparing)
        let newCommitted = session.commitListening(g2)
        #expect(newCommitted)
        #expect(session.phase == .listening)
    }

    @Test func 現行世代の失敗はfailedに遷移する() {
        var session = TranscriptionSession()
        let gen = session.begin()
        let failed = session.fail(gen, message: "boom")
        #expect(failed)
        #expect(session.phase == .failed("boom"))
        #expect(!session.isRunning)
    }

    @Test func 古い世代の失敗は無視される() {
        var session = TranscriptionSession()
        let g1 = session.begin()
        _ = session.stop()
        let failed = session.fail(g1, message: "late")
        #expect(!failed)
        #expect(session.phase != .failed("late"))
    }

    @Test func forceFailは世代によらず失敗にする() {
        var session = TranscriptionSession()
        let g1 = session.begin()
        _ = session.begin()
        _ = g1
        session.forceFail(message: "stream")
        #expect(session.phase == .failed("stream"))
    }

    @Test func 停止済みならstopは停止処理不要を返すが世代は進める() {
        var session = TranscriptionSession()
        let g1 = session.begin()
        _ = session.stop()
        session.finishStop()
        let before = session.generation
        let needsStop = session.stop()
        #expect(!needsStop)  // idle: 停止処理は不要
        #expect(session.generation > before)  // それでも世代は進める（進行中セットアップの無効化）
        #expect(!session.isCurrent(g1))
        #expect(session.phase == .idle)  // phase は変えない
    }

    @Test func failed状態のstopは停止処理不要() {
        var session = TranscriptionSession()
        let gen = session.begin()
        _ = session.fail(gen, message: "boom")
        let needsStop = session.stop()
        #expect(!needsStop)
        #expect(session.phase == .failed("boom"))
    }
}
