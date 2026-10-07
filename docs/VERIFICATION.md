# Verification and scope

## Acceptance flows

- Start the native app without credentials and open the offline demo.
- Save Night Windows, open Library, remove it, and verify the empty state.
- Search for Mara; only Low Tide appears. Clear or enter an unknown term and check the empty state.
- Choose an album; pause, seek, resume, and reach the end. A new selection resets progress.
- End/reset the session; catalog, library and player return to their initial state.
- Check keyboard/VoiceOver control labels and phone-width browser layout.

Core tests exercise the shared API injection, cancelled queries, player bounds and
end-of-track, library toggling, an RFC 7636 PKCE vector, reserved-character form
encoding and callback origin/state/duplicate-parameter rejection. GitHub Actions
runs these tests plus macOS compilation and the iOS simulator flow; browser tests
cover the separate JavaScript state model. Pure model tests do not establish visual
or screen-reader behavior, which requires the acceptance checks above.

Live Spotify authorization, domain association, catalog access and token refresh are
not claimed as account-verified. They require a developer-owned application and
signed build. Device signing, App Store distribution and real audio playback are
outside this demo's scope. macOS and iOS are the supported targets; visionOS is not
claimed. No secrets or personal listening data are included.
