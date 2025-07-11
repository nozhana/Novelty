//
//  DropTargetView.swift
//  Novelty
//
//  Created by Nozhan A. on 7/10/25.
//

import SwiftUI
import UniformTypeIdentifiers

struct DropTargetView: View {
    @Binding var dropState: DropState
    
    @EnvironmentObject private var router: Router
    
    @State private var showFilePicker = false
    
    var body: some View {
        ZStack {
            switch dropState {
            case .idle:
                RoundedRectangle(cornerRadius: 16)
                    .fill(.background.secondary)
                    .transition(.opacity)
                    
                VStack(spacing: 12) {
                    Image(systemName: "square.and.arrow.down")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 32, height: 32)
                        .imageScale(.large)
                    Text("Import Story")
                        .font(.title2.bold())
                    Text("Drop a story bundle file here to import.")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                    Button("Pick a file", systemImage: "document.badge.ellipsis") {
                        showFilePicker = true
                    }
                    .font(.subheadline.bold())
                    .fileImporter(isPresented: $showFilePicker, allowedContentTypes: [.noveltyStoryBundle]) { result in
                        switch result {
                        case .success(let url):
                            router.process(url)
                        case .failure(let error):
                            print("Failed to import file: \(error)")
                        }
                    }
                }
                .transition(.scale.combined(with: .opacity))
            case .invalid:
                RoundedRectangle(cornerRadius: 16)
                    .fill(.red.opacity(0.4))
                    .transition(.opacity)
                
                Text("Invalid file type")
                    .font(.title.bold())
                    .foregroundStyle(.white)
                    .transition(.scale.combined(with: .opacity))
            case .valid:
                RoundedRectangle(cornerRadius: 16)
                    .fill(.tint.opacity(0.4))
                    .transition(.opacity)
                
                Text("Import story")
                    .font(.title.bold())
                    .foregroundStyle(.white)
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .animation(.smooth, value: dropState)
    }
}

enum DropState {
    case idle, valid, invalid
}

struct StoryBundleDropDelegate: DropDelegate {
    @Binding var dropState: DropState
    
    func dropUpdated(info: DropInfo) -> DropProposal? {
        if info.hasItemsConforming(to: [.noveltyStoryBundle]) {
            return .init(operation: .copy)
        } else {
            return .init(operation: .forbidden)
        }
    }
    
    func dropEntered(info: DropInfo) {
        if info.hasItemsConforming(to: [.noveltyStoryBundle]) {
            DispatchQueue.main.async {
                dropState = .valid
            }
        } else {
            DispatchQueue.main.async {
                dropState = .invalid
            }
        }
    }
    
    func dropExited(info: DropInfo) {
        DispatchQueue.main.async {
            dropState = .idle
        }
    }
    
    func validateDrop(info: DropInfo) -> Bool {
        info.hasItemsConforming(to: [.noveltyStoryBundle])
    }
    
    func performDrop(info: DropInfo) -> Bool {
        DispatchQueue.main.async {
            dropState = .idle
        }
        guard let storyBundleProvider = info.itemProviders(for: [.noveltyStoryBundle]).first else { return false }
        storyBundleProvider.loadItem(forTypeIdentifier: UTType.noveltyStoryBundle.identifier) { item, error in
            if let error {
                print("Failed to drop item: \(error)")
            }
            
            let storyData: Data?
            if let url = item as? URL,
               url.startAccessingSecurityScopedResource() {
                defer { url.stopAccessingSecurityScopedResource() }
                storyData = try? Data(contentsOf: url)
            } else if let data = item as? Data {
                storyData = data
            } else {
                storyData = nil
            }
            if let storyData,
               let base64DecodedData = Data(base64Encoded: storyData),
               let decodedStoryDto = try? JSONDecoder().decode(StoryDTO.self, from: base64DecodedData) {
                DispatchQueue.main.async {
                    AlertManager.shared.presentImportStoryAlert(for: decodedStoryDto)
                }
            } else if let storyData,
                      let decodedPasswordProtectedStory = try? JSONDecoder().decode(PasswordProtectedStoryDTO.self, from: storyData) {
                DispatchQueue.main.async {
                    AlertManager.shared.presentImportPasswordProtectedStoryAlert(for: decodedPasswordProtectedStory)
                }
            }
        }
        
        return true
    }
}
