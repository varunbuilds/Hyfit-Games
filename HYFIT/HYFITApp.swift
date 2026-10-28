//
//  HYFITApp.swift
//  HYFIT
//

import SwiftUI
import SwiftData

@main
struct HYFITApp: App {
    init() {
        HYFITTypography.configureUIKitAppearance()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .font(HYFITTypography.body)
        }
        .modelContainer(for: PersistedRaceResult.self)
    }
}
