import Foundation
import Combine

final class CalculatorViewModel: ObservableObject {
    @Published var presentingErrorPopup = false
    @Published var visualValue = "0"
    @Published var inputInProgress = false
    @Published var displayButtons = [[CalculatorButton]]()
    @Published var settingsButtons = [SettingsButton]()
    @Published var isDarkModeOn = false
    var errorMessage = ""
    
    private let apiClient: APIClient
    private let internetMonitor: InternetMonitorManaging
    private let operationMngr: CalculatorOperations
    private let settingsMngr: SettingsManager
    
    private var operationNumber: Double = 0
    private var currentOperation: OperationType?
    private var isInternetConnected = false
    private var cancellables = Set<AnyCancellable>()
    private enum Constants {
        static let textLimit = 10
        static let noInternetMessage = "No Internet Connection!\nAn Internet connection is required for this operation."
        static let textLimitErrorMessage = "The value exceeds the \(Constants.textLimit) character limit"
    }
    
    init(
        buttonTypes: [[CalculatorButtonType]],
        apiClient: APIClient,
        internetMonitor: InternetMonitorManaging,
        operationMngr: CalculatorOperations,
        settingsMngr: SettingsManager
    ) {
        self.apiClient = apiClient
        self.internetMonitor = internetMonitor
        self.operationMngr = operationMngr
        self.settingsMngr = settingsMngr
        
        self.displayButtons = getButtons(with: buttonTypes)
        
        updateAppColorTheme()
        fillSettingsButtons()
        createBindings()
    }
}

extension CalculatorViewModel {
    
    func updateSettings() {
        settingsMngr.disabledButtons = settingsButtons
            .filter { !$0.isOn }
            .map { $0.id }
        
        settingsMngr.isLightStyle = !isDarkModeOn
        updateDisplayButtons()
    }
    
    func updateDisplayButtons() {
        for (index, row) in displayButtons.enumerated(){
            for (index2, button) in row.enumerated() {
                if button.type.isVisibleInSettings {
                    displayButtons[index][index2].isVisible = !settingsMngr.disabledButtons.contains(button.name)
                }
            }
        }
    }
    
    func didTap(_ button: CalculatorButtonType) {
        switch button {
        case .clear:
            resetOperationAndUpdateValue(0)
            
        case .delete:
            deleteButtonTapped()
            
        case .bitcoin:
            bitcoinButtonTapped()
            
        case .cos:
            resetOperationAndUpdateValue(operationMngr.performCos(visualValue.double))
            
        case .sin:
            resetOperationAndUpdateValue(operationMngr.performSin(visualValue.double))
            
        case .negative:
            negativeButtonTapped()
            
        case .decimal:
            if visualValue.contains(button.rawValue) {
                break
            }
            if inputInProgress && visualValue.count == Constants.textLimit {
                presentError(message: Constants.textLimitErrorMessage)
                return
            }
            visualValue = visualValue + button.rawValue
            inputInProgress = true
            
        case .zero, .one, .two, .three, .four, .five, .six, .seven, .eight, .nine:
            if inputInProgress && visualValue.count == Constants.textLimit {
                presentError(message: Constants.textLimitErrorMessage)
                return
            }
            numberButtonTapped(button.rawValue)
            
        case .addition, .subtraction, .multiplication, .division:
            performMathOperation()
            currentOperation = button.operation
            
        case .equal:
            performMathOperation()
        }
    }
}

private extension CalculatorViewModel {
    private func getButtons(with buttonTypes: [[CalculatorButtonType]]) -> [[CalculatorButton]] {
        var buttons = [[CalculatorButton]]()
        for row in buttonTypes {
            var buttonsRow = [CalculatorButton]()
            for buttonType in row {
                var isButtonVisible = true
                if buttonType.isVisibleInSettings {
                    isButtonVisible = !settingsMngr.disabledButtons.contains(buttonType.rawValue)
                }
                buttonsRow.append(CalculatorButton(type: buttonType, isVisible: isButtonVisible))
            }
            buttons.append(buttonsRow)
        }
        return buttons
    }
    
    private func fillSettingsButtons() {
        settingsButtons = displayButtons.map { row in
            row.filter { $0.type.isVisibleInSettings }
        }
        .flatMap { $0 }
        .map {
            SettingsButton(id: $0.name, isOn: $0.isVisible)
        }
    }
    
    private func updateAppColorTheme() {
        isDarkModeOn = !settingsMngr.isLightStyle
    }
    
    func createBindings() {
        internetMonitor.isInternetConnected
            .removeDuplicates()
            .sink { [weak self] isInternetConnected in
                guard let self else { return }
                self.isInternetConnected = isInternetConnected
            }
            .store(in: &cancellables)
        
        $presentingErrorPopup
            .sink { [weak self] isPopupVisible in
                guard let self else { return }
                if !isPopupVisible {
                    errorMessage = ""
                }
            }
            .store(in: &cancellables)
    }
    
    func deleteButtonTapped() {
        if visualValue.count == 1 {
            visualValue = "0"
            operationNumber = 0
            inputInProgress = false
        } else {
            visualValue = String(visualValue.dropLast())
            if visualValue.hasSuffix(CalculatorButtonType.decimal.rawValue) {
                visualValue = String(visualValue.dropLast())
                operationNumber = visualValue.double
            }
            if visualValue == "0" {
                inputInProgress = false
            }
        }
    }
    
    func negativeButtonTapped() {
        let currentNumer = visualValue.double
        if currentNumer == 0 {
            return
        }
        let result = currentNumer * -1
        visualValue = result.stringWithoutZeroFraction
    }
    
    func numberButtonTapped(_ inputNumber: String) {
        if visualValue == "0" && inputNumber == "0" {
            return
        }
        if inputInProgress {
            visualValue = visualValue + inputNumber
        } else {
            visualValue = inputNumber
            inputInProgress = true
        }
    }
    
    func bitcoinButtonTapped() {
        if visualValue.double == 0 {
            return
        }
        if !isInternetConnected {
            presentError(message: Constants.noInternetMessage)
            return
        }
        Task {
            await perfomBitcoint()
        }
    }
    
    func perfomBitcoint() async {
        let result = await apiClient.getUSDFromBitcoin()
        switch result {
        case .success(let usdValue):
            await MainActor.run {
                let currentNumber = visualValue.double
                let result = operationMngr.multiply(currentNumber, by: usdValue)
                resetOperationAndUpdateValue(result)
            }
        case .failure(let error):
            presentError(message: error.humanReadableDescription)
        }
    }
    
    // TODO: rename
    func resetOperationAndUpdateValue(_ value: Double) {
        let stringValue = value.stringWithoutZeroFraction
        if stringValue.count > Constants.textLimit {
            presentError(message: "Result:\n\(stringValue)\n\(Constants.textLimitErrorMessage)")
            resetOperationAndUpdateValue(0)
            return
        }
        
        visualValue = stringValue
        inputInProgress = false
        currentOperation = nil
        operationNumber = value
    }
    
    func presentError(message: String) {
        errorMessage = message
        presentingErrorPopup = true
        print(message)
    }
    
    func performMathOperation() {
        if !inputInProgress {
            return
        }
        let currentNumber = visualValue.double
        guard let currentOperation else {
            resetOperationAndUpdateValue(currentNumber)
            return
        }
        
        switch currentOperation {
        case .add:
            resetOperationAndUpdateValue(operationMngr.add(operationNumber, to: currentNumber))
        case .subtract:
            resetOperationAndUpdateValue(operationMngr.subtract(operationNumber, from: currentNumber))
        case .multiply:
            resetOperationAndUpdateValue(operationMngr.multiply(operationNumber, by: currentNumber))
        case .divide:
            resetOperationAndUpdateValue(operationMngr.divide(operationNumber, by: currentNumber))
        }
    }
}
