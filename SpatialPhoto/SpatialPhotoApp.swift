//
//  SpatialPhotoApp.swift
//  SpatialPhoto
//
//  Created by Kazuya Ueoka on 2025/05/10.
//

import SwiftUI

@main
struct SpatialPhotoApp: App {
  var body: some Scene {
    WindowGroup {
      TabView {
        SplitSpatialPhotoView()
          .tabItem {
            Image(systemName: "rectangle.split.2x1")
            Text("Split")
          }

        GenerateSplitView()
          .tabItem {
            Image(systemName: "wand.and.sparkles")
            Text("Generate")
          }
      }
    }
  }
}
