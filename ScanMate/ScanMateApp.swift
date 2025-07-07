//
//  ScanMateApp.swift
//  ScanMate
//
//  Created by Maruf on 26/6/25.
//

import SwiftUI

@main
struct ScanMateApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            HomeView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
