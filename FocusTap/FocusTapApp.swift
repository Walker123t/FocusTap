//
//  FocusTapApp.swift
// FocusTap
//
//  Created by Oz Tamir on 19/08/2024.
//

import SwiftUI

@main
struct FocusTapApp: App {
  @StateObject private var appBlocker = AppBlocker()
  @StateObject private var profileManager = ProfileManager()

  var body: some Scene {
    WindowGroup {
      FocusView()
        .environmentObject(appBlocker)
        .environmentObject(profileManager)
    }
  }
}
