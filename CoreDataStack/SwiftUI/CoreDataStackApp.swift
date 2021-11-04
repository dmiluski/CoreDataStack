//
//  CoreDataStackApp.swift
//  CoreDataStack
//
//  Created by loaner on 10/26/21.
//

import SwiftUI
import CoreData

@main
struct CoreDataStackApp: App {

    /// Coordinates Persistent Store
    let persistentCoordinator = PersistenceCoordinator()

    // MARK: - Helper Accessors

    var viewContext: NSManagedObjectContext {
        persistentCoordinator.persistenceController.container.viewContext
    }

    var routeCollectionViewController: RouteCollectionViewController {
        RouteCollectionViewController(persistentCoordinator.persistenceController.container.viewContext)
    }

    var body: some Scene {
        WindowGroup {
            TabView {
                ContentView()
                    .tabItem {
                        VStack {
                            Image(systemName: "swift")
                            Text("SwiftUI")
                        }
                    }

                NavigationViewControllerRepresentable(rootViewController: routeCollectionViewController)
                .tabItem {
                    VStack {
                        Image(systemName: "shippingbox")
                        Text("UIKit")
                    }
                }
            }
            .environment(\.managedObjectContext, viewContext)
        }
    }
}


