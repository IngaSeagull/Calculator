import Foundation

extension UserDefaults {
    func setData<T>(value: T, key: UserDefaultsKey) {
        let defaults = UserDefaults.standard
        defaults.set(value, forKey: key.rawValue)
    }

    func getData<T>(type: T.Type, forKey: UserDefaultsKey) -> T? {
        let defaults = UserDefaults.standard
        let value = defaults.object(forKey: forKey.rawValue) as? T
        return value
    }

    func removeData(key: UserDefaultsKey) {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: key.rawValue)
    }
}
