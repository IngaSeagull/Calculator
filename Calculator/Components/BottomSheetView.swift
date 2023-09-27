import SwiftUI

struct BottomSheetView<Content: View>: View {
    
    @Binding var isShowing: Bool
    @ViewBuilder let content: Content
    private let maxHeight: CGFloat = UIScreen.main.bounds.height / 3
    private let cornerRadius: CGFloat = 16
    
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
                    content
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
