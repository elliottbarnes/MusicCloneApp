//
//  HomeViewModel.swift
//  MusicCloneApp
//
//  Created by Elliott Barnes on 2024-12-15.
//

import Foundation

class HomeViewModel: ObservableObject {
    @Published var featuredAlbums: [SpotifyAlbum] = []
    @Published var recommendedAlbums: [SpotifyAlbum] = []

    private let spotifyAPI: SpotifyAPI

    init(spotifyAPI: SpotifyAPI) {
        self.spotifyAPI = spotifyAPI
    }

    func loadData() async {
        do {
            let newReleases = try await spotifyAPI.fetchNewReleases()
            await MainActor.run {
                self.featuredAlbums = Array(newReleases.prefix(6))
                self.recommendedAlbums = Array(newReleases.shuffled().prefix(6))
            }
        } catch {
            print("Failed to load data: \(error)")
        }
    }
}
