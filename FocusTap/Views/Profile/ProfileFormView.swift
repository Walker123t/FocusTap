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
  @State private var showAlert: ProfileAlertType? = nil
  @State private var activitySelection: FamilyActivitySelection = .init()
  @State private var requireMatchingTag: Bool
  @State private var requireTagToBlock: Bool
  @State private var isActivityPickerPresented = false
  @State private var allowTempUnblock: Bool = false
  @State private var tempUnblockTime: Int = 0
  @State private var tempUnblockCount: Int = 0

  let profile: Profile?
  private var tagPhrase: String
  let onDismiss: () -> Void
  private let nfcReader = NFCReader()

  private enum ProfileAlertType: Identifiable {
    case createTag
    case deleteConfirmation

    var id: String {
      switch self {
      case .createTag: return "createTag"
      case .deleteConfirmation: return "deleteConfirmation"
      }
    }
  }

  init(profile: Profile? = nil, profileManager: ProfileManager, onDismiss: @escaping () -> Void) {
    self.profile = profile
    self.profileManager = profileManager
    self.onDismiss = onDismiss
    self.tagPhrase = profile?.tagPhrase ?? "focusTap://\(UUID().uuidString.prefix(8).uppercased())"

    _profileName = State(initialValue: profile?.name ?? "")
    _profileIcon = State(initialValue: profile?.icon ?? "bell.slash")
    _requireMatchingTag = State(initialValue: profile?.requireMatchingTag ?? false)
    _requireTagToBlock = State(initialValue: profile?.requireTagToBlock ?? true)
    _allowTempUnblock = State(initialValue: profile?.allowTempUnblock ?? false)
    _tempUnblockTime = State(initialValue: profile?.tempUnblockTime ?? 0)
    _tempUnblockCount = State(initialValue: profile?.tempUnblockCount ?? 0)

    if let profile = profile {
      var tempSelection = FamilyActivitySelection()
      tempSelection.applicationTokens = profile.appTokens
      tempSelection.categoryTokens = profile.categoryTokens
      tempSelection.webDomainTokens = profile.webTokens

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
            HStack {
              Text(.blockedWebsitesBodyText)
              Spacer()
              Text("\(activitySelection.webDomainTokens.count)")
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

          Toggle("Allow Temporary Unblock", isOn: $allowTempUnblock)

          if allowTempUnblock {
            Text("This will allow you to unblock a profile temporarily. This is not recommended to have enabled and may be removed in the future depending on feedback")
              .font(.caption)
              .foregroundColor(.secondary)

            HStack {
              Stepper("Minutes: \(tempUnblockTime)", value: $tempUnblockTime, in: 1...120)
            }

            HStack {
              Stepper("Allowed per day: \(tempUnblockCount)", value: $tempUnblockCount, in: 1...120)
            }
          }
        }
        
        Section {
          Button("Create Tag") {
            showAlert = .createTag
          }
          .foregroundStyle(.blue)
        }
        
        if profile != nil {
          Section {
            Button(action: { showAlert = .deleteConfirmation }) {
              Text(.deleteProfileButtonText)
                .foregroundColor(.red)
            }
          }
        }
      }
      .navigationTitle(profile == nil ? String.profileForm(.addProfilePageHeader) : String.profileForm(.editProfilePageHeader))
      .navigationBarItems(
        leading: Button(String.common(.cancel), action: onDismiss)
          .foregroundStyle(.red),
        trailing: Button(String.common(.save), action: handleSave)
          .disabled(profileName.isEmpty)
          .foregroundStyle(.blue)
      )
      .sheet(isPresented: $showSymbolsPicker) {
        SymbolsPicker(selection: $profileIcon, title: .profileForm(.chooseIconSheetHeader), autoDismiss: true)
      }
      .alert(item: $showAlert) { alertType in
        switch alertType {
        case .createTag:
          return Alert(
            title: Text(.createTag(.title)),
            message: Text(.createTag(.message)),
            primaryButton: .default(Text(.create)) { createFocusTag() },
            secondaryButton: .cancel(Text(.cancel))
          )
        case .deleteConfirmation:
          return Alert(
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
  }

  private func handleSave() {
    if let existingProfile = profile {
      profileManager.updateProfile(
        id: existingProfile.id,
        name: profileName,
        appTokens: activitySelection.applicationTokens,
        categoryTokens: activitySelection.categoryTokens,
        webTokens: activitySelection.webDomainTokens,
        icon: profileIcon,
        requireMatchingTag: requireMatchingTag,
        requireTagToBlock: requireTagToBlock,
        allowTempUnblock: allowTempUnblock,
        tempUnblockTime: tempUnblockTime,
        tempUnblockCount: tempUnblockCount
      )
    } else {
      let newProfile = Profile(
        name: profileName,
        appTokens: activitySelection.applicationTokens,
        categoryTokens: activitySelection.categoryTokens,
        webTokens: activitySelection.webDomainTokens,
        icon: profileIcon,
        tagPhrase: tagPhrase,
        requireMatchingTag: requireMatchingTag,
        requireTagToBlock: requireTagToBlock,
        allowTempUnblock: allowTempUnblock,
        tempUnblockTime: tempUnblockTime,
        tempUnblockCount: tempUnblockCount
      )
      profileManager.addProfile(newProfile: newProfile)
    }
    onDismiss()
  }

  private func createFocusTag() {
    nfcReader.write(tagPhrase)
  }
}
