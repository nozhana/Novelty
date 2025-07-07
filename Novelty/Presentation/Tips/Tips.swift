//
//  Tips.swift
//  Novelty
//
//  Created by Nozhan A. on 7/7/25.
//

import TipKit
import SwiftUI

struct EditStoryTip: Tip {
    var title: Text {
        Text("Edit Content")
    }
    
    var message: Text? {
        Text("Edit the content of this page by double tapping on it.")
    }
    
    var image: Image? {
        Image(systemName: "hand.point.up.left")
    }
}

struct QuickLinkTip: Tip {
    var title: Text {
        Text("Quick Link")
    }
    
    var message: Text? {
        Text("Tap and hold on the link button to quickly link to another page.")
    }
    
    var image: Image? {
        Image(systemName: "link.badge.plus")
    }
}
