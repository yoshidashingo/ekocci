import Testing
@testable import EkocciShared

@Suite("HiddenStats Tests")
struct HiddenStatsTests {

    @Test("初期値がゼロ")
    func initialValues() {
        let stats = HiddenStats.initial
        #expect(stats.effort == 0)
        #expect(stats.bonding == 0)
    }

    @Test("effortを加算できる")
    func addEffort() {
        let stats = HiddenStats(effort: 10, bonding: 20)
        let result = stats.addingEffort(5)
        #expect(result.effort == 15)
        #expect(result.bonding == 20)
    }

    @Test("bondingを加算できる")
    func addBonding() {
        let stats = HiddenStats(effort: 10, bonding: 20)
        let result = stats.addingBonding(3)
        #expect(result.effort == 10)
        #expect(result.bonding == 23)
    }

    @Test("effortは100を超えない")
    func effortCapped() {
        let stats = HiddenStats(effort: 95, bonding: 0)
        let result = stats.addingEffort(10)
        #expect(result.effort == 100)
    }

    @Test("bondingは100を超えない")
    func bondingCapped() {
        let stats = HiddenStats(effort: 0, bonding: 98)
        let result = stats.addingBonding(5)
        #expect(result.bonding == 100)
    }

    @Test("effortは0未満にならない")
    func effortFloor() {
        let stats = HiddenStats(effort: 3, bonding: 0)
        let result = stats.addingEffort(-10)
        #expect(result.effort == 0)
    }

    @Test("bondingは0未満にならない")
    func bondingFloor() {
        let stats = HiddenStats(effort: 0, bonding: 2)
        let result = stats.addingBonding(-10)
        #expect(result.bonding == 0)
    }

    @Test("イミュータブル: 元のstatsが変わらない")
    func immutability() {
        let original = HiddenStats(effort: 50, bonding: 50)
        let _ = original.addingEffort(10)
        let _ = original.addingBonding(10)
        #expect(original.effort == 50)
        #expect(original.bonding == 50)
    }
}
