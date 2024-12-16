//
//  LibraryView.swift
//  MusicCloneApp
//
//  Created by Elliott Barnes on 2024-12-15.
//

import SwiftUI

struct LibraryView: View {
    var body: some View {
        Text("Your Library")
            .font(.largeTitle)
            .bold()
            .foregroundColor(.white)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black.edgesIgnoringSafeArea(.all))
    }
}
