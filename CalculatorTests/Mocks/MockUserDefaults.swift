import Foundation

class SettingsManagerUserDefaultsMock: UserDefaults {
    var disabledButtons: [String]?
    var lightStyle: Bool?

    override func bool(forKey defaultName: String) -> Bool {
        lightStyle ?? false
    }

    override func set(_ value: Bool, forKey defaultName: String) {
        lightStyle = value
    }
    
    override func object(forKey defaultName: String) -> Any? {
        disabledButtons ?? []
    }
    
    override func set(_ value: Any?, forKey defaultName: String) {
        disabledButtons = value as? [String] ?? []
    }
    
}
