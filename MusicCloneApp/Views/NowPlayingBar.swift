import SwiftUI

struct NowPlayingBar: View {
    @EnvironmentObject private var player: PlayerViewModel
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                VStack(alignment: .leading) {
                    Text(player.currentTrack?.name ?? "Choose an album").font(.headline)
                    Text("Playback simulation · no audio").font(.caption).foregroundStyle(.secondary)
                }
                Spacer()
                Button { player.togglePlayPause() } label: {
                    Image(systemName: player.isPlaying ? "pause.fill" : "play.fill").padding(8)
                }.disabled(player.currentTrack == nil)
                    .accessibilityLabel(player.isPlaying ? "Pause preview" : "Play preview")
            }
            Slider(value: Binding(get: { player.progress }, set: { player.seek(to: $0) }), in: 0...1)
                .disabled(player.currentTrack == nil).accessibilityLabel("Preview progress")
        }.padding().background(.regularMaterial)
        .task {
            // Monotonic elapsed time; pause stops advancement and leaving the view cancels the task.
            let clock = ContinuousClock()
            var previous = clock.now
            while !Task.isCancelled {
                do { try await Task.sleep(for: .milliseconds(250)) } catch { return }
                let now = clock.now
                let delta = previous.duration(to: now).components
                player.advance(seconds: Double(delta.seconds) + Double(delta.attoseconds) / 1e18)
                previous = now
            }
        }
    }
}
