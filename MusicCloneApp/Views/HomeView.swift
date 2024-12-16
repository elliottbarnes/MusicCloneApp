//
//  HomeView.swift
//  MusicCloneApp
//
//  Created by Elliott Barnes on 2024-12-15.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var spotifyAPI: SpotifyAPI
    @EnvironmentObject var playerVM: PlayerViewModel
    @StateObject var viewModel: HomeViewModel

    init() {
        let viewModel = HomeViewModel(spotifyAPI: SpotifyAPI())
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    SectionHeader(title: "Featured")

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 15) {
                            ForEach(viewModel.featuredAlbums) { album in
                                AlbumCard(album: album)
                                    .onTapGesture {
                                        let track = SpotifyTrack(id: "fake-track", name: album.name, artists: album.artists, duration_ms: 180000)
                                        playerVM.play(track: track)
                                    }
                            }
                        }
                        .padding(.horizontal)
                    }

                    SectionHeader(title: "Recommended For You")

                    VStack(spacing: 15) {
                        ForEach(viewModel.recommendedAlbums) { album in
                            AlbumRow(album: album)
                                .onTapGesture {
                                    let track = SpotifyTrack(id: "fake-track", name: album.name, artists: album.artists, duration_ms: 180000)
                                    playerVM.play(track: track)
                                }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }

            if let currentTrack = playerVM.currentTrack {
                NowPlayingBar(track: currentTrack)
            }
        }
        .background(Color.black.edgesIgnoringSafeArea(.all))
        .foregroundColor(.white)
        .task {
            await viewModel.loadData()
        }
    }
}
