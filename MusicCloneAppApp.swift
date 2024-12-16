//
//  MusicCloneAppApp.swift
//  MusicCloneApp
//
//  Created by Elliott Barnes on 2024-12-15.
//


//
//  MusicCloneAppApp.swift
//  MusicCloneApp
//
//  Created by Elliott Barnes on 2024-12-15.
//
import SwiftUI

@main
struct MusicCloneAppApp: App {
    @StateObject var spotifyAPI: SpotifyAPI
    @StateObject var authVM: AuthViewModel
    @StateObject var playerVM = PlayerViewModel()

    init() {
        let api = SpotifyAPI()
        _spotifyAPI = StateObject(wrappedValue: api)
        _authVM = StateObject(wrappedValue: AuthViewModel(
            spotifyAPI: api,
            clientID: "YOUR_CLIENT_ID",
            redirectURI: "myapp://spotify/callback"
        ))
    }

    var body: some Scene {
        WindowGroup {
            if authVM.isAuthorized {
                ContentView()
                    .environmentObject(playerVM)
                    .environmentObject(spotifyAPI)
            } else {
                AuthView(authVM: authVM)
            }
        }
    }
}
