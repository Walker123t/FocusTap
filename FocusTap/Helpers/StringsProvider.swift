import Foundation
import SwiftUI

// MARK: - Common Strings
enum CommonStrings: String {
  case ok = "OK"
  case create = "Create"
  case cancel = "Cancel"
  case done = "Done"
  case save = "Save"
}

// MARK: - Home Page Strings
enum HomeStrings: String {
  case tapToBlock = "Tap to block"
  case tapToUnblock = "Tap to unblock"
}

// MARK: - Profile Picker Strings
enum ProfilePickerStrings: String {
  case title = "Profiles"
  case newProfile = "New..."
  case editHint = "Long press on a profile to edit..."
  case statsFormat = "A: %d | C: %d"
}

// MARK: - Alert Strings
enum AlertType {
  case wrongTag(AlertString)
  case notFocusTag(AlertString)
  case createTag(AlertString)

  enum AlertString {
    case title
    case message
  }

  var text: String {
    let alertString = switch self {
    case .wrongTag(let str), .notFocusTag(let str), .createTag(let str): str
    }
    return alertString == .title ? title : message
  }

  private var title: String {
    switch self {
    case .wrongTag: return "Wrong Tag Scanned"
    case .notFocusTag: return "Not a Focus Tag"
    case .createTag: return "Create Focus Tag"
    }
  }

  private var message: String {
    switch self {
    case .wrongTag: return "The current profile requires you scan its corresponding tag to unlock it."
    case .notFocusTag: return "You can create a new Focus tag using the + button. If this tag was previously a Focus tag, try tapping create a new tag and rescanning this one as an update may be required."
    case .createTag: return "Do you want to create a new Focus tag?"
    }
  }
}

// MARK: - Log Strings
enum LogStrings: String {
  case matchingTag = "Matching tag, unblocking"
  case wrongTag = "Wrong Tag for unblocking!\nPayload: %@"
  case nonBrokeTag = "A Non Broke tag was scanned!\nPayload: %@"
  case noMatchRequired = "Tag matching not required, unblocking"
  case switchingProfile = "Switching to profile: %@"
  case usingCurrentProfile = "No matching profile, using current"
}

enum profileFormStrings: String {
  case addProfilePageHeader = "Add Profile"
  case editProfilePageHeader = "Edit Profile"

  case profileDetailsSectionHeader = "Profile Details"
  case profileNameSubHeader = "Profile Name"
  case profileNamePlaceholder = "Enter profile name"
  case chooseIconButtonText = "Choose Icon"
  case chooseIconSheetHeader = "Pick an icon"

  case appConfigurationSectionHeader = "App Configuration"
  case configureBlockedAppsButtonText = "Configure Blocked Apps"
  case blockedAppsBodyText = "Blocked Apps:"
  case blockedCategoriesBodyText = "Blocked Categories:"
  case appConfigurationDescription = "Broke can't list the names of the apps due to privacy concerns, it is only able to see the amount of apps selected in the configuration screen."

  case securitySectionHeader = "Security"
  case requireMatchingTagToggleText = "Require matching tag to unblock"
  case requireMatchingTagDescription = "When enabled, only the tag created for this profile can unblock it"
  case requireTagToBlockToggleText = "Require tag to block"
  case requireTagToBlockDescription = "When disabled you will be able to block apps without scanning a tag. MAKE SURE YOU SCAN A FOCUS TAG BEFORE USING THIS ACTION OR YOU WILL NOT BE ABLE TO UNBLOCK"

  case deleteProfileButtonText = "Delete Profile"

  case selectAppsToBlockTitle = "Select Apps to Block"
  case selectAppsToBlockDesctiption = "Choose which apps and app categories you want to block when this profile is active."
  case selectAppsToBlockDesctiption2 = "Selecting more than 50 of either apps or categories will not work. Don't blame me, blame Apple."
}

// MARK: - String Extensions
extension String {
  static func common(_ strings: CommonStrings) -> String { strings.rawValue }

  static func home(_ strings: HomeStrings) -> String { strings.rawValue }

  static func profilePicker(_ strings: ProfilePickerStrings) -> String { strings.rawValue }

  static func alerts(_ strings: AlertType) -> String { strings.text }

  static func logs(_ strings: LogStrings) -> String { strings.rawValue }

  static func profileForm(_ strings: profileFormStrings) -> String { strings.rawValue }
}

// MARK: - Text Extension
extension Text {
  init(_ strings: CommonStrings) {
    self.init(strings.rawValue)
  }

  init(_ strings: HomeStrings) {
    self.init(strings.rawValue)
  }

  init(_ strings: ProfilePickerStrings) {
    self.init(strings.rawValue)
  }

  init(_ strings: AlertType) {
    self.init(strings.text)
  }

  init(_ strings: LogStrings) {
    self.init(strings.rawValue)
  }

  init(_ strings: profileFormStrings) {
    self.init(strings.rawValue)
  }
}

// MARK: - TextField Extension
extension TextField where Label == Text {
  init(_ strings: CommonStrings, text: Binding<String>) {
    self.init(strings.rawValue, text: text)
  }

  init(_ strings: HomeStrings, text: Binding<String>) {
    self.init(strings.rawValue, text: text)
  }

  init(_ strings: ProfilePickerStrings, text: Binding<String>) {
    self.init(strings.rawValue, text: text)
  }

  init(_ strings: LogStrings, text: Binding<String>) {
    self.init(strings.rawValue, text: text)
  }

  init(_ strings: profileFormStrings, text: Binding<String>) {
    self.init(strings.rawValue, text: text)
  }
}

// MARK: - Toggle Extension
extension Toggle where Label == Text {
  init(_ strings: CommonStrings, isOn: Binding<Bool>) {
    self.init(strings.rawValue, isOn: isOn)
  }

  init(_ strings: HomeStrings, isOn: Binding<Bool>) {
    self.init(strings.rawValue, isOn: isOn)
  }

  init(_ strings: ProfilePickerStrings, isOn: Binding<Bool>) {
    self.init(strings.rawValue, isOn: isOn)
  }

  init(_ strings: LogStrings, isOn: Binding<Bool>) {
    self.init(strings.rawValue, isOn: isOn)
  }

  init(_ strings: profileFormStrings, isOn: Binding<Bool>) {
    self.init(strings.rawValue, isOn: isOn)
  }
}
