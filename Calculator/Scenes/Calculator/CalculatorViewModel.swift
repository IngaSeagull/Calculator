import Foundation
import Combine

protocol CalculatorViewModelProtocol: ObservableObject {
    var presentingErrorPopup: Bool { get set }
    var visualValue: String { get }
    var inputInProgress: Bool { get }
    var displayButtons: [[CalculatorButton]] { get }
    var settingsButtons: [SettingsButton] { get set }
    var isDarkModeOn: Bool { get set }
    var errorMessage: String { get }
    
//    init(
//        buttonTypes: [[CalculatorButtonType]],
//        apiClient: APIClient,
//        internetMonitor: InternetMonitorManaging,
//        operationMngr: CalculatorOperations,
//        settingsMngr: SettingsManager
//    )
    func updateSettings()
    func updateDisplayButtons()
    func didTap(_ button: CalculatorButtonType)
}

final class CalculatorViewModel: CalculatorViewModelProtocol {
    @Published var presentingErrorPopup = false
    @Published var visualValue = "0"
    @Published var inputInProgress = false
    @Published var displayButtons = [[CalculatorButton]]()
    @Published var settingsButtons = [SettingsButton]()
    @Published var isDarkModeOn = false
    var errorMessage = "TextLimitErrorMessage"// \(textLimit)"//""
    
    private let apiClient: APIClient
    private let internetMonitor: InternetMonitorProtocol
    private let operationMngr: CalculatorOperations
    private let settingsMngr: SettingsManager
    
    var operationNumber: Double = 0
    var currentOperation: OperationType?
    var isInternetConnected = false
    var cancellables = Set<AnyCancellable>()
    let textLimit = 10
//        static let textLimitErrorMessage = "The value exceeds the \(textLimit) character limit"

    
    init(
        buttonTypes: [[CalculatorButtonType]],
        apiClient: APIClient,
        internetMonitor: InternetMonitorProtocol,
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
            if inputInProgress && visualValue.count == textLimit {
                presentError(message: "TextLimitErrorMessage \(textLimit)")
                return
            }
            visualValue = visualValue + button.rawValue
            inputInProgress = true
            
        case .zero, .one, .two, .three, .four, .five, .six, .seven, .eight, .nine:
            if inputInProgress && visualValue.count == textLimit {
                presentError(message: "TextLimitErrorMessage \(textLimit)")
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
    
    // TODO: rename
    func getButtons(with buttonTypes: [[CalculatorButtonType]]) -> [[CalculatorButton]] {
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
    
    func fillSettingsButtons() {
        settingsButtons = displayButtons.map { row in
            row.filter { $0.type.isVisibleInSettings }
        }
        .flatMap { $0 }
        .map {
            SettingsButton(id: $0.name, isOn: $0.isVisible)
        }
    }
    
    func updateAppColorTheme() {
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
                    self.errorMessage = ""
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
            presentError(message: "NoInternetMessage")
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
        if stringValue.count > textLimit {
//            presentError(message: "Result:\n\(stringValue)\n\(textLimitErrorMessage)")
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
