import XCTest
@testable import Calculator

final class CalculatorViewModelTests: XCTestCase {

    var sut: CalculatorViewModel!
    var userDefaultsMock: SettingsManagerUserDefaultsMock!
    var settingsMngr: SettingsManager!
    var cryptoClientMock: CryptoConverterAPIClientMock!
    var internetMonitorMock: NetworkMonitorManagerMock!
    
    let buttonAdd = CalculatorButton(type: .addition, isVisible: true)
    let buttonCos = CalculatorButton(type: .cos, isVisible: false)
    let buttonSin = CalculatorButton(type: .sin, isVisible: false)
    let buttonClear = CalculatorButton(type: .clear, isVisible: true)
    let buttonZero = CalculatorButton(type: .zero, isVisible: true)
    let buttonOne = CalculatorButton(type: .one, isVisible: true)
    
    override func setUp() async throws {
        let buttons: [[CalculatorButtonType]] = [
            [.clear, .seven, .four, .one, .zero],
            [.negative, .eight, .five, .two, .decimal],
            [.delete, .nine, .six, .three, .equal],
            [.division, .multiplication, .subtraction, .addition],
            [.sin, .cos, .bitcoin]
        ]
        userDefaultsMock = SettingsManagerUserDefaultsMock()
        settingsMngr = SettingsManager(userDefaults: userDefaultsMock)
        cryptoClientMock = CryptoConverterAPIClientMock()
        internetMonitorMock = NetworkMonitorManagerMock()
        sut = CalculatorViewModel(
            buttonTypes: buttons,
            apiClient: cryptoClientMock,
            internetMonitor: NetworkMonitorManager(),
            operationMngr: CalculatorOperations(),
            settingsMngr: settingsMngr
        )
        try await super.setUp()
    }

    override func tearDown() async throws {
        sut = nil
        userDefaultsMock = nil
        settingsMngr = nil
        cryptoClientMock = nil
        internetMonitorMock = nil
        try await super.tearDown()
    }
    
    func test_updateSettings() {
        settingsMngr.isLightStyle = false
        settingsMngr.disabledButtons = []
        let expectedSettingsButtons = [buttonAdd.name, buttonSin.name]
        sut.settingsButtons = [
            SettingsButton(id: buttonCos.name, isOn: true),
            SettingsButton(id: buttonAdd.name, isOn: false),
            SettingsButton(id: buttonSin.name, isOn: false)
        ]
        sut.isDarkModeOn = false
        sut.updateSettings()
        
        XCTAssertTrue(settingsMngr.isLightStyle)
        XCTAssertEqual(settingsMngr.disabledButtons, expectedSettingsButtons)
    }
    
    func test_didTap_ButtonClear() {
        let previousValue: Double = 7
        sut.visualValue = "\(previousValue)"
        sut.operationNumber = previousValue
        sut.inputInProgress = true
        sut.currentOperation = .add
        
        let expectedValue: Double = 0
        sut.didTap(.clear)
        
        XCTAssertEqual(sut.visualValue, expectedValue.stringWithoutZeroFraction)
        XCTAssertEqual(sut.operationNumber, expectedValue)
        XCTAssertFalse(sut.inputInProgress)
        XCTAssertNil(sut.currentOperation)
    }
    
    
    func test_didTap_ButtonDecimal() {
        var expectedValue = "0."
        sut.visualValue = "0"
        sut.inputInProgress = false
        
        sut.didTap(.decimal)
        
        XCTAssertEqual(sut.visualValue, expectedValue)
        XCTAssertTrue(sut.inputInProgress)
        
        expectedValue = "9.08"
        sut.visualValue = expectedValue
        
        sut.didTap(.decimal)
        
        XCTAssertEqual(sut.visualValue, expectedValue)
    }
    
    func test_getButtons() {
        let buttonTypes: [[CalculatorButtonType]] = [
            [.addition, .cos],
            [.clear],
            [.zero, .one]
        ]
        let expectedResult = [
            [
                buttonAdd,
                buttonCos
            ],
            [buttonClear],
            [buttonZero, buttonOne]
        ]
        sut.settingsButtons = [SettingsButton(id: buttonCos.name, isOn: buttonCos.isVisible)]
        sut.updateSettings()
        let buttons = sut.getButtons(with: buttonTypes)
        
        XCTAssertEqual(buttons, expectedResult)
    }
    
    func test_fillSettingsButtons() {
        let expectedResult = [
            SettingsButton(id: buttonAdd.name, isOn: buttonAdd.isVisible),
            SettingsButton(id: buttonCos.name, isOn: buttonCos.isVisible)
        ]
        sut.displayButtons = [
            [
                buttonAdd,
                buttonCos
            ],
            [buttonClear],
            [buttonZero]
        ]
        
        sut.fillSettingsButtons()
        
        XCTAssertEqual(sut.settingsButtons, expectedResult)
    }
    
    func test_updateAppColorTheme() {
        sut.isDarkModeOn = true
        settingsMngr.isLightStyle = true
        
        sut.updateAppColorTheme()
        
        XCTAssertFalse(sut.isDarkModeOn)
    }
    
    func test_deleteButtonTapped() {
        var expectedResult = "3"
        sut.visualValue = "3.7"
        sut.deleteButtonTapped()
        
        XCTAssertEqual(sut.visualValue, expectedResult)
        
        expectedResult = "0"
        sut.deleteButtonTapped()
        
        XCTAssertEqual(sut.visualValue, expectedResult)
    }
    
    func test_negativeButtonTapped() {
        var expectedResult = "-0.7"
        sut.visualValue = "0.7"
        sut.negativeButtonTapped()
        
        XCTAssertEqual(sut.visualValue, expectedResult)
        
        expectedResult = "0.7"
        sut.negativeButtonTapped()
        
        XCTAssertEqual(sut.visualValue, expectedResult)
        
        expectedResult = "0"
        sut.visualValue = expectedResult
        sut.negativeButtonTapped()
        
        XCTAssertEqual(sut.visualValue, expectedResult)
    }
    
    func test_numberButtonTapped() {
        let inputNumber = "0"
        sut.visualValue = inputNumber
        sut.inputInProgress = false
        sut.numberButtonTapped(inputNumber)
        
        XCTAssertFalse(sut.inputInProgress)
        XCTAssertEqual(sut.visualValue, inputNumber)
        
        let previousVisualValue = "10"
        sut.visualValue = previousVisualValue
        sut.numberButtonTapped(inputNumber)
        
        XCTAssertTrue(sut.inputInProgress)
        XCTAssertEqual(sut.visualValue, inputNumber)
        
        sut.visualValue = previousVisualValue
        sut.numberButtonTapped(inputNumber)
        
        XCTAssertTrue(sut.inputInProgress)
        XCTAssertEqual(sut.visualValue, previousVisualValue + inputNumber)
    }
    
    func test_bitcoinButtonTapped() {
        // TODO
    }
    
    func test_perfomBitcoint() async {
        let value = 8.2
        sut.visualValue = value.stringWithoutZeroFraction
        await sut.perfomBitcoint()
        sut.visualValue = (value * cryptoClientMock.usdFromBitcoinResult).stringWithoutZeroFraction
    }
    
    func test_resetOperationAndUpdateValue_ValueInLimit() {
        let previousValue: Double = 7
        sut.visualValue = "\(previousValue)"
        sut.operationNumber = previousValue
        sut.inputInProgress = true
        sut.currentOperation = .add
        
        let expectedValue: Double = -5.6
        sut.resetOperationAndUpdateValue(expectedValue)
        
        XCTAssertEqual(sut.visualValue, expectedValue.stringWithoutZeroFraction)
        XCTAssertEqual(sut.operationNumber, expectedValue)
        XCTAssertFalse(sut.inputInProgress)
        XCTAssertNil(sut.currentOperation)
    }
    
    
    func test_resetOperationAndUpdateValue_ValueOutsideLimit() {
        let newValue: Double = 99999999999
        let expectedValue: Double = 0
        sut.resetOperationAndUpdateValue(newValue)
        
        XCTAssertEqual(sut.visualValue, expectedValue.stringWithoutZeroFraction)
        XCTAssertEqual(sut.operationNumber, expectedValue)
        XCTAssertFalse(sut.inputInProgress)
        XCTAssertNil(sut.currentOperation)
    }

    func test_presentError() {
        let erorMessage = "Test"
        sut.presentError(message: erorMessage)
        
        XCTAssertTrue(sut.presentingErrorPopup)
        XCTAssertEqual(sut.errorMessage, erorMessage)
    }
}
