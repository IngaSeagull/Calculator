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

struct CalculatorView <ViewModel>: View where ViewModel: CalculatorViewModelProtocol {
    @StateObject private var viewModel: ViewModel
    @State private var presentingBottomSheet = false

//        private let padding: CGFloat = 15
        private let buttonSpacing: CGFloat = 10
//        private let maxCalculatorWidth: CGFloat = 460
    
//    private var calculatorWidth: CGFloat {
//        var width = UIScreen.main.bounds.width - Constants.padding * 2
//        if width > Constants.maxCalculatorWidth {
//            width = Constants.maxCalculatorWidth
//        }
//        return width
//    }
//
    
    // TODO: rename all
    private func getButtonWidth(from geometrySize: CGSize) -> CGFloat {
        let width = geometrySize.width < geometrySize.height ? geometrySize.width : geometrySize.height
        return (width - (6 * buttonSpacing)) / 6
    }
    
    init(viewModel: ViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    func getSettingsButton(buttonWidth: CGFloat) -> some View {
        Button {
            presentingBottomSheet = true
        } label: {
            ZStack {
                Circle()
                    .tint(Color.background)
                    .squareFrame(size: buttonWidth) // TODO
                    .shadow()
                Image("settings")
                    .scaledToFitSquareFrame(size: buttonWidth / 2)
                    .tint(.button2)
            }
            .padding(20)
        }
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                VStack() {
                    HStack {
                        Spacer()
                        if geometry.size.width > geometry.size.height {
                            getSettingsButton(buttonWidth: getButtonWidth(from: geometry.size))
                        }
                    }
                    Spacer()
                }
                VStack(alignment: .trailing) {
                    if geometry.size.width < geometry.size.height {
                        getSettingsButton(buttonWidth: getButtonWidth(from: geometry.size))
                    }
                    Text(viewModel.visualValue)
                        .font(.system(size: Constants.isDeviceIPad ? 80 : 53))
                        .foregroundColor(.white)
                        .shadow()
                    
                    HStack(spacing: buttonSpacing) {
                        if geometry.size.width > geometry.size.height {
                            VStack {
                                ForEach(viewModel.displayButtons, id: \.self) { row in
                                    VStack(spacing: buttonSpacing) {
                                        ForEach(row.filter { $0.type.displayType == .flexible }) { item in
                                            getRoundButton(item, buttonWidth: getButtonWidth(from: geometry.size))
                                        }
                                    }
                                }
                            }
                        }
                        ForEach(viewModel.displayButtons, id: \.self) { row in
                            VStack(spacing: buttonSpacing) {
                                if geometry.size.width > geometry.size.height {
                                    ForEach(row.filter { $0.isVisible && $0.type.displayType != .flexible }) { item in
                                        getRoundButton(item, buttonWidth: getButtonWidth(from: geometry.size)) // for iPad 80?
                                    }
                                } else {
                                    ForEach(row.filter { $0.isVisible }) { item in
                                        getRoundButton(item, buttonWidth: getButtonWidth(from: geometry.size)) // for iPad 80?
                                    }
                                }
                            }
                        }
                    }
                }
                .background(.yellow)
                .frame(width: geometry.size.width, height: geometry.size.height)// * 0.9)
                
                AlertBottomSheetView(isShowing: $viewModel.presentingErrorPopup, errorMessage: viewModel.errorMessage)
            }
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
    
    private func getRoundButton(_ button: CalculatorButton, buttonWidth: CGFloat) -> some View {
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

struct CalculatorView_Previews: PreviewProvider {
    static var previews: some View {
        AppBuilder().buildCalculatorView()
    }
}

fileprivate extension View {
    func shadow() -> some View {
        shadow(color: .gray, radius: 2, x: 0, y: 2)
    }
}
