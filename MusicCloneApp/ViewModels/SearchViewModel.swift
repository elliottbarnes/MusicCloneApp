//
//  SearchViewModel.swift
//  MusicCloneApp
//
//  Created by Elliott Barnes on 2024-12-15.
//

import Foundation

class SearchViewModel: ObservableObject {
    @Published var query: String = ""
    @Published var results: [SpotifyAlbum] = []

    private var task: Task<Void, Never>? = nil
    private let spotifyAPI: SpotifyAPI

    init(spotifyAPI: SpotifyAPI) {
        self.spotifyAPI = spotifyAPI
    }

    func search() {
        task?.cancel()
        guard !query.isEmpty else {
            results = []
            return
        }

        task = Task {
            try? await Task.sleep(nanoseconds: 300_000_000)
            do {
                let albums = try await spotifyAPI.searchAlbums(query: query)
                await MainActor.run {
                    results = albums
                }
            } catch {
                print("Search failed: \(error)")
            }
        }
    }
}
