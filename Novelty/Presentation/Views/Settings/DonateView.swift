//
//  DonateView.swift
//  Novelty
//
//  Created by Nozhan A. on 7/12/25.
//

import SwiftUI

struct DonateView: View {
    @State private var copyTrigger = 0
    
    var body: some View {
        List {
            ForEach(Constants.CryptoWalletAddress.allCases) { wallet in
                LabeledContent {
                    Text(wallet.walletAddress)
                        .font(.caption.monospaced())
                        .lineLimit(1)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: 140, alignment: .trailing)
                } label: {
                    Button {
                        UIPasteboard.general.string = wallet.walletAddress
                        copyTrigger += 1
                    } label: {
                        HStack(spacing: 6) {
                            Image(wallet.icon)
                            Text(wallet.title)
                                .font(.callout)
                        }
                    }
                }
                .labelStyle(.titleAndIcon)
            }
        }
        .safeAreaInset(edge: .bottom) {
            Label("Copied to clipboard.", systemImage: "link")
                .font(.callout.width(.condensed).bold())
                .foregroundStyle(.secondary)
                .phaseAnimator([0.0, 1.0], trigger: copyTrigger) { content, phase in
                    content
                        .scaleEffect(phase, anchor: .bottom)
                        .opacity(phase)
                } animation: { phase in
                        .snappy.delay(phase == 0 ? 1 : 0)
                }
                .padding(.bottom, 36)
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Label("Buy me a coffee", systemImage: "mug")
                    .font(.headline.weight(.semibold).width(.condensed))
                    .labelStyle(.titleAndIcon)
                    .foregroundStyle(.orange.gradient)
            }
        }
    }
}

#Preview {
    DonateView()
}
