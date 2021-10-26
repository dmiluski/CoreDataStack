//
//  CoreDataStackApp.swift
//  CoreDataStack
//
//  Created by loaner on 10/26/21.
//

import SwiftUI

@main
struct CoreDataStackApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
