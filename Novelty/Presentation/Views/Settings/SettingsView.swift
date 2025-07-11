//
//  SettingsView.swift
//  Novelty
//
//  Created by Nozhan A. on 7/11/25.
//

import SwiftUI

struct SettingsView: View {
    private let cacheStore = DefaultsCacheStore.shared
    
    @State private var invalidator = 0
    
    @AppStorage(DefaultsKey.defaultCacheTime, store: .group) private var defaultCacheTime: TimeInterval = 300
    
    @Environment(\.dismiss) private var dismiss
    
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
            }
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
