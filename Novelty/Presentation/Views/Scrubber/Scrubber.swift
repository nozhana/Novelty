//
//  Scrubber.swift
//  Novelty
//
//  Created by Nozhan A. on 7/10/25.
//

import SwiftUI

struct Scrubber<CurrentValueLabel: View>: View {
    @Binding var value: CGFloat
    var range: ClosedRange<CGFloat>
    var step: CGFloat = 1
    @ViewBuilder var currentValueLabel: () -> CurrentValueLabel
    
    @State private var selectedRidge: Int?
    
    init(value: Binding<CGFloat>, in range: ClosedRange<CGFloat>, step: CGFloat, @ViewBuilder currentValueLabel: @escaping () -> CurrentValueLabel) {
        self._value = value
        self.range = range
        self.step = step
        self.currentValueLabel = currentValueLabel
        let ridgeValues = stride(from: range.lowerBound, through: range.upperBound, by: step).map(\.self)
        if let ridge = ridgeValues.firstIndex(where: { $0 >= value.wrappedValue }) {
            self._selectedRidge = .init(initialValue: ridge)
        }
    }
    
    var body: some View {
        GeometryReader { proxy in
            ScrollView {
                LazyVStack(spacing: 16) {
                    let ridges = Int((range.upperBound - range.lowerBound) / step) + 1
                    ForEach(0..<ridges, id: \.self) { ridge in
                        Group {
                            if ridge.isMultiple(of: 5) {
                                Capsule()
                                    .fill(.primary)
                                    .frame(height: 1.5)
                                    .safeAreaInset(edge: .leading, spacing: 4) {
                                        let ridgeValue = range.lowerBound + CGFloat(ridge) * step
                                        Text(ridgeValue, format: .number.precision(.fractionLength(0...1)))
                                            .font(.system(size: 10, weight: .light))
                                    }
                            } else {
                                Capsule()
                                    .fill(.secondary)
                                    .frame(height: 1)
                                    .padding(.horizontal, 4)
                            }
                        }
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(width: 32, height: 0)
                    }
                    .scrollTransition(.interactive.threshold(.centered)) { content, phase in
                        content
                            .scaleEffect(phase.isIdentity ? 1 : 0.6)
                            .blur(radius: phase.isIdentity ? 0 : 1.4)
                            .opacity(phase.isIdentity ? 1 : 0.6)
                    }
                }
                .safeAreaPadding(.vertical, proxy.size.height / 2)
                .scrollTargetLayout()
            }
            .scrollIndicators(.hidden)
            .scrollTargetBehavior(.viewAligned(limitBehavior: .always))
            .scrollPosition(id: $selectedRidge, anchor: .center)
            .sensoryFeedback(trigger: selectedRidge) { oldValue, newValue in
                if let oldValue, let newValue {
                    return newValue > oldValue ? .increase : .decrease
                }
                return .impact
            }
        }
        .overlay {
            Capsule()
                .fill(.tint)
                .frame(width: 44, height: 1)
        }
        .onChange(of: selectedRidge) { _, newValue in
            guard let newValue else { return }
            let ridgeValues = stride(from: range.lowerBound, through: range.upperBound, by: step).map(\.self)
            let value = ridgeValues[newValue]
            self.value = value
        }
    }
}

extension Scrubber where CurrentValueLabel == EmptyView {
    init(value: Binding<CGFloat>, in range: ClosedRange<CGFloat>, step: CGFloat = 1) {
        self.init(value: value, in: range, step: step) {
            EmptyView()
        }
    }
}

#Preview {
    @Previewable @State var value: CGFloat = 67
    
    VStack(spacing: 64) {
        Scrubber(value: $value, in: 0...100)
            .frame(height: 200)
        
        Text(value, format: .number)
    }
}
