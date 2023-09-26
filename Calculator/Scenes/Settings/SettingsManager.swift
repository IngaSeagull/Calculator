import Foundation
import Combine

final class SettingsManager: ObservableObject {
    private let disabledButtonsKey = "disabledButtonsKey"
    private let lightStyleKey = "lightStyleKey"
    private let userDefaults = UserDefaults.standard
    
    @Published var isLightStyle = false
    @Published var disabledButtons = [String]()
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        self.isLightStyle = userDefaults.bool(forKey: lightStyleKey)
        self.disabledButtons = userDefaults.object(forKey: disabledButtonsKey) as? [String] ?? [String]()
        createBindings()
    }
}

private extension SettingsManager {
    func createBindings() {
        $isLightStyle
            .sink { [weak self] isLightStyle in
                guard let self else { return }
                self.setLightStyle(to: isLightStyle)
            }
            .store(in: &cancellables)
        
        $disabledButtons
            .sink { [weak self] disabledButtons in
                guard let self else { return }
                self.saveDisabledButtons(disabledButtons)
            }
            .store(in: &cancellables)
    }
    
    func saveDisabledButtons(_ disabledButtons: [String]) {
        userDefaults.set(disabledButtons, forKey: disabledButtonsKey)
    }
    
    func setLightStyle(to isLightStyle: Bool) {
        userDefaults.set(isLightStyle, forKey: lightStyleKey)
    }
}
