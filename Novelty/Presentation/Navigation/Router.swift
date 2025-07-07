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
    
    @MainActor
    func process(_ url: URL) {
        let stories = url.absoluteString.split(separator: ":").map(String.init).reduce(into: [Story]()) { partialResult, component in
            guard let uuid = UUID(uuidString: component),
                  let story = DatabaseManager.shared.fetchFirst(Story.self, predicate: #Predicate { $0.id == uuid }) else { return }
            partialResult.append(story)
        }
        self.stories = stories
    }
}
