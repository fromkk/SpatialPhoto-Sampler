//
//  Data+Temp.swift
//  SpatialPhoto
//
//  Created by Kazuya Ueoka on 2025/05/10.
//

import Foundation

extension Data {
  func copyToTemporaryDirectory() throws -> URL {
    let tempDirectoryURL = FileManager.default.temporaryDirectory
    let imageFormat = self.imageFormat
    let ext: String
    switch imageFormat {
    case .gif:
      ext = "gif"
    case .jpeg:
      ext = "jpg"
    case .png:
      ext = "png"
    case .heic:
      ext = "heic"
    case .unknown:
      fallthrough
    @unknown default:
      fatalError("Unsupported image format: \(imageFormat)")
    }
    let path = tempDirectoryURL.appendingPathComponent(UUID().uuidString).appendingPathExtension(
      ext)
    try write(to: path)
    return path
  }
}
