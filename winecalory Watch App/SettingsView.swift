import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var userSettings: UserSettings

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Preferred Drink")) {
                    Picker(selection: $userSettings.selectedDrinkType, label: Text("Drink Type")) {
                        ForEach(DrinkType.allCases) { drinkType in
                            Text(drinkType.localizedName).tag(drinkType)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }
            }
            .navigationTitle("Settings")
        }
    }
}
