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

  @Published var unblockTime: Date? = nil

  @Published var secondsLeft: Int = 0

  @Published private(set) var tempUnblocksUsedToday: Int = 0

  private var lastUnblockDay: Date?

  private var countdownTimer: Timer?

  private var lastProfile: Profile?

  private enum UserDefaultsKeys {
    static let isBlocking = "isBlocking"
    static let unblockTime = "unblockTime"
    static let lastUnblockDay = "lastUnblockDay"
    static let tempUnblocksUsedToday = "tempUnblocksUsedToday"
  }

  init() {
    loadBlockingState()
    if let timestamp = UserDefaults.standard.object(forKey: UserDefaultsKeys.unblockTime) as? Double {
      let until = Date(timeIntervalSince1970: timestamp)
      if until > Date() {
        self.unblockTime = until
        self.disableBlocking()
        self.startCountdownTimer()
      } else {
        UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.unblockTime)
      }
    }

    if let day = UserDefaults.standard.object(forKey: UserDefaultsKeys.lastUnblockDay) as? Double {
      lastUnblockDay = Date(timeIntervalSince1970: day)
      if !isSameDay(Date(), lastUnblockDay!) {
        tempUnblocksUsedToday = 0
        lastUnblockDay = Date()
        UserDefaults.standard.set(lastUnblockDay!.timeIntervalSince1970, forKey: UserDefaultsKeys.lastUnblockDay)
      } else {
        tempUnblocksUsedToday = UserDefaults.standard.integer(forKey: UserDefaultsKeys.tempUnblocksUsedToday)
      }
    } else {
      tempUnblocksUsedToday = 0
      lastUnblockDay = Date()
      UserDefaults.standard.set(lastUnblockDay!.timeIntervalSince1970, forKey: UserDefaultsKeys.lastUnblockDay)
    }

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

    lastProfile = profile
    applyBlockingState(for: profile)
  }
  
  func temporarilyUnblock(for profile: Profile) {
    lastProfile = profile
    let today = Date()
    if !isSameDay(today, lastUnblockDay ?? .distantPast) {
      tempUnblocksUsedToday = 0
      lastUnblockDay = today
      UserDefaults.standard.set(today.timeIntervalSince1970, forKey: UserDefaultsKeys.lastUnblockDay)
    }
    if tempUnblocksUsedToday >= profile.tempUnblockCount {
      NSLog("Temp unblock limit reached for today")
      return
    }
    tempUnblocksUsedToday += 1
    UserDefaults.standard.set(tempUnblocksUsedToday, forKey: UserDefaultsKeys.tempUnblocksUsedToday)
    UserDefaults.standard.set(today.timeIntervalSince1970, forKey: UserDefaultsKeys.lastUnblockDay)

    let duration = TimeInterval(profile.tempUnblockTime * 60)
    let until = Date().addingTimeInterval(duration)
    DispatchQueue.main.async {
      self.unblockTime = until
      UserDefaults.standard.set(until.timeIntervalSince1970, forKey: UserDefaultsKeys.unblockTime)
      self.disableBlocking()
      self.startCountdownTimer()
    }
  }
  
  // MARK: - Private Methods
  func applyBlockingState(for profile: Profile) {
    isBlocking ? disableBlocking(): enableBlocking(for: profile)
  }

  func enableBlocking(for profile: Profile) {
    NSLog("Blocking \(profile.appTokens.count) apps")
    lastProfile = profile
    setIsBlocking(to: true)
    store.shield.applications = profile.appTokens
    store.shield.webDomains = profile.webTokens
    store.shield.applicationCategories = .specific(profile.categoryTokens)
    store.shield.webDomainCategories = .specific(profile.categoryTokens)
  }

  private func disableBlocking() {
    setIsBlocking(to: false)
    store.shield.applications = .none
    store.shield.applicationCategories = .none
    store.shield.webDomains = .none
    store.shield.webDomainCategories = .none
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

  private func startCountdownTimer() {
    countdownTimer?.invalidate()
    guard let unblockTime = unblockTime else { return }
    let interval = unblockTime.timeIntervalSinceNow
    if interval <= 0 {
      handleUnblockExpired()
      return
    }
    DispatchQueue.main.async {
      self.secondsLeft = Int(interval)
    }
    countdownTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
      guard let self = self else { return }
      let remaining = Int(unblockTime.timeIntervalSinceNow)
      DispatchQueue.main.async {
        self.secondsLeft = max(remaining, 0)
        if remaining <= 0 {
          self.handleUnblockExpired()
        }
      }
    }
  }

  private func handleUnblockExpired() {
    countdownTimer?.invalidate()
    countdownTimer = nil
    DispatchQueue.main.async {
      self.unblockTime = nil
      self.secondsLeft = 0
      UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.unblockTime)
      if let profile = self.lastProfile {
        self.enableBlocking(for: profile)
      }
    }
  }

  private func isSameDay(_ lhs: Date, _ rhs: Date) -> Bool {
    let calendar = Calendar.current
    return calendar.isDate(lhs, inSameDayAs: rhs)
  }
}

