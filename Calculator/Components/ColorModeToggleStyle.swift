import SwiftUI

struct ColorModeToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: 25) {
            Image("bMode")
                .resizable()
                .scaledToFit()
                .frame(width: 30, height: 30)
            RoundedRectangle(cornerRadius: 16, style: .circular)
                .fill(Color.colorToggle)
                .frame(width: 50, height: 29)
                .overlay(
                    Circle()
                        .fill(.white)
                        .shadow(radius: 1, x: 0, y: 1)
                        .padding(1.5)
                        .offset(x: configuration.isOn ? 10 : -10))
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        configuration.isOn.toggle()
                    }
                }
            
            Image("ohMode")
                .resizable()
                .scaledToFit()
                .frame(width: 30, height: 30)
        }
    }
}
