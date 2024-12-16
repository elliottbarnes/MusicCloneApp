//
//  SearchView.swift
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

struct SearchView: View {
    @EnvironmentObject var spotifyAPI: SpotifyAPI
    @EnvironmentObject var playerVM: PlayerViewModel
    @StateObject var viewModel: SearchViewModel

    init() {
        let viewModel = SearchViewModel(spotifyAPI: SpotifyAPI())
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                TextField("Search albums", text: $viewModel.query)
                    .padding()
                    #if os(iOS)
                    .background(Color(UIColor.systemGray4))
                    #elseif os(macOS)
                    .background(Color(NSColor.systemGray))
                    #endif
                    .cornerRadius(8)
                    .foregroundColor(.black)
                    .onChange(of: viewModel.query) { _ in
                        viewModel.search()
                    }
            }
            .padding()

            List {
                ForEach(viewModel.results) { album in
                    HStack {
                        if let url = album.artworkURL {
                            AsyncImage(url: url) { img in
                                img.resizable().scaledToFill()
                            } placeholder: {
                                Color.gray
                            }
                            .frame(width: 50, height: 50)
                            .cornerRadius(4)
                        } else {
                            Color.gray.frame(width:50, height:50).cornerRadius(4)
                        }

                        VStack(alignment: .leading) {
                            Text(album.name)
                                .font(.headline)
                            Text(album.artistName)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        let track = SpotifyTrack(id: "fake-track", name: album.name, artists: album.artists, duration_ms: 180000)
                        playerVM.play(track: track)
                    }
                    .listRowBackground(Color.black)
                }
            }
            .listStyle(PlainListStyle())
            .background(Color.black)
            .foregroundColor(.white)
        }
        .background(Color.black.edgesIgnoringSafeArea(.all))
    }
}
