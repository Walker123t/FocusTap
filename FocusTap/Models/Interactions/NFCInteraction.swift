//
//  NFCInteraction.swift
//  FocusTap
//
//  Created by Trevor Walker on 6/8/25.
//

import SwiftData
import SwiftUI

class NFCInteraction: Interaction {
  static var id: String = "NFCBlockingStrategy"

  var name: String = "NFC Tags"
  var description: String =
  "Block and unblock profiles by using the exact same NFC tag"
  var iconType: String = "wave.3.right.circle.fill"
  var color: Color = .yellow

  private let nfcScanner: NFCReader = NFCReader()
  private let appBlocker: AppBlocker = AppBlocker()

  func startBlocking(
    context: ModelContext,
    profile: Profile,
    forceStart: Bool?
  ) -> (any View)? {
//    nfcScanner.onTagScanned = { tag in
//      self.appBlocker
//        .activateRestrictions(
//          selection: profile.selectedActivity,
//          strict: profile.enableStrictMode,
//          allowOnly: profile.enableAllowMode
//        )
//
//      let tag = tag.url ?? tag.id
//      let activeSession =
//      BlockedProfileSession
//        .createSession(
//          in: context,
//          withTag: tag,
//          withProfile: profile,
//          forceStart: forceStart ?? false
//        )
//      self.onSessionCreation?(.started(activeSession))
//    }
//
//    nfcScanner.scan(profileName: profile.name)

    return nil
  }

  func stopBlocking(
    context: ModelContext,
    session: Profile
  ) -> (any View)? {
//    nfcScanner.onTagScanned = { tag in
//      let tag = tag.url ?? tag.id
//
//      // If it was force started, we don't care about the tag
//      if !session.forceStarted && session.tag != tag {
//        self.onErrorMessage?(
//          "You must scan the original tag to stop focus"
//        )
//        return
//      }
//
//      session.endSession()
//      self.appBlocker.deactivateRestrictions()
//
//      self.onSessionCreation?(.ended(session.blockedProfile))
//    }
//
//    nfcScanner.scan(profileName: session.blockedProfile.name)

    return nil
  }
}
