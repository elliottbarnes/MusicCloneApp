//
//  ContentView.swift
//  MusicCloneApp
//
//  Created by Elliott Barnes on 2024-12-15.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }

            SearchView()
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }

            LibraryView()
                .tabItem {
                    Label("Library", systemImage: "music.note.list")
                }
        }
        .accentColor(.white)
        .background(Color.black.edgesIgnoringSafeArea(.all))
    }
}
