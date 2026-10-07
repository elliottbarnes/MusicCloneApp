import Foundation
import CryptoKit

enum OAuth {
    static func challenge(_ verifier: String) -> String {
        Data(SHA256.hash(data: Data(verifier.utf8))).base64EncodedString()
            .replacingOccurrences(of: "+", with: "-").replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }
    static func randomString() -> String {
        let chars = Array("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-._~")
        return String((0..<64).map { _ in chars.randomElement()! })
    }
    static func form(_ fields: [String: String]) -> Data {
        let allowed = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-._~")
        return Data(fields.sorted { $0.key < $1.key }.map {
            "\($0.key.addingPercentEncoding(withAllowedCharacters: allowed)!)=\($0.value.addingPercentEncoding(withAllowedCharacters: allowed)!)"
        }.joined(separator: "&").utf8)
    }
    static func callbackCode(_ url: URL, redirect: URL, state: String) throws -> String {
        guard url.scheme == "https", url.host == redirect.host, url.port == redirect.port,
              url.path == redirect.path, url.user == nil, url.password == nil, url.fragment == nil,
              let parts = URLComponents(url: url, resolvingAgainstBaseURL: false) else { throw CatalogError.invalidCallback }
        let items = parts.queryItems ?? []
        guard items.filter({ $0.name == "state" }).count == 1,
              items.first(where: { $0.name == "state" })?.value == state,
              items.filter({ $0.name == "code" }).count == 1,
              !items.contains(where: { $0.name == "error" }),
              let code = items.first(where: { $0.name == "code" })?.value, !code.isEmpty else { throw CatalogError.invalidCallback }
        return code
    }
}

struct TokenResponse: Decodable {
    let access_token: String
    let token_type: String
    let expires_in: Int
    let refresh_token: String?
}

enum CatalogError: LocalizedError {
    case invalidCallback, signedOut, denied, rateLimited, response, configuration
    var errorDescription: String? {
        switch self {
        case .invalidCallback: return "The sign-in response did not match this session. Try again."
        case .signedOut: return "Your session expired. End the session and connect again."
        case .denied: return "Spotify denied this request. Check your app's development-mode access."
        case .rateLimited: return "Spotify is rate limiting requests. Wait before trying again."
        case .response: return "The catalog request failed. Check your connection and retry."
        case .configuration: return "Configure a client ID and associated HTTPS callback before connecting."
        }
    }
}
