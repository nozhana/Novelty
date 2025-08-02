//
//  LanguageSettingsView.swift
//  Novelty
//
//  Created by Nozhan A. on 7/30/25.
//

import SwiftUI

struct LanguageSettingsView: View {
    init() {
        self._languageToSet = .init(initialValue: Localizer.shared.language)
    }
    
    @State private var languageToSet: Language
    
    @EnvironmentObject private var localizer: Localizer
    
    var body: some View {
        List {
            ForEach(Language.allCases) { language in
                Button {
                    withAnimation(.smooth) {
                        languageToSet = language
                    }
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(language.displayName)
                            if language != .en {
                                Text(language.englishDisplayName)
                                    .font(.caption)
                            }
                        }
                        
                        Spacer()
                        
                        if languageToSet == language {
                            Image(systemName: "checkmark")
                                .padding(.trailing, 8)
                                .transition(.move(edge: .trailing).combined(with: .opacity))
                        }
                    }
                }
            }
        }
        .navigationTitle("Language")
        .onDisappear {
            if localizer.language != languageToSet {
                DispatchQueue.main.async {
                    localizer.language  = languageToSet
                }
            }
        }
    }
}

#Preview {
    LanguageSettingsView()
}
