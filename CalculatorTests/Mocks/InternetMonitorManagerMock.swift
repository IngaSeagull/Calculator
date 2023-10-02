import Foundation
@testable import Calculator
import Combine

final class InternetMonitorManagerMock: InternetMonitorProtocol {
    var isInternetConnected = CurrentValueSubject<Bool, Never>(true)
}
