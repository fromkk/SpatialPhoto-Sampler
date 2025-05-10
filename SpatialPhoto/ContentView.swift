//
//  ContentView.swift
//  SpatialPhoto
//
//  Created by Kazuya Ueoka on 2025/05/10.
//

import Photos
import PhotosUI
import SwiftUI

struct ContentView: View {

  @State var isPresented: Bool = false
  @State var selectedItem: PhotosPickerItem?
  @State var imageURL: URL?
  @State var leftImage: CGImage?
  @State var rightImage: CGImage?
  @State var orientation: Image.Orientation? = nil

  @State var value: Double = 0

  var body: some View {
    VStack(spacing: 16) {
      if selectedItem != nil {
        if let leftImage, let rightImage {
          HStack(spacing: 8) {
            Image(decorative: leftImage, scale: 1, orientation: orientation ?? .up)
              .resizable()
              .aspectRatio(contentMode: .fit)

            Image(decorative: rightImage, scale: 1, orientation: orientation ?? .up)
              .resizable()
              .aspectRatio(contentMode: .fit)
          }
        } else if let imageURL {
          AsyncImage(url: imageURL) {
            switch $0 {
            case let .success(image):
              image
                .resizable()
                .aspectRatio(contentMode: .fit)
            default:
              ProgressView()
            }
          }
        } else {
          ProgressView()
        }
      }

      Button {
        isPresented = true
      } label: {
        Text("Pick Spatial Image")
      }
      .buttonStyle(.borderedProminent)
    }
    .padding()
    .photosPicker(
      isPresented: $isPresented,
      selection: Binding<PhotosPickerItem?>(
        get: {
          selectedItem
        },
        set: { pickerItem in
          selectedItem = pickerItem
          Task {
            if let pickerItem {
              try await loadImage(from: pickerItem)
            }
          }
        }
      ),
      matching: matching()
    )
  }

  private func matching() -> PHPickerFilter {
    if #available(iOS 18.0, *) {
      return .spatialMedia
    } else {
      return .images
    }
  }

  private func loadImage(from item: PhotosPickerItem) async throws {
    let data = try await item.loadTransferable(type: Data.self)

    switch data?.orientation {
    case .up:
      orientation = .up
    case .upMirrored:
      orientation = .upMirrored
    case .down:
      orientation = .down
    case .downMirrored:
      orientation = .downMirrored
    case .left:
      orientation = .left
    case .leftMirrored:
      orientation = .leftMirrored
    case .right:
      orientation = .right
    case .rightMirrored:
      orientation = .rightMirrored
    case nil:
      orientation = .up
    }

    if let splitImages = data?.splitImages {
      leftImage = splitImages.0
      rightImage = splitImages.1
    } else {
      imageURL = try data?.copyToTemporaryDirectory()
    }
  }
}

#Preview {
  ContentView()
}
