import SwiftUI

struct CircleButtonView<Overlay: View>: View {
    private var onButtonTap: () -> Void
    private var circleColor: Color
    private var width: CGFloat
    private let overlay: Overlay
    
    init(
        onButtonTap: @escaping () -> Void,
        circleColor: Color, width: CGFloat, @ViewBuilder overlay: () -> Overlay) {
        self.onButtonTap = onButtonTap
        self.circleColor = circleColor
        self.width = width
        self.overlay = overlay()
    }
    
    var body: some View {
        Button(
            action: onButtonTap,
            label: {
                Circle()
                    .tint(circleColor)
                    .squareFrame(size: width)
                    .shadow()
                    .overlay(overlay)
            }
        )
    }
}

struct CircleButtonView_Previews: PreviewProvider {
    static var previews: some View {
        CircleButtonView(onButtonTap: {}, circleColor: Color.background, width: 60, overlay: {
            Image("settings")
                .scaledToFitSquareFrame(size: 60 / 2)
                .tint(.button2)
        })
    }
}
