import Foundation
import os

private let appGroupLogger = Logger(subsystem: "com.ekocci", category: "AppGroup")

/// App Group 設定 (メインアプリとWidget間のデータ共有)
enum AppGroupConfig {
    static let suiteName = "group.com.ekocci.shared"

    /// 共有 UserDefaults
    static var sharedDefaults: UserDefaults {
        guard let defaults = UserDefaults(suiteName: suiteName) else {
            appGroupLogger.fault("App Group '\(suiteName)' is unavailable — check entitlements. Falling back to .standard")
            assertionFailure("App Group '\(suiteName)' is unavailable — check entitlements")
            return .standard
        }
        return defaults
    }
}
