import SwiftUI

@main struct MusicCloneAppApp: App {
    @StateObject private var spotifyAPI: SpotifyAPI
    @StateObject private var authVM: AuthViewModel
    @StateObject private var player = PlayerViewModel()
    @StateObject private var library = LibraryViewModel()
    init() {
        let api = SpotifyAPI()
        _spotifyAPI = StateObject(wrappedValue: api)
        _authVM = StateObject(wrappedValue: AuthViewModel(spotifyAPI: api,
            clientID: Bundle.main.object(forInfoDictionaryKey: "SpotifyClientID") as? String ?? "",
            redirectURI: Bundle.main.object(forInfoDictionaryKey: "SpotifyRedirectURI") as? String ?? ""))
    }
    var body: some Scene {
        WindowGroup {
            Group {
                if authVM.isAuthorized {
                    VStack(spacing: 0) {
                        HStack {
                            Text(spotifyAPI.isDemo ? "OFFLINE DEMO" : "SPOTIFY CATALOG").font(.caption.monospaced())
                            Spacer()
                            Button("End session") { player.reset(); library.reset(); authVM.signOut() }
                        }.padding(.horizontal).padding(.vertical, 8)
                        ContentView(spotifyAPI: spotifyAPI)
                    }
                } else { AuthView(authViewModel: authVM) }
            }.environmentObject(player).environmentObject(library)
                .preferredColorScheme(.dark)
        }
    }
}
