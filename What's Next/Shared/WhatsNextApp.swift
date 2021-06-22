//
//  WhatsNextApp.swift
//  Shared
//
//  Created by Hundter Biede on 6/17/21.
//

import SwiftUI

@main
struct WhatsNextApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            MainScreenView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
