//
//  Profile.swift
//  FocusTap
//
//  Created by Trevor Walker on 6/8/25.
//

import Foundation
import FamilyControls
import ManagedSettings
import SwiftData

@Model
class Profile: Identifiable {
  @Attribute(.unique) var id: UUID
  var name: String
  var icon: String
  var sessions: [BlockedProfileSession] = []

  var enableLiveActivity: Bool
  var timed: Bool
  var enableStrictMode: Bool

  @Relationship var selection: FamilyActivitySelection

  var interactionId: String

  init(id: UUID = UUID(),
       name: String,
       selection: FamilyActivitySelection,
       icon: String = "bell.slash",
       interactionId: String,
       enableLiveActivity: Bool = false,
       timed: Bool = false,
       enableStrictMode: Bool = false) {
    self.id = id
    self.name = name
    self.selection = selection
    self.icon = icon
    self.interactionId = interactionId

    self.enableLiveActivity = enableLiveActivity
    self.timed = timed
    self.enableStrictMode = enableStrictMode
  }

  var activeDuration: TimeInterval {
    sessions.reduce(into: 0, {$0 += $1.duration})
  }
}
