//
//  NearbyConnectionManager.swift
//  Novelty
//
//  Created by Nozhan A. on 7/11/25.
//

import Foundation
import MultipeerConnectivity

final class NearbyConnectionManager: NSObject, MCSessionDelegate, MCNearbyServiceAdvertiserDelegate, MCNearbyServiceBrowserDelegate, ObservableObject {
    // MARK: - Private
    private let peerID = MCPeerID(displayName: UIDevice.current.name)
    private lazy var session = {
        let session = MCSession(peer: peerID)
        session.delegate = self
        return session
    }()
    private lazy var advertiser = {
        let advertiser = MCNearbyServiceAdvertiser(peer: peerID, discoveryInfo: Constants.multipeerDiscoveryInfo, serviceType: Constants.multipeerServiceType)
        advertiser.delegate = self
        return advertiser
    }()
    private lazy var browser = {
        let browser = MCNearbyServiceBrowser(peer: peerID, serviceType: Constants.multipeerServiceType)
        browser.delegate = self
        return browser
    }()
    
    private var dataHandler: ((Data, NearbyPeer) -> Void)?
    
    // MARK: - Default Instance
    static func `default`() -> NearbyConnectionManager {
        NearbyConnectionManager()
            .onData { data, _ in
                if let storyDto = try? JSONDecoder().decode(StoryDTO.self, from: data) {
                    DispatchQueue.main.async {
                        AlertManager.shared.presentImportStoryAlert(for: storyDto)
                    }
                } else if let base64DecodedData = Data(base64Encoded: data),
                          let storyDto = try? JSONDecoder().decode(StoryDTO.self, from: base64DecodedData) {
                    DispatchQueue.main.async {
                        AlertManager.shared.presentImportStoryAlert(for: storyDto)
                    }
                } else if let passwordProtectedStoryDto = try? JSONDecoder().decode(PasswordProtectedStoryDTO.self, from: data) {
                    DispatchQueue.main.async {
                        AlertManager.shared.presentImportPasswordProtectedStoryAlert(for: passwordProtectedStoryDto)
                    }
                }
            }
    }
    
    // MARK: - Public
    var isConnected: Bool {
        !session.connectedPeers.isEmpty
    }
    
    // MARK: - Published
    @Published var isAdvertising = false {
        willSet {
            if newValue {
                advertiser.startAdvertisingPeer()
            } else {
                advertiser.stopAdvertisingPeer()
            }
        }
    }
    
    @Published var isBrowsing = false {
        willSet {
            if newValue {
                browser.startBrowsingForPeers()
            } else {
                browser.stopBrowsingForPeers()
            }
        }
    }
    
    @Published private(set) var peers: Set<NearbyPeer> = []
    
    // MARK: - Public methods
    @discardableResult
    func onData(handler: @Sendable @escaping (_ data: Data, _ peerID: NearbyPeer) -> Void) -> NearbyConnectionManager {
        dataHandler = handler
        return self
    }
    
    func disconnectSession() {
        session.disconnect()
    }
    
    func invite(_ peer: NearbyPeer) {
        browser.invitePeer(peer.peerID, to: session, withContext: nil, timeout: 30)
    }
    
    func send<Value>(_ value: Value, to peer: NearbyPeer) where Value: Codable {
        guard session.connectedPeers.contains(peer.peerID) else { return }
        do {
            let data = try JSONEncoder().encode(value)
            try session.send(data, toPeers: [peer.peerID], with: .reliable)
        } catch {
            print("Failed to send data to peer: \(peer) - \(value)")
        }
    }
    
    // MARK: - MCSession delegate methods
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case .notConnected:
            peers.removeAll(where: { $0.id == peerID })
        case .connecting:
            if var previousPeer = peers.first(where: { $0.id == peerID }) {
                previousPeer.status = .connecting
                peers.removeAll(where: { $0.id == peerID })
                peers.insert(previousPeer)
            } else {
                peers.insert(.init(peerID: peerID, status: .connecting))
            }
        case .connected:
            if var previousPeer = peers.first(where: { $0.id == peerID }) {
                previousPeer.status = .connected
                peers.removeAll(where: { $0.id == peerID })
                peers.insert(previousPeer)
            } else {
                peers.insert(.init(peerID: peerID, status: .connected))
            }
        @unknown default:
            break
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        let nearbyPeer = peers.first(where: { $0.id == peerID }) ?? .init(peerID: peerID, status: .connected)
        dataHandler?(data, nearbyPeer)
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        // Not implemented
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        // Not implemented
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: (any Error)?) {
        // Not implemented
    }
    
    // MARK: - MCNearbyServiceBrowser delegate methods
    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: any Error) {
        print("Failed to start browsing: \(error)")
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        if var peer = peers.first(where: { $0.id == peerID }),
            !session.connectedPeers.contains(peerID) {
            peer.status = .found
            peer.discoveryInfo = info ?? peer.discoveryInfo
            peers.removeAll { $0.id == peerID }
            peers.insert(peer)
        } else {
            peers.insert(.init(peerID: peerID, discoveryInfo: info ?? [:]))
        }
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        peers.removeAll(where: { $0.id == peerID })
    }
    
    // MARK: - MCNearbyServiceAdvertiser delegate methods
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: any Error) {
        print("Failed to start advertising: \(error)")
    }
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        guard let peer = peers.first(where: { $0.id == peerID }) else { return }
        DispatchQueue.main.async { [weak self] in
            AlertManager.nearbyView.presentNearbyInvitationAlert(from: peer) { invitationHandler($0, self?.session) }
        }
    }
}

struct NearbyPeer: Identifiable, Hashable {
    var peerID: MCPeerID
    var status: Status = .found
    var discoveryInfo: [String: String] = [:]
    
    var id: MCPeerID { peerID }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(peerID)
    }
    
    var deviceModel: String? {
        discoveryInfo["deviceModel"]
    }
}

extension NearbyPeer {
    enum Status: String {
        case found, connecting, connected
    }
}
