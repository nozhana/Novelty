//
//  ContentView.swift
//  Novelty
//
//  Created by Nozhan A. on 7/6/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        StoriesListView()
    }
}

#Preview {
    ContentView()
        .database(.preview)
}
