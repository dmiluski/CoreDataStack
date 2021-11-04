//
//  ContentView.swift
//  CoreDataStack
//
//  Created by loaner on 10/26/21.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Route.timestamp, ascending: true)],
        animation: .default)
    private var items: FetchedResults<Route>

    @State
    var isPerformingAsync: Bool = false

    var body: some View {
        NavigationView {
            List {
                ForEach(items) { route in
                    NavigationLink {
                        ContentDetailsView(route: route)
                    } label: {
                        RouteCellView(route: route)
                    }
                }
                .onDelete(perform: deleteItems)
            }
            .listStyle(PlainListStyle())
            .navigationTitle(Text("SwfitUI Routes"))
            .toolbar {

                // Nav Bar
                ToolbarItem(placement: .navigationBarLeading) {

                    if !isPerformingAsync {
                        Button(action: loadRemoteRoutes) {
                            Image(systemName: "arrow.clockwise")
                        }
                    } else {
                        ActivityIndicator(
                            isAnimating: $isPerformingAsync,
                            style: .medium,
                            color: UIColor.tertiaryLabel
                        )
                    }
                }

                ToolbarItemGroup(placement: .navigationBarTrailing) {

                    Button(action: {
                        withAnimation {
                            items.forEach(viewContext.delete(_:))
                        }
                    }){
                        Image(systemName: "trash")
                    }

                    Button(action: addItem) {
                        Label("Add Item", systemImage: "plus")
                    }
                    EditButton()
                }
            }
        }
    }

    // MARK: - Actions

    private func loadRemoteRoutes() {

        isPerformingAsync = true
        // TODO: - Perform Async Remote Loading
        DispatchQueue
            .global()
            .asyncAfter(deadline: .now() + 2) {

                let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
                context.parent = viewContext

                items
                    // Convert to Child Context Routes
                    .compactMap { context.object(with: $0.objectID) as? Route }
                    .forEach { route in

                    // Apply Random Mutation Demonstrating background context merging
                    //
                    // Either
                    // - Delete
                    // - Prefix Name
                    if (Bool.random()) {
                        // Either Delete
                        context.delete(route)
                    } else {
                        route.displayableName = "1" + (route.displayableName ?? "")
                    }
                }

                do {
                    try context.save()

                    // Save to disk
                    DispatchQueue.main.async(execute: trySave)
                } catch {
                    print("Dane - error: \(error)")
                }

                DispatchQueue.main.async {
                    isPerformingAsync = false
                }
            }
    }

    private func addItem() {
        withAnimation {
            let newItem = Route(context: viewContext)
            newItem.timestamp = Date()
            newItem.displayableName = String(UUID().uuidString.prefix(5))
            trySave()
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { items[$0] }.forEach(viewContext.delete)
            trySave()
        }
    }

    private func trySave() {
        do {
            try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
