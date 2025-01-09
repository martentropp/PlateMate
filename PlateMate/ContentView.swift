//
//  ContentView.swift
//  PlateMate
//
//  Created by Märten Tropp on 1/6/25.
//

import SwiftUI

struct ContentView: View {
    @State private var targetWeight: String = ""   // Input weight
    @State private var plateResults: [String] = [] // Resulted plate selection
    @EnvironmentObject var equipmentModel: EquipmentModel
    @State private var selectedBarbellID: UUID?
    @State private var showingUnitToggleSheet = false // Control showing the side sheet

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Input field for target weight
                TextField("Enter Target Weight (\(equipmentModel.unit))", text: $targetWeight)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.decimalPad)
                    .padding()

                // Barbell Picker
                Picker("Select Barbell", selection: $selectedBarbellID) {
                    Text("No barbell selected")
                        .tag(nil as UUID?)

                    ForEach(equipmentModel.customBarbells) { barbell in
                        Text("\(barbell.weight, specifier: "%.1f") \(equipmentModel.unit)")
                            .tag(barbell.id as UUID?)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .onChange(of: selectedBarbellID) { oldValue, newValue in
                    if let id = newValue {
                        equipmentModel.selectedBarbell = equipmentModel.customBarbells.first { $0.id == id }
                    } else {
                        equipmentModel.selectedBarbell = nil
                    }
                }

                // Button to calculate result
                Button(action: calculatePlates) {
                    Text("Calculate Plates")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()

                Text("Results will appear below:")
                    .foregroundColor(.gray)
                    .padding(.horizontal)
                
                
                if !plateResults.isEmpty {
                    List(plateResults, id: \.self) { plate in
                        Text (plate)
                    }
                    .scrollContentBackground(.hidden)
                }

                Spacer()
            }
            .modifier(KeyboardDismissModifier())
            .navigationTitle("Plate Calculator")
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

    private func calculatePlates() {
        // Check that entered weight is a valid number and positive
        guard let weight = Double(targetWeight), weight > 0 else {
            plateResults = ["Please enter a valid target weight."]
            return
        }

        // Ensure a barbell is selected
        guard let selectedBarbell = equipmentModel.selectedBarbell else {
            plateResults = ["Please select a barbell."]
            return
        }

        let barWeight = selectedBarbell.weight
        let targetWeightWithBarbell = weight - barWeight

        // Check if the target weight with the barbell is positive
        if targetWeightWithBarbell <= 0 {
            plateResults = ["Weight must be greater than the barbell weight (\(barWeight))"]
            return
        }

        // Calculate the plate combination for each side
        let sidePlateWeight = targetWeightWithBarbell / 2.0
        let plateCombination = equipmentModel.calculatePlateCombination(forWeight: sidePlateWeight)

        // If no valid combination exists
        if plateCombination.isEmpty {
            plateResults = ["Cannot exactly match the target weight with available plates."]
        } else {
            // Sort the plate results by the weight (keys) in descending order
            let sortedPlateCombination = plateCombination.sorted { (first, second) -> Bool in
                // Compare by weight in descending order
                let firstWeight = Double(first.key.split(separator: " ")[0]) ?? 0
                let secondWeight = Double(second.key.split(separator: " ")[0]) ?? 0
                return firstWeight > secondWeight
            }

            // Map the sorted combination to a readable format
            plateResults = sortedPlateCombination.map { "\($0.key) x \($0.value)" }
        }
    }

    private func adjustWeightsForUnitChange() {
        // Adjust all barbells and plates to the new unit
        equipmentModel.adjustWeightsForUnitChange()
    }
}
