import Foundation
import Combine

/// Playback UI state only. No audio is streamed or decoded.
@MainActor final class PlayerViewModel: ObservableObject {
    @Published private(set) var currentTrack: SpotifyTrack?
    @Published private(set) var isPlaying = false
    @Published private(set) var progress = 0.0
    func play(track: SpotifyTrack) {
        currentTrack = track
        progress = 0
        isPlaying = track.duration > 0
    }
    func togglePlayPause() {
        guard let track = currentTrack, track.duration > 0 else { return }
        if progress >= 1 { progress = 0 }
        isPlaying.toggle()
    }
    func seek(to value: Double) {
        guard currentTrack != nil, value.isFinite else { return }
        progress = min(1, max(0, value))
        if progress == 1 { isPlaying = false }
    }
    func advance(seconds: Double) {
        guard isPlaying, let track = currentTrack, track.duration > 0,
              seconds.isFinite, seconds > 0 else { return }
        seek(to: progress + seconds / track.duration)
    }
    func reset() { currentTrack = nil; isPlaying = false; progress = 0 }
}
