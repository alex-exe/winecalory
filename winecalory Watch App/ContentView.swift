import SwiftUI

struct ContentView: View {
    @State private var caloriesBurned: Double = 0
    @StateObject private var userSettings = UserSettings()
    @State private var showingSettings = false
    @State private var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    
    var body: some View {
        let drinkType = userSettings.selectedDrinkType // Получаем выбранный тип напитка
        let caloriesPerServing = drinkType.caloriesPerServing
        let calories = Int(caloriesBurned)
        let fullServings = calories / caloriesPerServing

        let completionPercentage = CGFloat(calories % caloriesPerServing) / CGFloat(caloriesPerServing) * CGFloat(100)

        VStack {
            ScrollView {
                VStack {
                    ZStack {
                        Circle()
                            .stroke(lineWidth: 4)
                            .opacity(0.3)
                            .foregroundColor(.gray)
                            .frame(width: 70, height: 70)

                        Circle()
                            .trim(from: 0, to: completionPercentage / 100)
                            .stroke(style: StrokeStyle(lineWidth: 4, lineCap: .round))
                            .foregroundColor(.green)
                            .rotationEffect(Angle(degrees: 270))
                            .animation(.linear, value: completionPercentage)
                            .frame(width: 70, height: 70)

                        Image(systemName: "wineglass")
                            .imageScale(.large)
                            .foregroundColor(.gray)
                        
                        if fullServings > 0 {
                            ZStack {
                                Circle()
                                    .foregroundColor(.red)
                                    .frame(width: 20, height: 20)
                                Text("\(fullServings)")
                                    .foregroundColor(.white)
                                    .font(.system(size: 12))
                            }
                            .offset(x: 15, y: -15)
                        }
                    }

                    .padding(.bottom, 2)
                    Text(wineText(for: self.caloriesBurned, lang: "en", completionPercentage: completionPercentage))
                        .padding() // Убедитесь, что текст не налегает на края
                }
                .background(Color.clear) // Устанавливаем прозрачный фон
            }

            Button("Settings") {
                showingSettings.toggle()
            }
            .font(.system(size: 12))
            .padding(5)
            .buttonStyle(PlainButtonStyle())
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
        }
        .onReceive(timer) { _ in
            fetchCalories()
        }   
        .onAppear {
            fetchCalories()
        }
        .environmentObject(userSettings)
            }

    func fetchCalories() {
        HealthKitManager.shared.requestAuthorization { authorized in
            if authorized {
                HealthKitManager.shared.fetchCalories { calories in
                    self.caloriesBurned = calories + 30 + self.caloriesBurned
                    
                }
            }
        }
    }
    
    func wineText(for caloriesBurned: Double, lang: String, completionPercentage: CGFloat) -> String {
        let drinkType = userSettings.selectedDrinkType // Получаем выбранный тип напитка
        let caloriesPerServing = drinkType.caloriesPerServing

        let calories = Int(caloriesBurned)
        let glasses = calories / caloriesPerServing

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

        let drinkWord: String
        switch lang {
        case "ru":
            drinkWord = drinkType == .wine ? "вина" : drinkType == .beer ? "пива" : "эля"
        case "uk":
            drinkWord = drinkType == .wine ? "вина" : drinkType == .beer ? "пива" : "елю"
        default:
            drinkWord = drinkType == .wine ? "of wine" : drinkType == .beer ? "of beer" : "of ale"
        }
        
        if glasses < 1 {
            let noWineText = {
                switch lang {
                case "ru":
                    return "Никакого \(drinkWord) не заработано!"
                case "uk":
                    return "Жодного келиха \(drinkWord) не зароблено!"
                default:
                    return "You have earned zero \(drinkWord) yet!"
                }
            }()
            return "\(caloriesText) \(completionPercentage)%\n\(noWineText)"
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
                return "Тебе можно \(glasses) \(glassesWord) \(drinkWord)."
            case "uk":
                return "Тобі можна \(glasses) \(glassesWord) \(drinkWord)."
            default:
                return "You can have \(glasses) \(glassesWord) \(drinkWord)."
            }
        }()
        
        return "\(caloriesText)\n\(wineText)"
    }



}

#Preview {
    ContentView()
}
