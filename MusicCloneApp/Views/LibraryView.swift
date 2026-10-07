import SwiftUI

struct LibraryView: View {
    @EnvironmentObject private var library: LibraryViewModel
    var body: some View {
        NavigationStack {
            Group {
                if library.albums.isEmpty {
                    ContentUnavailableView("Your collection starts here", systemImage: "square.stack",
                        description: Text("Save an album from Home or Search. This library lasts for this session."))
                } else { List(library.albums) { album in AlbumRow(album: album) } }
            }.navigationTitle("Library")
        }
    }
}
