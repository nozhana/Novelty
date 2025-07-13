//
//  PasswordWallView.swift
//  Novelty
//
//  Created by Nozhan A. on 7/10/25.
//

import SwiftUI

struct PasswordWallView: View {
    var password: String
    var onUnlocked: (() -> Void)?
    
    var body: some View {
        if let pinCode = Int(password),
           password.count == 4 {
            PinCodeView(code: pinCode, onUnlocked: onUnlocked)
        } else {
            // TextPasswordView(password: password, onUnlocked: onUnlocked)
            EmptyView()
        }
    }
}

#Preview {
    PasswordWallView(password: "1234")
}

private struct PinCodeView: View {
    var code: Int
    var onUnlocked: (() -> Void)?
    
    @State private var resolved = false
    @State private var inputCode: String = ""
    @State private var incorrectCount = 0
    
    var body: some View {
        if !resolved {
            ZStack {
                Rectangle()
                    .fill(.ultraThinMaterial)
                    .ignoresSafeArea()
                    .transition(.opacity)
                
                VStack(spacing: 24) {
                    Spacer()
                    
                    HStack(spacing: 24) {
                        ForEach(0..<4) { index in
                            let isFilled = inputCode.map(\.self).indices.contains(index)
                            Circle()
                                .fill(isFilled ? .primary : .tertiary)
                                .animation(.smooth, value: isFilled)
                                .frame(width: 20, height: 20)
                        }
                    }
                    .phaseAnimator([0.0, -8, 8, -6, 6, -4, 4, -2, 2], trigger: incorrectCount) { content, phase in
                        content
                            .offset(x: phase)
                            .rotationEffect(.degrees(phase))
                            .brightness(abs(phase) / 10)
                    } animation: { phase in
                        .linear(duration: 0.05)
                    }
                    .transition(.move(edge: .top).combined(with: .blurReplace))
                    
                    Spacer()
                    
                    if !inputCode.isEmpty {
                        Button("Clear", systemImage: "clear", role: .destructive) {
                            withAnimation(.smooth) {
                                inputCode.removeAll()
                            }
                        }
                        .transition(.move(edge: .trailing).combined(with: .offset(x: 20)).animation(.smooth))
                        .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                    
                    Grid(horizontalSpacing: 12, verticalSpacing: 12) {
                        ForEach(0..<4) { index in
                            let numbers = index == 3 ? [0] : (1...3).map { index * 3 + $0 }
                            GridRow {
                                ForEach(numbers, id:  \.self) { number in
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(.fill.tertiary)
                                        .overlay {
                                            Text(number, format: .number)
                                                .font(.largeTitle.bold())
                                        }
                                        .asButton {
                                            if inputCode.count < 4 {
                                                withAnimation(.smooth) {
                                                    inputCode.append("\(number)")
                                                }
                                            }
                                            if inputCode.count == 4 {
                                                withAnimation(.smooth) {
                                                    if inputCode == String(code) {
                                                        resolved = true
                                                        onUnlocked?()
                                                    } else {
                                                        inputCode.removeAll()
                                                        withTransaction(\.disablesAnimations, true) {
                                                            incorrectCount += 1
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                        .gridCellColumns(3 / numbers.count)
                                }
                            }
                        }
                    }
                    .aspectRatio(1.2, contentMode: .fit)
                    .transition(.move(edge: .bottom).combined(with: .blurReplace))
                }
                .safeAreaPadding(.horizontal, 16)
                .safeAreaPadding(.vertical, 24)
            }
        }
    }
}

private struct TextPasswordView: View {
    var password: String
    var onUnlocked: (() -> Void)?
    
    var body: some View {
        Text(password)
            .font(.title.bold())
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.ultraThinMaterial)
    }
}
