//
//  SectionHeader.swift
//  MusicCloneApp
//
//  Created by Elliott Barnes on 2024-12-15.
//

import SwiftUI

struct SectionHeader: View {
    let title: String
    
    var body: some View {
        Text(title)
            .font(.title2)
            .bold()
            .padding(.horizontal)
            .foregroundColor(.white)
    }
}
