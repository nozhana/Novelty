//
//  Router.swift
//  Novelty
//
//  Created by Nozhan A. on 7/7/25.
//

import SwiftUI

final class Router: ObservableObject {
    enum NavigationItem: String {
        case stories
    }
    
    @Published var selectedItem: NavigationItem = .stories
    @Published var navigationPath = NavigationPath()
    
    static let shared = Router()
    private init() {}
    
    @MainActor
    private func handleFileResource(_ url: URL) {
        guard url.startAccessingSecurityScopedResource() else { return }
        defer { url.stopAccessingSecurityScopedResource() }
        guard let data = try? Data(contentsOf: url) else { return }
        if let storyDto = try? JSONDecoder().decode(StoryDTO.self, from: data) {
            AlertManager.shared.presentImportStoryAlert(for: storyDto)
        } else if let base64DecodedData = Data(base64Encoded: data),
           let storyDto = try? JSONDecoder().decode(StoryDTO.self, from: base64DecodedData) {
            AlertManager.shared.presentImportStoryAlert(for: storyDto)
        } else if let passwordProtectedStoryDto = try? JSONDecoder().decode(PasswordProtectedStoryDTO.self, from: data) {
            AlertManager.shared.presentImportPasswordProtectedStoryAlert(for: passwordProtectedStoryDto)
        }
    }
    
    @MainActor
    func process(_ url: URL) {
        if url.isFileURL {
            handleFileResource(url)
            return
        }
        url.absoluteString.split(separator: ":").map(String.init).forEach { component in
            guard let uuid = UUID(uuidString: component),
                  let story = DatabaseManager.shared.fetchFirst(Story.self, predicate: #Predicate { $0.id == uuid }) else { return }
            navigationPath.append(story)
        }
    }
}
