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
        var current = strings
        for component in path.components {
            guard let next = current?[component] as? [String: Any] else {
                return path.components.last ?? ""
            }
            current = next
        }
        return (current as? String) ?? path.components.last ?? ""
    }
}

struct StringPath {
    let components: [String]
    
    static func common(_ path: String) -> StringPath {
        StringPath(components: ["common", path])
    }
    
    static func broker(_ path: String) -> StringPath {
        StringPath(components: ["broker", path])
    }
    
    static func alerts(_ type: String, _ field: String) -> StringPath {
        StringPath(components: ["alerts", type, field])
    }
    
    static func logs(_ path: String) -> StringPath {
        StringPath(components: ["logs", path])
    }
}

// String convenience extensions
extension String {
    static func common(_ path: String) -> String {
        StringsProvider.shared.string(for: .common(path))
    }
    
    static func broker(_ path: String) -> String {
        StringsProvider.shared.string(for: .broker(path))
    }
    
    static func alerts(_ type: String, _ field: String) -> String {
        StringsProvider.shared.string(for: .alerts(type, field))
    }
    
    static func logs(_ path: String) -> String {
        StringsProvider.shared.string(for: .logs(path))
    }
}
