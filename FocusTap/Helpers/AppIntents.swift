import AppIntents
import SwiftUI

// MARK: - Shortcut Provider
struct ProfileShortcutsProvider: AppShortcutsProvider {
  static var shortcutTileColor: ShortcutTileColor = .blue

  static var appShortcuts: [AppShortcut] {
    let setProfileState = AppShortcut(
      intent: SetProfileStateIntent(),
      phrases: ["Set Profile State in \(.applicationName)"],
      shortTitle: "Set Profile State",
      systemImageName: "clock.arrow.circlepath"
    )

    return [setProfileState]
  }
}

// MARK: - Set Profile State Intent

struct SetProfileStateIntent: AppIntent {
  static var title: LocalizedStringResource = "Set Profile State"

  @Parameter(title: "Profile")
  var profile: Profile
  
  @Parameter(title: "State")
  var profileState: AppBlocker.ProfileState

  init() {}

  init(profile: Profile) {
    self.profile = profile
  }

  static var parameterSummary: some ParameterSummary {
    Summary("\(\.$profileState) \(\.$profile)")
  }

  func perform() async throws -> some IntentResult {
    ProfileManager.shared.setCurrentProfile(id: profile.id)
    AppBlocker.shared.applyBlockingState(for: profile, to: profileState)
    
    return .result()
  }
}

struct ProfileQuery: EntityQuery {
    func entities(for identifiers: [Profile.ID]) async throws -> [Profile] {
        return identifiers.compactMap { id in
            ProfileManager.shared.profiles.first { $0.id == id }
        }
    }
    
    func suggestedEntities() async throws -> [Profile] {
        return ProfileManager.shared.profiles
    }
}

extension Profile: AppEntity {
  static var typeDisplayRepresentation: TypeDisplayRepresentation = "Profile"

  var displayRepresentation: DisplayRepresentation {
    DisplayRepresentation(title: "\(name)")
  }

  static var defaultQuery = ProfileQuery()
}

extension Profile {
    static var shortcutsProvider: ProfileShortcutsProvider {
        ProfileShortcutsProvider()
    }
}
