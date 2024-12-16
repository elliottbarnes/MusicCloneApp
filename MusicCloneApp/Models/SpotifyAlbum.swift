//
//  SpotifyAlbum.swift
//  MusicCloneApp
//
//  Created by Elliott Barnes on 2024-12-15.
//

import Foundation

struct SpotifyAlbum: Identifiable, Decodable {
    let id: String
    let name: String
    let images: [SpotifyImage]
    let artists: [SpotifyArtist]

    var artistName: String {
        artists.map { $0.name }.joined(separator: ", ")
    }

    var artworkURL: URL? {
        images.first?.url
    }
}

struct SpotifyArtist: Decodable {
    let name: String
}

struct SpotifyImage: Decodable {
    let url: URL
    let height: Int?
    let width: Int?
}
