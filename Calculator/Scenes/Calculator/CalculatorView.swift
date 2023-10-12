import SwiftUI

struct CalculatorView <ViewModel: CalculatorViewModelProtocol>: View {
    @StateObject private var viewModel: ViewModel
    @State private var presentingBottomSheet = false
    private let buttonSpacing: CGFloat = 10
    @State private var orientation = UIDevice.current.orientation
    private let settingsButtonHeight: CGFloat = 50
    private let maxButtonWidth: CGFloat = 100
    
    init(viewModel: ViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                getSettingsButton()
                GeometryReader { geometry in
                    VStack(alignment: .trailing, spacing: 5) {
                        Text(viewModel.visualValue)
                            .font(.system(size: Constants.isDeviceIPad ? 80 : 53))
                            .foregroundColor(.white)
                            .shadow()
                        withAnimation(.easeInOut) {
                            getCalculatorButtons(geometrySize: geometry.size)
                        }
                    }
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    
                    AlertBottomSheetView(isShowing: $viewModel.presentingErrorPopup, errorMessage: viewModel.errorMessage)
                }
                .sheet(isPresented: $presentingBottomSheet) {
                    SettingsView(isDarkModeOn: $viewModel.isDarkModeOn, settingsButtons: $viewModel.settingsButtons, onCloseTap: {
                        presentingBottomSheet.toggle()
                    })
                }
                .onChange(of: presentingBottomSheet) { newValue in
                    if !newValue {
                        viewModel.updateSettings()
                    }
                }
                .onRotate { newOrientation in
                    if newOrientation.isFlat || !newOrientation.isValidInterfaceOrientation || (Constants.isDeviceIPhone && newOrientation == .portraitUpsideDown) {
                        return
                    }
                    orientation = newOrientation
                }
            }
            .background(Color.background)
            .preferredColorScheme(viewModel.isDarkModeOn ? .dark : .light)
        }
    }
    
    private func getCalculatorButtons(geometrySize: CGSize) -> some View {
        let buttonWidth = getButtonWidth(from: geometrySize)
        return HStack(spacing: buttonSpacing) {
            if orientation.isLandscape {
                VStack {
                    ForEach(viewModel.displayButtons.flatMap { $0 }.filter { $0.type.displayType == .flexible }) { item in
                        getCalculatorButton(item, buttonWidth: buttonWidth)
                    }
                }
            }
            ForEach(viewModel.displayButtons, id: \.self) { row in
                VStack(spacing: buttonSpacing) {
                    ForEach(row.filter { $0.isVisible && (orientation.isLandscape ? $0.type.displayType != .flexible : true) }) { item in
                        getCalculatorButton(item, buttonWidth: buttonWidth)
                    }
                    
                }
            }
        }
    }
    
    private func getButtonWidth(from geometrySize: CGSize) -> CGFloat {
        print("geometrySize: \(geometrySize)")
        let width = geometrySize.width < geometrySize.height ? geometrySize.width : geometrySize.height
        var buttonWidth = width * 0.16
        if buttonWidth > maxButtonWidth {
            buttonWidth = maxButtonWidth
        }
        return buttonWidth
    }
    
    private func getCalculatorButton(_ button: CalculatorButton, buttonWidth: CGFloat) -> some View {
        CircleButtonView(onButtonTap: {
            viewModel.didTap(button.type)
        }, circleColor: button.type.buttonColor, width: buttonWidth) {
            Text(button.name)
                .font(.system(size: Constants.isDeviceIPad ? 24 : 18).bold())
                .foregroundColor(Color.buttonTint)
        }
    }
    
    func getSettingsButton() -> some View {
        VStack {
            HStack {
                Spacer()
                CircleButtonView(onButtonTap: {
                    presentingBottomSheet.toggle()
                }, circleColor: Color.background, width: settingsButtonHeight) {
                    Image("settings")
                        .scaledToFitSquareFrame(size: settingsButtonHeight / 2)
                        .tint(.button2)
                }
                .padding(20)
            }
            Spacer()
        }
    }
}

struct CalculatorView_Previews: PreviewProvider {
    static var previews: some View {
        AppBuilder().buildCalculatorView()
    }
}

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
