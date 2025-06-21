//
//  BlockedProfileSession.swift
//  FocusTap
//
//  Created by Trevor Walker on 6/8/25.
//

import Foundation
import SwiftData

@Model
class BlockedProfileSession {
  @Attribute(.unique) var id: String
  var tag: String

  @Relationship var blockedProfile: Profile

  var startTime: Date
  var endTime: Date?

  var isActive: Bool {
    return endTime == nil
  }

  var duration: TimeInterval {
    let end = endTime ?? Date()
    return end.timeIntervalSince(startTime)
  }

  init(
    tag: String,
    blockedProfile: Profile,
    forceStarted: Bool = false
  ) {
    self.id = UUID().uuidString
    self.tag = tag
    self.blockedProfile = blockedProfile
    self.startTime = Date()

    // Add this session to the profile's sessions array
    blockedProfile.sessions.append(self)
  }

  func endSession() {
    self.endTime = Date()
  }

  static func createSession(
    in context: ModelContext,
    withTag tag: String,
    withProfile profile: Profile,
    forceStart: Bool = false
  ) -> BlockedProfileSession {
    let newSession = BlockedProfileSession(
      tag: tag,
      blockedProfile: profile,
      forceStarted: forceStart
    )

    context.insert(newSession)
    return newSession
  }
}
