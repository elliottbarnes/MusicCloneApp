//
//  AlbumCard.swift
//  MusicCloneApp
//
//  Created by Elliott Barnes on 2024-12-15.
//

import SwiftUI

struct AlbumCard: View {
    let album: SpotifyAlbum
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let url = album.artworkURL {
                AsyncImage(url: url) { image in
                    image.resizable().scaledToFill()
                } placeholder: {
                    Color.gray
                }
                .frame(width: 150, height: 150)
                .cornerRadius(8)
                .clipped()
            } else {
                Color.gray.frame(width: 150, height: 150).cornerRadius(8)
            }

            Text(album.name)
                .font(.headline)
                .lineLimit(1)
            Text(album.artistName)
                .font(.subheadline)
                .foregroundColor(.gray)
                .lineLimit(1)
        }
        .frame(width: 150)
        .foregroundColor(.white)
    }
}
