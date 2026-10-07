import Foundation
import Combine

@MainActor final class HomeViewModel: ObservableObject {
    @Published private(set) var featured: [SpotifyAlbum] = []
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?
    private let spotifyAPI: SpotifyAPI
    init(spotifyAPI: SpotifyAPI) { self.spotifyAPI = spotifyAPI }
    func loadData() async {
        isLoading = true; errorMessage = nil
        defer { isLoading = false }
        do { featured = try await spotifyAPI.fetchNewReleases() }
        catch is CancellationError { }
        catch { featured = []; errorMessage = error.localizedDescription }
    }
}
