//
//  SquartApp.swift
//  Squart
//
//  Created by Gazza on 10.3.25..
//

import SwiftUI

@main
struct SquartApp: App {
    var body: some Scene {
        WindowGroup {
            WelcomeView()
                .environmentObject(Localization.shared)
        }
    }
}
