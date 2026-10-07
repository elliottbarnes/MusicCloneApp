import Foundation
import Combine

@MainActor final class SearchViewModel: ObservableObject {
    @Published var query = ""
    @Published private(set) var results: [SpotifyAlbum] = []
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?
    private let spotifyAPI: SpotifyAPI
    init(spotifyAPI: SpotifyAPI) { self.spotifyAPI = spotifyAPI }
    // SwiftUI .task(id:) cancels the previous query. Check cancellation after every await.
    func search() async {
        let requested = query.trimmingCharacters(in: .whitespacesAndNewlines)
        results = []; errorMessage = nil; isLoading = !requested.isEmpty
        guard !requested.isEmpty else { return }
        do {
            try await Task.sleep(for: .milliseconds(250))
            let albums = try await spotifyAPI.searchAlbums(query: requested)
            try Task.checkCancellation()
            guard query.trimmingCharacters(in: .whitespacesAndNewlines) == requested else { return }
            results = albums; isLoading = false
        } catch is CancellationError { }
        catch {
            guard !Task.isCancelled else { return }
            errorMessage = error.localizedDescription; isLoading = false
        }
    }
}
