//
//  ContentView.swift
//  SpatialPhoto
//
//  Created by Kazuya Ueoka on 2025/05/10.
//

import Photos
import PhotosUI
import SwiftUI

enum ComparisonMode {
  case sideBySide
  case verticalSideBySide
  case overlay
  case slide
}

enum OverlayMode: String, CaseIterable {
  case motionManager
  case manual
}

struct SplitSpatialPhotoView: View {
  @Bindable var motionManager = MotionManager()

  @State var isPresented: Bool = false
  @State var selectedItem: PhotosPickerItem?
  @State var imageURL: URL?
  @State var leftImage: CGImage?
  @State var rightImage: CGImage?
  @State var orientation: Image.Orientation? = nil

  @State var value: Double = 0
  @State var comparisonMode: ComparisonMode = .sideBySide
  @State var overlayMode: OverlayMode = .motionManager

  var adjustedValue: CGFloat {
    if overlayMode == .motionManager {
      // value = 0 (左傾き), 0.1 (中央), 0.2 (右傾き) にマッピング
      let normalizedValue = min(max((motionManager.deviceTilt + .pi / 4) / (.pi / 2), 0), 1)
      return 0.1 + (normalizedValue - 0.5) * 0.2
    } else {
      return value
    }
  }

  var body: some View {
    NavigationStack {
      VStack(spacing: 16) {
        if selectedItem != nil {
          if let leftImage, let rightImage {
            switch comparisonMode {
            case .sideBySide:
              HStack(spacing: 8) {
                Image(
                  decorative: leftImage,
                  scale: 1,
                  orientation: orientation ?? .up
                )
                .resizable()
                .aspectRatio(contentMode: .fit)

                Image(
                  decorative: rightImage,
                  scale: 1,
                  orientation: orientation ?? .up
                )
                .resizable()
                .aspectRatio(contentMode: .fit)
              }
            case .verticalSideBySide:
              VStack(spacing: 8) {
                Image(
                  decorative: leftImage,
                  scale: 1,
                  orientation: orientation ?? .up
                )
                .resizable()
                .aspectRatio(contentMode: .fit)

                Image(
                  decorative: rightImage,
                  scale: 1,
                  orientation: orientation ?? .up
                )
                .resizable()
                .aspectRatio(contentMode: .fit)
              }
            case .overlay:
              ZStack {
                Image(
                  decorative: leftImage,
                  scale: 1,
                  orientation: orientation ?? .up
                )
                .resizable()
                .aspectRatio(contentMode: .fit)

                Image(
                  decorative: rightImage,
                  scale: 1,
                  orientation: orientation ?? .up
                )
                .resizable()
                .aspectRatio(contentMode: .fit)
                .mask(alignment: .leading) {
                  GeometryReader { proxy in
                    Rectangle()
                      .frame(maxWidth: proxy.size.width * value)
                  }
                }
              }

              Slider(value: $value, in: 0...1)
            case .slide:
              ZStack {
                GeometryReader { proxy in
                  Image(
                    decorative: leftImage,
                    scale: 1,
                    orientation: orientation ?? .up
                  )
                  .resizable()
                  .aspectRatio(contentMode: .fit)
                  .offset(x: -proxy.size.width * adjustedValue)

                  Image(
                    decorative: rightImage,
                    scale: 1,
                    orientation: orientation ?? .up
                  )
                  .resizable()
                  .aspectRatio(contentMode: .fit)
                  .opacity(0.5)
                  .offset(x: proxy.size.width * adjustedValue)
                  .blendMode(.normal)
                }
              }
              .compositingGroup()
              .padding()

              Slider(
                value: overlayMode == .motionManager ? .constant(adjustedValue) : $value,
                in: -0.2...0.2)
              Text("\(adjustedValue)")

              Picker(
                selection: $overlayMode,
                content: {
                  ForEach(OverlayMode.allCases, id: \.self) {
                    Text($0.rawValue)
                  }
                },
                label: {
                  Text("Overlay Mode")
                }
              )
              .pickerStyle(.segmented)
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
      .toolbar {
        ToolbarItem(placement: .primaryAction) {
          HStack(spacing: 8) {
            switch comparisonMode {
            case .overlay:
              Button {
                comparisonMode = .sideBySide
              } label: {
                Image(systemName: "rectangle.split.2x1")
              }
              .accessibilityLabel(Text("Side by side"))

              Button {
                comparisonMode = .verticalSideBySide
              } label: {
                Image(systemName: "rectangle.split.1x2")
              }
              .accessibilityLabel(Text("Vertical side by side"))

              Button {
                comparisonMode = .slide
              } label: {
                Image(systemName: "square.stack.3d.down.forward")
              }
              .accessibilityLabel(Text("Slide"))
            case .sideBySide:
              Button {
                comparisonMode = .verticalSideBySide
              } label: {
                Image(systemName: "rectangle.split.1x2")
              }
              .accessibilityLabel(Text("Vertical side by side"))

              Button {
                comparisonMode = .overlay
              } label: {
                Image(systemName: "rectangle.on.rectangle")
              }
              .accessibilityLabel(Text("Overlay"))

              Button {
                comparisonMode = .slide
              } label: {
                Image(systemName: "square.stack.3d.down.forward")
              }
              .accessibilityLabel(Text("Slide"))
            case .verticalSideBySide:
              Button {
                comparisonMode = .sideBySide
              } label: {
                Image(systemName: "rectangle.split.2x1")
              }
              .accessibilityLabel(Text("Side by side"))

              Button {
                comparisonMode = .overlay
              } label: {
                Image(systemName: "rectangle.on.rectangle")
              }
              .accessibilityLabel(Text("Overlay"))

              Button {
                comparisonMode = .slide
              } label: {
                Image(systemName: "square.stack.3d.down.forward")
              }
              .accessibilityLabel(Text("Slide"))
            case .slide:
              Button {
                comparisonMode = .sideBySide
              } label: {
                Image(systemName: "rectangle.split.2x1")
              }
              .accessibilityLabel(Text("Side by side"))

              Button {
                comparisonMode = .verticalSideBySide
              } label: {
                Image(systemName: "rectangle.split.1x2")
              }
              .accessibilityLabel(Text("Vertical side by side"))

              Button {
                comparisonMode = .overlay
              } label: {
                Image(systemName: "rectangle.on.rectangle")
              }
              .accessibilityLabel(Text("Overlay"))
            }
          }
        }
      }
    }
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
  SplitSpatialPhotoView()
}
