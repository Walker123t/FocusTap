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
  case create
  case cancel

  var rawValue: [String] {
    switch self {
    case .ok: return ["common", "ok"]
    case .create: return ["common", "create"]
    case .cancel: return ["common", "cancel"]
    }
  }
}

enum BrokerStrings: StringPath {
  case tapToBlock
  case tapToUnblock

  var rawValue: [String] {
    switch self {
    case .tapToBlock: return ["broker", "tapToBlock"]
    case .tapToUnblock: return ["broker", "tapToUnblock"]
    }
  }
}

enum ProfileStrings: StringPath {
  case title
  case newProfile
  case editHint
  case statsFormat

  var rawValue: [String] {
    switch self {
    case .title: return ["profiles", "title"]
    case .newProfile: return ["profiles", "newProfile"]
    case .editHint: return ["profiles", "editHint"]
    case .statsFormat: return ["profiles", "statsFormat"]
    }
  }
}

enum AlertStrings: StringPath {
  case wrongTagTitle
  case wrongTagMessage
  case notBrokerTagTitle
  case notBrokerTagMessage
  case createTagTitle
  case createTagMessage
  case tagCreationTitle
  case tagCreationSuccess
  case tagCreationFailure

  var rawValue: [String] {
    switch self {
    case .wrongTagTitle: return ["alerts", "wrongTag", "title"]
    case .wrongTagMessage: return ["alerts", "wrongTag", "message"]
    case .notBrokerTagTitle: return ["alerts", "notBrokerTag", "title"]
    case .notBrokerTagMessage: return ["alerts", "notBrokerTag", "message"]
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
  case nonBrokeTag
  case noMatchRequired
  case switchingProfile
  case usingCurrentProfile

  var rawValue: [String] {
    switch self {
    case .matchingTag: return ["logs", "matchingTag"]
    case .wrongTag: return ["logs", "wrongTag"]
    case .nonBrokeTag: return ["logs", "nonBrokeTag"]
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

  static func broker(_ path: BrokerStrings) -> String {
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
