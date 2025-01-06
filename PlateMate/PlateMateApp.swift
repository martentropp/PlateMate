//
//  PlateMateApp.swift
//  PlateMate
//
//  Created by Märten Tropp on 1/6/25.
//

import SwiftUI

@main
struct PlateMateApp: App {
    @StateObject private var equipmentModel = EquipmentModel()

    var body: some Scene {
        WindowGroup {
            TabView {
                ContentView()
                    .tabItem {
                        Image(systemName: "scalemass")
                        Text("Calculator")
                    }
                EquipmentSetupView()
                    .tabItem {
                        Image(systemName: "gear")
                        Text("Equipment Setup")
                    }
            }
            .environmentObject(equipmentModel)
            .onAppear {
                equipmentModel.unit = "kg" // Default unit is kg
            }
        }
    }


}
