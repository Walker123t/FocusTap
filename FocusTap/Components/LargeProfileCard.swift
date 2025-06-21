//
//  ProfileCard.swift
//  FocusTap
//
//  Created by Trevor Walker on 6/8/25.
//

import FamilyControls
import SwiftUI

struct LargeProfileCard: View {
  let profile: Profile

  var body: some View {
    ZStack {
      // Use the CardBackground component
      RoundedRectangle(cornerRadius: 24)
        .fill(Color(UIColor.systemBackground))

      // Content
      VStack(alignment: .leading, spacing: 12) {
        // Header section - Profile name, edit button, and indicators
        HStack {
          VStack(alignment: .leading, spacing: 10) {
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

//            // Using the new ProfileIndicators component
            ModifierIndicatorView(enableLiveActivity: profile.enableLiveActivity,
                                  timed: profile.timed,
                                  enableStrictMode: profile.enableStrictMode)
          }

          Spacer()
        }

        // Middle section - Strategy and apps info
        VStack(alignment: .leading, spacing: 16) {
          // Using the new StrategyInfoView component
          InteractionTypeView(interaction: InteractionManager.interaction(with: profile.interactionId))

//          // Using the new ProfileStatsRow component
          ProfileStatsRow(
            selectedActivity: profile.selection,
            sessionCount: profile.sessions.count,
            totalTime: profile.activeDuration
          )
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
      LargeProfileCard(profile: Profile(name: "Test",
                                          selection: FamilyActivitySelection(),
                                          interactionId: NFCInteraction.id))
    }
  }
}
