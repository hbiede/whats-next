//
//  What_s_NextApp.swift
//  Shared
//
//  Created by Hundter Biede on 6/17/21.
//

import SwiftUI

@main
struct What_s_NextApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            MainScreenView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
