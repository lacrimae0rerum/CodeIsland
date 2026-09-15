import Foundation
import CodeIslandCore

/// The unique mascot artwork bundled with CodeIsland.
enum BuiltInMascot: String, CaseIterable, Codable, Identifiable {
    case clawd
    case dex
    case grok
    case gemini
    case cursor
    case trae
    case copilot
    case qoder
    case droid
    case buddy
    case stepFun = "stepfun"
    case openCode = "opencode"
    case qwen
    case antiGravity = "antigravity"
    case workBuddy = "workbuddy"
    case hermes
    case molty
    case kiro
    case kimi
    case pi
    case cline

    var id: String { rawValue }

    /// Runtime source persisted by the existing global idle-default setting.
    var defaultSource: String {
        switch self {
        case .clawd: "claude"
        case .dex: "codex"
        case .grok: "grok"
        case .gemini: "gemini"
        case .cursor: "cursor"
        case .trae: "trae"
        case .copilot: "copilot"
        case .qoder: "qoder"
        case .droid: "droid"
        case .buddy: "codebuddy"
        case .stepFun: "stepfun"
        case .openCode: "opencode"
        case .qwen: "qwen"
        case .antiGravity: "antigravity"
        case .workBuddy: "workbuddy"
        case .hermes: "hermes"
        case .molty: "openclaw"
        case .kiro: "kiro"
        case .kimi: "kimi"
        case .pi: "pi"
        case .cline: "cline"
        }
    }

    var name: String {
        switch self {
        case .clawd: "Clawd"
        case .dex: "Dex"
        case .grok: "Grok"
        case .gemini: "Gemini"
        case .cursor: "CursorBot"
        case .trae: "TraeBot"
        case .copilot: "CopilotBot"
        case .qoder: "QoderBot"
        case .droid: "Droid"
        case .buddy: "Buddy"
        case .stepFun: "StepFun"
        case .openCode: "OpBot"
        case .qwen: "QwenBot"
        case .antiGravity: "AntiGravity"
        case .workBuddy: "WorkBuddy"
        case .hermes: "Hermes"
        case .molty: "Molty"
        case .kiro: "Kiro"
        case .kimi: "KimiBot"
        case .pi: "Pi"
        case .cline: "ClineBot"
        }
    }

    var sourceDescription: String {
        switch self {
        case .clawd: "Claude Code"
        case .dex: "Codex (OpenAI)"
        case .grok: "Grok CLI"
        case .gemini: "Gemini / Google Antigravity"
        case .cursor: "Cursor"
        case .trae: "Trae / Trae CN / Trae CLI"
        case .copilot: "GitHub Copilot"
        case .qoder: "Qoder / QoderWork"
        case .droid: "Factory"
        case .buddy: "CodeBuddy / CodyBuddyCN"
        case .stepFun: "StepFun"
        case .openCode: "OpenCode"
        case .qwen: "Qwen Code"
        case .antiGravity: "AntiGravity"
        case .workBuddy: "WorkBuddy"
        case .hermes: "Hermes"
        case .molty: "OpenClaw"
        case .kiro: "Kiro"
        case .kimi: "Kimi Code CLI"
        case .pi: "Pi / Oh My Pi"
        case .cline: "Cline"
        }
    }

    /// Preserves the existing source-driven routing when no override is assigned.
    static func automatic(for source: String) -> BuiltInMascot {
        let normalized = SessionSnapshot.normalizedSupportedSource(source)
            ?? source.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        return switch normalized {
        case "codex": .dex
        case "grok": .grok
        case "gemini", "google-antigravity": .gemini
        case "cursor", "cursor-cli": .cursor
        case "trae", "traecn", "traecli": .trae
        case "copilot": .copilot
        case "qoder", "qoder-cli", "qoderwork": .qoder
        case "droid": .droid
        case "codebuddy", "codybuddycn": .buddy
        case "stepfun": .stepFun
        case "opencode": .openCode
        case "qwen": .qwen
        case "antigravity": .antiGravity
        case "workbuddy": .workBuddy
        case "hermes": .hermes
        case "openclaw": .molty
        case "kiro": .kiro
        case "kimi": .kimi
        case "pi", "omp": .pi
        case "cline": .cline
        default: .clawd
        }
    }
}

/// Persists visual overrides without changing runtime agent identity.
struct MascotSelectionStore {
    private(set) var assignments: [String: BuiltInMascot]

    init(serializedValue: String = SettingsDefaults.mascotSelections) {
        guard let data = serializedValue.data(using: .utf8),
              let decoded = try? JSONDecoder().decode([String: String].self, from: data) else {
            assignments = [:]
            return
        }

        var sanitized: [String: BuiltInMascot] = [:]
        for (source, mascotValue) in decoded {
            guard let normalizedSource = Self.normalizedSource(source),
                  let mascot = BuiltInMascot(rawValue: mascotValue) else { continue }
            sanitized[normalizedSource] = mascot
        }
        assignments = sanitized
    }

    init(defaults: UserDefaults) {
        self.init(serializedValue: defaults.string(forKey: SettingsKey.mascotSelections)
            ?? SettingsDefaults.mascotSelections)
    }

    func selection(for source: String) -> BuiltInMascot? {
        guard let normalizedSource = Self.normalizedSource(source) else { return nil }
        return assignments[normalizedSource]
    }

    func resolvedMascot(for source: String) -> BuiltInMascot {
        selection(for: source) ?? BuiltInMascot.automatic(for: source)
    }

    mutating func setSelection(_ mascot: BuiltInMascot?, for source: String) {
        guard let normalizedSource = Self.normalizedSource(source) else { return }
        assignments[normalizedSource] = mascot
    }

    var serializedValue: String {
        let rawAssignments = assignments.mapValues(\.rawValue)
        guard let data = try? JSONEncoder.sorted.encode(rawAssignments),
              let value = String(data: data, encoding: .utf8) else {
            return SettingsDefaults.mascotSelections
        }
        return value
    }

    func persist(to defaults: UserDefaults) {
        defaults.set(serializedValue, forKey: SettingsKey.mascotSelections)
    }

    private static func normalizedSource(_ source: String) -> String? {
        SessionSnapshot.normalizedSupportedSource(source)
    }
}

private extension JSONEncoder {
    static var sorted: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        return encoder
    }
}
