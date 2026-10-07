import Foundation
import Combine

@MainActor final class LibraryViewModel: ObservableObject {
    @Published private(set) var albums: [SpotifyAlbum] = []
    func contains(_ album: SpotifyAlbum) -> Bool { albums.contains { $0.id == album.id } }
    func toggle(_ album: SpotifyAlbum) {
        if contains(album) { albums.removeAll { $0.id == album.id } }
        else { albums.append(album) }
    }
    func reset() { albums = [] }
}
