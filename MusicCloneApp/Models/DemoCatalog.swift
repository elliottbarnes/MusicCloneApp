import Foundation

/// Original fictional metadata shared with the browser example. No copyrighted recordings.
enum DemoCatalog {
    static let albums: [SpotifyAlbum] = [
        album("night", "Night Windows", "Parallel Lines"),
        album("tide", "Low Tide", "Mara Vale"),
        album("signal", "Soft Signal", "Signal Garden"),
        album("orbit", "Small Orbit", "North Arcade"),
        album("paper", "Paper Cities", "June Atlas"),
        album("blue", "Blue Hour", "Static Coast")
    ]
    private static func album(_ id: String, _ name: String, _ artist: String) -> SpotifyAlbum {
        SpotifyAlbum(id: id, name: name, images: [], artists: [SpotifyArtist(name: artist)])
    }
    static func search(_ query: String) -> [SpotifyAlbum] {
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !q.isEmpty else { return [] }
        return albums.filter { ($0.name + " " + $0.artistName).localizedCaseInsensitiveContains(q) }
    }
}
