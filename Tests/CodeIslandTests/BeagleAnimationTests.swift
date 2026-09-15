import XCTest
@testable import CodeIsland

final class BeagleAnimationTests: XCTestCase {
    func testCalmAndWaitingStatusesUseDistinctStableFrames() {
        let idleFrames = [0.0, 1.0, 60.0].map { BeagleAnimation.frameIndex(for: .idle, at: $0) }
        let approvalFrames = [0.0, 1.0, 60.0].map { BeagleAnimation.frameIndex(for: .waitingApproval, at: $0) }
        let questionFrames = [0.0, 1.0, 60.0].map { BeagleAnimation.frameIndex(for: .waitingQuestion, at: $0) }

        XCTAssertEqual(Set(idleFrames).count, 1)
        XCTAssertEqual(Set(approvalFrames).count, 1)
        XCTAssertEqual(Set(questionFrames).count, 1)
        XCTAssertEqual(Set([idleFrames[0], approvalFrames[0], questionFrames[0]]).count, 3)
    }

    func testWorkStatusesAdvanceThroughSafeGallopFrames() {
        for status in [MascotAgentStatus.processing, .running] {
            XCTAssertTrue(BeagleAnimation.isAnimated(status))
            let sampledFrames = stride(from: 0.0, through: 2.0, by: 0.1)
                .map { BeagleAnimation.frameIndex(for: status, at: $0) }

            XCTAssertGreaterThan(Set(sampledFrames).count, 1)
            XCTAssertTrue(sampledFrames.allSatisfy { 0..<BeagleAnimation.frameCount ~= $0 })
        }

        XCTAssertNotEqual(
            BeagleAnimation.frameIndex(for: .processing, at: 0.1),
            BeagleAnimation.frameIndex(for: .running, at: 0.1),
            "running should advance faster than processing"
        )
    }

    func testAllBundledFramesLoadAtTheSourceCanvasSize() {
        XCTAssertEqual(BeagleAssets.frameSizes, Array(repeating: CGSize(width: 60, height: 36), count: 9))
    }
}
