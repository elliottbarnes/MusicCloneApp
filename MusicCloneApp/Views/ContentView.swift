import SwiftUI

struct ContentView: View {
    let spotifyAPI: SpotifyAPI
    var body: some View {
        TabView {
            HomeView(spotifyAPI: spotifyAPI).tabItem { Label("Home", systemImage: "house") }
            SearchView(spotifyAPI: spotifyAPI).tabItem { Label("Search", systemImage: "magnifyingglass") }
            LibraryView().tabItem { Label("Library", systemImage: "square.stack") }
        }
        .safeAreaInset(edge: .bottom, spacing: 0) { NowPlayingBar() }
        .tint(.mint)
    }
}
