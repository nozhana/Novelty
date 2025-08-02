//
//  Localizer.swift
//  Novelty
//
//  Created by Nozhan A. on 7/30/25.
//

import SwiftUI

final class Localizer: ObservableObject {
    static let shared = Localizer()
    private init() {
        if let languageId = UserDefaults.standard.stringArray(forKey: "AppleLanguages")?.first,
           let language = Language(rawValue: languageId) {
            self._language = .init(initialValue: language)
        } else {
            self._language = .init(initialValue: .en)
        }
    }
    
    @Published var language: Language {
        didSet {
            UserDefaults.standard.set([language.id], forKey: "AppleLanguages")
        }
    }
}

enum Language: String, Identifiable, CaseIterable {
    case en
    case fr
    case de
    case fa
    
    var id: String { rawValue }
    
    var locale: Locale {
        Locale(identifier: id)
    }
    
    var displayName: String {
        locale.localizedString(forIdentifier: id)?.capitalized ?? id
    }
    
    var englishDisplayName: String {
        Language.en.locale.localizedString(forIdentifier: id)?.capitalized ?? id
    }
    
    var layoutDirection: LayoutDirection {
        switch self {
        case .fa: .rightToLeft
        default: .leftToRight
        }
    }
}

extension View {
    func localized(_ localizer: Localizer = .shared) -> some View {
        self
            .environment(\.locale, localizer.language.locale)
            .environment(\.layoutDirection, localizer.language.layoutDirection)
            .environmentObject(localizer)
    }
}
