//
//  EquipmentModel.swift
//  PlateMate
//
//  Created by Märten Tropp on 1/6/25.
//

import SwiftUI

class EquipmentModel: ObservableObject {
    @Published var customBarbells: [Barbell] {
        didSet {
            saveData() // Save data when customBarbells changes
        }
    }
    @Published var selectedBarbell: Barbell? = nil // Keeps track of selected barbell
    @Published var unit: String {
        didSet {
            saveData() // Save data when unit changes
        }
    }
    @Published var availablePlates: [Plate] {
        didSet {
            saveData() // Save data when availablePlates changes
        }
    }
    
    // Constants for UserDefaults keys
    private let barbellsKey = "customBarbells"
    private let platesKey = "availablePlates"
    private let unitKey = "unit"

    // Initializer
    init() {
        // Set default values first
        self.customBarbells = [Barbell(weight: 32.0),
                               Barbell(weight: 25.0),
                               Barbell(weight: 20.0),
                               Barbell(weight: 15.0),
                               Barbell(weight: 11.4),
                               Barbell(weight: 10.0)]
        self.availablePlates = [Plate(weight: 25.0, quantity: 4),
                                Plate(weight: 20.0, quantity: 4),
                                Plate(weight: 15.0, quantity: 6),
                                Plate(weight: 10.0, quantity: 6),
                                Plate(weight: 5.0, quantity: 8),
                                Plate(weight: 2.5, quantity: 8),
                                Plate(weight: 1, quantity: 8)]
        self.unit = "kg"
        
        // Load saved data after the properties are initialized
        self.loadSavedData()
    }
    
    // Restore default barbells and plates
    func restoreDefaultBarbellsAndPlates() {
        if unit == "kg" {
            self.customBarbells = [Barbell(weight: 32.0),
                                   Barbell(weight: 25.0),
                                   Barbell(weight: 20.0),
                                   Barbell(weight: 15.0),
                                   Barbell(weight: 11.4),
                                   Barbell(weight: 10.0)]
            self.availablePlates = [Plate(weight: 25.0, quantity: 4),
                                    Plate(weight: 20.0, quantity: 4),
                                    Plate(weight: 15.0, quantity: 6),
                                    Plate(weight: 10.0, quantity: 6),
                                    Plate(weight: 5.0, quantity: 8),
                                    Plate(weight: 2.5, quantity: 8),
                                    Plate(weight: 1, quantity: 8)]
        } else {
            self.customBarbells = [Barbell(weight: 70.0),
                                   Barbell(weight: 55.0),
                                   Barbell(weight: 45.0),
                                   Barbell(weight: 33.0),
                                   Barbell(weight: 25.0),
                                   Barbell(weight: 22.0)]
            self.availablePlates = [Plate(weight: 55.0, quantity: 4),
                                    Plate(weight: 45.0, quantity: 4),
                                    Plate(weight: 25.0, quantity: 6),
                                    Plate(weight: 10.0, quantity: 6),
                                    Plate(weight: 5.0, quantity: 8),
                                    Plate(weight: 2.5, quantity: 8),
                                    Plate(weight: 1.25, quantity: 8)]
        }
    }

    // Clear all barbells and plates
    func clearBarbellsAndPlates() {
        self.customBarbells.removeAll()
        self.availablePlates.removeAll()
    }

    // Load saved data from UserDefaults
    private func loadSavedData() {
        if let savedBarbells = loadBarbells(),
           let savedPlates = loadPlates(),
           let savedUnit = loadUnit() {
            self.customBarbells = savedBarbells
            self.availablePlates = savedPlates
            self.unit = savedUnit
        }
    }

    // Load data from UserDefaults
    private func loadBarbells() -> [Barbell]? {
        guard let data = UserDefaults.standard.data(forKey: barbellsKey) else { return nil }
        let decoder = JSONDecoder()
        return try? decoder.decode([Barbell].self, from: data)
    }

    private func loadPlates() -> [Plate]? {
        guard let data = UserDefaults.standard.data(forKey: platesKey) else { return nil }
        let decoder = JSONDecoder()
        return try? decoder.decode([Plate].self, from: data)
    }

    private func loadUnit() -> String? {
        return UserDefaults.standard.string(forKey: unitKey)
    }

    // Save data to UserDefaults
    private func saveData() {
        let encoder = JSONEncoder()
        if let barbellsData = try? encoder.encode(customBarbells) {
            UserDefaults.standard.set(barbellsData, forKey: barbellsKey)
        }
        
        if let platesData = try? encoder.encode(availablePlates) {
            UserDefaults.standard.set(platesData, forKey: platesKey)
        }
        
        UserDefaults.standard.set(unit, forKey: unitKey)
    }

    struct Barbell: Identifiable, Hashable, Codable {
        var id: UUID = UUID()
        var weight: Double
        
        // Custom initializer for decoding
        init(id: UUID = UUID(), weight: Double) {
            self.id = id
            self.weight = weight
        }
    }

    struct Plate: Identifiable, Hashable, Codable {
        var id: UUID = UUID()
        var weight: Double
        var quantity: Int
        
        // Custom initializer for decoding
        init(id: UUID = UUID(), weight: Double, quantity: Int) {
            self.id = id
            self.weight = weight
            self.quantity = quantity
        }
    }

    func convertWeightToUnit(_ weight: Double) -> Double {
        if unit == "lbs" {
            return weight * 2.20462  // Convert kg to lbs
        } else {
            return weight / 2.20462  // Convert lbs to kg
        }
    }

    // Add a custom plate
    func addPlate(weight: Double, quantity: Int) {
        // Allow for small rounding differences in the weight comparison
        if availablePlates.contains(where: { abs($0.weight - weight) < 0.1 }) {
            // If the plate already exists, update the quantity
            availablePlates[0].quantity += quantity
        } else {
            // If the plate doesn't exist, append it as a new entry
            availablePlates.append(Plate(weight: weight, quantity: quantity))
        }
    }

    func addBarbell(weight: Double) {
        // Check if a barbell with the same weight already exists
        if customBarbells.contains(where: { $0.weight == weight }) {
            return
        }
        
        // If no duplicate barbell exists, add the new barbell
        customBarbells.append(Barbell(weight: weight))
    }
    
    // Calculate the plate combination for the weight
    func calculatePlateCombination(forWeight weight: Double) -> [String: Int] {
        var remainingWeight: Double = weight
        var plateCombination: [String: Int] = [:]
        
        // Sort plates by weight in descending order
        for plate: EquipmentModel.Plate in availablePlates.sorted(by: { $0.weight > $1.weight }) {
            // Calculate how many plates we can use (at most the quantity of plates available)
            let maxPossible: Int = min(Int(remainingWeight / plate.weight), plate.quantity / 2)
            
            // If we can use any plates of this type, add them to the combination
            if maxPossible > 0 {
                plateCombination["\(plate.weight) \(unit)"] = maxPossible
                remainingWeight -= plate.weight * Double(maxPossible)
            }
            
            // If we have reached a sufficient weight, exit early
            if remainingWeight <= 0.01 {
                break
            }
        }
    
        // If we couldn't match the weight exactly, return an empty dictionary
        return remainingWeight <= 0.01 ? plateCombination : [:]
    }

    // Adjust all barbells and plates when changing units
    func adjustWeightsForUnitChange() {
        for i in 0..<customBarbells.count {
            customBarbells[i].weight = convertWeightToUnit(customBarbells[i].weight)
        }
        
        for i in 0..<availablePlates.count {
            availablePlates[i].weight = convertWeightToUnit(availablePlates[i].weight)
        }
    }
}
