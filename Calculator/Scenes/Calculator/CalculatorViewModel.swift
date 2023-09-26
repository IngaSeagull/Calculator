import Foundation
import Combine

fileprivate extension CalcButtonM {
    var operation: Operation? {
        switch self {
        case .addition:
            return .add
        case .subtraction:
            return .subtract
        case .multiplication:
            return .multiply
        case .division:
            return .divide
        default:
            return nil//.none // TODO: może zrobić to inaczej? nie do końca ok że każdemu jest przypisywana operacja
        }
    }
    
    var isToggler: Bool { // TODO: rename
        switch self {
        case .addition, .subtraction, .multiplication, .division, .sin, .cos, .bitcoin:
            return true
        case .zero, .one, .two, .three, .four, .five, .six, .seven, .eight, .nine, .decimal, .equal, .clear, .negative, .delete:
            return false
        }
    }
}

enum Operation { // Czy powinno być w tym pliku?
    case add
    case subtract
    case multiply
    case divide
//    case none
}

final class CalculatorViewModel: ObservableObject {
    @Published var presentingErrorPopup = false
    @Published var visualValue = "0" //Rename
    @Published var inputInProgress = false
    @Published var displayButtons = [[CalcButtonM]]()
    
    private var operationNumber: Double = 0
    private var currentOperation: Operation?
    private let apiClient: APIClient
    private let internetMonitor: InternetMonitorManaging
    private var cancellables = Set<AnyCancellable>()
    private var isInternetConnected = false
    private let operationMngr: CalculatorOperations
    
    let allButtonsCopy: [[CalcButtonM]] // do multilevel array?
    var settings: SettingsViewModel
    
    init(
        buttons: [[CalcButtonM]],
        apiClient: APIClient,
        internetMonitor: InternetMonitorManaging,
        operationMngr: CalculatorOperations
    ) {
        self.apiClient = apiClient
        self.internetMonitor = internetMonitor
        self.operationMngr = operationMngr
        self.allButtonsCopy = buttons
        
        let dynamicButtons = buttons.map({ cbm in
            cbm.filter { $0.isToggler }
        })
        
        let togglers = dynamicButtons.flatMap { $0 }//Array(togglerButtons.joined())
        settings = SettingsViewModel(buttons: togglers)
        filterXXX()
        createBindings()
    }
    
    func filterXXX() {
        var filteredDisplayButtons = allButtonsCopy
        for (index, row) in allButtonsCopy.enumerated() {
            
            for button in row {
                
                if settings.settingsTogglers.contains(where: { toggleButton in
                    toggleButton.name == button.rawValue && !toggleButton.isOn
                }) {
                    if let buttonIndex = filteredDisplayButtons[index].firstIndex(of: button) {
                        filteredDisplayButtons[index].remove(at: buttonIndex)
                    }
                }
            }
        }
        displayButtons = filteredDisplayButtons
    }
    
    func updateSettings() {
        settings.updateTogglerSettings()
        filterXXX()
    }
}

extension CalculatorViewModel {
    
    func didTap(_ button: CalcButtonM) {
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
            visualValue = visualValue + button.rawValue
            
        case .zero, .one, .two, .three, .four, .five, .six, .seven, .eight, .nine:
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
    func createBindings() {
        internetMonitor.isInternetConnected
            .removeDuplicates()
            .sink { [weak self] isInternetConnected in
                guard let self else { return }
                self.isInternetConnected = isInternetConnected
            }
            .store(in: &cancellables)
    }
    
    func deleteButtonTapped() {
        if visualValue.count == 1 {
            visualValue = "0"
            operationNumber = 0
        } else {
            visualValue = String(visualValue.dropLast())
            if visualValue.hasSuffix(CalcButtonM.decimal.rawValue) {
                visualValue = String(visualValue.dropLast())
                operationNumber = visualValue.double
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
        if inputInProgress {
            visualValue = visualValue + inputNumber
        } else {
            visualValue = inputNumber
            inputInProgress = true
        }
    }
    
    func bitcoinButtonTapped() {
        if !isInternetConnected {
            presentingErrorPopup = true
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
            print(error.humanReadableDescription) // TODO popup
        }
    }
    
    // TODO: rename
    func resetOperationAndUpdateValue(_ value: Double) {
        visualValue = value.stringWithoutZeroFraction
        inputInProgress = false
        currentOperation = nil
        operationNumber = value
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
