import SwiftUI

struct SettingsView: View {
    @Binding private var isDarkModeOn: Bool
    @Binding private var settingsButtons: [SettingsButton]
    private var onCloseTap: () -> Void
    private let navigationButtonHeight: CGFloat = 30
    
    init(
        isDarkModeOn: Binding<Bool>,
        settingsButtons: Binding<[SettingsButton]>,
        onCloseTap: @escaping () -> Void
    ) {
        self._isDarkModeOn = isDarkModeOn
        self._settingsButtons = settingsButtons
        self.onCloseTap = onCloseTap
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("ColorMode") {
                    Toggle("", isOn: $isDarkModeOn)
                        .toggleStyle(ColorModeToggleStyle())
                }
                Section("ButtonsVisibility") {
                    ForEach($settingsButtons) { $button in
                        Toggle(button.id, isOn: $button.isOn)
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem {
                    CircleButtonView(
                        onButtonTap: onCloseTap,
                        circleColor: Color.background,
                        width: navigationButtonHeight
                    ) {
                        Image("close")
                            .scaledToFitSquareFrame(size: navigationButtonHeight / 2)
                            .tint(.button2)
                    }
                }
            }
        }
        .preferredColorScheme(isDarkModeOn ? .dark : .light)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(isDarkModeOn: .constant(true), settingsButtons: .constant([SettingsButton(id: "con", isOn: true)]), onCloseTap: {})
    }
}
