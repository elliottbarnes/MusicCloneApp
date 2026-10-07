import SwiftUI

struct AlbumRow: View {
    let album: SpotifyAlbum
    @EnvironmentObject private var player: PlayerViewModel
    @EnvironmentObject private var library: LibraryViewModel
    var body: some View {
        HStack(spacing: 14) {
            Button { player.play(track: album.previewTrack) } label: {
                HStack {
                    AlbumArtwork(album: album).frame(width: 56, height: 56)
                    VStack(alignment: .leading) {
                        Text(album.name).font(.headline)
                        Text(album.artistName).font(.caption).foregroundStyle(.secondary)
                    }
                }
            }.buttonStyle(.borderless).accessibilityLabel("Preview \(album.name)")
            Spacer()
            Button { library.toggle(album) } label: {
                Image(systemName: library.contains(album) ? "checkmark.circle.fill" : "plus.circle")
            }.buttonStyle(.borderless).accessibilityLabel("\(library.contains(album) ? "Remove" : "Save") \(album.name)")
        }
    }
}
