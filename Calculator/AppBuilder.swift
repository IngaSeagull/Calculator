import Foundation

struct AppBuilder {
    func buildCalculatorView() -> CalculatorView {
        let buttons: [[CalculatorButtonType]] = [
            [.clear, .seven, .four, .one, .zero],
            [.negative, .eight, .five, .two, .decimal],
            [.delete, .nine, .six, .three, .equal],
            [.division, .multiplication, .subtraction, .addition],
            [.sin, .cos, .bitcoin]
        ]
        let calulatorViewModel = CalculatorViewModel(
            buttonTypes: buttons,
            apiClient: CryptoCompareAPIClient(),
            internetMonitor: NetworkMonitorManager(),
            operationMngr: CalculatorOperations(),
            settingsMngr: SettingsManager()
        )
        return CalculatorView(viewModel: calulatorViewModel)
    }
}
