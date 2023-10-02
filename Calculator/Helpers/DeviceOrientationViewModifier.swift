import SwiftUI

struct DeviceRotationViewModifier: ViewModifier {
    let action: (UIDeviceOrientation) -> Void

        func body(content: Content) -> some View {
            content
                .onAppear()
                .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
                    var deviceOrientation = UIDevice.current.orientation
                    if deviceOrientation == .unknown {
                        if let interfaceOrientation = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.windowScene?.interfaceOrientation {
                            deviceOrientation = UIDeviceOrientation(rawValue: interfaceOrientation.rawValue) ?? .unknown
                        }
                    }
                    action(deviceOrientation)
                }
        }
}
