import XCTest
@testable import MusicCloneCore

private final class SessionProtocol: URLProtocol {
    static let fixture = RefreshFixture()
    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }
    override func startLoading() { Self.fixture.receive(self) }
    override func stopLoading() { }
    func finish(_ json: String) {
        client?.urlProtocol(self, didReceive: HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: ["Content-Type":"application/json"])!, cacheStoragePolicy: .notAllowed)
        client?.urlProtocol(self, didLoad: Data(json.utf8))
        client?.urlProtocolDidFinishLoading(self)
    }
}
private final class RefreshFixture: @unchecked Sendable {
    private let lock = NSLock()
    private var pending: SessionProtocol?
    private var tokenRequests = 0
    private var headers: [String] = []
    private var started: XCTestExpectation?
    func reset(_ expectation: XCTestExpectation) {
        lock.lock(); defer { lock.unlock() }
        pending = nil; tokenRequests = 0; headers = []; started = expectation
    }
    func receive(_ request: SessionProtocol) {
        lock.lock()
        if request.request.url!.path == "/api/token" {
            tokenRequests += 1; pending = request
            let expectation = started; started = nil; lock.unlock(); expectation?.fulfill()
        } else {
            headers.append(request.request.value(forHTTPHeaderField: "Authorization") ?? "")
            lock.unlock(); request.finish("{\"albums\":{\"items\":[]}}")
        }
    }
    func release() {
        lock.lock(); let request = pending; pending = nil; lock.unlock()
        request?.finish("{\"access_token\":\"refreshed\",\"token_type\":\"Bearer\",\"expires_in\":3600}")
    }
    func snapshot() -> (Int, [String]) { lock.lock(); defer { lock.unlock() }; return (tokenRequests, headers) }
}
final class RefreshTests: XCTestCase {
    @MainActor private func api() -> SpotifyAPI {
        let config = URLSessionConfiguration.ephemeral; config.protocolClasses = [SessionProtocol.self]
        let api = SpotifyAPI(session: URLSession(configuration: config))
        api.setSession(TokenResponse(access_token: "expired", token_type: "Bearer", expires_in: -1, refresh_token: "refresh"), clientID: "test")
        return api
    }
    @MainActor func testConcurrentRequestsShareOneRefresh() async throws {
        let ready = expectation(description: "Refresh started"); SessionProtocol.fixture.reset(ready)
        let api = api()
        let first = Task { try await api.fetchNewReleases() }
        let second = Task { try await api.searchAlbums(query: "test") }
        await fulfillment(of: [ready], timeout: 3)
        SessionProtocol.fixture.release()
        _ = try await first.value; _ = try await second.value
        XCTAssertEqual(SessionProtocol.fixture.snapshot().0, 1)
        XCTAssertEqual(SessionProtocol.fixture.snapshot().1, ["Bearer refreshed", "Bearer refreshed"])
    }
    @MainActor func testOldRefreshCannotReplaceReconnectedSession() async throws {
        let ready = expectation(description: "Old refresh started"); SessionProtocol.fixture.reset(ready)
        let api = api()
        let old = Task { try await api.fetchNewReleases() }
        await fulfillment(of: [ready], timeout: 3)
        api.setSession(TokenResponse(access_token: "new-session", token_type: "Bearer", expires_in: 3600, refresh_token: nil), clientID: "new-client")
        SessionProtocol.fixture.release()
        do { _ = try await old.value; XCTFail("An old request must not adopt the new session") } catch { }
        _ = try await api.fetchNewReleases()
        XCTAssertEqual(SessionProtocol.fixture.snapshot().1, ["Bearer new-session"])
    }
}
