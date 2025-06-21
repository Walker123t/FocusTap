//
//  ManualInteraction.swift
//  FocusTap
//
//  Created by Trevor Walker on 6/8/25.
//

import SwiftData
import SwiftUI

class ManualInteraction: Interaction {
  static var id: String = "ManualBlockingStrategy"

  var name: String = "Manual"
  var description: String =
  "Block and unblock profiles manually through the app"
  var iconType: String = "button.horizontal.top.press.fill"
  var color: Color = .blue

  private let appBlocker: AppBlocker = AppBlocker()

  func startBlocking(
    context: ModelContext,
    profile: Profile,
    forceStart: Bool?
  ) -> (any View)? {
//    self.appBlocker
//      .activateRestrictions(
//        selection: profile.selectedActivity,
//        strict: profile.enableStrictMode,
//        allowOnly: profile.enableAllowMode
//      )
//
//    let activeSession =
//    BlockedProfileSession
//      .createSession(
//        in: context,
//        withTag: ManualBlockingStrategy.id,
//        withProfile: profile,
//        forceStart: forceStart ?? false
//      )
//
//    self.onSessionCreation?(.started(activeSession))

    return nil
  }

  func stopBlocking(
    context: ModelContext,
    session: Profile
  ) -> (any View)? {
//    session.endSession()
//    self.appBlocker.deactivateRestrictions()
//
//    self.onSessionCreation?(.ended(session.blockedProfile))

    return nil
  }
}
