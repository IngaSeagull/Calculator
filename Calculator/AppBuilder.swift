import Foundation
import SwiftUI

struct AppBuilder {
    func buildCalculatorView() -> CalculatorView<CalculatorViewModel> {
        let buttons: [[CalculatorButtonType]] = [
            [.clear, .seven, .four, .one, .zero],
            [.negative, .eight, .five, .two, .decimal],
            [.delete, .nine, .six, .three, .equal],
            [.division, .multiplication, .subtraction, .addition],
            [.sin, .cos, .bitcoin]
        ]
        let calulatorViewModel = CalculatorViewModel(
            buttonTypes: buttons,
            apiClient: CryptoConverterAPIClient(),
            internetMonitor: InternetMonitorManager(),
            operationMngr: CalculatorOfflineOperations(),
            settingsMngr: SettingsManager()
        )
        return CalculatorView(viewModel: calulatorViewModel)
    }
}
