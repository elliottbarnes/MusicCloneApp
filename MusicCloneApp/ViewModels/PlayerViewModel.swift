//
//  PlayerViewModel.swift
//  MusicCloneApp
//
//  Created by Elliott Barnes on 2024-12-15.
//

import Foundation

class PlayerViewModel: ObservableObject {
    @Published var currentTrack: SpotifyTrack? = nil
    @Published var isPlaying: Bool = false
    @Published var progress: Double = 0.0

    func play(track: SpotifyTrack) {
        currentTrack = track
        isPlaying = true
        progress = 0.0
        // In a real app, start playback logic here.
    }

    func togglePlayPause() {
        isPlaying.toggle()
    }

    func seek(to value: Double) {
        progress = value
    }
}
