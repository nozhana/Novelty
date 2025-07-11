//
//  NearbyView.swift
//  Novelty
//
//  Created by Nozhan A. on 7/11/25.
//

import SwiftUI

struct NearbyView: View {
    @EnvironmentObject private var manager: NearbyConnectionManager
    
    @Environment(\.dismiss) private var dismiss
    
    @Keychain(itemClass: .password, key: .storyPasswords) private var storyPasswords: [UUID: String]?
    
    @State private var peerForStoriesPickerView: NearbyPeer?
    
    @ObservedObject private var alertManager = AlertManager.nearbyView
    
    var body: some View {
        NavigationStack {
            ZStack {
                if manager.isAdvertising {
                    PhaseAnimator([0, 1]) { phase in
                        Circle()
                            .fill(.tint.secondary)
                            .opacity(Double(1 - phase))
                            .blur(radius: CGFloat(phase * 64))
                            .brightness(Double(phase * 0.2))
                            .scaleEffect(CGFloat(phase))
                    } animation: { phase in
                        phase == 0 ? nil : .easeOut(duration: 1.2).delay(1)
                    }
                    .frame(width: 300, height: 300)
                    .transition(.opacity)
                    
                    Label("You", systemImage: "person.fill")
                        .labelStyle(.vertical(spacing: 6))
                        .font(.callout.bold())
                        .padding(24)
                        .background(Circle().stroke(.fill.tertiary, lineWidth: 2))
                        .background(.ultraThinMaterial, in: .circle)
                        .transition(.scale.combined(with: .opacity))
                } else {
                    Button("Become available", systemImage: "wifi") {
                        withAnimation(.smooth) {
                            manager.isAdvertising = true
                            manager.isBrowsing = true
                        }
                    }
                    .transition(.scale.combined(with: .opacity))
                }
                
                RadialLayout {
                    ForEach(manager.peers.sorted(using: KeyPathComparator(\.peerID.displayName))) { peer in
                        Label(peer.peerID.displayName, systemImage: "person")
                            .labelStyle(.vertical(spacing: 6))
                            .font(.caption.bold())
                            .safeAreaInset(edge: .bottom, spacing: 4) {
                                if let deviceModel = peer.deviceModel {
                                    Text(deviceModel)
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                }
                                if peer.status == .connected {
                                    Image(systemName: "wifi")
                                        .font(.subheadline.bold())
                                        .imageScale(.small)
                                        .foregroundStyle(.green.gradient)
                                }
                            }
                            .padding(18)
                            .background(Circle().stroke(.fill.tertiary, lineWidth: 2))
                            .background(.ultraThinMaterial, in: .circle)
                            .blur(radius: peer.status == .connecting ? 6 : 0)
                            .overlay {
                                if peer.status == .connecting {
                                    Image(systemName: "ellipsis")
                                        .symbolEffect(.bounce.up.byLayer)
                                        .imageScale(.large)
                                }
                            }
                            .asButton {
                                switch peer.status {
                                case .found:
                                    manager.invite(peer)
                                case .connecting:
                                    break
                                case .connected:
                                    peerForStoriesPickerView = peer
                                }
                            }
                    }
                }
            }
            .navigationDestination(item: $peerForStoriesPickerView) { peer in
                NearbyStoriesPickerView(targetPeer: peer)
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        manager.isAdvertising = false
                        manager.isBrowsing = false
                        manager.disconnectSession()
                        dismiss()
                    }
                }
            }
            .navigationTitle("Nearby users")
            .alertManager(alertManager)
        }
    }
}

#Preview {
    NearbyView()
        .environmentObject(NearbyConnectionManager())
}
