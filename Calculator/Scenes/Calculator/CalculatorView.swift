import SwiftUI

fileprivate extension CalcButtonM {
    var buttonColor: Color {
        switch self {
        case .equal:
            return Color("Blue 1")
        case .clear:
            return Color("pink4")
        case .delete, .negative:
            return Color("Blue")
        case .bitcoin:
            return Color("Blue 2")
        case .addition, .subtraction, .multiplication, .division, .sin, .cos:
            return Color("Pink 3")
        default:
            return Color("Pink")
        }
    }
}

struct CalculatorView: View {
    @StateObject private var viewModel: CalculatorViewModel
    @State private var presentingBottomSheet = false
    
    init(viewModel: CalculatorViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        ZStack {
            Color("Pink 2")
            VStack {
                HStack {
                    Spacer()
                    Button {
                        presentingBottomSheet = true
                        // TODO: performe Settings action
                        // Maybe bottom popup?
                    } label: {
                        Image("settings3-B")
                            .resizable()
                            .scaledToFit()
                    }
                    //                    .background(Color("Pink 2"))
                    .frame(width: 30, height: 30)
                }
                HStack {
                    Spacer()
                    Text(viewModel.visualValue)
                        .font(.system(size: 60))
                        .foregroundColor(.white)
                }
                HStack {
                    HStack {
                        ForEach(viewModel.displayButtons, id: \.self) { row in
                            VStack {
                                ForEach(row, id: \.self) { item in
                                    bubbleButton(item)
                                }
                            }
                        }
                    }
                }
            }
            .padding()
        }
        .ignoresSafeArea()
        .sheet(isPresented: $presentingBottomSheet) {
            VStack {
                ForEach($viewModel.settings.settingsTogglers, id: \.self) { $toggle in
                    
                    Toggle(isOn: $toggle.isOn) {
                        Text(toggle.name)
                    }
                }
            }
            .padding()
        }
        .onChange(of: presentingBottomSheet) { newValue in
            if newValue == false {
                viewModel.updateSettings()
            }
        }
        .popover(isPresented: $viewModel.presentingErrorPopup) {
            ZStack {
                Color.blue.frame(width: 200, height: 100)
                Text("Popup!")
            }
        }
    }
    
    func bubbleButton(_ button: CalcButtonM) -> some View {
        Button(action: {
            viewModel.didTap(button)
        }, label: {
            Text(button.rawValue)
                .frame(width: 60, height: 60)
                .background(button.buttonColor)
                .cornerRadius(35)
        })
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        AppBuilder().buildCalculatorView()
    }
}
