import Testing
import Foundation
@testable import EkocciShared

@Suite("LifeStage Tests")
struct LifeStageTests {

    // MARK: - durationSeconds

    @Test("たまごの持続時間は30秒")
    func eggDuration() {
        #expect(LifeStage.egg.durationSeconds == 30)
    }

    @Test("あかちゃんの持続時間は1時間")
    func babyDuration() {
        #expect(LifeStage.baby.durationSeconds == 3600)
    }

    @Test("こどもの持続時間は24時間")
    func childDuration() {
        #expect(LifeStage.child.durationSeconds == 86400)
    }

    @Test("ヤングの持続時間は3日")
    func youngDuration() {
        #expect(LifeStage.young.durationSeconds == 259200)
    }

    @Test("おとな・シニア・死亡はduration nil")
    func noDurationStages() {
        #expect(LifeStage.adult.durationSeconds == nil)
        #expect(LifeStage.senior.durationSeconds == nil)
        #expect(LifeStage.dead.durationSeconds == nil)
    }

    // MARK: - next

    @Test("egg→baby→child→young→adult→senior→dead の順序")
    func stageProgression() {
        #expect(LifeStage.egg.next == .baby)
        #expect(LifeStage.baby.next == .child)
        #expect(LifeStage.child.next == .young)
        #expect(LifeStage.young.next == .adult)
        #expect(LifeStage.adult.next == .senior)
        #expect(LifeStage.senior.next == .dead)
        #expect(LifeStage.dead.next == nil)
    }

    // MARK: - canPlayGames

    @Test("egg, baby, dead はゲーム不可")
    func cannotPlayGames() {
        #expect(!LifeStage.egg.canPlayGames)
        #expect(!LifeStage.baby.canPlayGames)
        #expect(!LifeStage.dead.canPlayGames)
    }

    @Test("child以降はゲーム可能")
    func canPlayGames() {
        #expect(LifeStage.child.canPlayGames)
        #expect(LifeStage.young.canPlayGames)
        #expect(LifeStage.adult.canPlayGames)
        #expect(LifeStage.senior.canPlayGames)
    }

    // MARK: - bedtimeHour

    @Test("あかちゃん・こどもは20時就寝")
    func babyChildBedtime() {
        #expect(LifeStage.baby.bedtimeHour == 20)
        #expect(LifeStage.child.bedtimeHour == 20)
    }

    @Test("ヤングは21時就寝")
    func youngBedtime() {
        #expect(LifeStage.young.bedtimeHour == 21)
    }

    @Test("おとなは22時就寝")
    func adultBedtime() {
        #expect(LifeStage.adult.bedtimeHour == 22)
    }

    @Test("シニアは21時就寝")
    func seniorBedtime() {
        #expect(LifeStage.senior.bedtimeHour == 21)
    }

    @Test("たまご・死亡のデフォルト就寝時刻は22時")
    func defaultBedtime() {
        #expect(LifeStage.egg.bedtimeHour == 22)
        #expect(LifeStage.dead.bedtimeHour == 22)
    }

    // MARK: - wakeUpHour

    @Test("あかちゃん・こども・ヤングは9時起床")
    func babyChildYoungWakeUp() {
        #expect(LifeStage.baby.wakeUpHour == 9)
        #expect(LifeStage.child.wakeUpHour == 9)
        #expect(LifeStage.young.wakeUpHour == 9)
    }

    @Test("おとな・シニアは8時起床")
    func adultSeniorWakeUp() {
        #expect(LifeStage.adult.wakeUpHour == 8)
        #expect(LifeStage.senior.wakeUpHour == 8)
    }

    @Test("たまご・死亡のデフォルト起床時刻は9時")
    func defaultWakeUp() {
        #expect(LifeStage.egg.wakeUpHour == 9)
        #expect(LifeStage.dead.wakeUpHour == 9)
    }

    // MARK: - poopIntervalSeconds

    @Test("あかちゃんのうんち間隔は20分")
    func babyPoopInterval() {
        #expect(LifeStage.baby.poopIntervalSeconds == 1200)
    }

    @Test("こどものうんち間隔は1時間")
    func childPoopInterval() {
        #expect(LifeStage.child.poopIntervalSeconds == 3600)
    }

    @Test("ヤングのうんち間隔は1.5時間")
    func youngPoopInterval() {
        #expect(LifeStage.young.poopIntervalSeconds == 5400)
    }

    @Test("おとなのうんち間隔は3時間")
    func adultPoopInterval() {
        #expect(LifeStage.adult.poopIntervalSeconds == 10800)
    }

    @Test("シニアのうんち間隔は2時間")
    func seniorPoopInterval() {
        #expect(LifeStage.senior.poopIntervalSeconds == 7200)
    }

    @Test("たまご・死亡のうんち間隔はinfinity")
    func noPoopStages() {
        #expect(LifeStage.egg.poopIntervalSeconds == .infinity)
        #expect(LifeStage.dead.poopIntervalSeconds == .infinity)
    }

    // MARK: - displayName

    @Test("全ステージの表示名が正しい")
    func displayNames() {
        #expect(LifeStage.egg.displayName == "たまご")
        #expect(LifeStage.baby.displayName == "あかちゃん")
        #expect(LifeStage.child.displayName == "こども")
        #expect(LifeStage.young.displayName == "ヤング")
        #expect(LifeStage.adult.displayName == "おとな")
        #expect(LifeStage.senior.displayName == "シニア")
        #expect(LifeStage.dead.displayName == "おわり")
    }
}
