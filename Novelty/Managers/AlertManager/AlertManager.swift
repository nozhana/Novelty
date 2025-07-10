//
//  AlertManager.swift
//  Novelty
//
//  Created by Nozhan A. on 7/10/25.
//

import SwiftUI

final class AlertManager: ObservableObject {
    static let shared = AlertManager()
    private init() {}
    
    @Published private(set) var alert: AlertContent?
    @Published var isPresented = false
    
    @MainActor
    func present(_ alert: AlertContent) {
        self.alert = alert
        self.isPresented = true
    }
    
    @MainActor
    func present(title: String, message: String, actions: [AlertAction] = []) {
        present(.init(title: title, message: message, actions: actions))
    }
}

struct AlertContent: Identifiable {
    var id = UUID()
    var title: String
    var message: String
    var actions: [AlertAction]
}

enum AlertAction: Identifiable {
    case `default`(_ title: String, action: () -> Void)
    case cancel(_ title: String = "Cancel", action: () -> Void)
    case destructive(_ title: String, action: () -> Void)
    
    var title: String {
        switch self {
        case .default(let title, _): title
        case .cancel(let title, _): title
        case .destructive(let title, _): title
        }
    }
    
    var action: () -> Void {
        switch self {
        case .default(_, let action): action
        case .cancel(_, let action): action
        case .destructive(_, let action): action
        }
    }
    
    var role: ButtonRole? {
        switch self {
        case .default: nil
        case .cancel: .cancel
        case .destructive: .destructive
        }
    }
    
    var id: String {
        title
    }
}

extension View {
    func alertManager(_ manager: AlertManager) -> some View {
        @ObservedObject var bindable = manager
        return self
            .alert(manager.alert?.title ?? "", isPresented: $bindable.isPresented, presenting: manager.alert) { alertContent in
                ForEach(alertContent.actions) { action in
                    Button(action.title, role: action.role, action: action.action)
                }
            } message: { alertContent in
                Text(alertContent.message)
            }
            .environmentObject(manager)
    }
}

extension AlertManager {
    @MainActor
    func presentImportStoryAlert(for storyDto: StoryDTO) {
        present(title: "Import \"\(storyDto.title ?? "Untitled Story")\"", message: "Would you like to save \"\(storyDto.title ?? "Untitled Story")\" to your stories?", actions: [.default("Save", action: {
            let story = Story(dto: storyDto)
            let database = DatabaseManager.shared
            database.save(story)
            database.undoManager.addManager(for: story.id)
            database.registerUndo("Import \(story.title ?? "Untitled Story")", for: story.id) {
                database.deleteStories([story])
                Router.shared.stories.removeAll(of: story)
            }
        }), .cancel {}])
    }
}
