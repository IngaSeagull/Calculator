import SwiftUI

struct SettingsView: View {
    @Binding private var isDarkModeOn: Bool
    @Binding private var settingsButtons: [SettingsButton]
    
    init(isDarkModeOn: Binding<Bool>, settingsButtons: Binding<[SettingsButton]>) {
        self._isDarkModeOn = isDarkModeOn
        self._settingsButtons = settingsButtons
    }
    
    var body: some View {
        Form {
            Section {
                Text("Settings")
            }
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
        .preferredColorScheme(isDarkModeOn ? .dark : .light)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(isDarkModeOn: .constant(true), settingsButtons: .constant([SettingsButton(id: "con", isOn: true)]))
    }
}
