import XCTest
@testable import MusicCloneApp

final class MusicCloneAppTests: XCTestCase {
    @MainActor func testOfflineSessionLoadsCatalogAndSharesLibraryState() async throws {
        let api = SpotifyAPI(); api.useDemo()
        let home = HomeViewModel(spotifyAPI: api); await home.loadData()
        XCTAssertEqual(home.featured.count, 6)
        let library = LibraryViewModel(); library.toggle(home.featured[0])
        XCTAssertTrue(library.contains(home.featured[0]))
        let player = PlayerViewModel(); player.play(track: home.featured[0].previewTrack)
        player.advance(seconds: 180)
        XCTAssertFalse(player.isPlaying); XCTAssertEqual(player.progress, 1)
    }
}
