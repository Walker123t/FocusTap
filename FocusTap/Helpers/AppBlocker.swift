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
  // MARK: - Properties
  private let store = ManagedSettingsStore()
  @Published private(set) var isBlocking = false
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
    
    isBlocking.toggle()
    saveBlockingState()
    applyBlockingSettings(for: profile)
  }
  
  // MARK: - Private Methods
  private func applyBlockingSettings(for profile: Profile) {
    if isBlocking {
      NSLog("Blocking \(profile.appTokens.count) apps")
      store.shield.applications = profile.appTokens.isEmpty ? nil : profile.appTokens
      store.shield.applicationCategories = profile.categoryTokens.isEmpty ? 
        .none : 
        .specific(profile.categoryTokens)
    } else {
      store.shield.applications = nil
      store.shield.applicationCategories = .none
    }
  }
  
  private func loadBlockingState() {
    isBlocking = UserDefaults.standard.bool(forKey: UserDefaultsKeys.isBlocking)
  }
  
  private func saveBlockingState() {
    UserDefaults.standard.set(isBlocking, forKey: UserDefaultsKeys.isBlocking)
  }
}
