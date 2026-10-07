# MusicCloneApp

A small SwiftUI music-library app with a complete offline demo: browse six fictional
albums, search titles and artists, save/remove albums, and use a simulated player.
Home, Search, Library, and the player share one session. No audio is streamed.

**[Try the interactive browser example](https://elliottbarnes.github.io/MusicCloneApp/)** ·
[Native source](MusicCloneApp) · [Verification](docs/VERIFICATION.md)

## Run the native app

Open `MusicCloneApp.xcodeproj` in Xcode 16.4 or newer, choose the shared
`MusicCloneApp` scheme and an iOS 18.2+ simulator or macOS 15.2+ destination, then Run.
Choose **Try offline demo**. No Spotify credentials, subscription, model, or backend
is needed. The library is session-only; **End session** clears it and player state.

Album metadata and procedural cover designs are original fictional demo material.
The three-minute preview advances UI state only; there are no recordings or playback SDKs.
This is an independent learning project, not an official Spotify product.

## Run the browser example

```sh
python3 -m http.server 8000 --bind 127.0.0.1 --directory demo
```

Open `http://127.0.0.1:8000`. Search, save/remove, play/pause, seek, end-of-track,
and reset all work without network requests. A hidden tab pauses its simulation.
Reload/reset clears session state. The example is a JavaScript adaptation of the
SwiftUI flows; it does not execute Swift in the browser.

## Optional Spotify catalog integration

The offline demo is the verified default. An optional metadata-only PKCE adapter
remains available for a developer-owned Spotify app. It has not been verified with
live credentials. It does not provide personalized recommendations, account-library
sync, streaming, or persistent login.

To configure it, add public `SpotifyClientID` and `SpotifyRedirectURI` strings to
`MusicCloneApp/Info.plist`. The redirect must be an exact registered HTTPS URL with
a path, no query or fragment. Configure your signed app's **Associated Domains**
capability with `webcredentials:YOUR_DOMAIN` and host the matching Apple association
file on that domain. No working domain/client ID is included. This setup requires
control of that domain and Apple signing; it is not a one-line client-ID change.
Never add a client secret. The Connect button appears only after valid local values
are supplied.

The adapter retains the authentication session, uses an S256 challenge and random
state, rejects mismatched/duplicate callbacks, form-encodes token requests, and keeps
tokens only in memory. It refreshes expiring access tokens; ending the session clears
them. Search cancellation prevents older responses from replacing a newer query.
Catalog errors are visible and do not silently substitute fictional albums.

Spotify app access and available catalog endpoints depend on the app's current access
mode. See [PKCE](https://developer.spotify.com/documentation/web-api/tutorials/code-pkce-flow),
[redirect requirements](https://developer.spotify.com/documentation/web-api/concepts/redirect_uri),
and [quota modes](https://developer.spotify.com/documentation/web-api/concepts/quota-modes).
There is no login or token handling in the GitHub Pages example.

## Checks

With Xcode selected via `xcode-select`, run `swift test` for catalog, player, library,
search cancellation and OAuth helper tests. Run `node --test tests/web/*.test.mjs`
with Node 24 for browser-state checks. Xcode's Test action includes an offline
Home → Library → Search → player UI test on iOS. CI also builds the macOS app and
publishes only `demo/` after all native and browser checks pass on `main`.

The project does not currently declare a software license. No new license is inferred
from its public visibility. Historical source remains in Git history; the previous
custom-scheme callback and placeholder login are replaced by the explicit setup above.
