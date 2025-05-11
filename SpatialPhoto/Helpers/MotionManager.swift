//
//  MotionManager.swift
//  SpatialPhoto
//
//  Created by Kazuya Ueoka on 2025/05/11.
//

import Combine
import CoreMotion
import Foundation
import UIKit  // UIApplication を使うために必要

@Observable
final class MotionManager {
  private let motionManager = CMMotionManager()
  private let updateInterval = 1.0 / 60.0

  var roll: Double = 0.0  // y軸の傾き
  var pitch: Double = 0.0  // X軸の傾き (ラジアン値)

  // ステータスバーの向きを保持するプロパティ
  var interfaceOrientation: UIInterfaceOrientation = .unknown

  // 現在の向きに応じた傾きを返すプロパティ
  var deviceTilt: Double {
    switch interfaceOrientation {
    case .portrait, .portraitUpsideDown:
      return roll  // 縦向きの場合はY軸(roll)を使用
    case .landscapeLeft, .landscapeRight:
      return pitch  // 横向きの場合はX軸(pitch)を使用
    case .unknown:
      return roll  // 不明な場合はデフォルトでY軸(roll)を使用
    @unknown default:
      return roll
    }
  }

  init() {
    motionManager.deviceMotionUpdateInterval = updateInterval
    motionManager.startDeviceMotionUpdates(to: .main) { [weak self] motion, _ in
      guard let motion = motion, let self = self else { return }
      self.roll = motion.attitude.roll
      self.pitch = motion.attitude.pitch
      // 現在のステータスバーの向きを取得
      // SwiftUIのView階層から取得するのがより現代的だが、ここでは簡潔化のためUIApplicationを使う
      if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
        self.interfaceOrientation = windowScene.interfaceOrientation
      }
    }
  }

  deinit {
    motionManager.stopDeviceMotionUpdates()
  }
}
