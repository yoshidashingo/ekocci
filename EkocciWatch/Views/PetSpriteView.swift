import SwiftUI

// MARK: - Clawd カラーパレット

private enum ClawdColors {
    static let terracotta = Color(red: 0.85, green: 0.47, blue: 0.34)   // #D97757
    static let terracottaLight = Color(red: 0.91, green: 0.58, blue: 0.42) // #E8956A
    static let terracottaDark = Color(red: 0.77, green: 0.38, blue: 0.25)  // #C4613F
    static let cream = Color(red: 0.98, green: 0.94, blue: 0.90)        // #FAF0E6
    static let blush = Color(red: 0.95, green: 0.65, blue: 0.55)        // #F2A68C
    static let eyeColor = Color(red: 0.20, green: 0.15, blue: 0.12)     // 濃いブラウン
}

// MARK: - PetSpriteView

/// ペットのスプライト表示 (Clawd テーマ)
struct PetSpriteView: View {
    let pet: Pet
    @Environment(\.isLuminanceReduced) var isLuminanceReduced
    @State private var bounceOffset: CGFloat = 0

    var body: some View {
        if isLuminanceReduced {
            aodView
        } else {
            animatedView
        }
    }

    // MARK: - AOD (Always-On Display)

    private var aodView: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(.black.opacity(0.2))

            VStack(spacing: 4) {
                Text(SpriteMapping.emoji(for: pet.characterId))
                    .font(.title2)
                    .opacity(0.7)
                if pet.stage != .egg && pet.stage != .dead {
                    HStack(spacing: 8) {
                        Text("♥\(pet.stats.happiness)")
                        Text("🍔\(pet.stats.hunger)")
                    }
                    .font(.caption2)
                    .foregroundStyle(.white.opacity(0.5))
                }
            }
        }
    }

    // MARK: - Animated (通常表示)

    private var animatedView: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(.black.opacity(0.3))

            petBody
                .overlay(alignment: .topTrailing) {
                    accessoryBadge
                }
                .offset(y: bounceOffset)
                .onAppear {
                    if !pet.isSleeping {
                        startBounce()
                    }
                }
                .onChange(of: pet.isSleeping) { _, isSleeping in
                    if isSleeping {
                        bounceOffset = 0
                    } else {
                        startBounce()
                    }
                }

            if pet.isSleeping {
                SleepBubblesView()
                    .offset(x: 22, y: -22)
            }
        }
    }

    @ViewBuilder
    private var petBody: some View {
        switch pet.stage {
        case .egg:
            ClawdEggView()
        case .baby:
            ClawdBabyView()
        case .child:
            ClawdChildView(isSick: pet.isSick)
        case .young:
            ClawdYoungView(isSick: pet.isSick)
        case .adult:
            ClawdAdultView(isSick: pet.isSick)
        case .senior:
            ClawdSeniorView(isSick: pet.isSick)
        case .dead:
            ClawdDeadView()
        }
    }

    @ViewBuilder
    private var accessoryBadge: some View {
        let info = SpriteMapping.spriteInfo(for: pet.characterId)
        if let accessory = info.accessory, pet.stage != .egg, pet.stage != .dead {
            Text(accessory)
                .font(.system(size: 12))
                .offset(x: 4, y: -4)
        }
    }

    private func startBounce() {
        withAnimation(
            .easeInOut(duration: 0.6)
            .repeatForever(autoreverses: true)
        ) {
            bounceOffset = -4
        }
    }
}

// MARK: - たまご

private struct ClawdEggView: View {
    @State private var wobble = false
    @State private var glowPulse = false

    var body: some View {
        ZStack {
            // たまご本体
            Ellipse()
                .fill(
                    LinearGradient(
                        colors: [ClawdColors.cream, ClawdColors.terracottaLight],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 32, height: 40)
                .overlay {
                    // Clawd マーク (小さな丸模様)
                    Circle()
                        .fill(ClawdColors.terracotta.opacity(0.4))
                        .frame(width: 10, height: 10)
                        .offset(x: 3, y: 4)
                }
                .overlay {
                    Ellipse()
                        .stroke(ClawdColors.terracottaDark.opacity(0.3), lineWidth: 1)
                }

            // 発光エフェクト
            Ellipse()
                .fill(ClawdColors.terracotta.opacity(glowPulse ? 0.15 : 0.0))
                .frame(width: 44, height: 52)
        }
        .rotationEffect(.degrees(wobble ? 5 : -5))
        .onAppear {
            withAnimation(.easeInOut(duration: 0.4).repeatForever(autoreverses: true)) {
                wobble = true
            }
            withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                glowPulse = true
            }
        }
    }
}

// MARK: - あかちゃん (ちいさな blob)

private struct ClawdBabyView: View {
    var body: some View {
        ZStack {
            // 体 — 小さくて丸い blob
            Ellipse()
                .fill(
                    RadialGradient(
                        colors: [ClawdColors.terracottaLight, ClawdColors.terracotta],
                        center: .center,
                        startRadius: 2,
                        endRadius: 18
                    )
                )
                .frame(width: 30, height: 26)

            // 顔パーツ
            VStack(spacing: 3) {
                // 目 — 大きめでかわいい
                HStack(spacing: 7) {
                    ClawdEye(size: 5, highlightSize: 2)
                    ClawdEye(size: 5, highlightSize: 2)
                }

                // 口 — 小さな「ω」型
                OmegaMouth(width: 6, height: 3)
            }
            .offset(y: 1)
        }
    }
}

// MARK: - こども

private struct ClawdChildView: View {
    let isSick: Bool

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                // 体 — 少し大きくなった blob
                ClawdBlobShape()
                    .fill(blobGradient(size: 22))
                    .frame(width: 36, height: 34)

                // 顔パーツ
                VStack(spacing: 3) {
                    // 目
                    HStack(spacing: 9) {
                        ClawdEye(size: 5, highlightSize: 2, isSick: isSick)
                        ClawdEye(size: 5, highlightSize: 2, isSick: isSick)
                    }

                    // 口
                    if isSick {
                        SickMouth(width: 8)
                    } else {
                        OmegaMouth(width: 8, height: 4)
                    }
                }
                .offset(y: 2)

                // ほっぺ
                if !isSick {
                    HStack(spacing: 22) {
                        Circle()
                            .fill(ClawdColors.blush.opacity(0.5))
                            .frame(width: 6, height: 6)
                        Circle()
                            .fill(ClawdColors.blush.opacity(0.5))
                            .frame(width: 6, height: 6)
                    }
                    .offset(y: 5)
                }
            }

            // 足
            ClawdFeet(spacing: 10, footWidth: 8, footHeight: 5)
        }
    }
}

// MARK: - ヤング

private struct ClawdYoungView: View {
    let isSick: Bool

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                // 体
                ClawdBlobShape()
                    .fill(blobGradient(size: 26))
                    .frame(width: 42, height: 40)

                // 顔パーツ
                VStack(spacing: 4) {
                    // 目 — 少し大人びた
                    HStack(spacing: 11) {
                        ClawdEye(size: 5, highlightSize: 2, isSick: isSick)
                        ClawdEye(size: 5, highlightSize: 2, isSick: isSick)
                    }

                    // 口
                    if isSick {
                        SickMouth(width: 10)
                    } else {
                        SmileMouth(width: 10, height: 4)
                    }
                }
                .offset(y: 2)

                // ほっぺ
                if !isSick {
                    HStack(spacing: 28) {
                        Circle()
                            .fill(ClawdColors.blush.opacity(0.4))
                            .frame(width: 7, height: 7)
                        Circle()
                            .fill(ClawdColors.blush.opacity(0.4))
                            .frame(width: 7, height: 7)
                    }
                    .offset(y: 5)
                }
            }

            // 足
            ClawdFeet(spacing: 14, footWidth: 9, footHeight: 6)
        }
    }
}

// MARK: - おとな (完全体 Clawd)

private struct ClawdAdultView: View {
    let isSick: Bool

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                // 体 — 堂々とした blob
                ClawdBlobShape()
                    .fill(blobGradient(size: 30))
                    .frame(width: 48, height: 46)

                // 顔パーツ
                VStack(spacing: 4) {
                    // 目
                    HStack(spacing: 13) {
                        ClawdEye(size: 6, highlightSize: 2.5, isSick: isSick)
                        ClawdEye(size: 6, highlightSize: 2.5, isSick: isSick)
                    }

                    // 口
                    if isSick {
                        SickMouth(width: 12)
                    } else {
                        SmileMouth(width: 12, height: 5)
                    }
                }
                .offset(y: 3)

                // ほっぺ
                if !isSick {
                    HStack(spacing: 32) {
                        Circle()
                            .fill(ClawdColors.blush.opacity(0.35))
                            .frame(width: 8, height: 8)
                        Circle()
                            .fill(ClawdColors.blush.opacity(0.35))
                            .frame(width: 8, height: 8)
                    }
                    .offset(y: 6)
                }
            }

            // 足
            ClawdFeet(spacing: 16, footWidth: 10, footHeight: 6)
        }
    }
}

// MARK: - シニア (知恵のある Clawd)

private struct ClawdSeniorView: View {
    let isSick: Bool

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                // 体 — 少し小さくなる
                ClawdBlobShape()
                    .fill(
                        RadialGradient(
                            colors: [
                                ClawdColors.terracottaLight.opacity(0.85),
                                ClawdColors.terracotta.opacity(0.75),
                            ],
                            center: .center,
                            startRadius: 2,
                            endRadius: 28
                        )
                    )
                    .frame(width: 44, height: 42)

                // 顔パーツ
                VStack(spacing: 4) {
                    // 目 — 細め（穏やかな表情）
                    HStack(spacing: 12) {
                        if isSick {
                            ClawdEye(size: 5, highlightSize: 2, isSick: true)
                            ClawdEye(size: 5, highlightSize: 2, isSick: true)
                        } else {
                            SeniorEye()
                            SeniorEye()
                        }
                    }

                    // 口
                    if isSick {
                        SickMouth(width: 10)
                    } else {
                        SmileMouth(width: 10, height: 4)
                    }
                }
                .offset(y: 2)
            }

            // 足
            ClawdFeet(spacing: 14, footWidth: 9, footHeight: 5)
        }
    }
}

// MARK: - おわり (天使 Clawd)

private struct ClawdDeadView: View {
    @State private var floatOffset: CGFloat = 0

    var body: some View {
        ZStack {
            // 天使の輪
            Ellipse()
                .stroke(Color.yellow.opacity(0.6), lineWidth: 1.5)
                .frame(width: 22, height: 6)
                .offset(y: -24)

            // ゴースト Clawd
            ClawdBlobShape()
                .fill(Color.white.opacity(0.4))
                .frame(width: 36, height: 34)
                .overlay {
                    VStack(spacing: 3) {
                        // 目 — ×印
                        HStack(spacing: 10) {
                            Text("×").font(.system(size: 8, weight: .bold))
                                .foregroundStyle(ClawdColors.eyeColor.opacity(0.5))
                            Text("×").font(.system(size: 8, weight: .bold))
                                .foregroundStyle(ClawdColors.eyeColor.opacity(0.5))
                        }
                        // 口
                        Capsule()
                            .fill(ClawdColors.eyeColor.opacity(0.3))
                            .frame(width: 6, height: 3)
                    }
                    .offset(y: 2)
                }

            // 羽
            HStack(spacing: 30) {
                WingShape()
                    .fill(Color.white.opacity(0.3))
                    .frame(width: 10, height: 14)
                WingShape()
                    .fill(Color.white.opacity(0.3))
                    .frame(width: 10, height: 14)
                    .scaleEffect(x: -1)
            }
            .offset(y: -4)
        }
        .offset(y: floatOffset)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                floatOffset = -6
            }
        }
    }
}

// MARK: - 睡眠エフェクト

private struct SleepBubblesView: View {
    @State private var phase: CGFloat = 0

    var body: some View {
        ZStack {
            Text("z")
                .font(.system(size: 10, weight: .bold, design: .rounded))
                .foregroundStyle(ClawdColors.cream.opacity(0.7))
                .offset(x: 0, y: -phase * 8)
                .opacity(1 - phase * 0.5)
            Text("z")
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundStyle(ClawdColors.cream.opacity(0.5))
                .offset(x: 6, y: -12 - phase * 6)
                .opacity(0.8 - phase * 0.3)
            Text("Z")
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundStyle(ClawdColors.cream.opacity(0.3))
                .offset(x: 12, y: -24 - phase * 4)
                .opacity(0.6 - phase * 0.2)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                phase = 1
            }
        }
    }
}

// MARK: - 共有パーツ

/// Clawd の目
private struct ClawdEye: View {
    let size: CGFloat
    let highlightSize: CGFloat
    var isSick: Bool = false

    var body: some View {
        if isSick {
            // 病気 — うずまき目
            Circle()
                .stroke(ClawdColors.eyeColor, lineWidth: 1)
                .frame(width: size, height: size)
                .overlay {
                    Circle()
                        .fill(ClawdColors.eyeColor)
                        .frame(width: size * 0.4, height: size * 0.4)
                }
        } else {
            ZStack(alignment: .topTrailing) {
                Circle()
                    .fill(ClawdColors.eyeColor)
                    .frame(width: size, height: size)
                // ハイライト
                Circle()
                    .fill(Color.white)
                    .frame(width: highlightSize, height: highlightSize)
                    .offset(x: -highlightSize * 0.2, y: highlightSize * 0.2)
            }
        }
    }
}

/// シニアの穏やかな目（半月型）
private struct SeniorEye: View {
    var body: some View {
        Capsule()
            .fill(ClawdColors.eyeColor.opacity(0.7))
            .frame(width: 6, height: 2.5)
    }
}

/// ω型の口（あかちゃん・こども）
private struct OmegaMouth: View {
    let width: CGFloat
    let height: CGFloat

    var body: some View {
        HStack(spacing: 0) {
            Circle()
                .stroke(ClawdColors.eyeColor, lineWidth: 1)
                .frame(width: width / 2, height: height)
                .clipShape(Rectangle().offset(y: -height / 4))
            Circle()
                .stroke(ClawdColors.eyeColor, lineWidth: 1)
                .frame(width: width / 2, height: height)
                .clipShape(Rectangle().offset(y: -height / 4))
        }
        .frame(width: width, height: height / 2)
    }
}

/// にっこり口（ヤング〜おとな）
private struct SmileMouth: View {
    let width: CGFloat
    let height: CGFloat

    var body: some View {
        SmileArc()
            .stroke(ClawdColors.eyeColor, lineWidth: 1.2)
            .frame(width: width, height: height)
    }
}

/// 病気の口
private struct SickMouth: View {
    let width: CGFloat

    var body: some View {
        WavyLine()
            .stroke(ClawdColors.eyeColor.opacity(0.7), lineWidth: 1)
            .frame(width: width, height: 4)
    }
}

/// Clawd の足
private struct ClawdFeet: View {
    let spacing: CGFloat
    let footWidth: CGFloat
    let footHeight: CGFloat

    var body: some View {
        HStack(spacing: spacing) {
            Capsule()
                .fill(ClawdColors.terracottaDark)
                .frame(width: footWidth, height: footHeight)
            Capsule()
                .fill(ClawdColors.terracottaDark)
                .frame(width: footWidth, height: footHeight)
        }
    }
}

// MARK: - カスタム Shape

/// Clawd の blob 型ボディ
private struct ClawdBlobShape: Shape {
    func path(in rect: CGRect) -> Path {
        // やわらかい blob 形状 — 上が少し広く、下が少し狭い
        let w = rect.width
        let h = rect.height

        var path = Path()
        path.move(to: CGPoint(x: w * 0.5, y: 0))
        // 右上
        path.addCurve(
            to: CGPoint(x: w, y: h * 0.45),
            control1: CGPoint(x: w * 0.82, y: 0),
            control2: CGPoint(x: w, y: h * 0.15)
        )
        // 右下
        path.addCurve(
            to: CGPoint(x: w * 0.5, y: h),
            control1: CGPoint(x: w, y: h * 0.78),
            control2: CGPoint(x: w * 0.78, y: h)
        )
        // 左下
        path.addCurve(
            to: CGPoint(x: 0, y: h * 0.45),
            control1: CGPoint(x: w * 0.22, y: h),
            control2: CGPoint(x: 0, y: h * 0.78)
        )
        // 左上
        path.addCurve(
            to: CGPoint(x: w * 0.5, y: 0),
            control1: CGPoint(x: 0, y: h * 0.15),
            control2: CGPoint(x: w * 0.18, y: 0)
        )
        path.closeSubpath()
        return path
    }
}

/// にっこりアーク
private struct SmileArc: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.addArc(
            center: CGPoint(x: rect.midX, y: rect.minY),
            radius: rect.width / 2,
            startAngle: .degrees(20),
            endAngle: .degrees(160),
            clockwise: false
        )
        return path
    }
}

/// 病気のうねうね線
private struct WavyLine: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let segments = 3
        let segmentWidth = rect.width / CGFloat(segments)

        path.move(to: CGPoint(x: 0, y: rect.midY))
        for i in 0..<segments {
            let startX = CGFloat(i) * segmentWidth
            let endX = startX + segmentWidth
            let midX = (startX + endX) / 2
            let controlY = i.isMultiple(of: 2) ? rect.minY : rect.maxY
            path.addQuadCurve(
                to: CGPoint(x: endX, y: rect.midY),
                control: CGPoint(x: midX, y: controlY)
            )
        }
        return path
    }
}

/// 天使の羽
private struct WingShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.maxX, y: rect.midY))
        path.addCurve(
            to: CGPoint(x: rect.maxX, y: rect.maxY),
            control1: CGPoint(x: rect.minX, y: rect.minY),
            control2: CGPoint(x: rect.minX, y: rect.maxY)
        )
        path.closeSubpath()
        return path
    }
}

// MARK: - ユーティリティ

private func blobGradient(size: CGFloat) -> RadialGradient {
    RadialGradient(
        colors: [ClawdColors.terracottaLight, ClawdColors.terracotta],
        center: .center,
        startRadius: 2,
        endRadius: size
    )
}
