import Foundation
import Network
import Combine

protocol InternetMonitorProtocol {
    var isInternetConnected: CurrentValueSubject<Bool, Never> { get }
}

final class InternetMonitorManager: InternetMonitorProtocol {
    private let monitor: NWPathMonitor
    private let queue = DispatchQueue(label: "NetworkMonitor")
    private(set) var isInternetConnected = CurrentValueSubject<Bool, Never>(false)

    init(monitor: NWPathMonitor = NWPathMonitor()) {
        self.monitor = monitor
        startMonitoring()
    }

    private func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            self?.isInternetConnected.send( path.status == .satisfied )
            if path.status == .satisfied {
                print("✅🌐 Internet connected!")
            } else {
                print("❌🌐 No Internet connection. Reson: \(path.unsatisfiedReason)")
            }
        }
        monitor.start(queue: queue)
    }
}
