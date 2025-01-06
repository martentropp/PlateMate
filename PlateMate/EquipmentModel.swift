//
//  EquipmentModel.swift
//  PlateMate
//
//  Created by Märten Tropp on 1/6/25.
//

import SwiftUI

class EquipmentModel: ObservableObject {
    @Published var customBarbells: [Barbell] = []  // Array Of barbells
    @Published var selectedBarbell: Barbell? = nil // Keeps track of selected barbell
    @Published var unit: String = "kg"             // Default unit
    @Published var availablePlates: [Plate] = []   // Array of plates

    struct Barbell: Identifiable, Hashable {
        let id: UUID = UUID()
        var weight: Double
    }

    struct Plate: Identifiable, Hashable {
        let id: UUID = UUID()
        var weight: Double
        var quantity: Int
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
