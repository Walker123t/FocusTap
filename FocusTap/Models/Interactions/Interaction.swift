//
//  Interaction.swift
//  FocusTap
//
//  Created by Trevor Walker on 6/8/25.
//

import SwiftData
import SwiftUI

enum BlockingStatus {
  case started
  case ended
}

protocol Interaction {
  static var id: String { get }
  var name: String { get }
  var description: String { get }
  var iconType: String { get }
  var color: Color { get }

  func startBlocking(
    context: ModelContext,
    profile: Profile,
    forceStart: Bool?
  ) -> (any View)?
  func stopBlocking(context: ModelContext, session: Profile)
  -> (any View)?
}

extension Interaction {
  func getIdentifier() -> String {
    return Self.id
  }
}
