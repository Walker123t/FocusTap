import Foundation

class StringsProvider {
  static let shared = StringsProvider()

  private var strings: [String: Any]?

  private init() {
    loadStrings()
  }

  private func loadStrings() {
    guard let url = Bundle.main.url(forResource: "Strings", withExtension: "json"),
          let data = try? Data(contentsOf: url),
          let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
      return
    }
    strings = json
  }

  func string(for path: StringPath) -> String {
    var current: Any? = strings
    let components = path.rawValue

    // Traverse the path except for the last component
    for component in components.dropLast() {
      guard let dict = current as? [String: Any],
            let next = dict[component] else {
        return components.last ?? ""
      }
      current = next
    }

    // Handle the final component
    if let dict = current as? [String: Any],
       let finalValue = dict[components.last ?? ""] as? String {
      return finalValue
    }

    return components.last ?? ""
  }
}

// MARK: - String Path Protocol
protocol StringPath {
  var rawValue: [String] { get }
}

// MARK: - String Path Enums
enum CommonStrings: StringPath {
  case ok
  case done
  case save
  case create
  case cancel
  case delete

  var rawValue: [String] {
    switch self {
    case .ok: return ["common", "ok"]
    case .done: return ["common", "done"]
    case .save: return ["common", "save"]
    case .create: return ["common", "create"]
    case .cancel: return ["common", "cancel"]
    case .delete: return ["common", "delete"]
    }
  }
}

enum FocusStrings: StringPath {
  case tapToBlock
  case tapToUnblock

  var rawValue: [String] {
    switch self {
    case .tapToBlock: return ["focus", "tapToBlock"]
    case .tapToUnblock: return ["focus", "tapToUnblock"]
    }
  }
}

enum ProfileStrings: StringPath {
  case title
  case newProfile
  case editHint
  case statsFormat
  case formAddTitle
  case formEditTitle
  case sectionDetails
  case sectionName
  case sectionNamePrompt
  case sectionChooseIcon
  case sectionPickIcon
  case sectionApps
  case sectionConfigureApps
  case sectionSelectApps
  case sectionBlockedApps
  case sectionBlockedCategories
  case sectionPrivacyNote
  case sectionSecurity
  case sectionRequireTag
  case sectionRequireTagNote
  case sectionDeleteProfile
  case deleteTitle
  case deleteMessage

  var rawValue: [String] {
    switch self {
    case .title: return ["profiles", "title"]
    case .newProfile: return ["profiles", "newProfile"]
    case .editHint: return ["profiles", "editHint"]
    case .statsFormat: return ["profiles", "statsFormat"]
    case .formAddTitle: return ["profiles", "form", "addTitle"]
    case .formEditTitle: return ["profiles", "form", "editTitle"]
    case .sectionDetails: return ["profiles", "form", "sections", "details"]
    case .sectionName: return ["profiles", "form", "sections", "name"]
    case .sectionNamePrompt: return ["profiles", "form", "sections", "namePrompt"]
    case .sectionChooseIcon: return ["profiles", "form", "sections", "chooseIcon"]
    case .sectionPickIcon: return ["profiles", "form", "sections", "pickIcon"]
    case .sectionApps: return ["profiles", "form", "sections", "apps"]
    case .sectionConfigureApps: return ["profiles", "form", "sections", "configureApps"]
    case .sectionSelectApps: return ["profiles", "form", "sections", "selectApps"]
    case .sectionBlockedApps: return ["profiles", "form", "sections", "blockedApps"]
    case .sectionBlockedCategories: return ["profiles", "form", "sections", "blockedCategories"]
    case .sectionPrivacyNote: return ["profiles", "form", "sections", "privacyNote"]
    case .sectionSecurity: return ["profiles", "form", "sections", "security"]
    case .sectionRequireTag: return ["profiles", "form", "sections", "requireTag"]
    case .sectionRequireTagNote: return ["profiles", "form", "sections", "requireTagNote"]
    case .sectionDeleteProfile: return ["profiles", "form", "sections", "deleteProfile"]
    case .deleteTitle: return ["profiles", "form", "delete", "title"]
    case .deleteMessage: return ["profiles", "form", "delete", "message"]
    }
  }
}

enum AlertStrings: StringPath {
  case wrongTagTitle
  case wrongTagMessage
  case notFocusTagTitle
  case notFocusTagMessage
  case createTagTitle
  case createTagMessage
  case tagCreationTitle
  case tagCreationSuccess
  case tagCreationFailure

  var rawValue: [String] {
    switch self {
    case .wrongTagTitle: return ["alerts", "wrongTag", "title"]
    case .wrongTagMessage: return ["alerts", "wrongTag", "message"]
    case .notFocusTagTitle: return ["alerts", "notFocusTag", "title"]
    case .notFocusTagMessage: return ["alerts", "notFocusTag", "message"]
    case .createTagTitle: return ["alerts", "createTag", "title"]
    case .createTagMessage: return ["alerts", "createTag", "message"]
    case .tagCreationTitle: return ["alerts", "tagCreation", "title"]
    case .tagCreationSuccess: return ["alerts", "tagCreation", "successMessage"]
    case .tagCreationFailure: return ["alerts", "tagCreation", "failureMessage"]
    }
  }
}

enum LogStrings: StringPath {
  case matchingTag
  case wrongTag
  case nonFocusTag
  case noMatchRequired
  case switchingProfile
  case usingCurrentProfile

  var rawValue: [String] {
    switch self {
    case .matchingTag: return ["logs", "matchingTag"]
    case .wrongTag: return ["logs", "wrongTag"]
    case .nonFocusTag: return ["logs", "nonFocusTag"]
    case .noMatchRequired: return ["logs", "noMatchRequired"]
    case .switchingProfile: return ["logs", "switchingProfile"]
    case .usingCurrentProfile: return ["logs", "usingCurrentProfile"]
    }
  }
}

// MARK: - String Extensions
extension String {
  static func common(_ path: CommonStrings) -> String {
    StringsProvider.shared.string(for: path)
  }

  static func focus(_ path: FocusStrings) -> String {
    StringsProvider.shared.string(for: path)
  }

  static func profiles(_ path: ProfileStrings) -> String {
    StringsProvider.shared.string(for: path)
  }

  static func alerts(_ path: AlertStrings) -> String {
    StringsProvider.shared.string(for: path)
  }

  static func logs(_ path: LogStrings) -> String {
    StringsProvider.shared.string(for: path)
  }
}
