//
//  SettingsView.swift
//  Novelty
//
//  Created by Nozhan A. on 7/11/25.
//

import SwiftUI

struct SettingsView: View {
    private let cacheStore = DefaultsCacheStore.shared
    
    @EnvironmentObject private var database: DatabaseManager
    @Environment(\.dismiss) private var dismiss
    
    @AppStorage(DefaultsKey.defaultCacheTime, store: .group) private var defaultCacheTime: TimeInterval = 300
    
    @State private var invalidator = 0
    
    @State private var showDonateView = false
    
    var body: some View {
        let unlockedStories = cacheStore.get([UUID].self, forKey: DefaultsKey.unlockedStories) ?? []
        
        NavigationStack {
            List {
                Section {
                    if !unlockedStories.isEmpty {
                        Button("Lock all stories", systemImage: "lock.circle.dotted", role: .destructive) {
                            cacheStore.clear(valueForKey: DefaultsKey.unlockedStories)
                            invalidator += 1
                        }
                        .foregroundStyle(.red)
                    }
                    Picker("Keep stories unlocked for...", systemImage: "lock.open", selection: $defaultCacheTime) {
                        ForEach([300.0, 3600, 12 * 3600, 24 * 3600], id: \.self) { interval in
                            let title: String = switch interval {
                            case 300: "Five minutes"
                            case 3600: "One hour"
                            case 12 * 3600: "12 Hours"
                            default: "One day"
                            }
                            Text(title)
                                .tag(interval)
                        }
                    }
                    .pickerStyle(.inline)
                } header: {
                    Label("Privacy", systemImage: "hand.raised")
                }
                
#if DEBUG
                Section {
                    Button("Add mock stories", systemImage: "books.vertical") {
                        database.save(Story.mockStory, .permissionToSwap)
                        database.undoManager.addManager(for: Story.mockStory.id)
                        database.undoManager.addManager(for: Story.permissionToSwap.id)
                        dismiss()
                    }
                } header: {
                    Label("Developer", systemImage: "hammer")
                }
#endif
            }
            .safeAreaInset(edge: .bottom, spacing: 16) {
                VStack(spacing: 12) {
                    Text("Made with 💜")
                        .font(.caption.weight(.heavy))
                    Link(destination: Constants.githubUrl) {
                        Label {
                            Text("@nozhana")
                        } icon: {
                            Image(.githubLogo)
                                .resizable().scaledToFit()
                                .frame(width: 24, height: 24)
                        }
                    }
                    .font(.caption.bold().monospaced())
                    Button("Buy me a coffee", systemImage: "mug") {
                        showDonateView = true
                    }
                    .foregroundStyle(.orange.gradient)
                    .font(.caption.weight(.medium))
                }
                .padding(.vertical, 12)
            }
            .navigationDestination(isPresented: $showDonateView, destination: DonateView.init)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .navigationTitle("Settings")
        }
        .invalidatable(trigger: invalidator)
    }
}

#Preview {
    SettingsView()
}
