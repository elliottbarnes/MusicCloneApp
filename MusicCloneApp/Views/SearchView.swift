import SwiftUI

struct SearchView: View {
    @StateObject private var viewModel: SearchViewModel
    init(spotifyAPI: SpotifyAPI) {
        _viewModel = StateObject(wrappedValue: SearchViewModel(spotifyAPI: spotifyAPI))
    }
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                TextField("Search albums or artists", text: $viewModel.query)
                    .textFieldStyle(.roundedBorder).padding(.horizontal)
                    .accessibilityIdentifier("albumSearch")
                if viewModel.isLoading { ProgressView("Searching") }
                if let error = viewModel.errorMessage { Text(error).foregroundStyle(.orange) }
                if !viewModel.isLoading && viewModel.results.isEmpty {
                    ContentUnavailableView(viewModel.query.isEmpty ? "Find an album" : "No matching albums",
                        systemImage: "magnifyingglass", description: Text("Try a title or artist name."))
                } else {
                    List(viewModel.results) { album in AlbumRow(album: album) }
                }
            }.navigationTitle("Search")
        }.task(id: viewModel.query) { await viewModel.search() }
    }
}
