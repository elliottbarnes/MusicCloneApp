import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel: HomeViewModel
    let spotifyAPI: SpotifyAPI
    init(spotifyAPI: SpotifyAPI) {
        self.spotifyAPI = spotifyAPI
        _viewModel = StateObject(wrappedValue: HomeViewModel(spotifyAPI: spotifyAPI))
    }
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text(spotifyAPI.isDemo ? "A small collection.\nA little discovery." : "New releases")
                        .font(.largeTitle.bold())
                    Text(spotifyAPI.isDemo ? "Fictional albums · playback simulation · session-only library" : "Spotify catalog · playback simulation")
                        .font(.caption).foregroundStyle(.secondary)
                    if viewModel.isLoading { ProgressView("Loading albums") }
                    if let error = viewModel.errorMessage {
                        Text(error).foregroundStyle(.orange)
                        Button("Retry") { Task { await viewModel.loadData() } }
                    }
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))], spacing: 24) {
                        ForEach(viewModel.featured) { album in AlbumCard(album: album) }
                    }
                }.padding(24)
            }.navigationTitle("Discover")
        }.task { await viewModel.loadData() }
    }
}
