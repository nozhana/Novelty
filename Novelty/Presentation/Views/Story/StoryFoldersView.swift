//
//  StoryFoldersView.swift
//  Novelty
//
//  Created by Nozhan A. on 7/12/25.
//

import SwiftUI
import SwiftData

struct StoryFoldersView: View {
    @Query(sort: [.init(\StoryFolder.layoutPriority)], animation: .smooth) private var folders: [StoryFolder]
    
    @EnvironmentObject private var router: Router
    @EnvironmentObject private var database: DatabaseManager
    
    @State private var dropState = DropState.idle
    @State private var showSettings = false
    @State private var showNearbyUsers = false
    @State private var showScanner = false
    
    @State private var draggedFolderId: UUID?
    
    var body: some View {
        NavigationStack(path: $router.navigationPath) {
            Group {
                if folders.isEmpty {
                    ContentUnavailableView("No Folders", systemImage: "questionmark.folder", description: Text("Create a new folder by tapping the \(Image(systemName: "folder.badge.plus")) button."))
                        .foregroundStyle(.secondary)
                        .transition(.blurReplace)
                } else {
                    ScrollView {
                        LazyVGrid(columns: Array(repeating: .init(spacing: 16), count: 2), spacing: 16) {
                            ReorderableForEach(data: folders, id: \.id, active: $draggedFolderId) { from, to in
                                var newFolders = folders
                                newFolders.move(fromOffsets: from, toOffset: to)
                                for (offset, folder) in newFolders.enumerated() {
                                    folder.layoutPriority = offset
                                }
                                database.saveChanges()
                            } content: { folder in
                                FolderItemView(folder: folder)
                            } preview: { folder in
                                Image(.folderIcon)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 120)
                                    .overlay(alignment: .bottomTrailing) {
                                        Text(folder.title)
                                            .font(.caption)
                                            .padding(24)
                                    }
                            }
                        }
                    }
                    .contentMargins(20, for: .scrollContent)
                    .transition(.blurReplace)
                    .dropOutsideContainer(forTypes: [.text]) {
                        draggedFolderId = nil
                    }
                }
            }
            .safeAreaInset(edge: .bottom, spacing: 16) {
                DropTargetView(dropState: $dropState)
                    .onDrop(of: [.noveltyStoryBundle], delegate: StoryBundleDropDelegate(dropState: $dropState))
                    .padding(16)
                    .frame(height: 240)
            }
            .navigationDestination(for: Story.self) { story in
                StoryView(story: story)
            }
            .navigationDestination(for: StoryFolder.self) { folder in
                StoryFolderView(folder: folder)
            }
            .fullScreenCover(isPresented: $showNearbyUsers) {
                NearbyView()
                    .environmentObject(NearbyConnectionManager.default())
                    .localized()
            }
            .fullScreenCover(isPresented: $showSettings) {
                SettingsView()
                    .localized()
            }
            .fullScreenCover(isPresented: $showScanner) {
                StoryQRScannerView()
                    .localized()
            }
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button("Nearby", systemImage: "wifi") {
                        showNearbyUsers = true
                    }
                    Button("Scanner", systemImage: "qrcode.viewfinder") {
                        showScanner = true
                    }
                    Button("Settings", systemImage: "gearshape.fill") {
                        showSettings = true
                    }
                    Button("New Folder", systemImage: "folder.badge.plus") {
                        let folder = StoryFolder(layoutPriority: folders.count)
                        database.save(folder)
                        router.navigationPath.append(folder)
                    }
                }
            }
            .navigationTitle("All Stories")
        }
    }
}

#Preview {
    StoryFoldersView()
        .database(.preview)
}

private struct FolderItemView: View {
    var folder: StoryFolder
    
    @EnvironmentObject private var router: Router
    @EnvironmentObject private var database: DatabaseManager
    
    @State private var isEnabled = false
    
    @FocusState private var isFocused: Bool
    
    var body: some View {
        Image(.folderIcon)
            .resizable().scaledToFit()
            .overlay(alignment: .bottomTrailing) {
                @Bindable var bindable = folder
                TextField("Title", text: $bindable.title, prompt: Text("Untitled Folder"))
                    .focused($isFocused)
                    .disabled(!isEnabled)
                    .submitLabel(.done)
                    .onSubmit {
                        isEnabled = false
                    }
                    .font(.system(.callout, weight: .semibold))
                    .padding(.bottom, 36)
                    .padding(.horizontal, 20)
                    .onTapGesture {
                        isEnabled = true
                    }
            }
            .asButton {
                router.navigationPath.append(folder)
            }
            .contentShape(.contextMenuPreview, .rect(cornerRadius: 12))
            .contextMenu {
                Button("Rename", systemImage: "pencil") {
                    isEnabled = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        isFocused = true
                    }
                }
                Button("Delete", systemImage: "xmark.bin", role: .destructive) {
                    database.delete(folder.stories)
                    database.delete(folder)
                }
                .foregroundStyle(.red)
            }
    }
}
