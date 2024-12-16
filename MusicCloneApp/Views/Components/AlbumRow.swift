//
//  AlbumRow.swift
//  MusicCloneApp
//
//  Created by Elliott Barnes on 2024-12-15.
//

import SwiftUI

struct AlbumRow: View {
    let album: SpotifyAlbum
    
    var body: some View {
        HStack(spacing: 15) {
            if let url = album.artworkURL {
                AsyncImage(url: url) { img in
                    img.resizable().scaledToFill()
                } placeholder: {
                    Color.gray
                }
                .frame(width: 60, height: 60)
                .cornerRadius(8)
            } else {
                Color.gray.frame(width:60, height:60).cornerRadius(8)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(album.name)
                    .font(.headline)
                    .lineLimit(1)
                Text(album.artistName)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .lineLimit(1)
            }

            Spacer()
        }
        .contentShape(Rectangle())
        .foregroundColor(.white)
    }
}
