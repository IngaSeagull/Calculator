import SwiftUI

struct AlertBottomSheetView: View {
    
    @Binding var isShowing: Bool
    private let maxHeight: CGFloat = UIScreen.main.bounds.height / 3
    private let cornerRadius: CGFloat = 16
    private let errorMessage: String
    private var isDeviceIPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    
    init(isShowing: Binding<Bool>, errorMessage: String) {
        self._isShowing = isShowing
        self.errorMessage = errorMessage
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            if isShowing {
                Color.black
                    .opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation {
                            isShowing = false
                        }
                    }
                ZStack {
                    Color.alertBackground
                    VStack {
                        Text(errorMessage)
                            .font(.system(size: isDeviceIPad ? 24 : 18))
                            .foregroundColor(Color.alertTint)
                        Image("error")
                            .scaledToFitSquareFrame(size: 60)
                            .foregroundColor(Color.alertTint)
                    }
                    .padding()
                }
                .frame(maxWidth: .infinity, maxHeight: maxHeight)
                .cornerRadius(cornerRadius, corners: .topLeft)
                .cornerRadius(cornerRadius, corners: .topRight)
                .transition(.opacity.combined(with: .move(edge: .bottom)))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        .ignoresSafeArea()
        .animation(.easeInOut, value: isShowing)
    }
}
