//
//  Constants.swift
//  Novelty
//
//  Created by Nozhan A. on 7/7/25.
//

import UIKit

enum Constants {
    static let groupIdentifier = "group.com.nozhana.Novelty"
    
    static let githubUrl = URL(string: "https://github.com/nozhana")!
    
    static let cryptoIcons: [ImageResource] = [.bitcoin, .bitcoinCash, .ethereum, .litecoin, .tether, .tron]
    
    static let multipeerServiceType = "novelty-mc"
    static let multipeerDiscoveryInfo = ["deviceModel": UIDevice.current.model]
}

extension Constants {
    enum CryptoWalletAddress: String, Identifiable, CaseIterable {
        case bitcoin
        case bitcoinCash
        case ethereum
        case litecoin
        case tether
        case tron
        
        var id: String { rawValue }
        
        var icon: ImageResource {
            switch self {
            case .bitcoin:
                    .bitcoin
            case .bitcoinCash:
                    .bitcoinCash
            case .ethereum:
                    .ethereum
            case .litecoin:
                    .litecoin
            case .tether:
                    .tether
            case .tron:
                    .tron
            }
        }
        
        var title: String {
            switch self {
            case .bitcoin:
                "Bitcoin"
            case .bitcoinCash:
                "Bitcoin Cash"
            case .ethereum:
                "Ethereum"
            case .litecoin:
                "Litecoin"
            case .tether:
                "Tether (TRC-20)"
            case .tron:
                "Tron"
            }
        }
        
        var walletAddress: String {
            switch self {
            case .bitcoin:
                "bc1qlzksrv5p95nc55rdc3zfr4fumfqz3wra60xup3"
            case .bitcoinCash:
                "qrtn50jd3ys6l8en0zt4xfp028zgxgdxkqps0xk77u"
            case .ethereum:
                "0xdd8270B7Bb300973C11264BFd0b7Dcb49188A041"
            case .litecoin:
                "ltc1q3dpkp8drklumwt5uglhkgsq40n65q6tnpe0jkz"
            case .tether:
                "TXyeiRXPHQL1PMEi1uV4KpcXvXcHFyHHMb"
            case .tron:
                "TXyeiRXPHQL1PMEi1uV4KpcXvXcHFyHHMb"
            }
        }
    }
}
