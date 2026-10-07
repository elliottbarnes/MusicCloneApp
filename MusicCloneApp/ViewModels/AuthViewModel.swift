import Foundation
import Combine
import AuthenticationServices
#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

@MainActor final class AuthViewModel: NSObject, ObservableObject {
    @Published private(set) var isAuthorized = false
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?
    private let spotifyAPI: SpotifyAPI
    private let clientID: String
    private let redirectURI: String
    private var session: ASWebAuthenticationSession?
    private var exchangeTask: Task<Void, Never>?
    private var attempt = UUID()
    init(spotifyAPI: SpotifyAPI, clientID: String, redirectURI: String) {
        self.spotifyAPI = spotifyAPI; self.clientID = clientID; self.redirectURI = redirectURI
    }
    var isConfigured: Bool {
        guard let url = URL(string: redirectURI) else { return false }
        return clientID.count == 32 && clientID.allSatisfy { $0.isHexDigit }
            && url.scheme == "https" && url.host != nil && !url.path.isEmpty
            && url.query == nil && url.fragment == nil && url.user == nil && url.password == nil
    }
    func startDemo() { signOut(); spotifyAPI.useDemo(); isAuthorized = true }
    func signOut() {
        attempt = UUID(); session?.cancel(); session = nil
        exchangeTask?.cancel(); exchangeTask = nil
        spotifyAPI.clear(); isAuthorized = false; isLoading = false; errorMessage = nil
    }
    func authorize() {
        guard isConfigured, let redirect = URL(string: redirectURI), let host = redirect.host else {
            errorMessage = CatalogError.configuration.localizedDescription; return
        }
        guard !isLoading else { return }
        errorMessage = nil; isLoading = true
        let verifier = OAuth.randomString(), state = OAuth.randomString(), current = UUID()
        attempt = current
        var url = URLComponents(string: "https://accounts.spotify.com/authorize")!
        url.queryItems = [URLQueryItem(name: "client_id", value: clientID),
            URLQueryItem(name: "response_type", value: "code"), URLQueryItem(name: "redirect_uri", value: redirectURI),
            URLQueryItem(name: "code_challenge_method", value: "S256"),
            URLQueryItem(name: "code_challenge", value: OAuth.challenge(verifier)), URLQueryItem(name: "state", value: state)]
        session = ASWebAuthenticationSession(url: url.url!, callback: .https(host: host, path: redirect.path)) { [weak self] callback, error in
            Task { @MainActor [weak self] in
                guard let self, self.attempt == current else { return }
                self.session = nil
                guard error == nil, let callback else {
                    self.isLoading = false; self.errorMessage = "Sign-in was cancelled or could not finish."; return
                }
                self.exchangeTask = Task { @MainActor [weak self] in
                    guard let self else { return }
                    defer { if self.attempt == current { self.isLoading = false } }
                    do {
                        let code = try OAuth.callbackCode(callback, redirect: redirect, state: state)
                        var request = URLRequest(url: URL(string: "https://accounts.spotify.com/api/token")!)
                        request.httpMethod = "POST"
                        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
                        request.httpBody = OAuth.form(["grant_type":"authorization_code", "code":code,
                            "redirect_uri":self.redirectURI, "client_id":self.clientID, "code_verifier":verifier])
                        let (data, response) = try await URLSession.shared.data(for: request)
                        try Task.checkCancellation()
                        guard (response as? HTTPURLResponse)?.statusCode == 200 else { throw CatalogError.response }
                        let token = try JSONDecoder().decode(TokenResponse.self, from: data)
                        guard self.attempt == current else { return }
                        self.spotifyAPI.setSession(token, clientID: self.clientID); self.isAuthorized = true
                    } catch {
                        if self.attempt == current && !Task.isCancelled { self.errorMessage = error.localizedDescription }
                    }
                }
            }
        }
        session?.presentationContextProvider = self
        session?.prefersEphemeralWebBrowserSession = true
        if session?.start() != true { session = nil; isLoading = false; errorMessage = "Could not open sign-in." }
    }
}

extension AuthViewModel: ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        #if os(iOS)
        return UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows).first(where: \.isKeyWindow) ?? ASPresentationAnchor()
        #else
        return NSApplication.shared.keyWindow ?? ASPresentationAnchor()
        #endif
    }
}
