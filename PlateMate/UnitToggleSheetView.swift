//
//  UnitToggleSheetView.swift
//  PlateMate
//
//  Created by Märten Tropp on 1/7/25.
//

import SwiftUI

struct UnitToggleSheetView: View {
    @EnvironmentObject var equipmentModel: EquipmentModel
    @Environment(\.dismiss) var dismiss  // To dismiss the sheet
    
    private let accentColor = Color.blue
    private let buttonTextColor = Color.white
    private let selectedColor = Color.green
    private let deselectedColor = Color.gray

    var body: some View {
        NavigationView {
            VStack(alignment: .center, spacing: 25) {
                Text("Select Unit")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                    .padding(.top, 30)
                
                // A more interactive toggle with buttons
                HStack(spacing: 20) {
                    UnitSelectionButton(unit: "kg", isSelected: equipmentModel.unit == "kg") {
                        equipmentModel.unit = "kg"
                        adjustWeightsForUnitChange()
                    }
                    UnitSelectionButton(unit: "lbs", isSelected: equipmentModel.unit == "lbs") {
                        equipmentModel.unit = "lbs"
                        adjustWeightsForUnitChange()
                    }
                }
                .padding(.top, 20)
                
                Text("Equipment Settings")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                    .padding(.top, 30)
                
                // Restore to Default Button
                Button(action: {
                    restoreToDefault()
                }) {
                    Text("Restore Default Equipment")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .shadow(radius: 3)
                        
                }
                .padding(.top, 15)

                // Clear Button
                Button(action: {
                    clearBarbellsAndPlates()
                }) {
                    Text("Clear All Barbells & Plates")
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .shadow(radius: 3)
                }
                .padding(.top, 15)

                Spacer()
                
                // Back Button
                Button(action: {
                    dismiss()
                }) {
                    Text("Back")
                }
                .buttonStyle(.borderless)
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("Settings")
            .navigationBarItems(leading: Button(action: {
                dismiss()
            }) {
                Image(systemName: "chevron.left")
                    .foregroundColor(accentColor)
            })
            .frame(maxWidth: .infinity)
            .padding()
        }
        .accentColor(accentColor)
    }

    private func adjustWeightsForUnitChange() {
        // Adjust all barbells and plates to the new unit
        equipmentModel.adjustWeightsForUnitChange()
    }
    
    private func restoreToDefault() {
        // Restore to default barbells and plates
        equipmentModel.restoreDefaultBarbellsAndPlates()
    }

    private func clearBarbellsAndPlates() {
        // Clear barbells and plates
        equipmentModel.clearBarbellsAndPlates()
    }
}

// Custom unit selection button
struct UnitSelectionButton: View {
    var unit: String
    var isSelected: Bool
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(unit.uppercased())
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: 80, minHeight: 40)
                .background(isSelected ? Color.green : Color.gray)
                .cornerRadius(10)
                .shadow(radius: 3)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
