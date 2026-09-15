import AppKit
import SwiftUI

/// Status presentation for the supplied nine-frame Beagle gallop cycle.
/// The source archive contains no state-specific artwork, so calm and waiting
/// states deliberately hold deterministic frames from the same cycle.
enum BeagleAnimation {
    static let frameCount = 9

    static func isAnimated(_ status: MascotAgentStatus) -> Bool {
        frameInterval(for: status) != nil
    }

    static func frameIndex(for status: MascotAgentStatus, at time: Double) -> Int {
        switch status {
        case .idle:
            return 6
        case .waitingApproval:
            return 8
        case .waitingQuestion:
            return 5
        case .processing, .running:
            guard let interval = frameInterval(for: status), time.isFinite else { return 0 }
            return Int((max(0, time) / interval).rounded(.down)) % frameCount
        }
    }

    static func frameInterval(for status: MascotAgentStatus) -> TimeInterval? {
        switch status {
        case .processing: 0.12
        case .running: 0.08
        case .idle, .waitingApproval, .waitingQuestion: nil
        }
    }
}

enum BeagleAssets {
    private static let frames: [NSImage?] = (0..<BeagleAnimation.frameCount).map { index in
        guard let url = Bundle.appModule.url(
            forResource: "beagle-frame-\(index)",
            withExtension: "png",
            subdirectory: "Resources/mascots/beagle"
        ) else { return nil }
        return NSImage(contentsOf: url)
    }

    static var frameSizes: [CGSize] {
        frames.compactMap(\.self).map(\.size)
    }

    static func image(at index: Int) -> NSImage? {
        guard frames.indices.contains(index) else { return nil }
        return frames[index]
    }
}

struct BeagleView: View {
    let status: MascotAgentStatus
    var size: CGFloat = 27

    @ViewBuilder
    var body: some View {
        if let interval = BeagleAnimation.frameInterval(for: status) {
            MascotTimeline(interval: interval) { time in
                frame(at: BeagleAnimation.frameIndex(for: status, at: time))
            }
        } else {
            frame(at: BeagleAnimation.frameIndex(for: status, at: 0))
        }
    }

    private func frame(at index: Int) -> some View {
        Group {
            if let image = BeagleAssets.image(at: index) {
                Image(nsImage: image)
                    .renderingMode(.template)
                    .resizable()
                    .interpolation(.none)
                    .scaledToFit()
                    .foregroundStyle(.white)
            } else {
                Color.clear
            }
        }
        .frame(width: size, height: size)
        .accessibilityHidden(true)
    }
}
