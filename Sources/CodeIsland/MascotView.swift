import SwiftUI

// MARK: - Mascot Animation Speed Environment

private struct MascotSpeedKey: EnvironmentKey {
    static let defaultValue: Double = 1.0
}

extension EnvironmentValues {
    var mascotSpeed: Double {
        get { self[MascotSpeedKey.self] }
        set { self[MascotSpeedKey.self] = newValue }
    }
}

/// Applies animation preferences and gating to one canonical built-in mascot.
struct MascotView: View {
    let mascot: BuiltInMascot
    let status: MascotAgentStatus
    let size: CGFloat
    @AppStorage(SettingsKey.mascotSpeed) private var speedPct = SettingsDefaults.mascotSpeed
    @ObservedObject private var animationGate = MascotAnimationGate.shared

    init(mascot: BuiltInMascot, status: MascotAgentStatus, size: CGFloat = 27) {
        self.mascot = mascot
        self.status = status
        self.size = size
    }

    init(source: String, status: MascotAgentStatus, size: CGFloat = 27) {
        self.init(mascot: .automatic(for: source), status: status, size: size)
    }

    var body: some View {
        MascotArtworkView(mascot: mascot, status: status, size: size)
        .environment(\.mascotSpeed, Double(speedPct) / 100.0)
        .environment(\.mascotAnimationsActive, animationGate.animationsActive)
        .environment(\.mascotAnimationEpoch, animationGate.epoch)
    }
}

/// Direct artwork routing used by the live view and deterministic render harness.
struct MascotArtworkView: View {
    let mascot: BuiltInMascot
    let status: MascotAgentStatus
    let size: CGFloat

    @ViewBuilder
    var body: some View {
        switch mascot {
        case .clawd: ClawdView(status: status, size: size)
        case .dex: DexView(status: status, size: size)
        case .grok: GrokView(status: status, size: size)
        case .gemini: GeminiView(status: status, size: size)
        case .cursor: CursorView(status: status, size: size)
        case .trae: TraeView(status: status, size: size)
        case .copilot: CopilotView(status: status, size: size)
        case .qoder: QoderView(status: status, size: size)
        case .droid: DroidView(status: status, size: size)
        case .buddy: BuddyView(status: status, size: size)
        case .stepFun: StepFunView(status: status, size: size)
        case .openCode: OpenCodeView(status: status, size: size)
        case .qwen: QwenView(status: status, size: size)
        case .antiGravity: AntiGravityView(status: status, size: size)
        case .workBuddy: WorkBuddyView(status: status, size: size)
        case .hermes: HermesView(status: status, size: size)
        case .molty: OpenClawView(status: status, size: size)
        case .kiro: KiroView(status: status, size: size)
        case .kimi: KimiView(status: status, size: size)
        case .pi: PiView(status: status, size: size)
        case .cline: ClineView(status: status, size: size)
        }
    }
}
