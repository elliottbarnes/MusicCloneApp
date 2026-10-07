import Foundation
import Combine

@MainActor final class SpotifyAPI: ObservableObject {
    @Published private(set) var isDemo = false
    private var accessToken: String?
    private var refreshToken: String?
    private var expiresAt = Date.distantPast
    private var clientID = ""
    private var refreshTask: Task<TokenResponse, Error>?
    private let session: URLSession
    init(session: URLSession = .shared) { self.session = session }
    func useDemo() { clear(); isDemo = true }
    func clear() {
        refreshTask?.cancel(); refreshTask = nil
        accessToken = nil; refreshToken = nil; expiresAt = .distantPast
        isDemo = false; clientID = ""
    }
    func setSession(_ token: TokenResponse, clientID: String) {
        self.clientID = clientID; accessToken = token.access_token
        if let refresh = token.refresh_token { refreshToken = refresh }
        expiresAt = Date().addingTimeInterval(Double(token.expires_in))
        isDemo = false
    }
    func fetchNewReleases() async throws -> [SpotifyAlbum] {
        if isDemo { return DemoCatalog.albums }
        return try JSONDecoder().decode(AlbumResponse.self, from: await request(url: SpotifyEndpoints.newReleases())).albums.items
    }
    func searchAlbums(query: String) async throws -> [SpotifyAlbum] {
        if isDemo { return DemoCatalog.search(query) }
        return try JSONDecoder().decode(AlbumResponse.self, from: await request(url: SpotifyEndpoints.search(query: query))).albums.items
    }
    private func validToken() async throws -> String {
        guard let accessToken else { throw CatalogError.signedOut }
        if expiresAt.timeIntervalSinceNow > 30 { return accessToken }
        guard let refreshToken else { throw CatalogError.signedOut }
        if refreshTask == nil {
            let id = clientID, session = session
            refreshTask = Task {
                var request = URLRequest(url: URL(string: "https://accounts.spotify.com/api/token")!)
                request.httpMethod = "POST"
                request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
                request.httpBody = OAuth.form(["grant_type":"refresh_token", "refresh_token":refreshToken, "client_id":id])
                let (data, response) = try await session.data(for: request)
                try Task.checkCancellation()
                guard (response as? HTTPURLResponse)?.statusCode == 200 else { throw CatalogError.signedOut }
                return try JSONDecoder().decode(TokenResponse.self, from: data)
            }
        }
        guard let task = refreshTask else { throw CatalogError.signedOut }
        defer { refreshTask = nil }
        let token = try await task.value
        try Task.checkCancellation()
        guard self.accessToken != nil, !isDemo else { throw CatalogError.signedOut }
        setSession(token, clientID: clientID)
        return token.access_token
    }
    private func request(url: URL) async throws -> Data {
        var request = URLRequest(url: url)
        request.setValue("Bearer \(try await validToken())", forHTTPHeaderField: "Authorization")
        let (data, response) = try await session.data(for: request)
        try Task.checkCancellation()
        guard let http = response as? HTTPURLResponse else { throw CatalogError.response }
        switch http.statusCode {
        case 200...299: return data
        case 401: throw CatalogError.signedOut
        case 403: throw CatalogError.denied
        case 429: throw CatalogError.rateLimited
        default: throw CatalogError.response
        }
    }
}

private struct AlbumResponse: Decodable {
    let albums: Container
    struct Container: Decodable { let items: [SpotifyAlbum] }
}
