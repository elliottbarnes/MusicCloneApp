import SwiftUI

struct AuthView: View {
    @ObservedObject var authViewModel: AuthViewModel
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "waveform").font(.system(size: 60)).foregroundStyle(.mint)
            Text("Music, in miniature.").font(.largeTitle.bold())
            Text("Explore six fictional albums, search by artist, save a collection, and try the player controls.")
                .multilineTextAlignment(.center).foregroundStyle(.secondary)
            Button("Try offline demo") { authViewModel.startDemo() }.buttonStyle(.borderedProminent).tint(.mint)
            Text("Playback is simulated. No recordings or account required.").font(.caption)
            if authViewModel.isConfigured {
                Button("Connect Spotify catalog") { authViewModel.authorize() }.disabled(authViewModel.isLoading)
            }
            if let error = authViewModel.errorMessage { Text(error).foregroundStyle(.orange) }
        }.padding(32).frame(maxWidth: 520).frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
