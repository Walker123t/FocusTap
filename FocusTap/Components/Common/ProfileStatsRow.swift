//
//  ProfileStatsRow.swift
//  FocusTap
//
//  Created by Trevor Walker on 6/8/25.
//

import SwiftUI
import FamilyControls

struct ProfileStatsRow: View {
  let selectedActivity: FamilyActivitySelection
  let sessionCount: Int
  let totalTime: TimeInterval

  private var activityCount: Int {
    selectedActivity.categories.count + selectedActivity.applications.count
    + selectedActivity.webDomains.count
  }

  var body: some View {
    HStack(spacing: 16) {
      // Apps count
      VStack(alignment: .leading, spacing: 2) {
        Text("Apps & Categories")
          .font(.caption)
          .foregroundColor(.secondary)

        Text(
            "\(activityCount)"
        )
        .font(.subheadline)
        .fontWeight(.semibold)
      }

      Divider()
        .frame(height: 24)

      // Active sessions
      VStack(alignment: .leading, spacing: 2) {
        Text("Total Sessions")
          .font(.caption)
          .foregroundColor(.secondary)

        Text(
          sessionCount.description
            .localizedLowercase
        )
        .font(.subheadline)
        .fontWeight(.semibold)
      }

      // Active sessions
      if let timeString = formattedTimeInterval(totalTime) {
        Divider()
          .frame(height: 24)

        VStack(alignment: .leading, spacing: 2) {
          Text("Total Time")
            .font(.caption)
            .foregroundColor(.secondary)

          Text(timeString)
            .font(.subheadline)
            .fontWeight(.semibold)
        }
      }
    }
  }

  private func formattedTimeInterval(_ timeInterval: TimeInterval) -> String? {
    let formatter = DateComponentsFormatter()
    formatter.allowedUnits = [.day, .hour, .minute]
    formatter.unitsStyle = .abbreviated

    return formatter.string(from: .now, to: .now + timeInterval)
  }
}

#Preview {
  ProfileStatsRow(
    selectedActivity: FamilyActivitySelection(),
    sessionCount: 12,
    totalTime: 120.0
  )
  .padding()
  .background(Color(.systemGroupedBackground))
}
