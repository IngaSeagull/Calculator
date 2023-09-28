import Foundation
@testable import Calculator
import Combine

final class NetworkMonitorManagerMock: InternetMonitorProtocol {
    var isInternetConnected = CurrentValueSubject<Bool, Never>(true)
}
