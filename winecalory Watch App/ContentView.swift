import SwiftUI

struct ContentView: View {
    @State private var caloriesBurned: Double = 2020

    var body: some View {
        let lang = Bundle.main.preferredLocalizations.first ?? "en"
        
        VStack {
            
            Image(systemName: "wineglass")
                .imageScale(.large)
                .foregroundStyle(.tint)

            Text(wineText(for: self.caloriesBurned, lang: lang))
                .padding()
        }
        .padding()
        .onAppear {
            HealthKitManager.shared.requestAuthorization { authorized in
                if authorized {
                    HealthKitManager.shared.fetchCalories { calories in
                        self.caloriesBurned = calories
                    }
                }
            }
        }
    }
    
    func wineText(for caloriesBurned: Double, lang: String) -> String {
        let calories = Int(caloriesBurned)
        let glasses = calories / 120

        // Объединенная функция для русского и украинского языков
        func slavicWord(for count: Int, singular: String, few: String, many: String) -> String {
            if count % 10 == 1 && count % 100 != 11 {
                return singular
            } else if count % 10 >= 2 && count % 10 <= 4 && (count % 100 < 10 || count % 100 >= 20) {
                return few
            } else {
                return many
            }
        }

        let calorieWord = {
            switch lang {
            case "ru":
                return slavicWord(for: calories, singular: "калория", few: "калории", many: "калорий")
            case "uk":
                return slavicWord(for: calories, singular: "калорія", few: "калорії", many: "калорій")
            default:
                return calories == 1 ? "calorie" : "calories"
            }
        }()

        let caloriesText = {
            switch lang {
            case "ru":
                return "Сегодня \(calories) \(calorieWord)."
            case "uk":
                return "Сьогодні \(calories) \(calorieWord)."
            default:
                return "Today you've burned \(calories) \(calorieWord)."
            }
        }()

        if glasses < 1 {
            let noWineText = {
                switch lang {
                case "ru":
                    return "Никакого вина пока не заработано!"
                case "uk":
                    return "Жодного келиха не зароблено!"
                default:
                    return "You haven't earned any wine yet!"
                }
            }()
            return "\(caloriesText)\n\(noWineText)"
        }

        let glassesWord = {
            switch lang {
            case "ru":
                let word = "бокал"
                return slavicWord(for: glasses, singular: word, few: "\(word)а", many: "\(word)ов")
            case "uk":
                let word = "келих"
                return slavicWord(for: glasses, singular: word, few: "\(word)а", many: "\(word)ів")
            default:
                return glasses == 1 ? "glass" : "glasses"
            }
        }()

        let wineText = {
            switch lang {
            case "ru":
                return "Тебе можно \(glasses) \(glassesWord) вина."
            case "uk":
                return "Тобі можна \(glasses) \(glassesWord) вина."
            default:
                return "You can have \(glasses) \(glassesWord) of wine."
            }
        }()
        
        return "\(caloriesText)\n\(wineText)"
    }



}

#Preview {
    ContentView()
}
