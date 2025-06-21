//
//  FTFamilyActivityPicker.swift
//  FocusTap
//
//  Created by Trevor Walker on 4/13/25.
//

import SwiftUI
import FamilyControls

struct FTFamilyActivityPicker: View {
  @Binding var selection: FamilyActivitySelection
  @Environment(\.dismiss) private var dismiss
  @State private var temporarySelection: FamilyActivitySelection

  init(selection: Binding<FamilyActivitySelection>) {
    self._selection = selection
    // Initialize temporary selection with current selection
    self._temporarySelection = State(initialValue: selection.wrappedValue)
  }

  var body: some View {
    NavigationView {
      VStack(spacing: 16) {
        // Header explanation
        VStack(alignment: .leading, spacing: 8) {
          if temporarySelection.applicationTokens.isEmpty && temporarySelection.categoryTokens.isEmpty {
            Text(String.profileForm(.selectAppsToBlockTitle))
              .font(.title2)
              .fontWeight(.bold)
          } else {
            Text("\(temporarySelection.applicationTokens.count)/50 Applications\n\(temporarySelection.categoryTokens.count)/50 Categories")
              .font(.title2)
              .fontWeight(.bold)
          }

          Text(String.profileForm((temporarySelection.applicationTokens.isEmpty && temporarySelection.categoryTokens.isEmpty) ? .selectAppsToBlockDesctiption : .selectAppsToBlockDesctiption2))
              .font(.subheadline)
              .foregroundColor(.secondary)
        }
        .padding(.horizontal)

        // FamilyActivityPicker with temporary selection
        FamilyActivityPicker(selection: $temporarySelection)
          .frame(maxHeight: .infinity)
      }
      .padding(.top)
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          Button(String.common(.cancel)) {
            dismiss()
          }
        }

        ToolbarItem(placement: .navigationBarTrailing) {
          Button(String.common(.done)) {
            // Only update the real selection when Done is tapped
            selection = temporarySelection
            dismiss()
          }
          .fontWeight(.bold)
        }
      }
    }
  }
}

#Preview {
  FTFamilyActivityPicker(selection: .constant(.init()))
}
