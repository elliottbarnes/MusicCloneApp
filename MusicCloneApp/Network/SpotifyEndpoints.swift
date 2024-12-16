//
//  SpotifyEndpoints.swift
//  MusicCloneApp
//
//  Created by Elliott Barnes on 2024-12-15.
//

import Foundation

enum SpotifyEndpoints {
    static let baseURL = URL(string: "https://api.spotify.com/v1")!
    
    static func newReleases() -> URL {
        return baseURL.appendingPathComponent("browse/new-releases")
    }

    static func search(query: String) -> URL {
        var components = URLComponents(url: baseURL.appendingPathComponent("search"), resolvingAgainstBaseURL: false)!
        components.queryItems = [
            URLQueryItem(name: "q", value: query),
            URLQueryItem(name: "type", value: "album"),
            URLQueryItem(name: "limit", value: "20")
        ]
        return components.url!
    }
}
