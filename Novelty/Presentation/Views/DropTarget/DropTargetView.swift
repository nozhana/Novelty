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
    
    private let startDate = Date.now
    
    var body: some View {
        ZStack {
            switch dropState {
            case .idle:
                RoundedRectangle(cornerRadius: 16)
                    .fill(.background.secondary)
                    .transition(.opacity)
                    
                ContentUnavailableView("Import Story", systemImage: "square.and.arrow.down", description: Text("Drop a story bundle file here to import."))
                    .foregroundStyle(.secondary)
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
            guard let storyData,
                  let base64DecodedData = Data(base64Encoded: storyData),
                  let decodedStoryDto = try? JSONDecoder().decode(StoryDTO.self, from: base64DecodedData) else { return }
            DispatchQueue.main.async {
                AlertManager.shared.presentImportStoryAlert(for: decodedStoryDto)
            }
        }
        
        return true
    }
}
