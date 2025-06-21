//
//  AppBlocker.swift
//  Broke
//
//  Created by Oz Tamir on 22/08/2024.
//

import SwiftUI
import ManagedSettings
import FamilyControls

class AppBlocker: ObservableObject {

  static let shared: AppBlocker = .init()
  // MARK: - Properties
  private let store = ManagedSettingsStore()
  @Published private(set) var isBlocking = false {
    didSet {
      saveBlockingState()
    }
  }

  @Published private(set) var isAuthorized = false
  
  private enum UserDefaultsKeys {
    static let isBlocking = "isBlocking"
  }

  init() {
    loadBlockingState()
    Task {
      await requestAuthorization()
    }
  }
  
  // MARK: - Public Methods
  func requestAuthorization() async {
    do {
      try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
      await MainActor.run { self.isAuthorized = true }
    } catch {
      NSLog("Failed to request authorization: \(error)")
      await MainActor.run { self.isAuthorized = false }
    }
  }
  
  func toggleBlocking(for profile: Profile) {
    guard isAuthorized else {
      NSLog("Not authorized to block apps")
      return
    }

    applyBlockingState(for: profile)
  }
  
  // MARK: - Private Methods
  func applyBlockingState(for profile: Profile) {
    isBlocking ? disableBlocking(): enableBlocking(for: profile)
  }

  func enableBlocking(for profile: Profile) {
//    NSLog("Blocking \(profile.appTokens.count) apps")
//    setIsBlocking(to: true)
//    store.shield.applications = profile.appTokens.isEmpty ? nil : profile.appTokens
//    store.shield.applicationCategories = profile.categoryTokens.isEmpty ?
//      .none :
//      .specific(profile.categoryTokens)
  }

  private func disableBlocking() {
//    setIsBlocking(to: false)
//    store.shield.applications = nil
//    store.shield.applicationCategories = .none
  }

  private func loadBlockingState() {
    isBlocking = UserDefaults.standard.bool(forKey: UserDefaultsKeys.isBlocking)
  }
  
  private func saveBlockingState() {
    NSLog("Saved blocking state: \(isBlocking)")
    UserDefaults.standard.set(isBlocking, forKey: UserDefaultsKeys.isBlocking)
  }
  
  private func setIsBlocking(to isBlocking: Bool) {
    DispatchQueue.main.async {
      self.isBlocking = isBlocking
    }
  }
}
