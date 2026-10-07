import SwiftUI

struct ContentView: View {
    let spotifyAPI: SpotifyAPI
    @State private var selectedTab = 0
    var body: some View {
        VStack(spacing: 0) {
            TabView(selection: $selectedTab) {
                HomeView(spotifyAPI: spotifyAPI).tabItem { Label("Home", systemImage: "house") }.tag(0)
                SearchView(spotifyAPI: spotifyAPI).tabItem { Label("Search", systemImage: "magnifyingglass") }.tag(1)
                LibraryView().tabItem { Label("Library", systemImage: "square.stack") }.tag(2)
            }.frame(maxHeight: .infinity)
            NowPlayingBar()
        }.tint(.mint)
    }
}
