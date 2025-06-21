//
//  EditProfileView.swift
//  Broke
//
//  Created by Oz Tamir on 23/08/2024.
//

import SwiftUI
import SFSymbolsPicker
import FamilyControls

struct ProfileFormView: View {
  @ObservedObject var profileManager: ProfileManager
  @State private var profileName: String
  @State private var profileIcon: String
  @State private var showSymbolsPicker = false
  @State private var activitySelection: FamilyActivitySelection = .init()
  @State private var showDeleteConfirmation = false
  @State private var requireMatchingTag: Bool
  @State private var requireTagToBlock: Bool
  @State private var isActivityPickerPresented = false
  let profile: Profile?
  let onDismiss: () -> Void

  init(profile: Profile? = nil, profileManager: ProfileManager, onDismiss: @escaping () -> Void) {
    self.profile = profile
    self.profileManager = profileManager
    self.onDismiss = onDismiss

    _profileName = State(initialValue: profile?.name ?? "")
    _profileIcon = State(initialValue: profile?.icon ?? "bell.slash")
    _requireMatchingTag = State(initialValue: /*profile?.requireMatchingTag ??*/ false)
    _requireTagToBlock = State(initialValue: /*profile?.requireTagToBlock ??*/ true)

    if let profile = profile {
      var tempSelection = FamilyActivitySelection()
      tempSelection.applicationTokens = [] /*profile.appTokens*/
      tempSelection.categoryTokens = [] /*profile.categoryTokens*/

      _activitySelection = State(initialValue: tempSelection)
    } else {
      _activitySelection = State(initialValue: .init())
    }
  }

  var body: some View {
    NavigationView {
      Form {
        Section(header: Text(.profileDetailsSectionHeader)) {
          VStack(alignment: .leading) {
            Text(.profileNameSubHeader)
              .font(.caption)
              .foregroundColor(.secondary)
            TextField(.profileNamePlaceholder, text: $profileName)
          }

          Button(action: { showSymbolsPicker = true }) {
            HStack {
              Image(systemName: profileIcon)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 40, height: 40)
              Text(.chooseIconButtonText)
              Spacer()
              Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
            }
          }
        }

        Section(header: Text(.appConfigurationSectionHeader)) {
          Button(action: { isActivityPickerPresented = true }) {
            Text(.configureBlockedAppsButtonText)
          }
          .sheet(isPresented: $isActivityPickerPresented) {
            FTFamilyActivityPicker(selection: $activitySelection)
          }

          VStack(alignment: .leading, spacing: 8) {
            HStack {
              Text(.blockedAppsBodyText)
              Spacer()
              Text("\(activitySelection.applicationTokens.count)")
                .fontWeight(.bold)
            }
            HStack {
              Text(.blockedCategoriesBodyText)
              Spacer()
              Text("\(activitySelection.categoryTokens.count)")
                .fontWeight(.bold)
            }
            Text(.appConfigurationDescription)
              .font(.caption)
              .foregroundColor(.secondary)
          }
        }

        Section(header: Text(.securitySectionHeader)) {
          Toggle(.requireMatchingTagToggleText, isOn: $requireMatchingTag)

          if requireMatchingTag {
            Text(.requireMatchingTagDescription)
              .font(.caption)
              .foregroundColor(.secondary)
          }

          Toggle(.requireTagToBlockToggleText, isOn: $requireTagToBlock)

          if !requireTagToBlock {
            Text(.requireTagToBlockDescription)
              .font(.caption)
              .fontWeight(.bold)
              .foregroundColor(.red)
          }
        }

        if profile != nil {
          Section {
            Button(action: { showDeleteConfirmation = true }) {
              Text(.deleteProfileButtonText)
                .foregroundColor(.red)
            }
          }
        }
      }
      .navigationTitle(profile == nil ? String.profileForm(.addProfilePageHeader) : String.profileForm(.editProfilePageHeader))
      .navigationBarItems(
        leading: Button(String.common(.cancel), action: onDismiss),
        trailing: Button(String.common(.save), action: handleSave)
          .disabled(profileName.isEmpty)
      )
      .sheet(isPresented: $showSymbolsPicker) {
        SymbolsPicker(selection: $profileIcon, title: .profileForm(.chooseIconSheetHeader), autoDismiss: true)
      }
      .alert(isPresented: $showDeleteConfirmation) {
        Alert(
          title: Text("Delete Profile"),
          message: Text("Are you sure you want to delete this profile?"),
          primaryButton: .destructive(Text("Delete")) {
            if let profile = profile {
              profileManager.deleteProfile(withId: profile.id)
            }
            onDismiss()
          },
          secondaryButton: .cancel()
        )
      }
    }
  }

  private func handleSave() {
//    if let existingProfile = profile {
//      profileManager.updateProfile(
//        id: existingProfile.id,
//        name: profileName,
//        appTokens: activitySelection.applicationTokens,
//        categoryTokens: activitySelection.categoryTokens,
//        icon: profileIcon,
//        requireMatchingTag: requireMatchingTag,
//        requireTagToBlock: requireTagToBlock
//      )
//    } else {
//      let newProfile = Profile(
//        name: profileName,
//        appTokens: activitySelection.applicationTokens,
//        categoryTokens: activitySelection.categoryTokens,
//        icon: profileIcon,
//        requireMatchingTag: requireMatchingTag,
//        requireTagToBlock: requireTagToBlock
//      )
//      profileManager.addProfile(newProfile: newProfile)
//    }
    onDismiss()
  }
}
