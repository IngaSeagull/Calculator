import SwiftUI

fileprivate extension CalculatorButtonType {
    var buttonColor: Color {
        switch self {
        case .clear:
            return .button2
        case .delete, .negative, .equal:
            return .button4
        case .bitcoin, .addition, .subtraction, .multiplication, .division, .sin, .cos:
            return .button1
        default:
            return .button3
        }
    }
}

struct CalculatorView: View {
    @StateObject private var viewModel: CalculatorViewModel
    @State private var presentingBottomSheet = false
    
    private enum Constants {
        static let padding: CGFloat = 15
        static let buttonSpacing: CGFloat = 12
        static let maxCalculatorWidth: CGFloat = 460
        static let isDeviceIPad = UIDevice.current.userInterfaceIdiom == .pad
    }
    
    private var calculatorWidth: CGFloat {
        var width = UIScreen.main.bounds.width - Constants.padding * 2
        if width > Constants.maxCalculatorWidth {
            width = Constants.maxCalculatorWidth
        }
        return width
    }
    
    private var buttonWidth: CGFloat {
        (calculatorWidth - (5 * Constants.buttonSpacing)) / 5
    }
    
    init(viewModel: CalculatorViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .trailing) {
                Button {
                    presentingBottomSheet = true
                } label: {
                    ZStack {
                        Circle()
                            .tint(Color.background)
                            .squareFrame(size: buttonWidth)
                            .shadow()
                        Image("settings")
                            .scaledToFitSquareFrame(size: 30)
                            .tint(.button2)
                    }
                }
                Text(viewModel.visualValue)
                    .font(.system(size: Constants.isDeviceIPad ? 80 : 53))
                    .foregroundColor(.white)
                    .shadow()
                
                HStack(spacing: Constants.buttonSpacing) {
                    ForEach(viewModel.displayButtons, id: \.self) { row in
                        VStack(spacing: Constants.buttonSpacing) {
                            ForEach(row, id: \.id) { item in
                                if item.isVisible {
                                    getRoundButton(item)
                                }
                            }
                        }
                    }
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height * 0.9)
            
            AlertBottomSheetView(isShowing: $viewModel.presentingErrorPopup, errorMessage: viewModel.errorMessage)
        }
        .ignoresSafeArea()
        .background(Color.background)
        .sheet(isPresented: $presentingBottomSheet) {
            SettingsView(isDarkModeOn: $viewModel.isDarkModeOn, settingsButtons: $viewModel.settingsButtons)
        }
        .onChange(of: presentingBottomSheet) { newValue in
            if !newValue {
                viewModel.updateSettings()
            }
        }
        .preferredColorScheme(viewModel.isDarkModeOn ? .dark : .light)
    }
    
    private func getRoundButton(_ button: CalculatorButton) -> some View {
        Button(action: {
            viewModel.didTap(button.type)
        }, label: {
            Text(button.name)
                .font(.system(size: Constants.isDeviceIPad ? 24 : 18).bold())
                .squareFrame(size: buttonWidth)
                .foregroundColor(Color.buttonTint)
                .background(
                    Circle()
                        .foregroundColor(button.type.buttonColor)
                )
                
        })
        .shadow()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        AppBuilder().buildCalculatorView()
    }
}

fileprivate extension View {
    func shadow() -> some View {
        shadow(color: .gray, radius: 2, x: 0, y: 2)
    }
}
