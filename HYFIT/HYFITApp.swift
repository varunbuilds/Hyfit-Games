//
//  HYFITApp.swift
//  HYFIT
//

import SwiftUI
import SwiftData

@main
struct HYFITApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: PersistedRaceResult.self)
    }
}
