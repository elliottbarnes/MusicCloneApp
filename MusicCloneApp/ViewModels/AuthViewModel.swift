//
//  AuthViewModel.swift
//  MusicCloneApp
//
//  Created by Elliott Barnes on 2024-12-15.
//

import Foundation
import Combine
import CryptoKit
import AuthenticationServices

#if os(iOS)
import UIKit
#endif

#if os(macOS)
import AppKit
#endif


class AuthViewModel: NSObject, ObservableObject {
    @Published var isAuthorized = false
    private let spotifyAPI: SpotifyAPI
    
    // The client ID from your Spotify Developer Dashboard
    let clientID: String
    // The redirect URI you configured in Spotify Developer Dashboard, matching your URL scheme
    let redirectURI: String
    // Scopes requested: customize as needed
    let scopes: String = "user-read-email user-read-private"
    
    private var codeVerifier: String?
    private var cancellables = Set<AnyCancellable>()

    init(spotifyAPI: SpotifyAPI, clientID: String, redirectURI: String) {
        self.spotifyAPI = spotifyAPI
        self.clientID = clientID
        self.redirectURI = redirectURI
    }

    func authorize() {
        // 1. Generate PKCE verifier and challenge
        let (verifier, challenge) = generatePKCE()
        self.codeVerifier = verifier

        // 2. Construct authorization URL
        guard let authURL = authorizationURL(withChallenge: challenge) else { return }

        // 3. Start ASWebAuthenticationSession
        let session = ASWebAuthenticationSession(url: authURL, callbackURLScheme: callbackURLScheme()) { [weak self] callbackURL, error in
            guard let self = self else { return }

            if let error = error {
                print("Authentication error: \(error)")
                return
            }

            guard let callbackURL = callbackURL else {
                print("No callback URL returned.")
                return
            }

            // 4. Extract authorization code from callback
            guard let code = self.codeFromCallbackURL(callbackURL) else {
                print("No code in callback URL.")
                return
            }

            // 5. Exchange code for access token
            self.exchangeCodeForToken(code: code)
        }

        if #available(iOS 13.0, *) {
            session.presentationContextProvider = self
        }

        session.start()
    }

    // MARK: - Token Exchange
    private func exchangeCodeForToken(code: String) {
        guard let verifier = codeVerifier else {
            print("No code verifier found.")
            return
        }

        let tokenURL = URL(string: "https://accounts.spotify.com/api/token")!
        var request = URLRequest(url: tokenURL)
        request.httpMethod = "POST"

        let bodyComponents = [
            "grant_type=authorization_code",
            "code=\(code)",
            "redirect_uri=\(redirectURI)",
            "client_id=\(clientID)",
            "code_verifier=\(verifier)"
        ]
        request.httpBody = bodyComponents.joined(separator: "&").data(using: .utf8)
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { (data, response) -> TokenResponse in
                guard let httpResponse = response as? HTTPURLResponse,
                      200...299 ~= httpResponse.statusCode else {
                    throw URLError(.badServerResponse)
                }
                return try JSONDecoder().decode(TokenResponse.self, from: data)
            }
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { completion in
                if case let .failure(error) = completion {
                    print("Failed to exchange code for token: \(error)")
                }
            }, receiveValue: { [weak self] tokenResponse in
                self?.spotifyAPI.setAccessToken(tokenResponse.access_token)
                self?.isAuthorized = true
                // If the token response includes a refresh token, store it securely (e.g., in Keychain) for later use.
                // self?.spotifyAPI.refreshToken = tokenResponse.refresh_token
            })
            .store(in: &cancellables)
    }

    // MARK: - Helpers
    private func authorizationURL(withChallenge challenge: String) -> URL? {
        var components = URLComponents(string: "https://accounts.spotify.com/authorize")
        components?.queryItems = [
            URLQueryItem(name: "client_id", value: clientID),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "redirect_uri", value: redirectURI),
            URLQueryItem(name: "scope", value: scopes),
            URLQueryItem(name: "code_challenge_method", value: "S256"),
            URLQueryItem(name: "code_challenge", value: challenge)
        ]
        return components?.url
    }

    private func codeFromCallbackURL(_ url: URL) -> String? {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let queryItems = components.queryItems else {
            return nil
        }
        return queryItems.first(where: { $0.name == "code" })?.value
    }

    private func callbackURLScheme() -> String {
        // Extract scheme from redirect URI (e.g., "myapp://spotify/callback" -> "myapp")
        guard let url = URL(string: redirectURI) else { return "" }
        return url.scheme ?? ""
    }

    private func generatePKCE() -> (verifier: String, challenge: String) {
        let verifier = randomString(length: 128)
        let challenge = codeChallenge(for: verifier)
        return (verifier, challenge)
    }

    private func randomString(length: Int) -> String {
        let chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-._~"
        return String((0..<length).compactMap { _ in chars.randomElement() })
    }

    private func codeChallenge(for verifier: String) -> String {
        let data = Data(verifier.utf8)
        let hash = SHA256.hash(data: data)
        return Data(hash).base64URLEncodedString()
    }
}

// MARK: - PKCE Extensions
extension Data {
    func base64URLEncodedString() -> String {
        return self.base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }
}

// MARK: - Token Response
struct TokenResponse: Decodable {
    let access_token: String
    let token_type: String
    let expires_in: Int
    let refresh_token: String?
    let scope: String?
}

// MARK: - ASWebAuthenticationPresentationContextProviding
@available(iOS 16.0, *)
extension AuthViewModel: ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        // This assumes your app is a UIKit lifecycle app.
        // If you use SwiftUI App lifecycle:
        // You need a window scene. For simplicity:
        #if os(iOS)
        return UIApplication.shared.windows.first ?? ASPresentationAnchor()
        #else
        // On macOS, you need a different approach, e.g.:
        // If using AppKit:
        // import AppKit
        return NSApplication.shared.windows.first ?? ASPresentationAnchor()
        #endif
    }
}
