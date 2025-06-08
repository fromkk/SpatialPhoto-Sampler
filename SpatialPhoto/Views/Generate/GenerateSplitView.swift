import CoreGraphics
import Photos
import PhotosUI
import SwiftUI

struct GenerateSplitView: View {
  @State var leftImage: CGImage?
  @State var rightImage: CGImage?

  @State var isLeftPhotosPickerPresented: Bool = false
  @State var isRightPhotosPickerPresented: Bool = false

  @State var leftPhotosPickerItem: PhotosPickerItem?
  @State var rightPhotosPickerItem: PhotosPickerItem?

  @State var leftImageOrientation: Image.Orientation?
  @State var rightImageOrientation: Image.Orientation?

  enum ImageType {
    case left
    case right
  }

  var body: some View {
    VStack {
      HStack(spacing: 16) {
        Button {
          isLeftPhotosPickerPresented = true
        } label: {
          VStack {
            if let leftImage {
              Image(
                decorative: leftImage,
                scale: 1,
                orientation: leftImageOrientation ?? .up
              )
              .resizable()
              .aspectRatio(1, contentMode: .fit)
            } else {
              Image(systemName: "photo")
                .font(.largeTitle)
            }
          }
          .frame(maxWidth: .infinity, maxHeight: .infinity)
          .background(Color.accentColor.opacity(0.1))
          .aspectRatio(1, contentMode: .fit)
          .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .photosPicker(
          isPresented: $isLeftPhotosPickerPresented,
          selection: Binding(
            get: {
              leftPhotosPickerItem
            },
            set: {
              leftPhotosPickerItem = $0
              loadImage(from: $0, imageType: .left)
            }
          )
        )

        Button {
          isRightPhotosPickerPresented = true
        } label: {
          VStack {
            if let rightImage {
              Image(
                decorative: rightImage,
                scale: 1,
                orientation: rightImageOrientation ?? .up
              )
              .resizable()
              .aspectRatio(1, contentMode: .fit)
            } else {
              Image(systemName: "photo")
                .font(.largeTitle)
            }
          }
          .frame(maxWidth: .infinity, maxHeight: .infinity)
          .background(Color.accentColor.opacity(0.1))
          .aspectRatio(1, contentMode: .fit)
          .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .photosPicker(
          isPresented: $isRightPhotosPickerPresented,
          selection: Binding(
            get: {
              rightPhotosPickerItem
            },
            set: {
              rightPhotosPickerItem = $0
              loadImage(from: $0, imageType: .right)
            }
          )
        )
      }
      .padding(16)
    }
  }

  private func loadImage(from item: PhotosPickerItem?, imageType: ImageType) {
    guard let item else { return }
    Task {
      guard let data = try await item.loadTransferable(type: Data.self) else {
        return
      }

      // DataからCGImageを作成
      let cgImage = createCGImage(from: data)

      switch imageType {
      case .left:
        if let orientation = data.orientation {
          leftImageOrientation = translateImageOrientation(orientation)
        }
        leftImage = cgImage

      case .right:
        if let orientation = data.orientation {
          rightImageOrientation = translateImageOrientation(orientation)
        }
        rightImage = cgImage
      }
    }
  }

  private func createCGImage(from data: Data) -> CGImage? {
    guard let imageSource = CGImageSourceCreateWithData(data as CFData, nil)
    else {
      return nil
    }
    return CGImageSourceCreateImageAtIndex(imageSource, 0, nil)
  }

  private func translateImageOrientation(
    _ imageOrientation: CGImagePropertyOrientation
  ) -> Image.Orientation {
    switch imageOrientation {
    case .up:
      return .up
    case .upMirrored:
      return .upMirrored
    case .left:
      return .left
    case .leftMirrored:
      return .leftMirrored
    case .right:
      return .right
    case .rightMirrored:
      return .rightMirrored
    case .down:
      return .down
    case .downMirrored:
      return .downMirrored
    }
  }
}

#Preview {
  GenerateSplitView()
}
