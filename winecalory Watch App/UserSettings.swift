//
//  UserSettings.swift
//  winecalory Watch App
//
//  Created by Alex Reshetko on 10.03.2024.
//

import Foundation

enum DrinkType: String, CaseIterable, Identifiable {
    case wine = "Wine"
    case beer = "Beer"
    case ale = "Ale"

    var id: String { self.rawValue }

    var caloriesPerServing: Int {
        switch self {
        case .wine:
            return 120 // Примерно для бокала вина
        case .beer:
            return 150 // Примерно для стакана пива
        case .ale:
            return 180 // Примерно для стакана эля
        }
    }

    // Локализованные названия напитков
    var localizedName: String {
        switch self {
        case .wine:
            return NSLocalizedString("Wine", comment: "Drink type")
        case .beer:
            return NSLocalizedString("Beer", comment: "Drink type")
        case .ale:
            return NSLocalizedString("Ale", comment: "Drink type")
        }
    }

    // Computed property to return the appropriate SF Symbol for each drink type
    var iconName: String {
        switch self {
        case .wine:
            return "wineglass.fill"
        case .beer:
            return "mug.fill"
        case .ale:
            // For example, use "bottle.fill" if it's available or choose a custom asset.
            return "mug"
        }
    }
}

class UserSettings: ObservableObject {
    @Published var selectedDrinkType: DrinkType {
        didSet {
            UserDefaults.standard.set(selectedDrinkType.rawValue, forKey: "selectedDrinkType")
        }
    }

    init() {
        let savedValue = UserDefaults.standard.string(forKey: "selectedDrinkType") ?? DrinkType.wine.rawValue
        self.selectedDrinkType = DrinkType(rawValue: savedValue) ?? .wine
    }
}

