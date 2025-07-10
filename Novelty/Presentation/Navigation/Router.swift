//
//  Router.swift
//  Novelty
//
//  Created by Nozhan A. on 7/7/25.
//

import Foundation

final class Router: ObservableObject {
    enum NavigationItem: String {
        case stories
    }
    
    @Published var selectedItem: NavigationItem = .stories
    @Published var stories: [Story] = []
    
    static let shared = Router()
    private init() {}
    
    @MainActor
    private func handleFileResource(_ url: URL) {
        guard url.startAccessingSecurityScopedResource() else { return }
        defer { url.stopAccessingSecurityScopedResource() }
        guard let data = try? Data(contentsOf: url) else { return }
        if let base64DecodedData = Data(base64Encoded: data),
           let storyDto = try? JSONDecoder().decode(StoryDTO.self, from: base64DecodedData) {
            AlertManager.shared.presentImportStoryAlert(for: storyDto)
        }
    }
    
    @MainActor
    func process(_ url: URL) {
        if url.isFileURL {
            handleFileResource(url)
            return
        }
        let stories = url.absoluteString.split(separator: ":").map(String.init).reduce(into: [Story]()) { partialResult, component in
            guard let uuid = UUID(uuidString: component),
                  let story = DatabaseManager.shared.fetchFirst(Story.self, predicate: #Predicate { $0.id == uuid }) else { return }
            partialResult.append(story)
        }
        self.stories = stories
    }
}
