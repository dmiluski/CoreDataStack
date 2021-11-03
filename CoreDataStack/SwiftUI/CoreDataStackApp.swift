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

    var routeCollectionViewController: RouteCollectionViewController {
        RouteCollectionViewController(persistenceController.container.viewContext)
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
            .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
