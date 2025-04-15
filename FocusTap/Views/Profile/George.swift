import AppIntents
import SwiftUI

struct ToggleProfileIntent: AppIntent {
    static var title: LocalizedStringResource = "Toggle Profile"
    
    @Parameter(title: "Profile")
    var profile: Profile
    
    init() {}
    
    init(profile: Profile) {
        self.profile = profile
    }
    
    static var parameterSummary: some ParameterSummary {
        Summary("Toggle \(\.$profile)")
    }
    
    func perform() async throws -> some IntentResult {
//      if ProfileManager.shared.currentProfile == profile {
////            ProfileManager.shared.stopProfile()
//        } else {
////            ProfileManager.shared.selectProfile(profile)
//        }
        return .result()
    }
}

extension Profile: AppEntity {
    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Profile"
    
    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(name)")
    }
    
    static var defaultQuery = ProfileQuery()
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

extension Profile {
    static var shortcutsProvider: ProfileShortcutsProvider {
        ProfileShortcutsProvider()
    }
}

struct ProfileShortcutsProvider: AppShortcutsProvider {
  static var shortcutTileColor: ShortcutTileColor = .blue

    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: ToggleProfileIntent(),
            phrases: ["Toggle Profile in \(.applicationName)"],
            shortTitle: "Toggle Profile",
            systemImageName: "clock.arrow.circlepath"
        )
    }
}
