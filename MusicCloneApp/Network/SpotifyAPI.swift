//
//  SpotifyAPI.swift
//  MusicCloneApp
//
//  Created by Elliott Barnes on 2024-12-15.
//

import Foundation
import Combine

class SpotifyAPI: ObservableObject {
    @Published var accessToken: String?

    func setAccessToken(_ token: String) {
        self.accessToken = token
    }

    func fetchNewReleases() async throws -> [SpotifyAlbum] {
        let url = SpotifyEndpoints.newReleases()
        let (data, _) = try await request(url: url)
        let response = try JSONDecoder().decode(NewReleasesResponse.self, from: data)
        return response.albums.items
    }

    func searchAlbums(query: String) async throws -> [SpotifyAlbum] {
        let url = SpotifyEndpoints.search(query: query)
        let (data, _) = try await request(url: url)
        let response = try JSONDecoder().decode(SearchAlbumsResponse.self, from: data)
        return response.albums.items
    }

    private func request(url: URL) async throws -> (Data, URLResponse) {
        guard let token = accessToken else {
            throw URLError(.userAuthenticationRequired)
        }

        var request = URLRequest(url: url)
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              200...299 ~= httpResponse.statusCode else {
            throw URLError(.badServerResponse)
        }

        return (data, response)
    }
}

struct NewReleasesResponse: Decodable {
    let albums: AlbumsContainer
    struct AlbumsContainer: Decodable {
        let items: [SpotifyAlbum]
    }
}

struct SearchAlbumsResponse: Decodable {
    let albums: AlbumsSearchContainer
    struct AlbumsSearchContainer: Decodable {
        let items: [SpotifyAlbum]
    }
}
