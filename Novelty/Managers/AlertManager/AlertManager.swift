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
    @Published var alertTextfieldContent = ""
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
    case textfield(_ title: String, secure: Bool = false)
    
    var title: String {
        switch self {
        case .default(let title, _): title
        case .cancel(let title, _): title
        case .destructive(let title, _): title
        case .textfield(let title, _): title
        }
    }
    
    var action: () -> Void {
        switch self {
        case .default(_, let action): action
        case .cancel(_, let action): action
        case .destructive(_, let action): action
        case .textfield: {}
        }
    }
    
    var role: ButtonRole? {
        switch self {
        case .default: nil
        case .cancel: .cancel
        case .destructive: .destructive
        case .textfield: nil
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
                    if case .textfield(let title, let secure) = action {
                        if secure {
                            SecureField(title, text: $bindable.alertTextfieldContent)
                                .keyboardType(.numberPad)
                        } else {
                            TextField(title, text: $bindable.alertTextfieldContent)
                                .keyboardType(.numberPad)
                        }
                    } else {
                        Button(action.title, role: action.role, action: action.action)
                    }
                }
            } message: { alertContent in
                Text(alertContent.message)
            }
            .environmentObject(manager)
    }
}

extension AlertManager {
    @MainActor
    func presentNearbyInvitationAlert(from peer: NearbyPeer, invitationHandler: @escaping (Bool) -> Void) {
        present(title: "Connect to \(peer.peerID.displayName)?", message: "\(peer.peerID.displayName) wants to connect.", actions: [
            .cancel("Refuse") { invitationHandler(false) },
            .default("Accept") { invitationHandler(true) }
        ])
    }
    
    @MainActor
    func presentImportStoryAlert(for storyDto: StoryDTO) {
        present(title: "Import \"\(storyDto.title ?? "Untitled Story")\"", message: "Would you like to save \"\(storyDto.title ?? "Untitled Story")\" to your stories?", actions: [.default("Save", action: {
            let story = Story(dto: storyDto)
            story.folder = .inbox
            let router = Router.shared
            let database = DatabaseManager.shared
            router.navigationPath = .init([StoryFolder.inbox])
            database.save(story)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                router.navigationPath.append(story)
            }
            database.undoManager.addManager(for: story.id)
            database.registerUndo("Import \(story.title ?? "Untitled Story")", for: story.id) {
                database.deleteStories([story])
                router.navigationPath = .init([story])
            }
            
        }), .cancel {}])
    }
    
    @MainActor
    func presentImportStoriesAlert(for storyDtos: [StoryDTO]) {
        present(title: "Import \(storyDtos.count) stories", message: "Would you like to save \(storyDtos.count) stories to your device?", actions: [.default("Save", action: {
            let database = DatabaseManager.shared
            var newStories = [Story]()
            for storyDto in storyDtos {
                let story = Story(dto: storyDto)
                story.folder = .inbox
                database.undoManager.addManager(for: story.id)
                newStories.append(story)
            }
            database.save(newStories)
            let router = Router.shared
            router.navigationPath = .init([StoryFolder.inbox])
        })])
    }
    
    @MainActor
    func presentImportPasswordProtectedStoryAlert(for storyDto: PasswordProtectedStoryDTO, retry: Bool = false) {
        present(title: "Import \"\(storyDto.title ?? "Untitled Story")\"", message: retry ? "Wrong password, try again." : "This story is password protected.", actions: [
            .textfield("Password", secure: true),
            .cancel { [weak self] in
                guard let self else { return }
                alertTextfieldContent.removeAll()
            },
            .default("Unbox") { [weak self] in
                guard let self else { return }
                do {
                    let unboxedStoryDto = try storyDto.storyBox.unbox(password: alertTextfieldContent)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        self.presentImportStoryAlert(for: unboxedStoryDto)
                    }
                } catch {
                    print("Failed to unbox story: \(error)")
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.presentImportPasswordProtectedStoryAlert(for: storyDto, retry: true)
                    }
                }
                alertTextfieldContent.removeAll()
            }
        ])
    }
}

extension AlertManager {
    static let nearbyView = AlertManager()
}
