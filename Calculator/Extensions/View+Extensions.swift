import SwiftUI

extension View {
    func squareFrame(size: CGFloat) -> some View {
        frame(width: size, height: size)
    }
    
    func shadow() -> some View {
        shadow(color: .gray, radius: 2, x: 0, y: 2)
    }
    
    func onRotate(perform action: @escaping (UIDeviceOrientation) -> Void) -> some View {
        self.modifier(DeviceRotationViewModifier(action: action))
    }
    
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape( RoundedCorner(radius: radius, corners: corners) )
    }
}
