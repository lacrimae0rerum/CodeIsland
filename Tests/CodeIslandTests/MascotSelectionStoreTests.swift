import XCTest
@testable import CodeIsland
import CodeIslandCore

final class MascotSelectionStoreTests: XCTestCase {
    private var defaults: UserDefaults!
    private var suiteName: String!

    override func setUp() {
        super.setUp()
        suiteName = "MascotSelectionStoreTests.\(UUID().uuidString)"
        defaults = UserDefaults(suiteName: suiteName)
        defaults.removePersistentDomain(forName: suiteName)
        UserDefaults.standard.removeObject(forKey: SessionSnapshot.customCLIConfigsKey)
    }

    override func tearDown() {
        defaults.removePersistentDomain(forName: suiteName)
        UserDefaults.standard.removeObject(forKey: SessionSnapshot.customCLIConfigsKey)
        defaults = nil
        suiteName = nil
        super.tearDown()
    }

    func testOverrideResolvesAssignedBuiltInMascot() {
        var store = MascotSelectionStore()

        store.setSelection(.dex, for: "claude")

        XCTAssertEqual(store.selection(for: "claude"), .dex)
        XCTAssertEqual(store.resolvedMascot(for: "claude"), .dex)
    }

    func testAutomaticPreservesExistingSourceDrivenRouting() {
        let expected: [String: BuiltInMascot] = [
            "claude": .clawd,
            "codex": .dex,
            "grok": .grok,
            "gemini": .gemini,
            "google-antigravity": .gemini,
            "cursor-cli": .cursor,
            "traecn": .trae,
            "copilot": .copilot,
            "qoderwork": .qoder,
            "droid": .droid,
            "codybuddycn": .buddy,
            "stepfun": .stepFun,
            "opencode": .openCode,
            "qwen": .qwen,
            "antigravity": .antiGravity,
            "workbuddy": .workBuddy,
            "hermes": .hermes,
            "openclaw": .molty,
            "kiro": .kiro,
            "kimi": .kimi,
            "pi": .pi,
            "cline": .cline,
            "zcode": .clawd,
        ]

        for (source, mascot) in expected {
            XCTAssertEqual(BuiltInMascot.automatic(for: source), mascot, source)
        }
    }

    func testSourcesKeepIndependentAssignments() {
        var store = MascotSelectionStore()

        store.setSelection(.dex, for: "claude")
        store.setSelection(.clawd, for: "codex")

        XCTAssertEqual(store.resolvedMascot(for: "claude"), .dex)
        XCTAssertEqual(store.resolvedMascot(for: "codex"), .clawd)
    }

    func testAliasesShareTheCanonicalSourceAssignment() {
        var store = MascotSelectionStore()

        store.setSelection(.gemini, for: " Factory ")

        XCTAssertEqual(store.selection(for: "factory"), .gemini)
        XCTAssertEqual(store.selection(for: "droid"), .gemini)
    }

    func testPersistenceReconstructsSelections() {
        var store = MascotSelectionStore()
        store.setSelection(.cursor, for: "claude")
        store.setSelection(.hermes, for: "codex")
        store.persist(to: defaults)

        let reconstructed = MascotSelectionStore(defaults: defaults)

        XCTAssertEqual(reconstructed.selection(for: "claude"), .cursor)
        XCTAssertEqual(reconstructed.selection(for: "codex"), .hermes)
    }

    func testClearingRestoresAutomaticSourceDrivenMascot() {
        var store = MascotSelectionStore()
        store.setSelection(.dex, for: "claude")

        store.setSelection(nil, for: "claude")

        XCTAssertNil(store.selection(for: "claude"))
        XCTAssertEqual(store.resolvedMascot(for: "claude"), .clawd)
    }

    func testInvalidAndRemovedMascotValuesFallBackToAutomatic() {
        defaults.set(#"{"claude":"removed-mascot","codex":"dex"}"#, forKey: SettingsKey.mascotSelections)

        let store = MascotSelectionStore(defaults: defaults)

        XCTAssertNil(store.selection(for: "claude"))
        XCTAssertEqual(store.resolvedMascot(for: "claude"), .clawd)
        XCTAssertEqual(store.resolvedMascot(for: "codex"), .dex)
    }

    func testDynamicallyConfiguredSourceCanBeAssigned() throws {
        let config: [[String: Any]] = [["source": "my-agent", "name": "My Agent"]]
        let data = try JSONSerialization.data(withJSONObject: config)
        UserDefaults.standard.set(data, forKey: SessionSnapshot.customCLIConfigsKey)
        var store = MascotSelectionStore()

        store.setSelection(.workBuddy, for: "MY-AGENT")

        XCTAssertEqual(store.selection(for: "my-agent"), .workBuddy)
        XCTAssertEqual(store.resolvedMascot(for: "my-agent"), .workBuddy)
    }

    func testUnknownSourceCannotCreateAnOrphanedAssignment() {
        var store = MascotSelectionStore()

        store.setSelection(.dex, for: "not-configured")

        XCTAssertNil(store.selection(for: "not-configured"))
        XCTAssertEqual(store.resolvedMascot(for: "not-configured"), .clawd)
    }
}
