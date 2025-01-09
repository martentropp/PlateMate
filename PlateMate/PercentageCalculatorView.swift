//
//  PercentageCalculatorView.swift
//  PlateMate
//
//  Created by Märten Tropp on 1/7/25.
//

import SwiftUI

struct PercentageCalculatorView: View {
    @State private var inputWeight: String = ""  // Weight input
    @State private var inputPercentage: String = ""  // Percentage input
    @State private var results: [(percentage: Double, weight: Double)] = []  // Results to display
    @EnvironmentObject var equipmentModel: EquipmentModel
    @State private var showingUnitToggleSheet = false // Control showing the side sheet
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Input field for weight
                TextField("Enter Weight (\(equipmentModel.unit))", text: $inputWeight)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.decimalPad)
                    .padding()
                
                // Input field for percentage
                TextField("Enter Percentage", text: $inputPercentage)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.decimalPad)
                    .padding()
                
                // Button to calculate results
                Button(action: calculatePercentageTable) {
                    Text("Calculate Percentages")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()
                
                // Display the results as a list
                if !results.isEmpty {
                    List {
                        ForEach(results, id: \.percentage) { result in
                            HStack {
                                Text("\(result.percentage, specifier: "%.0f")%")
                                Spacer()
                                Text("\(result.weight, specifier: "%.1f") \(equipmentModel.unit)")
                            }
                        }
                    }
                    .scrollContentBackground(.hidden)
                } else {
                    Text("Results will appear here.")
                        .foregroundColor(.gray)
                        .padding()
                }
                
                Spacer()
            }
            .modifier(KeyboardDismissModifier())
            .navigationTitle("Percentage Calculator")
            .toolbar {
                // Add settings button to open the unit toggle side sheet
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingUnitToggleSheet.toggle()
                    }) {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .sheet(isPresented: $showingUnitToggleSheet) {
                UnitToggleSheetView()
                    .environmentObject(equipmentModel)
            }
        }
    }
    
    private func calculatePercentageTable() {
        // Validate input for weight
        guard let weight = Double(inputWeight), weight > 0 else {
            results = []
            return
        }
        
        // Validate input for percentage
        guard let percentage = Double(inputPercentage), percentage > 0, percentage <= 100 else {
            results = []
            return
        }
        
        // Convert input weight to the correct unit
        let weightInSelectedUnit = equipmentModel.unit == "lbs" ? convertToLbs(weightInKg: weight) : weight
        
        // Calculate the 100% value based on the input percentage
        let fullWeight = weightInSelectedUnit / (percentage / 100)  // This calculates the full weight (100%)
        
        // Generate table of percentages that are divisible by 5
        results = (5...100).filter { $0 % 5 == 0 }.map { i in
            let calculatedWeight = fullWeight * (Double(i) / 100)
            return (percentage: Double(i), weight: calculatedWeight)
        }
        
        // Sort the results in decreasing order of percentage
        results.sort { $0.percentage > $1.percentage }
    }
    
    private func convertToLbs(weightInKg: Double) -> Double {
        return weightInKg * 2.20462  // Convert kg to lbs
    }
}
