//
//  AuthView.swift
//  MusicCloneApp
//
//  Created by Elliott Barnes on 2024-12-15.
//

import SwiftUI

struct AuthView: View {
    @ObservedObject var authVM: AuthViewModel

    var body: some View {
        VStack {
            Text("Welcome to Spotify Clone")
                .font(.title)
                .padding()
            
            Button("Authorize with Spotify") {
                authVM.authorize()
            }
            .padding()
            .background(Color.green)
            .foregroundColor(.white)
            .cornerRadius(8)

        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.edgesIgnoringSafeArea(.all))
        .foregroundColor(.white)
    }
}
