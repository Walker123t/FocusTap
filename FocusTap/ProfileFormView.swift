//
//  EditProfileView.swift
// FocusTap
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
  @State private var showAppSelection = false
  @State private var activitySelection: FamilyActivitySelection
  @State private var showDeleteConfirmation = false
  @State private var requireMatchingTag: Bool
  let profile: Profile?
  let onDismiss: () -> Void

  init(profile: Profile? = nil, profileManager: ProfileManager, onDismiss: @escaping () -> Void) {
    self.profile = profile
    self.profileManager = profileManager
    self.onDismiss = onDismiss
    _profileName = State(initialValue: profile?.name ?? "")
    _profileIcon = State(initialValue: profile?.icon ?? "bell.slash")
    _requireMatchingTag = State(initialValue: profile?.requireMatchingTag ?? false)

    var selection = FamilyActivitySelection()
    selection.applicationTokens = profile?.appTokens ?? []
    selection.categoryTokens = profile?.categoryTokens ?? []
    _activitySelection = State(initialValue: selection)
  }

  var body: some View {
    NavigationView {
      Form {
        Section(header: Text(verbatim: String.profiles(.sectionDetails))) {
          VStack(alignment: .leading) {
            Text(verbatim: String.profiles(.sectionName))
              .font(.caption)
              .foregroundColor(.secondary)
            TextField(String.profiles(.sectionNamePrompt), text: $profileName)
          }

          Button(action: { showSymbolsPicker = true }) {
            HStack {
              Image(systemName: profileIcon)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 40, height: 40)
              Text(verbatim: String.profiles(.sectionChooseIcon))
              Spacer()
              Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
            }
          }
        }

        Section(header: Text(verbatim: String.profiles(.sectionApps))) {
          Button(action: { showAppSelection = true }) {
            Text(verbatim: String.profiles(.sectionConfigureApps))
          }

          VStack(alignment: .leading, spacing: 8) {
            HStack {
              Text(verbatim: String.profiles(.sectionBlockedApps))
              Spacer()
              Text("\(activitySelection.applicationTokens.count)")
                .fontWeight(.bold)
            }
            HStack {
              Text(verbatim: String.profiles(.sectionBlockedCategories))
              Spacer()
              Text("\(activitySelection.categoryTokens.count)")
                .fontWeight(.bold)
            }
            Text(verbatim: String.profiles(.sectionPrivacyNote))
              .font(.caption)
              .foregroundColor(.secondary)
          }
        }

        Section(header: Text(verbatim: String.profiles(.sectionSecurity))) {
          Toggle(String.profiles(.sectionRequireTag), isOn: $requireMatchingTag)

          if requireMatchingTag {
            Text(verbatim: String.profiles(.sectionRequireTagNote))
              .font(.caption)
              .foregroundColor(.secondary)
          }
        }

        if profile != nil {
          Section {
            Button(action: { showDeleteConfirmation = true }) {
              Text(verbatim: String.profiles(.sectionDeleteProfile))
                .foregroundColor(.red)
            }
          }
        }
      }
      .navigationTitle(profile == nil ?
                       String.profiles(.formAddTitle) :
                        String.profiles(.formEditTitle))
      .navigationBarItems(
        leading: Button(String.common(.cancel), action: onDismiss),
        trailing: Button(String.common(.save), action: handleSave)
          .disabled(profileName.isEmpty)
      )
      .sheet(isPresented: $showSymbolsPicker) {
        SymbolsPicker(
          selection: $profileIcon,
          title: String.profiles(.sectionPickIcon),
          autoDismiss: true
        )
      }
      .sheet(isPresented: $showAppSelection) {
        NavigationView {
          FamilyActivityPicker(selection: $activitySelection)
            .navigationTitle(String.profiles(.sectionSelectApps))
            .navigationBarItems(trailing: Button(String.common(.done)) {
              showAppSelection = false
            })
        }
      }
      .alert(isPresented: $showDeleteConfirmation) {
        Alert(
          title: Text(verbatim: String.profiles(.deleteTitle)),
          message: Text(verbatim: String.profiles(.deleteMessage)),
          primaryButton: .destructive(Text(verbatim: String.common(.delete))) {
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
    if let existingProfile = profile {
      profileManager.updateProfile(
        id: existingProfile.id,
        name: profileName,
        appTokens: activitySelection.applicationTokens,
        categoryTokens: activitySelection.categoryTokens,
        icon: profileIcon,
        requireMatchingTag: requireMatchingTag
      )
    } else {
      let newProfile = Profile(
        name: profileName,
        appTokens: activitySelection.applicationTokens,
        categoryTokens: activitySelection.categoryTokens,
        icon: profileIcon,
        requireMatchingTag: requireMatchingTag
      )
      profileManager.addProfile(newProfile: newProfile)
    }
    onDismiss()
  }
}
