//
//  MaxCalculatorView.swift
//  PlateMate
//
//  Created by Märten Tropp on 1/7/25.
//

import SwiftUI

struct MaxCalculatorView: View {
    @EnvironmentObject var equipmentModel: EquipmentModel
    @State private var weightLifted: String = ""
    @State private var reps: String = ""
    @State private var oneRepMax: String = ""
    @State private var selectedFormula: String = "Epley"
    @State private var showingUnitToggleSheet = false // Control showing the side sheet
    
    let formulas = ["Epley", "Brzycki", "Wathan", "O'Conner", "Schwimmer"]

    var body: some View {
        NavigationView {
            VStack {
                TextField("Weight Lifted (\(equipmentModel.unit))", text: $weightLifted)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.decimalPad)
                    .padding()

                TextField("Reps", text: $reps)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.numberPad)
                    .padding()

                Picker("Formula", selection: $selectedFormula) {
                    ForEach(formulas, id: \.self) { formula in
                        Text(formula)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .padding()

                Button(action: calculateMax) {
                    Text("Calculate 1RM")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()

                if !oneRepMax.isEmpty {
                    Text("Your 1RM is: \(oneRepMax) \(equipmentModel.unit)")
                        .font(.title)
                        .padding()
                }

                Spacer()
            }
            .modifier(KeyboardDismissModifier())
            .navigationTitle("Max Calculator")
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

    private func calculateMax() {
        guard let weight = Double(weightLifted), let reps = Int(reps), reps > 0 else {
            oneRepMax = "Invalid input"
            return
        }
        
        let calculatedMax: Double
        
        switch selectedFormula {
        case "Epley":
            calculatedMax = weight + (0.0333 * weight * Double(reps))
        case "Brzycki":
            calculatedMax = weight * (36 / (37 - Double(reps)))
        case "Wathan":
            calculatedMax = weight * (1 + 0.025 * Double(reps))
        case "O'Conner":
            calculatedMax = weight * (1 + 0.025 * Double(reps))
        case "Schwimmer":
            calculatedMax = weight * (1 + 0.025 * Double(reps))
        default:
            calculatedMax = weight
        }

        oneRepMax = String(format: "%.2f", calculatedMax)
    }
}
