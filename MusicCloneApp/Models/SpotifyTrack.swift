//
//  SpotifyTrack.swift
//  MusicCloneApp
//
//  Created by Elliott Barnes on 2024-12-15.
//

//
//  SpotifyTrack.swift
//  MusicCloneApp
//
//  Created by Elliott Barnes on 2024-12-15.
//

import Foundation

struct SpotifyTrack: Identifiable, Decodable {
    let id: String
    let name: String
    let artists: [SpotifyArtist]
    let duration_ms: Int

    var duration: TimeInterval {
        Double(duration_ms) / 1000.0
    }

    var artistName: String {
        artists.map { $0.name }.joined(separator: ", ")
    }
}
