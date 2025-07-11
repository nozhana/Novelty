//
//  DonateView.swift
//  Novelty
//
//  Created by Nozhan A. on 7/12/25.
//

import SwiftUI

struct DonateView: View {
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
