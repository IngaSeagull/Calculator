import SwiftUI

public extension Image {
    
    func resizableAndScaledToFit() -> some View {
        resizable().scaledToFit()
    }
    
    func scaledToFitSquareFrame(size: CGFloat) -> some View {
        resizableAndScaledToFit().squareFrame(size: size)
    }
}
