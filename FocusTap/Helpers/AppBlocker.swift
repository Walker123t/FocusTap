//
//  AppBlocker.swift
//  Broke
//
//  Created by Oz Tamir on 22/08/2024.
//

import SwiftUI
import ManagedSettings
import FamilyControls
import AppIntents

class AppBlocker: ObservableObject {
  static let shared: AppBlocker = .init()

  // MARK: - Properties
  private let store = ManagedSettingsStore()
  @Published private(set) var isBlocking = ProfileState.disabled
  @Published private(set) var isAuthorized = false
  
  private enum UserDefaultsKeys {
    static let isBlocking = "isBlocking"
  }

  enum ProfileState: String, AppEnum {
    case enabled = "Enable"
    case disabled = "Disable"

    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Profile State"

    static var caseDisplayRepresentations: [Self : DisplayRepresentation] = [
      .enabled: .init(title: "Enable"),
      .disabled: .init(title: "Disable"),
    ]

    mutating func toggle() {
      self = self == .enabled ? .disabled : .enabled
    }
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
    applyBlockingState(for: profile)
  }
  
  // MARK: - Private Methods
  func applyBlockingState(for profile: Profile, to state: ProfileState? = nil) {
    if let state = state {
      DispatchQueue.main.async { self.isBlocking = state }
    }
    saveBlockingState()

    if isBlocking == .enabled {
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
    if let raw = UserDefaults.standard.string(forKey: UserDefaultsKeys.isBlocking),
       let state = ProfileState(rawValue: raw) {
      isBlocking = state
    } else {
      isBlocking = .disabled
    }
  }
  
  private func saveBlockingState() {
    UserDefaults.standard.set(isBlocking.rawValue, forKey: UserDefaultsKeys.isBlocking)
  }
}
