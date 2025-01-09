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

    init() {
        // Set the navigation bar appearance for the entire app
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .systemBackground  // System white in light mode, black in dark mode
        appearance.shadowColor = .clear // Remove the shadow line
        
        // Title text styling - will automatically adapt to light/dark mode
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor.label
        ]
        appearance.largeTitleTextAttributes = [
            .foregroundColor: UIColor.label
        ]
        
        // Apply the appearance to all navigation bars
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        
        // Style the Tab Bar to match
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        tabBarAppearance.backgroundColor = .systemBackground
        UITabBar.appearance().standardAppearance = tabBarAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
    }
    
    var body: some Scene {
        WindowGroup {
            TabView {
                ContentView()
                    .tabItem {
                        Image(systemName: "scalemass")
                        Text("Plates")
                    }
                PercentageCalculatorView()
                    .tabItem {
                        Image(systemName: "percent")
                        Text("Percentages")
                    }
                StopwatchView()
                    .tabItem {
                        Image(systemName: "clock")
                        Text("Stopwatch")
                    }
                
                MaxCalculatorView()
                    .tabItem {
                        Image(systemName: "dumbbell")
                        Text("Max Calculator")
                    }
                EquipmentSetupView()
                    .tabItem {
                        Image(systemName: "gear")
                        Text("Equipment")
                    }
            }
            .environmentObject(equipmentModel)
        }
    }
}
