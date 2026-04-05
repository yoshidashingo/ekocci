import Testing
@testable import EkocciShared

@Suite("MiniGameTypes Tests")
struct MiniGameTypesTests {

    @Test("勝利結果が正しく生成される")
    func winResult() {
        let result = MiniGameResult.win(correct: 4, total: 5)
        #expect(result.won == true)
        #expect(result.correctCount == 4)
        #expect(result.totalRounds == 5)
        #expect(result.ecoPointsEarned == GameConfig.miniGameWinPoints)
    }

    @Test("敗北結果が正しく生成される")
    func loseResult() {
        let result = MiniGameResult.lose(correct: 1, total: 5)
        #expect(result.won == false)
        #expect(result.correctCount == 1)
        #expect(result.totalRounds == 5)
        #expect(result.ecoPointsEarned == GameConfig.miniGameLosePoints)
    }

    @Test("MiniGameDescriptorのIDが一意")
    func descriptorIdentifiable() {
        let desc = MiniGameDescriptor(id: "test", displayName: "テスト", iconSystemName: "star")
        #expect(desc.id == "test")
    }
}
