import XCTest
@testable import MusicCloneCore

final class CoreTests: XCTestCase {
    func testPKCEKnownRFC7636Vector() {
        XCTAssertEqual(OAuth.challenge("dBjftJeZ4CVP-mB92K27uhbUJU1p1r_wW1gFWFOEjXk"),
            "E9Melhoa2OwvFrEMTJguCHaoeK1t8URWbuGJSstw-cM")
    }
    func testFormEncodingPreservesReservedCharacters() {
        XCTAssertEqual(String(data: OAuth.form(["code":"a+b&c=d", "redirect_uri":"https://example.com/cb"]), encoding: .utf8),
            "code=a%2Bb%26c%3Dd&redirect_uri=https%3A%2F%2Fexample.com%2Fcb")
    }
    func testCallbackRejectsWrongStateOriginAndDuplicateParameters() throws {
        let redirect = URL(string: "https://example.com/callback")!
        XCTAssertEqual(try OAuth.callbackCode(URL(string: "https://example.com/callback?code=ok&state=nonce")!, redirect: redirect, state: "nonce"), "ok")
        for url in ["https://evil.com/callback?code=ok&state=nonce", "https://example.com/other?code=ok&state=nonce",
            "https://example.com/callback?code=ok&state=wrong", "https://example.com/callback?code=ok&code=bad&state=nonce",
            "https://example.com/callback?code=ok&state=nonce&state=nonce", "https://example.com/callback?code=ok&state=nonce&error=denied",
            "http://example.com/callback?code=ok&state=nonce", "https://example.com/callback?code=ok&state=nonce#fragment"] {
            XCTAssertThrowsError(try OAuth.callbackCode(URL(string: url)!, redirect: redirect, state: "nonce"))
        }
    }
    func testCatalogUsesDistinctStableTrackIDsAndSearchesArtists() {
        XCTAssertEqual(Set(DemoCatalog.albums.map { $0.previewTrack.id }).count, 6)
        XCTAssertEqual(DemoCatalog.search("  MARA  ").map(\.id), ["tide"])
        XCTAssertTrue(DemoCatalog.search(" ").isEmpty)
        XCTAssertTrue(DemoCatalog.search("no such album").isEmpty)
    }
    @MainActor func testPlayerCannotPlayNothingOrSeekToNonfiniteValues() async {
        let player = PlayerViewModel()
        player.togglePlayPause(); XCTAssertFalse(player.isPlaying)
        player.play(track: DemoCatalog.albums[0].previewTrack)
        player.seek(to: 0.5); player.seek(to: .nan)
        XCTAssertEqual(player.progress, 0.5)
        player.seek(to: -2); XCTAssertEqual(player.progress, 0)
        player.advance(seconds: 180); XCTAssertEqual(player.progress, 1); XCTAssertFalse(player.isPlaying)
        player.togglePlayPause(); XCTAssertEqual(player.progress, 0); XCTAssertTrue(player.isPlaying)
        player.togglePlayPause(); player.advance(seconds: 60); XCTAssertEqual(player.progress, 0)
    }
    @MainActor func testLibraryToggleAndReset() async {
        let library = LibraryViewModel(), album = DemoCatalog.albums[0]
        library.toggle(album); XCTAssertEqual(library.albums.count, 1)
        library.toggle(album); XCTAssertTrue(library.albums.isEmpty)
        library.toggle(album); library.reset(); XCTAssertTrue(library.albums.isEmpty)
    }
    @MainActor func testHomeAndSearchUseInjectedOfflineAPI() async {
        let api = SpotifyAPI(); api.useDemo()
        let home = HomeViewModel(spotifyAPI: api)
        await home.loadData(); XCTAssertEqual(home.featured.count, 6); XCTAssertNil(home.errorMessage)
        let search = SearchViewModel(spotifyAPI: api); search.query = "Mara"
        await search.search(); XCTAssertEqual(search.results.map(\.id), ["tide"])
        search.query = " "; await search.search(); XCTAssertTrue(search.results.isEmpty); XCTAssertFalse(search.isLoading)
    }
    @MainActor func testCancelledSearchCannotPublishStaleResults() async {
        let api = SpotifyAPI(); api.useDemo()
        let search = SearchViewModel(spotifyAPI: api); search.query = "Mara"
        let old = Task { await search.search() }
        old.cancel(); await old.value
        search.query = "North"; await search.search()
        XCTAssertEqual(search.results.map(\.id), ["orbit"])
    }
    @MainActor func testOfflineSessionWorksWithoutCredentialsAndSignOutClearsIt() async {
        let api = SpotifyAPI(), auth = AuthViewModel(spotifyAPI: SpotifyAPI(), clientID: "", redirectURI: "")
        XCTAssertFalse(auth.isConfigured)
        auth.startDemo(); XCTAssertTrue(auth.isAuthorized)
        auth.signOut(); XCTAssertFalse(auth.isAuthorized)
        api.useDemo(); XCTAssertEqual(try? await api.fetchNewReleases().count, 6)
        api.clear()
        do { _ = try await api.fetchNewReleases(); XCTFail("Signed-out API must fail") } catch { }
    }
}
