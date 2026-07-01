import Testing
@testable import whisperkunCore

@Suite struct TranscriptAssemblerTests {
    @Test func 確定結果は蓄積されliveTextにも反映される() {
        var assembler = TranscriptAssembler()
        assembler.apply(text: "こんにちは", isFinal: true)
        #expect(assembler.finalizedText == "こんにちは")
        #expect(assembler.liveText == "こんにちは")
    }

    @Test func 確定結果は末尾に連結される() {
        var assembler = TranscriptAssembler()
        assembler.apply(text: "こんにちは", isFinal: true)
        assembler.apply(text: "、世界", isFinal: true)
        #expect(assembler.finalizedText == "こんにちは、世界")
        #expect(assembler.liveText == "こんにちは、世界")
    }

    @Test func 暫定結果は確定済みの後ろに表示されるが蓄積されない() {
        var assembler = TranscriptAssembler()
        assembler.apply(text: "こんにちは", isFinal: true)
        assembler.apply(text: "、せか", isFinal: false)
        #expect(assembler.finalizedText == "こんにちは")
        #expect(assembler.liveText == "こんにちは、せか")
    }

    @Test func 暫定結果は次の暫定で置き換わる() {
        var assembler = TranscriptAssembler()
        assembler.apply(text: "こんにちは", isFinal: true)
        assembler.apply(text: "、せか", isFinal: false)
        assembler.apply(text: "、世界", isFinal: false)
        #expect(assembler.liveText == "こんにちは、世界")
    }

    @Test func 暫定のみでも表示される() {
        var assembler = TranscriptAssembler()
        assembler.apply(text: "こんに", isFinal: false)
        #expect(assembler.finalizedText.isEmpty)
        #expect(assembler.liveText == "こんに")
    }

    @Test func 正常確定なら確定テキストを返す() {
        var assembler = TranscriptAssembler()
        assembler.apply(text: "確定", isFinal: true)
        assembler.apply(text: "した暫定", isFinal: false)
        #expect(assembler.finalText(finished: true) == "確定")
    }

    @Test func タイムアウトで確定が空ならliveTextで代替する() {
        var assembler = TranscriptAssembler()
        assembler.apply(text: "暫定のみ", isFinal: false)
        #expect(assembler.finalText(finished: false) == "暫定のみ")
    }

    @Test func タイムアウトでも確定があれば確定を優先する() {
        var assembler = TranscriptAssembler()
        assembler.apply(text: "確定", isFinal: true)
        assembler.apply(text: "の続き", isFinal: false)
        #expect(assembler.finalText(finished: false) == "確定")
    }

    @Test func 何も取り込んでいなければ空() {
        let assembler = TranscriptAssembler()
        #expect(assembler.finalText(finished: true).isEmpty)
        #expect(assembler.finalText(finished: false).isEmpty)
    }
}
