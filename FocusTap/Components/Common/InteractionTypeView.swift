//
//  InteractionTypeView.swift
//  FocusTap
//
//  Created by Trevor Walker on 6/8/25.
//

import SwiftUI

struct InteractionTypeView: View {
  let interaction: Interaction
  let withText: Bool

  init(interaction: Interaction, withText: Bool = false) {
    self.interaction = interaction
    self.withText = withText
  }

  var body: some View {
    HStack {
      Image(systemName: interaction.iconType)
        .foregroundColor(interaction.color)
        .font(.system(size: 16))
        .frame(width: 28, height: 28)
        .background(
          Circle()
            .fill(
              interaction.color.opacity(0.15)
            )
        )
      if withText {
        VStack(alignment: .leading, spacing: 2) {
          Text(interaction.name)
            .foregroundColor(.primary)
            .font(.subheadline)
            .fontWeight(.medium)
        }
      }
    }
  }
}
