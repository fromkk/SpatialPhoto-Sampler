import CoreGraphics
import Photos
import PhotosUI
import SwiftUI
import UniformTypeIdentifiers

struct GenerateSplitView: View {
  @State var leftImage: CGImage?
  @State var rightImage: CGImage?

  @State var isLeftPhotosPickerPresented: Bool = false
  @State var isRightPhotosPickerPresented: Bool = false

  @State var leftPhotosPickerItem: PhotosPickerItem?
  @State var rightPhotosPickerItem: PhotosPickerItem?

  @State var leftImageOrientation: Image.Orientation?
  @State var rightImageOrientation: Image.Orientation?

  @State var error: (any Error)?

  enum ImageType {
    case left
    case right
  }

  var body: some View {
    VStack(spacing: 16) {
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
              .aspectRatio(contentMode: .fit)

              Button {
                deleteImage(.left)
              } label: {
                Text("削除")
                  .foregroundStyle(.background)
                  .padding(
                    EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16)
                  )
                  .background(Color.red)
                  .clipShape(RoundedRectangle(cornerRadius: 8))
              }
            } else {
              Image(systemName: "photo")
                .font(.largeTitle)
            }
          }
          .padding(8)
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
              .aspectRatio(contentMode: .fit)

              Button {
                deleteImage(.right)
              } label: {
                Text("削除")
                  .foregroundStyle(.background)
                  .padding(
                    EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16)
                  )
                  .background(Color.red)
                  .clipShape(RoundedRectangle(cornerRadius: 8))
              }
            } else {
              Image(systemName: "photo")
                .font(.largeTitle)
            }
          }
          .padding(8)
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

      if leftImage != nil && rightImage == nil {
        Button {
          splitAndGenerateSpatialPhoto()
        } label: {
          Text("画像を分割して空間写真を生成する")
            .padding(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
            .foregroundStyle(.background)
            .background(Color.accentColor)
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
      } else if let leftPhotosPickerItem, let rightPhotosPickerItem {
        Button {
          let leftImageURL = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent("left.jpg")
          let rightImageURL = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent("right.jpg")
          Task {
            do {
              guard
                let leftImageData =
                  try await leftPhotosPickerItem.loadTransferable(
                    type: Data.self
                  ),
                let rightImageData =
                  try await rightPhotosPickerItem.loadTransferable(
                    type: Data.self
                  )
              else {
                return
              }
              try leftImageData.write(to: leftImageURL)
              try rightImageData.write(to: rightImageURL)

              try generateSpatialPhoto(
                leftImageURL: leftImageURL,
                rightImageURL: rightImageURL
              )
            } catch {
              self.error = error
            }
          }
        } label: {
          Text("空間写真を生成する")
            .padding(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
            .foregroundStyle(.background)
            .background(Color.accentColor)
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
      } else {
        Text("画像を選択してください")
          .font(.caption)
          .foregroundStyle(.secondary)
      }
    }
    .alert(
      "エラー",
      isPresented: Binding(
        get: { error != nil },
        set: { _ in error = nil }
      )
    ) {
      Button("OK") {
        error = nil
      }
    } message: {
      Text(error?.localizedDescription ?? "")
    }
  }

  func deleteImage(_ imageType: ImageType) {
    switch imageType {
    case .left:
      leftImage = nil
      leftPhotosPickerItem = nil
      leftImageOrientation = nil
    case .right:
      rightImage = nil
      rightPhotosPickerItem = nil
      rightImageOrientation = nil
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

  func splitAndGenerateSpatialPhoto() {
    guard let leftImage else { return }

    Task {
      do {
        // 画像のサイズを取得
        let width = leftImage.width
        let height = leftImage.height

        // 左半分と右半分のCGRectを定義
        let leftRect = CGRect(x: 0, y: 0, width: width / 2, height: height)
        let rightRect = CGRect(x: width / 2, y: 0, width: width / 2, height: height)

        // 左右に分割
        guard let leftHalfImage = leftImage.cropping(to: leftRect),
          let rightHalfImage = leftImage.cropping(to: rightRect)
        else {
          self.error = NSError(
            domain: "SpatialPhotoError", code: 1,
            userInfo: [NSLocalizedDescriptionKey: "画像の分割に失敗しました"])
          return
        }

        // temporaryディレクトリのパスを作成
        let leftImageURL = URL(fileURLWithPath: NSTemporaryDirectory())
          .appendingPathComponent("left_split.jpg")
        let rightImageURL = URL(fileURLWithPath: NSTemporaryDirectory())
          .appendingPathComponent("right_split.jpg")

        // CGImageをJPEGデータに変換して保存
        try saveCGImageToJPEG(leftHalfImage, to: leftImageURL)
        try saveCGImageToJPEG(rightHalfImage, to: rightImageURL)

        // 分割した画像で空間写真を生成
        try generateSpatialPhoto(
          leftImageURL: leftImageURL,
          rightImageURL: rightImageURL
        )
      } catch {
        self.error = error
      }
    }
  }

  private func saveCGImageToJPEG(_ cgImage: CGImage, to url: URL) throws {
    guard
      let destination = CGImageDestinationCreateWithURL(
        url as CFURL,
        UTType.heic.identifier as CFString,
        1,
        nil
      )
    else {
      throw NSError(
        domain: "SpatialPhotoError", code: 2,
        userInfo: [NSLocalizedDescriptionKey: "HEICファイルの作成に失敗しました"])
    }

    CGImageDestinationAddImage(destination, cgImage, nil)

    if !CGImageDestinationFinalize(destination) {
      throw NSError(
        domain: "SpatialPhotoError", code: 3,
        userInfo: [NSLocalizedDescriptionKey: "HEICファイルの保存に失敗しました"])
    }
  }

  func generateSpatialPhoto(leftImageURL: URL, rightImageURL: URL) throws {
    let outputImageURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(
      "output.heic")
    let converter = SpatialPhotoConverter(
      leftImageURL: leftImageURL,
      rightImageURL: rightImageURL,
      outputImageURL: outputImageURL,
      baselineInMillimeters: 1,
      horizontalFOV: 42,
      disparityAdjustment: 0
    )
    try converter.convert()

    PHPhotoLibrary.shared().performChanges {
      PHAssetChangeRequest.creationRequestForAssetFromImage(atFileURL: outputImageURL)
    }
  }
}

#Preview {
  GenerateSplitView()
}
