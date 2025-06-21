//
//  ModifierIndicatorView.swift
//  FocusTap
//
//  Created by Trevor Walker on 6/8/25.
//

import SwiftUI

struct ModifierIndicatorView: View {
  let enableLiveActivity: Bool
  let timed: Bool
  let enableStrictMode: Bool

  var body: some View {
    HStack(spacing: 16) {
      indicatorView(isEnabled: enableLiveActivity, label: "Live Activity")
      indicatorView(isEnabled: enableStrictMode, label: "Strict")
      indicatorView(isEnabled: timed, label: "Timed")
    }
  }

  private func indicatorView(isEnabled: Bool, label: String) -> some View {
    HStack(spacing: 6) {
      Circle()
        .fill(
          isEnabled
          ? Color.green.opacity(0.85)
          : Color.gray.opacity(0.35)
        )
        .frame(width: 6, height: 6)

      Text(label)
        .font(.caption2)
        .foregroundColor(.secondary)
    }
  }
}

#Preview {
  VStack(spacing: 20) {
    ModifierIndicatorView(
      enableLiveActivity: true,
      timed: true,
      enableStrictMode: false
    )
    ModifierIndicatorView(
      enableLiveActivity: false,
      timed: false,
      enableStrictMode: true
    )
  }
  .padding()
  .background(Color(.systemGroupedBackground))
}
