//
//  DonateView.swift
//  Novelty
//
//  Created by Nozhan A. on 7/12/25.
//

import CoreImage.CIFilterBuiltins
import SwiftUI

struct DonateView: View {
    @State private var coin: Constants.CryptoCoin?
    
    var body: some View {
        List {
            ForEach(Constants.CryptoCoin.allCases) { coin in
                LabeledContent {
                    Text(coin.walletAddress)
                        .font(.caption.monospaced())
                        .lineLimit(1)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: 140, alignment: .trailing)
                } label: {
                    Button {
                        self.coin = coin
                    } label: {
                        HStack(spacing: 6) {
                            Image(coin.icon)
                            Text(coin.title)
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
        .sheet(item: $coin, content: DonateDetailView.init)
    }
}

#Preview {
    DonateView()
}

private struct DonateDetailView: View {
    var coin: Constants.CryptoCoin
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var copyTrigger = 0
    
    private let context = CIContext()
    private let qrFilter = CIFilter.qrCodeGenerator()
    
    private func generateQRCode(from string: String) -> UIImage {
        guard let data = string.data(using: .utf8) else { return .init(ciImage: .red) }
        qrFilter.message = data
        guard let outputImage = qrFilter.outputImage,
              let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else { return .init(ciImage: .red) }
        return UIImage(cgImage: cgImage)
    }
    
    private var trustWalletURLAddress: String {
        "https://link.trustwallet.com/send?asset=\(coin.uai)&address=\(coin.walletAddress)&memo=Donation%20to%20Novelty%20developers"
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Image(uiImage: generateQRCode(from: trustWalletURLAddress))
                    .interpolation(.none)
                    .resizable()
                    .scaledToFit()
                
                Button(coin.walletAddress, systemImage: "link") {
                    UIPasteboard.general.string = coin.walletAddress
                    copyTrigger += 1
                }
                .foregroundStyle(.secondary)
                .font(.system(.caption, design: .monospaced, weight: .bold))
                .buttonStyle(.bordered)
                .buttonBorderShape(.capsule)
                .safeAreaInset(edge: .bottom, spacing: 16) {
                    Label("Copied to clipboard.", systemImage: "link")
                        .font(.callout.width(.condensed).bold())
                        .foregroundStyle(.secondary)
                        .phaseAnimator([0.0, 1.0], trigger: copyTrigger) { content, phase in
                            content
                                .scaleEffect(phase, anchor: .top)
                                .opacity(phase)
                        } animation: { phase in
                                .snappy.delay(phase == 0 ? 1 : 0)
                        }
                        .padding(.bottom, 36)
                }
                
                Link(destination: URL(string: trustWalletURLAddress)!) {
                    Label("Donate using Trust Wallet", systemImage: "wallet.pass")
                }
                .font(.headline.bold())
                .buttonStyle(.borderedProminent)
                .buttonBorderShape(.capsule)
            }
            .safeAreaPadding(.horizontal, 44)
            .safeAreaPadding(.vertical, 24)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Label(coin.title, image: coin.icon)
                        .bold()
                        .labelStyle(.titleAndIcon)
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Dismiss", systemImage: "checkmark") {
                        dismiss()
                    }
                }
            }
        }
    }
}
