//
//  MotionManager.swift
//  SpatialPhoto
//
//  Created by Kazuya Ueoka on 2025/05/11.
//

import Combine
import CoreMotion
import Foundation

@Observable
final class MotionManager {
  private let motionManager = CMMotionManager()
  private let updateInterval = 1.0 / 60.0

  var roll: Double = 0.0  // y軸の傾き

  init() {
    motionManager.deviceMotionUpdateInterval = updateInterval
    motionManager.startDeviceMotionUpdates(to: .main) { [weak self] motion, _ in
      guard let motion = motion else { return }
      self?.roll = motion.attitude.roll  // ラジアン値
    }
  }

  deinit {
    motionManager.stopDeviceMotionUpdates()
  }
}
