//
//  InteractionManager.swift
//  FocusTap
//
//  Created by Trevor Walker on 6/8/25.
//

import SwiftData
import SwiftUI

class InteractionManager: ObservableObject {
  static var shared = InteractionManager()

  static let interactionTypes: [Interaction] = [
    NFCInteraction(),
    ManualInteraction()
  ]

  static func interaction(with id: String) -> Interaction {
    interactionTypes.first(where: { $0.getIdentifier() == id }) ?? NFCInteraction()
  }
}
