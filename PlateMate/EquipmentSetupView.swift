//
//  EquipmentSetupView.swift
//  PlateMate
//
//  Created by Märten Tropp on 1/6/25.
//

import SwiftUI

struct EquipmentSetupView: View {
    @EnvironmentObject var equipmentModel: EquipmentModel
    @State private var newBarbellWeight: String = ""
    @State private var newPlateWeight: String = ""
    @State private var newPlateQuantity: String = ""
    @State private var selectedTab: Tab = .barbells
    @State private var plateToRemove: EquipmentModel.Plate? = nil  // Plate to be removed
    @State private var showingUnitToggleSheet = false // Control showing the side sheet

    enum Tab {
        case barbells
        case plates
    }

    var body: some View {
        NavigationView {
            VStack {
                // Segmented Control for Tab Navigation
                Picker("Select Tab", selection: $selectedTab) {
                    Text("Barbells").tag(Tab.barbells)
                    Text("Plates").tag(Tab.plates)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()

                // Dynamic content based on the selected tab
                if selectedTab == .barbells {
                    // Barbell Tab Content
                    VStack {
                        // Add Barbell Section
                        VStack(alignment: .leading) {
                            Text("Add a New Barbell")
                                .font(.headline)
                                .padding(.bottom, 5)
                            
                            TextField("Barbell Weight (\(equipmentModel.unit))", text: $newBarbellWeight)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.decimalPad)
                                .padding()
                            
                            HStack {
                                Spacer()
                                Button(action: addBarbell) {
                                    HStack {
                                        Image(systemName: "plus.circle")
                                        Text("Add Barbell")
                                    }
                                    .padding()
                                    .foregroundColor(.white)
                                    .background(Color.blue)
                                    .cornerRadius(10)
                                }
                                Spacer()
                            }
                            .padding(.top, 5)
                        }
                        .padding()

                        // Barbell List Section
                        List {
                            Section(header: Text("Barbells")) {
                                ForEach(equipmentModel.customBarbells) { barbell in
                                    HStack {
                                        Text("\(barbell.weight, specifier: "%.1f") \(equipmentModel.unit)")
                                    }
                                }
                                .onDelete(perform: removeBarbell)
                            }
                        }
                        .listStyle(InsetGroupedListStyle())
                        .padding(.top)
                    }
                } else {
                    // Plates Tab Content
                    VStack {
                        // Add Plate Section
                        VStack(alignment: .leading) {
                            Text("Add Plates")
                                .font(.headline)
                            VStack {
                                TextField("Plate Weight (\(equipmentModel.unit))", text: $newPlateWeight)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .keyboardType(.decimalPad)
                                    .padding(.bottom)

                                TextField("Quantity", text: $newPlateQuantity)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .keyboardType(.numberPad)
                                    .padding(.bottom)
                            }
                            HStack {
                                Spacer()
                                Button(action: addPlate) {
                                    HStack {
                                        Image(systemName: "plus.circle")
                                        Text("Add Plate")
                                    }
                                    .padding()
                                    .foregroundColor(.white)
                                    .background(Color.blue)
                                    .cornerRadius(10)
                                }
                                Spacer()
                            }
                            .padding(.top, 5)
                        }
                        .padding()

                        // Plate List Section
                        List {
                            Section(header: Text("Plates")) {
                                ForEach(equipmentModel.availablePlates) { plate in
                                    HStack {
                                        Text("\(plate.weight, specifier: "%.1f") \(equipmentModel.unit)")
                                        Spacer()
                                        Text("x\(plate.quantity)")
                                        
                                        Button(action: {
                                            increasePlateQuantity(for: plate)
                                        }) {
                                            Image(systemName: "plus.circle.fill")
                                                .foregroundColor(.green)
                                        }
                                        .buttonStyle(BorderlessButtonStyle())
                                        .padding(.leading, 10)
                                        Button(action: {
                                            decreasePlateQuantity(for: plate)
                                            
                                        }) {
                                            Image(systemName: "minus.circle.fill")
                                                .foregroundColor(.red)
                                        }
                                        .buttonStyle(BorderlessButtonStyle())
                                    }
                                }
                                .onDelete(perform: removePlate)
                            }
                        }
                        .listStyle(InsetGroupedListStyle())
                        .padding(.top)
                    }
                }
            }
            .modifier(KeyboardDismissModifier())
            .navigationTitle("Equipment Setup")
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

    private func addBarbell() {
        guard let weight = Double(newBarbellWeight), weight > 0 else {
            return
        }

        equipmentModel.addBarbell(weight: weight)
        newBarbellWeight = ""
    }

    private func removeBarbell(at offsets: IndexSet) {
        equipmentModel.customBarbells.remove(atOffsets: offsets)
    }

    private func addPlate() {
        guard let weight: Double = Double(newPlateWeight), let quantity: Int = Int(newPlateQuantity), weight > 0, quantity > 0 else {
            return
        }

        equipmentModel.addPlate(weight: weight, quantity: quantity)
        newPlateWeight = ""
        newPlateQuantity = ""
    }
    
    private func increasePlateQuantity(for plate: EquipmentModel.Plate) {
        if let index = equipmentModel.availablePlates.firstIndex(where: { $0.id == plate.id }) {
            equipmentModel.availablePlates[index].quantity += 1
        }
    }

    private func decreasePlateQuantity(for plate: EquipmentModel.Plate) {
        if let index = equipmentModel.availablePlates.firstIndex(where: { $0.id == plate.id }),
           equipmentModel.availablePlates[index].quantity > 0 {
            equipmentModel.availablePlates[index].quantity -= 1
            
            // If the quantity reaches zero, remove the plate from the available plates list
            if equipmentModel.availablePlates[index].quantity == 0 {
                equipmentModel.availablePlates.remove(at: index)
            }
        }
    }

    private func removePlate(at offsets: IndexSet) {
        equipmentModel.availablePlates.remove(atOffsets: offsets)
    }
}
