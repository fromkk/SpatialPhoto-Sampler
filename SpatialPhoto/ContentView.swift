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

struct ContentView: View {

  @State var isPresented: Bool = false
  @State var selectedItem: PhotosPickerItem?
  @State var imageURL: URL?
  @State var leftImage: CGImage?
  @State var rightImage: CGImage?
  @State var orientation: Image.Orientation? = nil

  @State var value: Double = 0
  @State var comparisonMode: ComparisonMode = .sideBySide

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
                  ZStack {
                    Image(
                      decorative: leftImage,
                      scale: 1,
                      orientation: orientation ?? .up
                    )
                    .resizable()
                    .aspectRatio(contentMode: .fit)

                    LinearGradient(
                      gradient: Gradient(
                        colors: [
                          .black.opacity(0),
                          .black.opacity(0.5),
                        ]
                      ),
                      startPoint: .leading,
                      endPoint: .trailing
                    )
                    .blendMode(.destinationOut)
                  }
                  .compositingGroup()
                  .offset(x: -proxy.size.width * value)

                  ZStack {
                    Image(
                      decorative: rightImage,
                      scale: 1,
                      orientation: orientation ?? .up
                    )
                    .resizable()
                    .aspectRatio(contentMode: .fit)

                    LinearGradient(
                      gradient: Gradient(
                        colors: [
                          .black.opacity(0),
                          .black.opacity(0.5),
                        ]
                      ),
                      startPoint: .trailing,
                      endPoint: .leading
                    )
                    .blendMode(.destinationOut)
                  }
                  .compositingGroup()
                  .offset(x: proxy.size.width * value)
                }
              }

              Slider(value: $value, in: 0...0.03)
              Text("\(value)")
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
  ContentView()
}
