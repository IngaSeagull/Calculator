import SwiftUI

fileprivate extension CalculatorButtonType {
    var buttonColor: Color {
        switch self {
        case .equal:
            return .button4
        case .clear:
            return .button2
        case .delete, .negative:
            return .button4
        case .bitcoin:
            return .button1
        case .addition, .subtraction, .multiplication, .division, .sin, .cos:
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
    }
    
    init(viewModel: CalculatorViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        ZStack {
            Color.background
            VStack {
                
                HStack {
                    Spacer()
                    Button {
                        presentingBottomSheet = true
                    } label: {
                        ZStack {
                            Circle()
                                .tint(Color.background)
                                .squareFrame(size: buttonWidth())
                                .shadow()
                            Image("settings")
                                .scaledToFitSquareFrame(size: 30)
                                .tint(.button2)
                        }
                    }
                }
                .padding(.bottom, 30)
                
                HStack {
                    Spacer()
                    Text(viewModel.visualValue)
                        .font(.system(size: isDeviceIPad() ? 80 : 53))
                        .foregroundColor(.white)
                        .shadow()
                }
                
                HStack(spacing: Constants.buttonSpacing) {
                    ForEach(viewModel.displayButtons, id: \.self) { row in
                        VStack(spacing: Constants.buttonSpacing) {
                            ForEach(row, id: \.id) { item in
                                if item.isVisible {
                                    roundButton(item)
                                }
                            }
                        }
                    }
                }
            }
            .frame(width: calculatorWidth())
            .padding(Constants.padding)
            
            BottomSheetView(isShowing: $viewModel.presentingErrorPopup) {
                ZStack {
                    Color.alertBackground
                    VStack {
                        Text(viewModel.errorMessage)
                            .font(.system(size: isDeviceIPad() ? 24 : 18))
                            .foregroundColor(Color.alertTint)
                        Image("error")
                            .scaledToFitSquareFrame(size: 60)
                            .foregroundColor(Color.alertTint)
                    }
                    .padding()
                }
            }
        }
        .ignoresSafeArea()
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
    
    func calculatorWidth() -> CGFloat {
        var width = UIScreen.main.bounds.width - Constants.padding * 2
        if width > Constants.maxCalculatorWidth {
            width = Constants.maxCalculatorWidth
        }
        return width
    }
    
    func buttonWidth() -> CGFloat {
        (calculatorWidth() - (5 * Constants.buttonSpacing)) / 5
    }
    
    func roundButton(_ button: CalculatorButton) -> some View {
        Button(action: {
            viewModel.didTap(button.type)
        }, label: {
            Text(button.name)
                .font(.system(size: isDeviceIPad() ? 24 : 18))
                .bold()
                .frame(width: buttonWidth(), height: buttonWidth())
                .background(button.type.buttonColor)
                .cornerRadius(buttonWidth() / 2)
                .foregroundColor(Color.buttonTint)
                
        })
        .shadow()
    }
    
    func isDeviceIPad() -> Bool {
        UIDevice.current.userInterfaceIdiom == .pad
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
