import SwiftUI

struct AudioVisualizer: View {
    let audioMeter: AudioMeter
    let color: Color
    let isActive: Bool

    private let barCount = 15
    private let barWidth: CGFloat = 3
    private let barSpacing: CGFloat = 2
    private let minHeight: CGFloat = 3
    private let maxHeight: CGFloat = 28

    private let phases: [Double]

    @State private var heights: [CGFloat]
    @State private var envelope: Double = 0
    @State private var gateOpen: Bool = false

    init(audioMeter: AudioMeter, color: Color, isActive: Bool) {
        self.audioMeter = audioMeter
        self.color = color
        self.isActive = isActive

        // Create smooth wave phases
        self.phases = (0..<barCount).map { Double($0) * 0.4 }
        _heights = State(initialValue: Array(repeating: minHeight, count: barCount))
    }

    var body: some View {
        HStack(spacing: barSpacing) {
            ForEach(0..<barCount, id: \.self) { index in
                RoundedRectangle(cornerRadius: barWidth / 2)
                    .fill(color)
                    .frame(width: barWidth, height: heights[index])
            }
        }
        .onChange(of: audioMeter) { _, newValue in
            // Only update when active - completely stop processing when fading out
            // This prevents frame drops during opacity transitions
            guard isActive else { return }
            updateWave(level: newValue.averagePower)
        }
    }

    private func updateWave(level: Double) {
        let time = Date().timeIntervalSince1970
        let amplitude = max(0, min(1, level))

        // Gate with hysteresis - different open/close thresholds prevent flicker
        let openThreshold: Double = 0.25   // Must exceed this to open
        let closeThreshold: Double = 0.12  // Must fall below this to close

        // Update gate state with hysteresis
        if amplitude > openThreshold {
            gateOpen = true
        } else if amplitude < closeThreshold {
            gateOpen = false
        }
        // Between thresholds: maintain current state

        let gated: Double = gateOpen ? amplitude : 0

        // Envelope follower on gated signal - graceful fade without noise
        let attackCoef: Double = 0.6    // Fast attack
        let releaseCoef: Double = 0.6   // Very quick release

        if gated > envelope {
            envelope = envelope + (gated - envelope) * attackCoef
        } else {
            envelope = envelope + (gated - envelope) * releaseCoef
        }

        // Boost for visibility
        let boosted = pow(envelope, 0.7)

        for i in 0..<barCount {
            let wave = sin(time * 8 + phases[i]) * 0.5 + 0.5
            let centerDistance = abs(Double(i) - Double(barCount) / 2) / Double(barCount / 2)
            let centerBoost = 1.0 - (centerDistance * 0.4)

            let height = minHeight + CGFloat(boosted * wave * centerBoost) * (maxHeight - minHeight)
            heights[i] = max(minHeight, height)
        }
    }

}

struct StaticVisualizer: View {
    // Match AudioVisualizer dimensions
    private let barCount = 15
    private let barWidth: CGFloat = 3
    private let staticHeight: CGFloat = 3
    private let barSpacing: CGFloat = 2
    let color: Color

    var body: some View {
        HStack(spacing: barSpacing) {
            ForEach(0..<barCount, id: \.self) { _ in
                RoundedRectangle(cornerRadius: barWidth / 2)
                    .fill(color)
                    .frame(width: barWidth, height: staticHeight)
            }
        }
    }
}

// MARK: - Processing Status Display (Transcribing/Enhancing states)
struct ProcessingStatusDisplay: View {
    enum Mode {
        case transcribing
        case enhancing
    }

    let mode: Mode
    let color: Color

    private var label: String {
        switch mode {
        case .transcribing:
            return "Transcribing"
        case .enhancing:
            return "Enhancing"
        }
    }

    private var animationSpeed: Double {
        switch mode {
        case .transcribing:
            return 0.18
        case .enhancing:
            return 0.22
        }
    }

    var body: some View {
        VStack(spacing: 4) {
            Text(label)
                .foregroundColor(color)
                .font(.system(size: 11, weight: .medium))
                .lineLimit(1)
                .minimumScaleFactor(0.5)

            ProgressAnimation(color: color, animationSpeed: animationSpeed)
        }
        .frame(height: 28) // Match AudioVisualizer maxHeight for no layout shift
    }
}
