//
//  NowPlayingBar.swift
//  MusicCloneApp
//
//  Created by Elliott Barnes on 2024-12-15.
//

import SwiftUI

#if os(iOS)
import UIKit
#endif

#if os(macOS)
import AppKit
#endif

struct NowPlayingBar: View {
    @EnvironmentObject var playerVM: PlayerViewModel
    let track: SpotifyTrack

    var backgroundColor: Color {
        #if os(iOS)
        Color(UIColor.systemGray4)
        #elseif os(macOS)
        Color(NSColor.systemGray)
        #endif
    }

    var body: some View {
        VStack {
            Divider().background(Color.gray)
            HStack {
                Text(track.name)
                    .lineLimit(1)
                    .font(.headline)
                    .foregroundColor(.white)
                Spacer()
                Button(action: { playerVM.togglePlayPause() }) {
                    Image(systemName: playerVM.isPlaying ? "pause.fill" : "play.fill")
                        .foregroundColor(.white)
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 10)
        }
        .background(backgroundColor)
    }
}
