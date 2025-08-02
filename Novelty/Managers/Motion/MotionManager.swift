//
//  MotionManager.swift
//  Novelty
//
//  Created by Nozhan A. on 7/16/25.
//

import Foundation
import CoreMotion

final class MotionManager: ObservableObject {
    private let manager = CMMotionManager()
    
    static let shared = MotionManager()
    private init() {}
    
    @Published var deviceMotion: CMDeviceMotion?
    
    func startDeviceMotionUpdates() {
        manager.deviceMotionUpdateInterval = 0.01
        manager.startDeviceMotionUpdates(to: .main) { [weak self] motion, error in
            if let error {
                print("Failed to start device motion updates: \(error)")
                return
            }
            
            self?.deviceMotion = motion
        }
    }
    
    func stopDeviceMotionUpdates() {
        manager.stopDeviceMotionUpdates()
    }
}
