//
//  SmallProfileCard.swift
//  FocusTap
//
//  Created by Trevor Walker on 6/9/25.
//

import FamilyControls
import SwiftUI

struct SmallProfileCard: View {
  let profile: Profile

  var body: some View {
    ZStack {
      RoundedRectangle(cornerRadius: 24)
        .fill(Color(UIColor.systemBackground))

      VStack(alignment: .leading, spacing: 12) {
        HStack {
          Label {
              Text(profile.name)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            } icon: {
              Image(systemName: profile.icon)
                .font(.title3)
                .foregroundColor(.primary)
            }

          InteractionTypeView(interaction: InteractionManager.interaction(with: profile.interactionId), withText: false)
          Spacer()
        }
        VStack(alignment: .leading, spacing: 16) {
          Text("1:00")
            .font(.subheadline)
            .fontWeight(.semibold)
        }
      }
      .padding(16)
    }
  }
}

#Preview {
  ZStack {
    Color(.systemGroupedBackground).ignoresSafeArea()

    VStack(spacing: 40) {
      // Inactive card
      SmallProfileCard(profile: Profile(name: "Test",
                                        selection: FamilyActivitySelection(),
                                        interactionId: NFCInteraction.id))
    }
  }
}
