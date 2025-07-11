//
//  NearbyStoriesPickerView.swift
//  Novelty
//
//  Created by Nozhan A. on 7/11/25.
//

import SwiftData
import SwiftUI

struct NearbyStoriesPickerView: View {
    var targetPeer: NearbyPeer
    @EnvironmentObject private var manager: NearbyConnectionManager
    @Environment(\.dismiss) private var dismiss
    
    @Query(sort: [.init(\Story.created, order: .reverse)], animation: .smooth) private var stories: [Story]
    
    @Keychain(itemClass: .password, key: .storyPasswords) private var storyPasswords: [UUID: String]?
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(stories) { story in
                    VStack(alignment: .leading, spacing: 6) {
                        Text(story.title ?? "Untitled Story")
                            .font(.headline)
                        if let tagline = story.tagline {
                            Text(tagline)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        if let author = story.author {
                            Text(author)
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                        }
                    }
                    .asButton {
                        let storyDto = StoryDTO(story: story)
                        if let password = storyPasswords?[story.id],
                           let passwordProtectedStory = try? PasswordProtectedStoryDTO(storyDto: storyDto, password: password) {
                            manager.send(passwordProtectedStory, to: targetPeer)
                        } else {
                            manager.send(storyDto, to: targetPeer)
                        }
                        dismiss()
                    }
                }
            }
            .navigationTitle("Send story")
        }
    }
}
