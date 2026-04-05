import Foundation

/// リアルタイム時刻管理
enum TimeManager {
    /// 指定時刻にペットが寝ているべきかを判定
    static func shouldBeSleeping(stage: LifeStage, at date: Date) -> Bool {
        guard stage != .egg, stage != .dead else { return false }

        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        let bedtime = stage.bedtimeHour
        let wakeUp = stage.wakeUpHour

        // 就寝時刻 > 起床時刻 (例: 22時就寝、8時起床)
        if bedtime > wakeUp {
            return hour >= bedtime || hour < wakeUp
        } else {
            return hour >= bedtime && hour < wakeUp
        }
    }

    /// 次の起床時刻を算出
    static func nextWakeUpTime(stage: LifeStage, after date: Date) -> Date {
        let calendar = Calendar.current
        let wakeUp = stage.wakeUpHour

        var components = calendar.dateComponents([.year, .month, .day], from: date)
        components.hour = wakeUp
        components.minute = 0
        components.second = 0

        guard let candidate = calendar.date(from: components) else { return date }

        if candidate > date {
            return candidate
        }
        return calendar.date(byAdding: .day, value: 1, to: candidate) ?? date
    }

    /// 次の就寝時刻を算出
    static func nextBedtime(stage: LifeStage, after date: Date) -> Date {
        let calendar = Calendar.current
        let bedtime = stage.bedtimeHour

        var components = calendar.dateComponents([.year, .month, .day], from: date)
        components.hour = bedtime
        components.minute = 0
        components.second = 0

        guard let candidate = calendar.date(from: components) else { return date }

        if candidate > date {
            return candidate
        }
        return calendar.date(byAdding: .day, value: 1, to: candidate) ?? date
    }

    /// 現在のペット年齢を計算
    static func petAge(birthDate: Date, at date: Date) -> Int {
        let elapsed = date.timeIntervalSince(birthDate)
        return max(0, Int(elapsed / GameConfig.secondsPerPetYear))
    }
}
