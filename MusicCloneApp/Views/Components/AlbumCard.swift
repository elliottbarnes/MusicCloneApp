import SwiftUI

struct AlbumArtwork: View {
    let album: SpotifyAlbum
    private var colors: [Color] { [.mint, .indigo, .pink, .orange, .cyan, .purple] }
    private var color: Color { colors[album.id.utf8.reduce(0) { $0 + Int($1) } % colors.count] }
    var body: some View {
        ZStack {
            LinearGradient(colors: [color.opacity(0.9), .black], startPoint: .topLeading, endPoint: .bottomTrailing)
            Image(systemName: "opticaldisc").resizable().scaledToFit().padding(25).foregroundStyle(.white.opacity(0.65))
            if let url = album.artworkURL {
                AsyncImage(url: url) { image in image.resizable().scaledToFill() }
                    placeholder: { Color.clear }
            }
        }.aspectRatio(1, contentMode: .fit).clipShape(.rect(cornerRadius: 12))
            .accessibilityHidden(true)
    }
}

struct AlbumCard: View {
    let album: SpotifyAlbum
    @EnvironmentObject private var player: PlayerViewModel
    @EnvironmentObject private var library: LibraryViewModel
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Button { player.play(track: album.previewTrack) } label: {
                VStack(alignment: .leading, spacing: 8) {
                    AlbumArtwork(album: album)
                    Text(album.name).font(.headline).lineLimit(2)
                    Text(album.artistName).font(.caption).foregroundStyle(.secondary).lineLimit(2)
                }
            }.buttonStyle(.plain).accessibilityLabel("Preview \(album.name) by \(album.artistName)")
            Button(library.contains(album) ? "Saved" : "Save", systemImage: library.contains(album) ? "checkmark" : "plus") { library.toggle(album) }
                .accessibilityLabel("\(library.contains(album) ? "Remove" : "Save") \(album.name)")
        }
    }
}
